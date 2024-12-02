* Analyze distance from raccoon dog stalls
use "Datasets/Huanan vendor-raccoondog distances.dta", clear
keep if idate==4
merge 1:1 _ID using "Datasets/environmental_test_vendor_index.dta"
keep if _merge==3
drop _merge
gen pos_flag = cond(missing(totpos) & missing(totneg), ., cond(totpos > 0,1, 0))
rename geodist_nearestRD distRD
gen bldg_flag = cond(building=="East", 0, 1)
gen bldg_distRD = bldg_flag * distRD

* All observations (no building-specific indicator)
bayesmh pos_flag, likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_modelA1.dta", replace)
estimates store modelA1
bayesmh pos_flag distRD, likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  prior({pos_flag: distRD}, uniform(-25, 25)) /// 
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_modelZ1.dta", replace)
estimates store modelZ1
bayesstats ic modelA1 modelZ1, basemodel(modelZ1)  

* All observations with building-specific intercept
bayesmh pos_flag bldg_flag, likelihood(probit) ///
  prior({pos_flag:}, normal(0,2)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_modelA2.dta", replace)
estimates store modelA2
bayesstats ic modelA1 modelA2, basemodel(modelA2)  
bayesmh pos_flag distRD bldg_flag, likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  prior({pos_flag: bldg_flag}, normal(0,2)) ///
  prior({pos_flag: distRD}, uniform(-25, 25)) /// 
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_modelZ2.dta", replace)
estimates store modelZ2
bayesstats ic modelZ1 modelZ2, basemodel(modelZ2)  
bayesstats ic modelA2 modelZ2, basemodel(modelZ2)  

* All observations with building-specific intercept & slope 
bayesmh pos_flag distRD bldg_flag bldg_distRD, likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  prior({pos_flag: bldg_flag}, normal(0,2)) ///
  prior({pos_flag: distRD}, uniform(-25, 25)) /// 
  prior({pos_flag: bldg_distRD}, uniform(-25, 25)) /// 
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_modelZ3.dta", replace)
estimates store modelZ3
bayesstats ic modelZ2 modelZ3, basemodel(modelZ3)  
bayesstats ic modelA2 modelZ3, basemodel(modelZ3)  
exit

* Only West Building 
bayesmh pos_flag if building=="West", likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_model2A.dta", replace)
estimates store model2A
bayesmh pos_flag distRD if building=="West", likelihood(probit) ///
  prior({pos_flag: _cons}, normal(0,2)) ///
  prior({pos_flag: distRD}, uniform(-25, 25)) /// 
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Estimates/pcrdata_model2Z.dta", replace)
estimates store model2Z
bayesstats ic model2A model2Z, basemodel(model2Z)    
  
