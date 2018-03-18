*Sides and Citrin DV1 Preferred Level of Immigration

sum imsmetn imdfetn eimpcnt impcntr eimrcnt imrcntr
clonevar dv1_samemaj = imsmetn
clonevar dv1_difrace = imdfetn
clonevar dv1_poorinEU = eimpcnt
clonevar dv1_pooroutEU = impcntr
clonevar dv1_richinEU = eimrcnt
clonevar dv1_richoutEU = imrcntr
recode dv1_samemaj dv1_difrace dv1_poorinEU dv1_pooroutEU dv1_richinEU dv1_richoutEU (4=1)(3=2)(2=3)(1=4)(*=.)

*Sides and Citrin DV2 Perceived Consequensces of Immigration

sum imwbcnt imbgeco imbleco imwbcrm imueclt
clonevar dv2_worse = imwbcnt
clonevar dv2_econ = imbgeco
clonevar dv2_take = imbleco
clonevar dv2_crime = imwbcrm
clonevar dv2_cultr = imueclt
recode dv2_worse dv2_econ dv2_take dv2_crime dv2_cultr (10=0)(9=1)(8=2)(7=3)(6=4)(5=5)(4=6)(3=7)(2=8)(1=9)(0=10)(*=.)
