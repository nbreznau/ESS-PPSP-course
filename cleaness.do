*ESS Data cleaning appendix
*For students downloading the file directly from Ilias, just so you know, don't re-run.
*European Social Survey (ESS) data Cumulative File downloaded from http://www.europeansocialsurvey.org/downloadwizard/, on 18.02.2018
*All countries and variables selected for download (data and codebook available in Ilias folder Dateien / ESS)
*Data was cleaned for variables that we will not use in this course, and countries not in Europe or only one wave
tab cntry
drop if cntry=="RU"
drop if cntry=="IL"
drop if cntry=="IS"
drop rlgdnbe-rlgdeua
drop edlvbe-eduagb2
drop edlvgr-edlvpdfr
drop edlvpgr-edlvpdie edlvpdlt-edlvpepl edlvppt-edlvmdua
drop edagegb-rshpsfi
drop yrbrn2-rshipa18
drop gndr2-gndr18

save "C:/data/ESS1-7e01.dta", replace
