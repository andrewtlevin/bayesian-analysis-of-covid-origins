* Analyze distance from raccoon dog stalls
use "Datasets/Huanan vendor to RD629 distances.dta", clear
keep if idate==4
merge 1:1 _ID using "Datasets/environmental_test_vendor_index.dta"
keep if _merge==3
drop _merge
gen pos_flag = cond(missing(totpos) & missing(totneg), ., cond(totpos > 0,1, 0))
rename geodist_RD629 distRD

* All observations
bayesmh pos_flag, likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_model3A.dta", replace)
estimates store model3A
bayesmh pos_flag distRD, likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  prior({pos_flag: distRD}, uniform(-25, 25)) /// 
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_model3Z.dta", replace)
estimates store model3Z
bayesstats ic model 3Z
bayesstats ic model3A model3Z, basemodel(model3Z)  

* Only West Building 
bayesmh pos_flag if building=="West", likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_model4A.dta", replace)
estimates store model4A
bayesmh pos_flag distRD if building=="West", likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  prior({pos_flag: distRD}, uniform(-25, 25)) /// 
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_model4Z.dta", replace)
estimates store model4Z
bayesstats ic model4A model4Z, basemodel(model4Z)    
  
