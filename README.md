# Spatio-Temporal Interpolation for AQI data

The source code for "Spatio-Temporal Interpolation for AQI data".

## Data 

### Raw Data 

* Air pollution data: [에어코리아 최종확정 측정자료 조회](https://www.airkorea.or.kr/web/last_amb_hour_data?pMENU_NO=123)
* Weather data: 대한민국 기상청

### Preprocessing 

see `src/data` directory (written in `R`).

## Models 

* Random Effects with Spatio-Temporal Basis Functions: see `src/model/ST` directory (written in `R`).
* Neural Networks model: see `src/model/NN` directory (written in `Python`).
* Random Forest model: see `src/model/RF` directory (written in `R`).

## Results

The following table displays (50%, 75%) quantile of RMSE using three methods. Each column in the table means quantile of 1-step, 3-step, and 6-step forecasting from left to right.

| Model |  (50%, 75%) & +1h | (50%, 75%) & +3h  | (50%, 75%) & +6h  |
|---|---|---|---|
| ST  | (8.0088, 10.2268)  | (8.8609, 10.7955)  | (10.0435, 12.2510)  |
| NN  |  (9.3418, 11.6526) |  (10.1430, 11.4923)  |  (11.1114, 12.7896)  |
| RF  | (4.3464, 5.0956)  | (6.6421, 8.1415)  |  (8.5955, 9.8522)  |

The following figures show the performance of the models.

![Plot between prediction and real value of PM2.5 using three methods ST, NN, and RF model(from top to bottom). The left column of the plot is 1-step forecasting. The middle column of the plot is 3-step forecasting. The right column of the plot is 6-step forecasting.](results/Fig1.png)

![Boxplot of RMSE for each method. Prediction is proceed for 1-step, 3-step, and 6-step(from left to right)](results/Fig2.png)

## Contacts

Should you have any queries or suggestions, you should contact either:

- [Kyeongeun Kim](mailto:kke712@snu.ac.kr)
- [Kyeongwon Lee](mailto:lkw1718@snu.ac.kr)
- [Miru Ma](mailto:mamilu63178@naver.com)

## Requirments

### R

```R
list.of.packages <- c(
    "tidyverse",
    "lubridate",
    "purrr",
    "phylin",
    "progress",
    "parallel",
    "randomForest",
    "tictoc",
    "spacetime",
    "FRK",
    "INLA",
    "foreach",
    "doParallel",
    "Metrics"
)
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
    install.packages(new.packages)
}
```

### Python

(optional) packages for NN model.

```bash
requirements
|-- conda.txt
`-- pip.txt
```


## LICENSE

TBA