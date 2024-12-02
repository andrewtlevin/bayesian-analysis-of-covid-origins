clear all
set maxvar 20000
use "Datasets/Wuhan_narrowcore_probit_data.dta", clear
drop if pop_density < 300
gen east_pop = eastbank_flag * lpopdensity
gen west_pop = (1-eastbank_flag) * lpopdensity
gen west_ldist1 = (1-eastbank_flag) * L1_ldist1
gen west_linked = (1-eastbank_flag) * L1_ldist1_linked
gen west_unlinked = (1-eastbank_flag) * L1_ldist1_unlinked

table (t5day) (result linked_flag), nototal ///
  stat(frequency) stat(percent, across(linked_flag))
table (t5day) (result unlinked_flag), nototal ///
  stat(frequency) stat(percent, across(unlinked_flag))

***********************************************
*  Probit with Flat Priors
***********************************************
bayesmh unlinked_flag t5flag eastbank ///
  west_pop L1_ldist1_linked L1_ldist1_unlinked, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(50000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA00.dta", replace)
bayesstats ic 

bayesmh unlinked_flag t5flag eastbank west_pop L1_ldist1_linked, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA01.dta", replace)
bayesstats ic 

bayesmh unlinked_flag t5flag eastbank west_pop L1_ldist1, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA02.dta", replace)
bayesstats ic 

bayesmh unlinked_flag t5flag eastbank west_pop west_ldist1, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA03.dta", replace)
bayesstats ic 

bayesmh unlinked_flag t5flag eastbank west_pop west_linked, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA04.dta", replace)
bayesstats ic 

bayesmh unlinked_flag t5flag eastbank ///
  west_pop west_linked L1_ldist1_unlinked, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA05.dta", replace)
bayesstats ic 

bayesmh unlinked_flag t5flag eastbank ///
  west_pop west_linked west_unlinked, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA06.dta", replace)
bayesstats ic 

**************************************************
* Hypothesis Z with Population Density
**************************************************
bayesmh unlinked_flag t5flag lpopdensity L1_ldist1 near1_flag, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelZ00.dta", replace)
bayesstats ic 

**************************************************
* Hypothesis Z with No Population Density
**************************************************
bayesmh unlinked_flag t5flag ///
  L1_ldist1_linked near1_linked, ///
  likelihood(probit) prior({unlinked_flag:}, flat) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelZ1.dta", replace)
bayesstats ic 

***********************************************
*  Probit with Diffuse Priors
***********************************************
bayesmh unlinked_flag t5flag eastbank ///
  west_pop L1_ldist1_linked L1_ldist1_unlinked, ///
  likelihood(probit) ///
  prior({unlinked_flag: L1_ldist1_linked}, uniform(-1,0)) ///
  prior({unlinked_flag: L1_ldist1_unlinked}, uniform(-1,0)) ///
  prior({unlinked_flag: eastbank_flag}, uniform(-5,5)) ///
  prior({unlinked_flag: west_pop}, uniform(0,1)) ///
  prior({unlinked_flag: _cons}, uniform(-8,0)) ///
  prior({t5flag}, uniform(-1,1)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(60000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA20.dta", replace)
bayesstats ic 
  
bayesmh unlinked_flag L1_ldist1_linked eastbank west_pop t5flag, ///
  likelihood(probit) ///
  prior({unlinked_flag: L1_ldist1_linked}, uniform(-1,0)) ///
  prior({unlinked_flag: eastbank_flag}, uniform(-5,5)) ///
  prior({unlinked_flag: west_pop}, uniform(0,1)) ///
  prior({unlinked_flag: _cons}, uniform(-8,0)) ///
  prior({t5flag}, uniform(-1,1)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelA21.dta", replace)
bayesstats ic 

bayesmh unlinked_flag L1_ldist1_linked near1_linked lpopdensity t5flag, ///
  likelihood(probit) ///
  prior({unlinked_flag: L1_ldist1_linked}, uniform(-1,0)) ///
  prior({unlinked_flag: near1_linked}, uniform(-5,5)) ///
  prior({unlinked_flag: lpopdensity}, uniform(0,1)) ///
  prior({t5flag}, uniform(-1,1)) ///
  prior({unlinked_flag: _cons}, uniform(-8,0)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelZ20.dta", replace)
bayesstats ic 
  
bayesmh unlinked_flag t5flag ///
  L1_ldist1_linked near1_linked, ///
  likelihood(probit) ///
  prior({unlinked_flag: L1_ldist1_linked}, uniform(-1,0)) ///
  prior({unlinked_flag: near1_linked}, uniform(-5,5)) ///
  prior({t5flag}, uniform(-1,1)) ///
  prior({unlinked_flag: _cons}, uniform(-8,0)) ///
  rseed(654321) nchains(10) ///
  mcmcsize(20000) dots(1000, every(10000)) burnin(10000) ///
  saving("Temp/wuhan_modelZ21.dta", replace)
bayesstats ic 
