#Spatio-Temporal Interpolation for AQI data

The datasets and code for "Spatio-Temporal Interpolation for AQI data".

## Requirments

* python
```bash
requirements # (optional) python packages for NN model
|-- conda.txt
`-- pip.txt
```

* R
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

## Contact

Should you have any queries or suggestions (all welcome), you should contact either:

- [Kyeongeun Kim](mailto:kke712@snu.ac.kr)
- [Kyeongwon Lee](mailto:lkw1718@snu.ac.kr)
- [Miru Ma](mailto:mamilu63178@naver.com)
