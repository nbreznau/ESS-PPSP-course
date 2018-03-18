*Merging the QoG Data

*The QoG data are a bunch of country-level indicators compiled for us.
*More info here: https://qog.pol.gu.se/data/datadownloads/qogoecddata

*To merge the data we need the same names for the country and year variables
*In the QoG data these are "ccode" and "year". Also, data must be sorted 
*and saved in the folder C:/data/ (or /data/ on a Mac)


use "C:/data/ESS1-7e01.dta", clear

gen ccode = .
replace ccode=40 if cntry=="AT"
replace ccode=56 if cntry=="BE"
replace ccode=100 if cntry=="BG"
replace ccode=756 if cntry=="CH"
replace ccode=196 if cntry=="CY"
replace ccode=203 if cntry=="CZ"
replace ccode=276 if cntry=="DE"
replace ccode=208 if cntry=="DK"
replace ccode=233 if cntry=="EE"
replace ccode=724 if cntry=="ES"
replace ccode=246 if cntry=="FI"
replace ccode=250 if cntry=="FR"
replace ccode=826 if cntry=="GB"
replace ccode=300 if cntry=="GR"
replace ccode=191 if cntry=="HR"
replace ccode=348 if cntry=="HU"
replace ccode=372 if cntry=="IE"
replace ccode=528 if cntry=="NL"
replace ccode=578 if cntry=="NO"
replace ccode=616 if cntry=="PL"
replace ccode=620 if cntry=="PT"
replace ccode=752 if cntry=="SE"
replace ccode=705 if cntry=="SI"
replace ccode=703 if cntry=="SK"
replace ccode=792 if cntry=="TR"
replace ccode=804 if cntry=="UA"
tab cntry, m

recode essround (1=2002)(2=2004)(3=2006)(4=2008)(5=2010)(6=2012)(7=2014), gen(year)

sort ccode year

merge m:1 ccode year using "C:/data/qog_oecd_ts_jan18.dta"

*In older versions of Stata the command looks like this:
    *merge ccode year using "C/data/qog_oecd_ts_jan18.dta"

*Not all countries from the ESS are in the QoG data (e.g., Bulgaria)
drop if _merge==1 | _merge==2

save "C:/data/essppsp1.dta", replace
