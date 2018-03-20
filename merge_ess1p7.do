*These versions change

use "C:\data\ESS7e02_1.dta", clear

append using "C:\data\ESS1e06_5.dta"

save "C:/data/ESS1and7.dta", replace

saveold "C:/data/ESS1and7v10.dta", version(12)
