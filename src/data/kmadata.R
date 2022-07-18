library(lubridate)

# csv files are downloaded from https://data.kma.go.kr/data/grnd/selectAsosRltmList.do

# 지점 -> loc
# 일시 -> datetime
# 기온(°C) -> temp
# 증기압(hPa) -> prec
# 풍속(m/s) -> windspeed
# 풍향(16방위) -> winddirection
# 습도(%) -> humidity
# 증기압(hPa) -> vaporpres
# 이슬점온도(°C) -> DPtemp
# 현지기압(hPa) -> Lpres
# 해면기압(hPa) -> Bpres
# 일조(hr) -> sunshine
# 일사(MJ/m2) -> radiation
# 적설(cm) -> snow
# 3시간신적설(cm) -> snow3
# 전운량(10분위) -> totalcloud
# 중하층운량(10분위) -> MLcloud
# 운형(운형약어) -> cloudshape
# 최저운고(100m) -> lowcloud
# 시정(10m) -> visibility
# 지면상태(지면상태코드) -> groudstate
# 지면온도 -> groundtemp

# kma18 <- read.csv("data/kma/kma_2018.csv")
# kma19 <- read.csv("data/kma/kma_2019.csv")
kma20 <- read.csv("data/kma/kma_2020.csv")

# kmadata <- rbind(kma18, kma19, kma20)
kmadata <- kma20

saveRDS(kmadata, "data/kmadata.rds")
