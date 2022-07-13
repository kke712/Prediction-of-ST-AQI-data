import subprocess as sps
import sys, os, time

# Note: we use slurm

def sbatch(job_name="py_job", mem='8', dep="", time='1-00:00:00', cpu="1", gpu=0, log="submit.out", wrap="python hello.py", add_option=""):
    sub = ['sbatch', '--ntasks=1', '--cpus-per-task=1', '-N', '1', f'--job-name={job_name}',
           f'--time={time} --cpus-per-task={cpu} --gres=gpu:{gpu}', dep, add_option, f'--wrap="{wrap.strip()}"']
    if gpu > 0:
        sub.append("-p gpu")
    process = sps.Popen(" ".join(sub), shell=True, stdout=sps.PIPE)
    stdout = process.communicate()[0].decode("utf-8")
    return (stdout)

for idx in range(1, 51):
    sbatch(wrap=f"module load cuda/11.2 && source /home/lkw1718/.bashrc && source activate torch \
            && python ./src/model/NN/model.py {idx}", 
            gpu=1, cpu=1, mem="8")
