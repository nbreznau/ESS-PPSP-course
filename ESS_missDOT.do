* Numeric variables
quietly label dir 					
foreach v in `r(names)' {
	capture confirm variable `v'
	if !_rc {
		quietly label list `v'	
		local length = length("`r(max)'")
		local format = (10^`length'-1)/9
		local 6 = 6*`format'
		local 7 = 7*`format'
		local 8 = 8*`format'
		local 9 = 9*`format'

		local a : label `v' `6'
		if regexm("`a'","Not .p+lic+able")  {
			local r `6'=. \
		}
		local b : label `v' `7'
		if regexm("`b'","Refus..") {
			local r `r' `7'=. \
		}
		local c : label `v' `8'
		if regexm("`c'","Don.?t .now") {
			local r `r' `8'=. \
		}
		local d : label `v' `9'
		if regexm("`d'","[No .nswer|Not .vailable]") {
			local r `r' `9'=. \
		}
		if !missing("`r'") mvdecode `v', mv(`r')
		local r
	}
}

* String variables
quietly ds, has(type string)
foreach v of varlist `r(varlist)' {	
	local length = substr("`:type `v''",4,4)
	local format = (10^`length'-1)/9
	local 6 = 6*`format'
	local 7 = 7*`format'
	local 8 = 8*`format'
	local 9 = 9*`format'
	di "`v'"
	replace `v'= "" if inlist(`v',"`9'","`8'","`7'","`6'")
}
