# ESS-PPSP-course

Repository for University of Mannheim Elective Seminar: 

### Public Preferences and Social Policy: The Impacts of Immigration in Europe
#### Spring Semester, 2018

## DESCRIPTION:
The number of foreign-born persons in Western Europe increased dramatically over the past three decades. Also in Eastern European countries, immigrants are increasing in numbers for the first time since transition. This produces many social outcomes that link to trust, voting, inequality and the role of the state. For example, having more foreigners in a country or region may reduce trust and increase intergroup conflicts. In Germany, for the first time since WWII, an anti-immigrant, populist party gained substantial political power. Also, many immigrants, in particular refugees or family reunification immigrants, face substantial labor market disadvantage and poverty. Many states were not equipped to deal with immigration and refugee asylum seeking on the scale that developed in recent history. All of these features of European societies affect public preferences and public opinion. At the same time, public preferences and opinion shapes how governments react to immigration.

This course considers the many linkages between public preferences and social policies as they relate to immigrants, immigration and refugee seeking in Europe. It considers how the public reacts to immigration in voting, group dynamics and social movements (protests, violence). It considers how immigrants react to their statuses in European countries. It looks at how public reactions link to state policies and the distribution of power among political parties, and how states interact with each other in the European Union. All of this will take place with a focus on survey data using the [European Social Survey](http://www.europeansocialsurvey.org/) (ESS). We will read relevant literature and analyze relevant data as part of the course work. This data analysis will take place using Stata statistical software. Knowledge of Stata is not necessary, but will be helpful for students in this course.

A primary project during the course is to replicate the work of Sides and Citrin (2007) and Emmenegger and Klemmensen (2013) using the ESS.

## STATA PROJECT:
I organize the code into a Stata project [essppsp.stpr](https://github.com/nbreznau/ESS-PPSP-course/blob/master/ess_ppsp.stpr) that  cotains the master file [essppsp.do](https://github.com/nbreznau/ESS-PPSP-course/blob/master/essppsp.do) which executes the do files in order as described below. 

### _Working with the ESS_
The users will need to download the file [ESS1-7e01.dta](http://www.europeansocialsurvey.org/downloadwizard/) with all countries and variables selected and then extract and save this file. The file is then cleaned using the coding in [cleaness.do](https://github.com/nbreznau/ESS-PPSP-course/blob/master/cleaness.do) mostly to reduce its size. Students enrolled in the course can short-cut this step by downloading [ESS1-7e01.dta](https://ilias.uni-mannheim.de/goto.php?target=fold_784215&client_id=ILIAS) via Ilias which is already cleaned (i.e., they don't need to run the cleaness.do). Also available is a file readble by earlier versions of Stata ESS1-7e01v10.dta. This file needs to be saved with the _exact same name_ in the folder C:/data/ in order to follow the course code. 

The users also need the Quality of Government (QoG) OECD time series data file [qog_oecd_ts_jan18.dta](http://www.qogdata.pol.gu.se/data/qog_oecd_ts_jan18.dta) downloaded and saved in C:/data/ to engage in multilevel modeling. The ESS are QoG are merged using [merge_goqess.do](https://github.com/nbreznau/ESS-PPSP-course/blob/master/merge_essqog.do).

Users can access the code for 'playing with' and learning Stata and the ESS as we've done in class via [ess_exercises.do](https://github.com/nbreznau/ESS-PPSP-course/blob/master/ess_exercises.do).

### _Replication Project_
The users will need to download the single-wave file ESS1 and ESS7. Note that the replication only uses the ESS1, but the ESS7 repeats the ESS1 module, at least mostly, and provides the opportunity to not only replicate but also expand the original research. The [merge_ess1p7.do](https://github.com/nbreznau/ESS-PPSP-course/blob/master/merge_ess1p7.do) file puts them together. Students in the course may shortcut this step by downloading the file [ESS1and7.dta](https://ilias.uni-mannheim.de/goto.php?target=fold_784215&client_id=ILIAS) or the older version ESS1and7v10.dta which is readable with earlier versions of Stata.

Thanks to Sides and Citrin making available their replication files, we are able to merge in the net household income variable from the ESS version 5_f1. This is the same variable they analyzed, but is no longer distributed with the ESS because of comprability problems. The datafile [hinc_merge.dta](https://github.com/nbreznau/ESS-PPSP-course/blob/master/hinc_merge.dta) provides this variable. 

Interestingly, the respondent ID numbers changed for all of France since the release of version 5_f1, such that it is impossible to merge the them 1:1. Therefore, I simply drop the newer version of the French data and replace it with the original data provided by Sides and Citrin using the file [france_merge.dta](https://github.com/nbreznau/ESS-PPSP-course/blob/master/france_merge.dta).

The [sides_ditrin.do](https://github.com/nbreznau/ESS-PPSP-course/blob/master/sides_citrin.do) contains the replication code including the fix for the income variable and the France ID variable. _NOTE: This is a work in progress at this point, as we have not finished the replicaiton yet in the course!_

## LITERATURE:
Bay, Ann-Helén and Axel West Pedersen. 2006. “The Limits of Social Solidarity: Basic Income, Immigration and the Legitimacy of the Universal Welfare State.” _Acta Sociologica_ 49(4):419–36.

Berg, Justin Allen. 2015. “Explaining Attitudes toward Immigrants and Immigration Policy: A Review of the Theoretical Literature.” _Sociology Compass_ 9(1):23–34.

Boeri, Tito. 2010. “Immigration to the Land of Redistribution.” _Economica_ 77(308):651–87.

Brady, David and Ryan Finnigan. 2014. “Does Immigration Undermine Public Support for Social Policy?” _American Sociological Review_ 79(1):17–42.

Burgoon, Brian. 2014. “Immigration, Integration, and Support for Redistribution in Europe.” _World Politics_ 66(3):365–405.

Dancygier, Rafaela M. and David D. Laitin. 2014. “Immigration into Europe: Economic Discrimination, Violence, and Public Policy.” _Annual Review of Political Science_ 17(1).

Eger, Maureen A. and Andrea Bohman. 2016. “The Political Consequences of Contemporary Immigration.” _Sociology Compass_ 10(10):877–92.

Emmenegger, Patrick and Robert Klemmensen. 2013. “What Motivates You? The Relationship between Preferences for Redistribution and Attitudes toward Immigration.” _Comparative Politics_ 45(2):227–46.

Golder, Matt. 2016. “Far Right Parties in Europe.” _Annual Review of Political Science_ 19(1):477–97.

Hainmueller, Jens and Daniel J. Hopkins. 2014. “Public Attitudes Toward Immigration.” _Annual Review of Political Science_ 17(1):225–49.

Herda, Daniel. 2010. “How Many Immigrants? Foreign-Born Population Innumeracy in Europe.” _Public Opinion Quarterly_ 74(4):674–95.

Mewes, Jan and Steffen Mau. 2013. “Globalization, Socio-Economic Status and Welfare Chauvinism: European Perspectives on Attitudes toward the Exclusion of Immigrants.” _International Journal of Comparative Sociology_ 54(3).

OECD/EU. 2015. _Indicators of Immigrant Integration, 2015: Settling In_. Paris.

Röth, Leonce, Alexandre Afonso, and Dennis C. Spies. 2017. “The Impact of Populist Radical Right Parties on Socio-Economic Policies.” _European Political Science Review_ 1–26.

Sides, John and Jack Citrin. 2007. “European Opinion about Immigration: The Role of Identities, Interests and Information.” _British Journal of Political Science_ 37(3):477–504.
