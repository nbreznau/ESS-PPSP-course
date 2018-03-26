
*Set up data
use "C:/data/ESS1and7.dta", clear

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
replace ccode=380 if cntry=="IT"
replace ccode=440 if cntry=="LT"
replace ccode=442 if cntry=="LU"
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

recode essround (1=2002)(7=2014), gen(year)

*Not used
gen ins = 0
replace ins = 1 if cntry=="IL"
replace ins = 1 if cntry=="LT"
replace ins = 1 if ccode==233 | ccode==705 | ccode==440

*Merge QoG data

sort ccode year
merge m:1 ccode year using "C:/data/qog_oecd_ts_jan18.dta"

*Lithuania does not seem to be in the QoG data, pity. Maybe we can find the macro-data somewhere else.
tab cntry if _merge==1

drop if _merge==2

*weights
gen weight2=pspwght*pweight
label var weight2 "Post-Strat*Population Weight"


*Sides and Citrin DV1 Preferred Level of Immigration
sum imsmetn imdfetn eimpcnt impcntr eimrcnt imrcntr
clonevar dv1_samemaj = imsmetn
clonevar dv1_difrace = imdfetn
clonevar dv1_poorinEU = eimpcnt
clonevar dv1_pooroutEU = impcntr
clonevar dv1_richinEU = eimrcnt
clonevar dv1_richoutEU = imrcntr
recode dv1_samemaj dv1_difrace dv1_poorinEU dv1_pooroutEU dv1_richinEU dv1_richoutEU (4=1)(3=.6667)(2=.3333)(1=0)(*=.)

egen DV1 = rowmean(dv1_samemaj dv1_difrace dv1_poorinEU dv1_pooroutEU dv1_richinEU dv1_richoutEU)

*Sides and Citrin DV2 Perceived Consequensces of Immigration

sum imwbcnt imbgeco imbleco imwbcrm imueclt
clonevar dv2_worse = imwbcnt
clonevar dv2_econ = imbgeco
clonevar dv2_jobs = imtcjob
clonevar dv2_take = imbleco
clonevar dv2_crime = imwbcrm
clonevar dv2_cultr = imueclt
recode dv2_worse dv2_econ dv2_jobs dv2_take dv2_crime dv2_cultr (10=0)(9=.1)(8=.2)(7=.3)(6=.4)(5=.5)(4=.6)(3=.7)(2=.8)(1=.9)(0=1)(*=.)

egen DV2 = rowmean(dv2_worse dv2_econ dv2_jobs dv2_take dv2_crime dv2_cultr)

*Table 1

recode dv2_worse dv2_econ dv2_jobs dv2_take dv2_crime dv2_cultr (.6/1=3 "Positive")(.5=2 "Neutral")(0/.4=1 "Negative")(.=.)(*=0), gen(dv2_w3 dv2_e3 dv2_j3 dv2_t3 dv2_cr3 dv2_cu3) label(dv23)

*ssc install tabm
tabm dv2_w3-dv2_cu3 if year==2002, nof row
*with weights, did they use both weights?
tabm dv2_w3-dv2_cu3 [aweight=weight2] if year==2002, nof row

*Table 2


table cntry if ins==0 & year==2002, c(m DV1 m DV2)
table cntry [aweight=weight2] if ins==0 & year==2002, c(m DV1 m DV2)

corr DV1 DV2 if ins==0 & year==2002


*Income
sum DV1 DV2 hinctnta if year==2002

*Education
tab1 eduyrs

*Demographic
tab1 gndr agea

*NO OBSERVATIONS
*Replicate everything except income!

*Economic Interests
tab1 hincfel stfeco mainact

*Cultural and National Identities
tab1 pplstrd euftf 

*Information about Immigration
tab1 noimbro cpimpop
recode ccode (40=12.5)(56=10.7)(203=4.4)(208=6.7)(246=2.5)(250=10.0)(276=11.1)(300=10.3)(348=2.9)(372=10.4)(380=3.9)(442=32.5)(528=10.1)(578=7.3)(616=2.0)(620=6.3)(724=5.3)(752=12.0)(756=21.6), gen(foreignb)
label var foreignb "Foreign-Born OECD, Sides and Citrin source"

clonevar sforeign = noimbro
recode noimbro(777/999=.)

***Impute subjective foreign-born
tab1 eduyrs discpol

*Contact with Immigrants
tab1 dfegcf

*Alienation
tab1 ppltrst pplfair pplhlp stflife 

*Political Awareness and Ideology
tab1 discpol lrscale 

*Immigrant Status
tab1 ctzcntr brncntr livecnta blgetmg


