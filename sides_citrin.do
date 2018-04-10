
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

*Merge income from ESSe05_f1.dta, income is not in the newer versions of the data
*probably due to problems with measurement of comprability
***drop wave7 for now
drop if year!=2002
drop hinctnt
sort cntry idno

merge 1:1 cntry idno using "C:/data/hinc_merge.dta" 
drop if cntry=="FR"
drop _merge*

*The id numbers in France changed between editions of the ESS for some reason
***This file brings back the orgiinal version of French data from Sides and Citrin
append using "C:/data/france_merge.dta"
***Note that France has a different coding here for its income variable from 1 to 9
***Other countries seem to be at parity
replace ccode=250 if cntry=="FR"
replace year=2002
*Merge QoG data

sort ccode
merge m:1 ccode year using "C:/data/qog_oecd_ts_jan18.dta"
***Lithuania does not seem to be in the QoG data, pity. Maybe we can find the macro-data somewhere else.
tab cntry if _merge==1
drop if _merge==2

drop _merge*



numlabel, add



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

**without weights
tabm dv2_w3-dv2_cu3 if year==2002, nof row

**with weights, did they use both weights?
tabm dv2_w3-dv2_cu3 [aweight=weight2], nof row


*Table 2

table cntry, c(m DV1 m DV2)
table cntry [aweight=weight2], c(m DV1 m DV2)

sum DV1 DV2
corr DV1 DV2


**************************************
*************  RECODES ***************
**************************************


*SOCIOECONOMIC AND DEMOGRAPHIC VARIABLES

*Income

***borrowed this code from Sides and Citrin
generate income=hinctnt
gen incomeimp=income
egen tincome=mean(income), by(ccode)
replace incomeimp=tincome if hinctnt==. /*replace missing data with country-level mean*/
replace incomeimp=(incomeimp-1)/11

*Education
tab1 eduyrs
clonevar educ = eduyrs
recode educ (77 88 99=.)(25/50=25)

*Demographic
tab1 gndr agea

recode gndr (2=1)(1=0)(*=.), gen(female)

clonevar ageyr = agea
recode ageyr (999=.) /*recode missing values*/
recode ageyr (85/114=85) /*recode outliers*/
*hist ageyr, bin(12)

*Employment
**Its not clear what varaibles they used
***could be 'mnactic' or individual variables, e.g., 'unempla'
recode mnactic (3 4=1)(*=0), gen(unemp)
recode mnactic (6=1)(*=0), gen(retired)
recode mnactic (2=1)(*=0), gen(student)

***Also, is house work more like paid work or being reitred?
****We decided in the lab to make young houseworkers into 'students'
****and old houseworkers into 'retirees'
replace retired = 1 if ageyr>64 & mnactic==8
replace student = 1 if ageyr<65 & mnactic==8


*Satisfaction with variables
tab1 hincfel stfeco
recode hincfel (1=1)(2=.67)(3=.33)(4=0)(8=.5)(7 9=.), gen(satfin)
recode stfeco (77 88 99=.), gen(satecon)
replace satecon = satecon/10
label var satfin "Satisfied with personal finances"
label var satecon "Satisfied with economy"

*Cultural and national identities
tab1 dclenv dclcrm dclagr dcldef dclwlfr dclaid dclmig dclintr
recode dclenv dclcrm dclagr dcldef dclwlfr dclaid dclmig dclintr (2 1=1)(*=0), gen(i1 i2 i3 i4 i5 i6 i7 i8)
tab1 i1-i8
egen natu = rowtotal(i1-i8)
tab natu
replace natu=((natu-8)/-8)
tab natu
label var natu "Preference for national authority"

recode pplstrd (1=1)(2=.75)(3 8=.5)(4=.25)(5=0)(*=.), gen(cultu)
label var cultu "Prefer cultural unity"


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


table ccode, c(m abs_misp) /*Check my work!*/

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

label var abs_mispi "Absolute misperception"

