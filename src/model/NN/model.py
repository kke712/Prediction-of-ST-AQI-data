import sys
import os
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from pytorch_lightning import LightningModule, Trainer, seed_everything

class Model(LightningModule):
    def __init__(self, **kwargs):
        super().__init__()
        self.save_hyperparameters() 

        self.block1 = nn.Sequential(
            nn.Linear(self.hparams.input_dim, self.hparams.block_dim),
            nn.BatchNorm1d(self.hparams.block_dim),
            nn.ReLU(inplace=True),
            nn.Linear(self.hparams.block_dim, self.hparams.block_dim),
            nn.BatchNorm1d(self.hparams.block_dim),
            nn.ReLU(inplace=True),
            nn.Linear(self.hparams.block_dim, self.hparams.block_dim),
            nn.BatchNorm1d(self.hparams.block_dim),
            nn.ReLU(inplace=True)
        )
        
        self.middle_block = []
        for _ in range(self.hparams.block_depth):
            self.middle_block.append(
                nn.Sequential(
                    nn.Linear(self.hparams.input_dim + self.hparams.block_dim, 
                            self.hparams.block_dim),
                    nn.BatchNorm1d(self.hparams.block_dim),
                    nn.ReLU(inplace=True),
                    nn.Linear(self.hparams.block_dim, self.hparams.block_dim),
                    nn.BatchNorm1d(self.hparams.block_dim),
                    nn.ReLU(inplace=True),
                    nn.Linear(self.hparams.block_dim, self.hparams.block_dim),
                    nn.BatchNorm1d(self.hparams.block_dim),
                    nn.ReLU(inplace=True)
               )
            )
        
        self.out = nn.Sequential(
            nn.Linear(self.hparams.input_dim + self.hparams.block_dim, 
                      self.hparams.hidden_dim),
            nn.BatchNorm1d(self.hparams.hidden_dim),
            nn.ReLU(inplace=True),
            nn.Linear(self.hparams.hidden_dim, self.hparams.hidden_dim),
            nn.BatchNorm1d(self.hparams.hidden_dim),
            nn.ReLU(inplace=True),
            nn.Linear(self.hparams.hidden_dim, self.hparams.hidden_dim),
            nn.BatchNorm1d(self.hparams.hidden_dim),
            nn.ReLU(inplace=True),
            nn.Linear(self.hparams.hidden_dim, 1),
            nn.Softplus()
        )

        self.lr = self.hparams.lr

    def forward(self, x):
        x1 = self.block1(x)
        for i in range(self.hparams.block_depth):
            x1 = self.middle_block[i](torch.cat([x1, x], axis=1))
        out = self.out(torch.cat([x1, x], axis=1)).squeeze()
        return out

    def training_step(self, batch, batch_idx):
        x, y, m_y = batch
        y_pred = self(x)
        loss = F.mse_loss(y_pred[~m_y], y[~m_y])
        metrics = {'train_loss': loss} 
        return loss

    def test_step(self, batch, batch_idx):
        x, y, m_y = batch
        y_pred = self(x)
        loss = F.mse_loss(y_pred[~m_y], y[~m_y])
        metrics = {'test_loss': loss} 

    def predict_step(self, batch, batch_idx):
        x, y, m_y = batch
        y_pred = self(x)
        return y_pred

    def configure_optimizers(self):
        if self.hparams.optimizer == 'AdamW':
            optimizer = optim.AdamW(self.parameters(), lr=self.hparams.lr)
        elif self.hparams.optimizer == 'AdamP':
            from adamp import AdamP
            optimizer = optim.AdamP(self.parameters(), lr=self.hparams.lr)
        else:
            raise NotImplementedError('Only AdamW and AdamP is Supported!')
        if self.hparams.lr_scheduler == 'cos':
            scheduler = optim.lr_scheduler.CosineAnnealingWarmRestarts(
                optimizer, T_mult=1, eta_min=1e-5, T_0=50)
        elif self.hparams.lr_scheduler == 'exp':
            scheduler = optim.lr_scheduler.ExponentialLR(optimizer, gamma=0.99)
        else:
            raise NotImplementedError('Only cos and exp lr scheduler is Supported!')
        return {
            'optimizer': optimizer,
            'lr_scheduler': scheduler,
        }

# custom datset 
class AirDataset(Dataset):
    """Airkorea + KMA dataset"""
    def __init__(self, df, isTest):
        super(AirDataset, self).__init__()
        if isTest:
            self.X = torch.from_numpy(
                df.drop(['date', 'PM25', 'predPM25'], axis=1).values
            ).float()
        else:
            self.X = torch.from_numpy(
                df.drop(['date', 'PM25'], axis=1).values
            ).float()
        self.y = torch.from_numpy(df['PM25'].values).float()
        self.M_X = torch.isnan(self.X)
        self.M_y = torch.isnan(self.y)
        self.X[self.M_X] = 0.0
        self.y[self.M_y] = 0.0

    def __len__(self):
        return len(self.y)

    def __getitem__(self, idx):
        x = self.X[idx, :]
        m_x = self.M_X[idx, :]
        y = self.y[idx]
        m_y = self.M_y[idx]
        return torch.cat([x, m_x], axis=0), y, m_y

def get_results(idx, args):
    train_df = pd.read_csv(f"./data/csv/train_{idx}.csv", index_col=0)
    test_df = pd.read_csv(f"./data/csv/test_{idx}.csv", index_col=0)
    seed_everything(args['seed'])
    train_dataset = AirDataset(train_df, isTest=False)
    train_loader = DataLoader(dataset=train_dataset, batch_size=args['batch_size'],
      num_workers=args['num_cpus'], shuffle=True)
    test_dataset = AirDataset(test_df, isTest=True)
    test_loader = DataLoader(dataset=test_dataset, batch_size=args['batch_size'],
      num_workers=args['num_cpus'], shuffle=False)
    model = Model(**args)

    if args['num_gpus'] > 0:
        device = torch.device("cuda")
        for bl in model.middle_block:
            bl.to(device)

    # train
    trainer = Trainer(
        max_epochs=args['epochs'], gpus=args['num_gpus'], auto_lr_find=True
    )
    trainer.fit(model, train_loader)
    y_preds = trainer.predict(model, dataloaders=test_loader)
    test_df.predPM25 = torch.cat(y_preds, axis=0).cpu().numpy()
    
    # save
    test_df.to_csv(f"./results/NN/pred_{idx}.csv", index=False)

if __name__ == "__main__":
    args = {
        'batch_size': 1024,
        'block_dim': 512,
        'hidden_dim': 512,
        'input_dim': 17 * 2,
        'block_depth': 3,
        'seed': 123,
        'num_cpus': 1,
        'num_gpus': 1,
        'epochs': 500,
        'optimizer': 'AdamW',
        'lr_scheduler': 'cos',
        'lr': 5e-3
    }
    get_results(sys.argv[1], args)
