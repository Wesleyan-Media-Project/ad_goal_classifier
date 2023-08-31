library(data.table)
library(dplyr)
library(tidyr)
library(stringr)

don <- fread("performance/rf/DONATE.csv")
perf_donate <- sum(don[4,2:3]*don[5,2:3])/sum(don[5,2:3])

gotv <- fread("performance/rf/GOTV.csv")
perf_gotv <- sum(gotv[4,2:3]*gotv[5,2:3])/sum(gotv[5,2:3])

learn <- fread("performance/rf/LEARNMORE.csv")
perf_learn <- sum(learn[4,2:3]*learn[5,2:3])/sum(learn[5,2:3])

pers <- fread("performance/rf/PRIMARY_PERSUADE.csv")
perf_pers <- sum(pers[4,2:3]*pers[5,2:3])/sum(pers[5,2:3])

(perf_donate + perf_gotv + perf_learn + perf_pers)/4
