*Playing around with the ESS data

****** A graph by country ordered from highest to lowest *******

graph bar imbleco, over(cntry, sort(1)) nofill

****** Using the weights to get population estimates ******

corr imbleco stfgov [aweight=dweight]


**** Another way to identify stacked observations ***

*scatter imbleco imueclt

*The problem with this scatterplot is that every point in the graph is filled so you cannot see any association. Therefore you can create a 'weighting' variable that contains the number of cases for each point, like so:

egen freq = total(1), by( imbleco imueclt)

*The you can use this weighting variable like a survey weight in a scatter command like so, and if you are looking to add a line you can use the two way command (as shown in the second line of code):

scatter imbleco imueclt [fw=freq]
twoway (scatter imbleco imueclt [fw=freq])(lfit imbleco imueclt)

*Antoher trick is to use the jitter option, this works better with tiny data points
twoway (scatter imbleco imueclt, jitter(15) msize(tiny))(lfit imbleco imueclt)

*Another option is to select a subsample of data, e.g. 5% of the 300,000 cases
*To do this you can generate a random number and then recode it to be 1% of the cases
gen subsamp = runiform()
recode subsamp (0/0.05=1)(0.050000001/1=0)

twoway (scatter imbleco imueclt if subsamp==1, jitter(15) msize(tiny))(lfit imbleco imueclt)
*Nice!
*************************************************************************************************************************************************************************

*Socio-Economic and Demographic Variables

*Education

tab eisced
numlabel eisced, add
tab eisced
gen educ = eisced
recode educ (0 55=.)

*Not all can be harmonized using ISCED if we want to analyze those countries not harmonized we need an alternative measure of education

tab eduyrs
gen edyear = eduyrs

*Need to set a maximum limit (26 years of education looks like a good cutoff)
recode edyear (26/56=26)

*Age
recode agea (.a =.), gen(age)
graph box age
recode age (80/123=80)

*Attitude Variables

*From Antje
*Generate and name dependent variable
egen nqual=anycount(qfimchr qfimcmt qfimedu qfimlng qfimwht qfimwsk), values(8/10)
*Alternative
egen qualc=rowmean(qfimchr qfimcmt qfimedu qfimlng qfimwht qfimwsk)
lab var nqual "Number of important qualifications necessary for immigration"
*Show summary statistics for ppltrst and nqual by country
tabstat ppltrst nqual [aw=dweight], by(cntry) statistics(mean median sd min max)

*From Felix
gen immig_crime=imwbcrm
label values immig_crime imwbcrm 
label var immig_crime "Immigrants make country’s crime problems worse or better"

*Multilevel Structures

corr ppltrst qualc edyear
preserve
collapse ppltrst qualc edyear, by(cntry)
corr ppltrst qualc edyear
restore


*Investigating the correlation in each country
bysort cntry: corr ppltrst qualc edyear


*Percent variance
*mixed ppltrst || cntry:, var

*ERROR! this does not converge. What is the problem?
*It will converge if selecting only one year

mixed ppltrst || ccode: if year==2008, var

*In the above model, between-variance is 1.219 and within-variance is 5.04, this means total-variance is 1.219+5.04= 6.259
*This means ICC = 1.219/6.259 = .195
*This mean 19.5% of the total variance in ppltrst occurs between countries, and thus 80.5% occurs within countries at the individual level

mixed qualc || cntry:, var
estat icc

mixed immig_crime || ccode:, var
estat icc

mixed immig_crime ppltrst || ccode:, var
estat icc

*The above models showed no real change in ICC, so the variance explained at both level-1 and level-2 was about equal between the two models

*Lets test a model where we explain only variance at level-1
*To do this we can mean-center a variable we know correlates with immig_crime
*Here I use imbleco (that immigrants put in more than they take out of the system)
mixed immig_crime imbleco || ccode:, var
*Again ICC does not change much from the empty-model

*Now mean-center, what will happen?
bysort ccode: egen imblecoM = mean(imbleco)
gen imblecoC = imbleco-imblecoM
mixed immig_crime imblecoC || ccode:, var
estat icc

*Likelihood Ratio Test

mixed ppltrst if year==2008, var
mixed ppltrst || cntry: if year==2008, var

*In these two models, we can subtract the -2 Log Likelihood and the degrees of freedom to come up with a chi-square test statistic
*the difference in log likelihoods and the difference in degrees of freedom produces a p-value for this test
*If the p-value is significant, then the model with fewer degrees of freedom is significantly worse in terms of deviance (-2LL is a measure of deviance)
*Luckily Stata calculates this for us regarding the empty model (its at the bottom of the output after mixed); however, if we want to compare two nested models we have to do it ourselves. Lets try

*We need the same number of cases to compare thus we need to make sure edyear is coded to mising
recode edyear (.a .b .c=.)

mixed ppltrst || cntry: if year==2008 & edyear!=., var
est store m1
mixed ppltrst edyear || cntry: if year==2008 & edyear!=., var
est store m2

*Degrees of freedom difference is 1 (found in the Wald chi2 statistic) and the -2LL difference is

display 90856.749 -89682.829

*1173.92

*Now we can ask Stata to calculate this from a chi-square distribution table, don't forget it is 1 minus chi2 p-value in this case

display 1-chi2(1,1173.92)

*The result is zero. When the result is significant at p<0.001, we can safely say that the model with fewer degrees of freedom is significantly worse. So in this case, the model with the addition of edyear is preferable.

*Alternative 'easier' way to do the Likelihood Ratio test

lrtest m1 m2
*restul is also p<0.000

*Graphing across countries

*Lets say we want a linear relationship for two variables by country, in the same graph
*Plus we want a thick line for the grand mean

local plot
foreach i in 40 56 203 208 233 246 250 276 300 348 372 528 578 616 620 703 705 724 752 756 792 826 {
local plot `plot' (lfit ppltrst edyear if ccode==`i', lpattern(dash) legend(off))
}
graph twoway `plot' (lfit ppltrst edyear, lwidth(thick) lcolor(gs2))

*One country has a flat line!

bysort ccode: corr ppltrst edyear

*Country with near-zero correlation is Turkey (792)
