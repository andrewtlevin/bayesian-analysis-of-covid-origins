* Merge data on vendor-case distances with data on distances 
* from raccoon dog shops, and drop 200 observations for 50 vacant stalls 
clear all
set maxvar 10000
use "Datasets/Huanan vendor-case distances.dta" 
merge 1:1 _ID idate ///
  using "Datasets/Huanan vendor-raccoondog distances.dta"
keep if _merge==3
drop _merge
merge 1:1 _ID idate ///
  using "Datasets/Huanan vendor to RD629 distances.dta"
keep if _merge==3
drop _merge
  
* Generate date-specific indicators
gen distRD = geodist_nearestRD 
gen d2_flag = cond(idate==2, 1, 0)
gen d3_flag = cond(idate==3, 1, 0)
gen d4_flag = cond(idate==4, 1, 0)
gen d3_distL1 = d3_flag * lag1_dist1
gen d4_distL1 = d4_flag * lag1_dist1
gen d3_distRD = d3_flag * distRD
gen d4_distRD = d4_flag * distRD

* Hypothesis A -- accidental lab leak 
* (date-specific intercept & slope for 26dec and 31dec2019)

bayesmh case_flag lag1_dist1 d3_flag d4_flag d3_distL1 d4_distL1, ///
  likelihood(probit) prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelA_d3dist_d4dist.dta", replace)
estimates save "Estimates/modelA_d3dist_d4dist", replace
bayesstats ess
bayesgraph diagnostics {case_flag:lag1_dist1}, name(probit_A, replace) 
graph export "Figures/Bayesian Charts for Hypothesis A.tif", replace
bayespredict pphatA, mean outcome(case_flag) ///
  rseed(654321) chains(10) dots(100, every(1000)) 

* Hypothesis Z -- zoonotic spillover 
* (distance to nearest raccoon dog shop, with date-specific intercept & slope 
*  for 26dec & 31dec2019)
bayesmh case_flag distRD d3_flag d3_distRD d4_flag d4_distRD ///
  if idate > 1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_nearest_d3d4distRD.dta", replace)
estimates save "Estimates/modelZ_nearestRD_d3d4distRD", replace
bayesstats ess
bayesgraph diagnostics {case_flag:distRD}, name(probit_Z, replace) 
graph export "Figures/Bayesian Charts for Hypothesis Z.tif", replace
bayespredict pphatZ, mean outcome(case_flag) ///
  rseed(654321) chains(10) dots(100, every(1000)) 
  
* Save all predicted probabilities 
save "Datasets/spatiotemporal_choropleth_data.dta", replace
		  
* Compare information criteria for model A vs. model Z
estimates use "Estimates/modelA_d3dist_d4dist"
estimates store modelA_d3dist_d4dist  
estimates use "Estimates/modelZ_nearestRD_d3d4distRD"
estimates store modelZ_nearestRD_d3d4distRD
bayesstats ic modelA_d3dist_d4dist modelZ_nearestRD_d3d4distRD, ///
              basemodel(modelA_d3dist_d4dist)
