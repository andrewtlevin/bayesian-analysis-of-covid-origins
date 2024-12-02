use "Datasets/Wuhan_narrowcore_probit_data.dta", clear
drop if pop_density < 300
table (t5day) (result linked_count), nototal ///
  stat(frequency) stat(percent, across(linked_count))
table (t5day) (result unlinked_count), nototal ///
  stat(frequency) stat(percent, across(unlinked_count))
  
replace unlinked_count = 2 if unlinked_count==3
gen east_pop = eastbank_flag * lpopdensity
gen west_pop = (1-eastbank_flag) * lpopdensity

* Probit
probit unlinked_flag lpopdensity ///
   eastbank#c.L1_ldist1_unlinked ///
   L1_ldist1_linked near1_linked near1_unlinked, ///
   nolog vce(robust) 
estat ic
probit unlinked_flag lpopdensity ///
   L1_ldist1_linked near1_linked ///
   t3flag-t5flag, nolog vce(robust) 
estat ic
probit unlinked_flag lpopdensity ///
   L1_ldist1_unlinked L1_ldist1_linked ///
   t5flag, nolog vce(robust) 
estat ic
probit unlinked_flag lpopdensity ///
   L1_ldist1_unlinked L1_ldist1_linked near1_linked ///
   t5flag t5flag#c.L1_ldist1_unlinked t5flag#c.L1_ldist1_linked, ///
   nolog vce(robust) 
estat ic   

probit unlinked_flag lpopdensity ///
   L1_ldist1_unlinked L1_ldist1_linked t5flag, nolog 
estimates store A0
estat ic
probit unlinked_flag lpopdensity ///
   L1_ldist1_linked near1_linked t5flag, nolog 
estimates store Z0
estat ic

probit unlinked_flag eastbank eastbank#c.lpopdensity ///
   L1_ldist1_linked t5flag, nolog 
estat ic
probit unlinked_flag t5flag eastbank west_pop ///
   L1_ldist1_linked, nolog 
estat ic
probit unlinked_flag t5flag lpopdensity ///
   L1_ldist1_linked near1_linked, nolog 
estat ic
probit unlinked_flag t5flag lpopdensity ///
   L1_ldist1_linked, nolog 
estat ic
probit unlinked_flag t5flag L1_ldist1_linked near1_linked, nolog 
estat ic

* Ordered Probit
oprobit unlinked_count t5flag eastbank west_pop ///
   L1_ldist1_linked, nolog 
estat ic
oprobit unlinked_count t5flag lpopdensity ///
   L1_ldist1_linked near1_linked, nolog 
estat ic
oprobit unlinked_count t5flag lpopdensity ///
   L1_ldist1_linked, nolog 
estat ic
oprobit unlinked_count t5flag L1_ldist1_linked near1_linked, nolog 
estat ic
oprobit unlinked_count t5flag ///
   lpopdensity L1_ldist1_unlinked L1_ldist1_linked ///
   eastbank_flag##c.lpopdensity t5flag, ///
   nolog vce(robust) 
estat ic
oprobit unlinked_count t5flag lpopdensity ///
   L1_ldist1_unlinked L1_ldist1_linked eastbank_flag, ///
   nolog vce(robust) 
estat ic
oprobit unlinked_count lpopdensity ///
   L1_ldist1_linked eastbank_flag ///
   t5flag, nolog vce(robust) 
estat ic
oprobit unlinked_count lpopdensity ///
   L1_ldist1_unlinked L1_ldist1_linked ///
   t5flag, nolog vce(robust) 
estat ic
oprobit unlinked_count lpopdensity ///
   L1_ldist1_linked near1_linked ///
   t5flag, nolog vce(robust) 
estat ic
oprobit unlinked_count ///
   lpopdensity L1_ldist1_unlinked L1_ldist1_linked near1_linked ///
   t4flag t5flag ///
   t4flag#c.L1_ldist1_unlinked t5flag#c.L1_ldist1_unlinked ///
   t4flag#c.L1_ldist1_linked t5flag#c.L1_ldist1_linked, ///
   nolog vce(robust) 
   