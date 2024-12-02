* Input data from WHO Annex E4, table 5
clear
input str12 vendor_type nvendors ncases 
  freshwater 559 15
  seafood 484 14
  livestock 318 9
  misc 266 3
  poultry 230 8
  vegetables 108 5
  liveanimals 15 0
  total 1162 30
  end
save "Datasets/vendor_cases_by_product_type.dta", replace  

* Store information in local variables
local ntypes = _N
disp "`ntypes'"
local type_list = ""
local nvendors_list = ""
local ncases_list = ""
forvalues ii = 1/`ntypes' {
  local type_list = "`type_list' " + vendor_type[`ii']
  local nvendors_list = "`nvendors_list' " + string(nvendors[`ii'],"%3.0f")
  local ncases_list = "`ncases_list' " + string(ncases[`ii'],"%2.0f")
}

* Loop over product types and compute Bayesian estimates and CIs
forvalues ii = 1/`ntypes' {
  local vtype = word("`type_list'",`ii')
  local nvendors = word("`nvendors_list'",`ii')
  local ncases = max(1, real(word("`ncases_list'",`ii')))
  clear
  set obs 1
  gen case_flag = `ncases'
  disp "Type of Product: `vtype'"
  bayesmh case_flag, likelihood(dbinomial({theta},`nvendors')) ///
    prior({theta}, beta(1,25)) ///
	initial({theta} 0.04) ///  
	saving("Temp/bayes_`vtype'_output.dta", replace)
}

		  