*Contact with Immigrants
tab1 dfegcf
recode dfegcf imgfrnd (1=1)(2 8=.5)(3=0)(*=.), gen(contact c2)
replace contact=c2 if contact==.
label var contact "Have immigrant friends"


*Alienation
tab1 ppltrst pplfair pplhlp stflife 
recode ppltrst pplfair pplhlp (77 99=.)(88=5), gen(st1 st2 st3)
egen strust = rowmean(st1 st2 st3)
label var strust "Social trust"
recode stflife (88=5)(77 99=.), gen(lifesat)
replace lifesat=lifesat/10
label var lifesat "Life satisfaction"



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

label var dpolf "Frequency of political discussion"
label var right "Conservatism"

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

recode blgetmg (1=1)(*=0), gen(minority)
label var minority "Self-identified minority"


**************************************************
******************* ANALYSES *********************
**************************************************


*sum satfin satecon unemp student retired cultu natu compest abs_mispi contact strust lifesat dpolf right minority secgen nat_m10 nat_l10 non_m10 non_l10


*Recode all remaining variables 0 to 1

foreach v of var abs_mispi strust dpolf educ ageyr incomeimp{
su `v', meanonly
gen `v'_1 = (`v' - r(min))/(r(max) - r(min))
}

label var abs_mispi_1 "Absolute misperception"
label var strust_1 "Social trust"
label var dpolf_1 "Frequency of political discussion"

drop if ccode==705
*Descriptives
sum satfin satecon incomeimp_1 unemp student retired cultu natu compest abs_mispi_1 contact strust_1 lifesat dpolf_1 right minority secgen nat_m10 nat_l10 non_m10 non_l10 educ_1 ageyr_1 female


*******************************
********* REGRESSIONS *********
*******************************

*DV1 - Percieved negative consequences
label var DV1 "Percieved negative consequences"

reg DV1 satfin satecon incomeimp_1 unemp student retired cultu natu c.compest##c.abs_mispi_1 contact strust_1 lifesat c.dpolf_1##c.right minority secgen nat_m10 nat_l10 non_m10 non_l10 educ_1 ageyr_1 female i.ccode, cluster(ccode)
*reg DV1 c.compest##c.abs_mispi_1 i.ccode, cluster(ccode)

*Like figure 2
margins, dydx(abs_mispi_1) at(compest=(0(.25)1))
marginsplot

*alternative (notice the tiny marginal differences)
margins, at(compest=(0(.25)1) abs_mispi_1=(0(.2)1))
marginsplot

*DV2 - Prefer lower levels
label var DV2 "Prefer lower levels"
reg DV2 satfin satecon incomeimp_1 unemp student retired cultu natu c.compest##c.abs_mispi_1 contact strust_1 lifesat c.dpolf_1##c.right minority secgen nat_m10 nat_l10 non_m10 non_l10 educ_1 ageyr_1 female i.ccode, cluster(ccode)

*Like figure 3
margins, dydx(abs_mispi_1) at(compest=(0(.25)1)) atmeans
marginsplot

*what happens without the imputation
reg DV1 satfin satecon incomeimp_1 unemp student retired cultu natu c.compest##c.abs_mispi_1 contact strust_1 lifesat c.dpolf_1##c.right minority secgen nat_m10 nat_l10 non_m10 non_l10 educ_1 ageyr_1 female i.ccode if sforeign!=., cluster(ccode)
*reg DV1 c.compest##c.abs_mispi_1 i.ccode, cluster(ccode)

*Like figure 2
margins, dydx(abs_mispi_1) at(compest=(0(.25)1))
marginsplot


reg DV2 satfin satecon incomeimp_1 unemp student retired cultu natu c.compest##c.abs_mispi_1 contact strust_1 lifesat c.dpolf_1##c.right minority secgen nat_m10 nat_l10 non_m10 non_l10 educ_1 ageyr_1 female i.ccode if sforeign!=., cluster(ccode)

*Like figure 3
margins, dydx(abs_mispi_1) at(compest=(0(.25)1))
marginsplot
