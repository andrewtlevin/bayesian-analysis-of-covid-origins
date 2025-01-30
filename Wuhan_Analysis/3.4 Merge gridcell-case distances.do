* Merge core data with distances to linked vs. unlinked cases
use "Datasets/Wuhan_narrowcore_case_distances.dta", clear
merge 1:1 _ID t5day ///
  using "Datasets/Wuhan_narrowcore_distances_by_link_status.dta" 

* Add nearby indicators
gen near1_flag = cond(L1_ldist1==0, 1, 0)
gen near1_linked = cond(L1_ldist1_linked==0, 1, 0)
gen near1_unlinked = cond(L1_ldist1_unlinked==0, 1, 0)

gen near2_flag = cond(L1_ldist1 > 0 & L1_ldist1 <= log(2), 1, 0)
gen near2_linked = cond(L1_ldist1_linked > 0 & L1_ldist1_linked <= log(2), 1, 0)
gen near2_unlinked = cond(L1_ldist1_unlinked > 0 & L1_ldist1_unlinked <= log(2), 1, 0)

* Add date indicators
gen t2flag = cond(t5num==2, 1, 0)
gen t3flag = cond(t5num==3, 1, 0)
gen t4flag = cond(t5num==4, 1, 0)
gen t5flag = cond(t5num==5, 1, 0)

* Generate date-specific indicators
gen t2_distL1 = t2flag * L1_ldist1
gen t3_distL1 = t3flag * L1_ldist1
gen t4_distL1 = t4flag * L1_ldist1
gen t5_distL1 = t5flag * L1_ldist1
gen t2_distL1_linked = t2flag * L1_ldist1_linked
gen t3_distL1_linked = t3flag * L1_ldist1_linked
gen t4_distL1_linked = t4flag * L1_ldist1_linked
gen t5_distL1_linked = t5flag * L1_ldist1_linked
gen t2_distL1_unlinked = t2flag * L1_ldist1_unlinked
gen t3_distL1_unlinked = t3flag * L1_ldist1_unlinked
gen t4_distL1_unlinked = t4flag * L1_ldist1_unlinked
gen t5_distL1_unlinked = t5flag * L1_ldist1_unlinked

table t5day, stat(total linked_count unlinked_count)
save "Datasets/Wuhan_narrowcore_probit_data.dta", replace
