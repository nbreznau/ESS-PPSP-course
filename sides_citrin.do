
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

*ssc install tab_chi
tabm dv2_w3-dv2_cu3 if year==2002, nof row
*with weights, did they use both weights?
tabm dv2_w3-dv2_cu3 [aweight=weight2] if year==2002, nof row

*Table 2


table cntry if ins==0 & year==2002, c(m DV1 m DV2)
table cntry [aweight=weight2] if ins==0 & year==2002, c(m DV1 m DV2)

sum DV1 DV2 if ins==0 & year==2002
corr DV1 DV2 if ins==0 & year==2002


*Income
sum DV1 DV2 hinctnta if year==2002

*Education
tab1 eduyrs
clonevar educ = eduyrs
recode educ (77 88 99=.)(25/50=25)




*Demographic
tab1 gndr agea

clonevar ageyr = agea
recode ageyr (999=.) /*recode missing values*/
recode ageyr (85/114=85) /*recode outliers*/
hist ageyr, bin(12)

*Employment
***Its not clear what varaibles they used
****could be 'mnactic' or individual variables, e.g., 'unempla'
recode mnactic (3 4=1)(*=0), gen(unemp)
recode mnactic (6=1)(*=0), gen(retired)
recode mnactic (2=1)(*=0), gen(student)
****Also, is house work more like paid work or being reitred?

****We decided in the lab to make young houseworkers into 'students'
****and old houseworkers into 'retirees'
replace retired = 1 if ageyr>64 & mnactic==8
replace student = 1 if ageyr<65 & mnactic==8

*NO OBSERVATIONS
*Replicate everything except income!

*Economic Interests
tab1 hincfel stfeco mainact

*Cultural and National Identities
tab1 pplstrd euftf 

*Information about Immigration
tab1 noimbro cpimpop

***Comparative Estimate
recode cpimpop (1=1)(2=0.75)(3=0.50)(4=0.25)(5=0)(*=.), gen(compest)
label var compest "Comparative Estimate"

***Absolute Misperception
recode ccode (40=12.5)(56=10.7)(203=4.4)(208=6.7)(246=2.5)(250=10.0)(276=11.1)(300=10.3)   ///
(348=2.9)(372=10.4)(380=3.9)(442=32.5)(528=10.1)(578=7.3)(616=2.0)(620=6.3)(724=5.3)  /// 
(752=12.0)(756=21.6)(826=8.3), gen(foreignb)  

label var foreignb "Foreign-Born OECD, Sides and Citrin source"

clonevar sforeign = noimbro
recode sforeign(777/999=.)

label var sforeign "Subjective % Foreign-born"

gen abs_misp = sforeign - foreignb


table ccode if ins==0, c(m abs_misp) /*Check my work!*/

***Impute subjective foreign-born
tab1 educ discpol
recode discpol (1=7)(2=6)(3=5)(4=4)(5=3)(6=2)(7=1)(*=.), gen(dpolf)
tab dpolf
bysort ccode: pwcorr abs_misp educ dpolf

gen abs_mispi = abs_misp

*****Imputation loop, runs a regression in each country then replaces missings in our 'absolute misperceptions' variable
foreach val in 40 56 203 208 246 250 276 300 348 372 380 442 528 578 616 620 724 752 756 826 {
reg abs_misp educ dpolf if ccode==`val'
predict abs_guess if ccode==`val'
replace abs_mispi = abs_guess if ccode==`val' & abs_mispi==.
drop abs_guess
}



*Contact with Immigrants
tab1 dfegcf

*Alienation
tab1 ppltrst pplfair pplhlp stflife 

*Political Awareness and Ideology
tab1 dpolf lrscale

****Three ways to recode****
*****By hand
recode lrscale (77 88 99=.)(0=0)(1=.1)(2=.2)(3=.3)(4=.4)(5=.5)(6=.6)(7=.7)(8=.8)(9=.9)(10=1), gen(right)
*****By math
recode lrscale (77 88 99=.), gen(righta)
replace righta = righta/10
*****By loop
recode lrscale (77 88 99=.), gen(rightb)
foreach v of var rightb {
su `v', meanonly
gen `v'_1 = (`v' - r(min))/(r(max) - r(min))
}
pwcorr right righta rightb
*****they are all identical!



*Immigrant Status
tab1 ctzcntr brncntr livecntr blgetmg facntr mocntr

***Katharina reports to us that the German Mikro-Zensus codes 'second generation' as either both or one parent born abroad
***Sides and Citrin do not seem to state how they coded it
recode facntr mocntr (2=1)(1=0)(*=.), gen(faimm moimm)
gen secgen = 0
replace secgen = 1 if faimm==1 | moimm==1
tab secgen
label var secgen "Second Generation"

recode livecntr (1 2 3 =0)(4 5 =1)(*=.), gen(more10)
recode livecntr (1 2 3 =1)(4 5 =0)(*=.), gen(less10)

gen citizen = 1 if ctzcntr==1
replace citizen = 0 if ctzcntr==2
gen nat_m10 = 0
gen nat_l10 = 0
gen non_m10 = 0
gen non_l10 = 0
replace nat_m10 = 1 if citizen==1 & more10==1
replace nat_l10 = 1 if citizen==1 & less10==1
replace non_m10 = 1 if citizen==0 & more10==1
replace non_l10 = 1 if citizen==0 & less10==1

label var nat_m10 "Naturalized (>10)"
label var nat_l10 "Naturalized (<10)"
label var non_m10 "Non-Citizen (>10)"
label var non_l10 "Non-Citizen (>10)"



*Recode All Variables 0 to 1
tab1 ageyr 

*Test run to create figure 2
reg DV2 unemp student retired c.compest##c.abs_mispi if ins==0

*Like figure 2
margins, dydx(abs_mispi) at(compest=(0(.25)1))
marginsplot

*alternative (notice the tiny marginal differences)
margins, at(compest=(0(.25)1) abs_mispi=(-5(5)25))
marginsplot
