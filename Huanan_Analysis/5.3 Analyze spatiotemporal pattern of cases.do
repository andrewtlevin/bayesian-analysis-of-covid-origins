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
gen d2_flag = cond(idate==2, 1, 0)
gen d3_flag = cond(idate==3, 1, 0)
gen d4_flag = cond(idate==4, 1, 0)
gen d3_distL1 = d3_flag * lag1_dist1
gen d4_distL1 = d4_flag * lag1_dist1

* Generate distances to raccoon dog shops & date-specific interactions
gen distRD = geodist_nearestRD 
gen d3_distRD = d3_flag * distRD
gen d4_distRD = d4_flag * distRD

* Determine specification of model under hypothesis A
** date-specific intercept & slope for 26dec and 31dec2019
bayesmh case_flag lag1_dist1 d3_flag d4_flag d3_distL1 d4_distL1, ///
  likelihood(probit) prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelA_d3dist_d4dist.dta", replace)
estimates store modelA_d3dist_d4dist
** date-specific intercepts for 26dec and 31dec2019
bayesmh case_flag lag1_dist1 d3_flag d4_flag, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelA_d3_d4.dta", replace)
estimates store modelA_d3_d4
** date-specific indicator for 26dec
bayesmh case_flag lag1_dist1 d3_flag, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelA_d3.dta", replace)
estimates store modelA_d3
** no date-specific indicators
bayesmh case_flag lag1_dist1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelA_none.dta", replace)
estimates store modelA_none
** date-specific intercept for 26dec, intercept & slope for 31dec2019
bayesmh case_flag lag1_dist1 d3_flag d4_flag d4_distL1, ///
  likelihood(probit) prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelA_d3_d4dist.dta", replace)
estimates store modelA_d3_d4dist
** date-specific intercept for 26dec, intercept & slope for 31dec2019
bayesmh case_flag lag1_dist1 d3_flag d3_distL1 d4_flag, ///
  likelihood(probit) prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelA_d3dist_d4.dta", replace)
estimates store modelA_d3dist_d4
**** Compare six models for hypothesis A
bayesstats ic modelA_none modelA_d3 modelA_d3_d4 ///
              modelA_d3_d4dist modelA_d3dist_d4 modelA_d3dist_d4dist, ///
			  basemodel(modelA_none)

* Determine specification of model under hypothesis Z
** distance to nearest raccoon dog shop
***** intercept & slope for 26dec & 31dec2019
bayesmh case_flag distRD d3_flag d3_distRD d4_flag d4_distRD ///
  if idate > 1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_nearest_d3d4distRD.dta", replace)
estimates store modelZ_nearestRD_d3d4distRD
*****  no date-specific indicators
bayesmh case_flag distRD if idate > 1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_nearestRD.dta", replace)
estimates store modelZ_nearestRD
***** intercept for 31dec2019
bayesmh case_flag distRD d4_flag if idate > 1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_nearest_d4.dta", replace)
estimates store modelZ_nearestRD_d4
***** intercept & slope for 31dec2019
bayesmh case_flag distRD d4_flag d4_distRD if idate > 1, ///
  likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_nearest_d4distRD.dta", replace)
estimates store modelZ_nearestRD_d4distRD
  
** distance to primary raccoon dog shop
replace distRD = geodist_RD629
replace d3_distRD = d3_flag * distRD
replace d4_distRD = d4_flag * distRD
  
***** no date-specific intercepts 
bayesmh case_flag distRD if idate > 1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_RD629.dta", replace)
estimates store modelZ_RD629
***** intercept for 31dec2019
bayesmh case_flag distRD d4_flag if idate > 1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_RD629_d4.dta", replace)
estimates store modelZ_RD629_d4
***** intercept & slope for 31dec2019
bayesmh case_flag distRD d4_flag d4_distRD if idate > 1, ///
  likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_RD629_d4distRD.dta", replace)
estimates store modelZ_RD629_d4distRD
** intercept & slope for 26dec & 31dec2019
bayesmh case_flag distRD d3_flag d3_distRD d4_flag d4_distRD ///
  if idate > 1, likelihood(probit) ///
  prior({case_flag:}, flat) rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/modelZ_RD629_d3d4distRD.dta", replace)
estimates store modelZ_RD629_d3d4distRD

*** Compare six models for hypothesis Z
bayesstats ic modelZ_nearestRD modelZ_nearestRD_d4 modelZ_nearestRD_d4distRD ///
			  modelZ_nearestRD_d3d4distRD ///
              modelZ_RD629_d4 modelZ_RD629 modelZ_RD629_d4distRD ///
			  modelZ_RD629_d3d4distRD, basemodel(modelZ_RD629)
		  
* Compare model A vs. model Z			  
bayesstats ic modelA_d3dist_d4dist modelZ_nearestRD_d3d4distRD, ///
              basemodel(modelA_d3dist_d4dist)
	  
