* Remove non-initial cluster cases
use "Datasets/Wuhan_narrowcore_cases.dta", clear
tab onset_period huanan_flag
sort cluster onset_period
by cluster: gen drop_flag = cond(_n==1 | missing(cluster), 0, 1)
list cluster onset_period _ID caseid huanan_flag drop_flag if !missing(cluster)
drop if drop_flag==1

* Tabulate cases by linked status, gridcell and onset date
* Note: for each gridcell and onset date, 
*       _PX and _PY are averaged across cases (only relevant when 
*       a gridcell has multiple cases on a given onset date) 
rename _PX case_X
rename _PY case_Y
sort huanan_flag _ID onset_period
by huanan_flag _ID onset_period: gen icount = _n
by huanan_flag _ID onset_period: gen ncount = _N
by huanan_flag _ID onset_period: egen _PX = mean(case_X)
by huanan_flag _ID onset_period: egen _PY = mean(case_Y)
keep if icount==1
drop huanan_linked notes case_X case_Y icount 
sort huanan_flag onset_period _ID 
by huanan_flag onset_period: gen date_caseid = _n
save "Temp/narrowcore_cases_by_linked_status.dta", replace

* Generate complete grid for each link status & onset date
use "Maps/Wuhan_narrowcore_popdensity.dta", clear
keep _ID _CX _CY 
expand 10
sort _ID
by _ID: gen huanan_flag = cond(inlist(_n,1,3,5,7,9),0,1)
by _ID: gen onset_period = cond(inlist(_n,1,2), mdy(12,11,2019), ///
                           cond(inlist(_n,3,4), mdy(12,16,2019), ///
						   cond(inlist(_n,5,6), mdy(12,21,2019), ///
						   cond(inlist(_n,7,8), mdy(12,26,2019), mdy(12,31,2019)))))
merge 1:1 huanan_flag _ID onset_period ///
  using "Temp/narrowcore_cases_by_linked_status.dta"
replace ncount = 0 if _merge < 3
drop _merge date_caseid _PX _PY 
gen case_flag = cond(ncount>0, 1, 0)

* For each status and onset date, tabulate total number of 
* positive gridcells and expand grid to three dimensions 
* (Onset_Date, _ID, CaseID)
sort huanan_flag onset_period _ID
by huanan_flag onset_period: egen totcase_date = total(case_flag)
expand totcase_date
sort huanan_flag onset_period _ID
by huanan_flag onset_period _ID: gen date_caseid = _n
merge m:1 huanan_flag onset_period date_caseid ///
  using "Temp/narrowcore_cases_by_linked_status.dta"
drop _merge 

* For each gridcell & onset date, compute distance from 3 nearest cases
geodist _CY _CX _PY _PX, gen(geodist_gc)
sort huanan_flag onset_period _ID geodist_gc
by huanan_flag onset_period _ID: gen tnearest_1 = cond(_n==1, date_caseid, 9999) 
by huanan_flag onset_period _ID: gen tdist_1 = cond(_n==1, geodist_gc, 9999) 
by huanan_flag onset_period _ID: gen tnearest_2 = cond(_n==2, date_caseid, 9999) 
by huanan_flag onset_period _ID: gen tdist_2 = cond(_n==2, geodist_gc, 9999) 
by huanan_flag onset_period _ID: gen tnearest_3 = cond(_n==3, date_caseid, 9999) 
by huanan_flag onset_period _ID: gen tdist_3 = cond(_n==3, geodist_gc, 9999) 
by huanan_flag onset_period _ID: egen nearest_1 = min(tnearest_1)
by huanan_flag onset_period _ID: egen nearest_2 = min(tnearest_2)
by huanan_flag onset_period _ID: egen nearest_3 = min(tnearest_3)
by huanan_flag onset_period _ID: egen geodist_1 = min(tdist_1)
by huanan_flag onset_period _ID: egen geodist_2 = min(tdist_2)
by huanan_flag onset_period _ID: egen geodist_3 = min(tdist_3)
by huanan_flag onset_period _ID: gen oid_id = _n
keep if oid_id == 1
drop oid_id date_caseid _PX _PY geodist_gc tnearest_* tdist_*
forvalues tt=1/3 {
  replace nearest_`tt' = . if nearest_`tt' == 9999
  replace geodist_`tt' = . if geodist_`tt' == 9999
}

* Reshape into one record per _ID and onset_period
gen huanan_label = cond(huanan_flag==1,"_linked","_unlinked")
rename onset_period t5day 
gen ldistance1 = max(0,log(geodist_1))
gen ldistance2 = max(0,log(geodist_2))
gen ldistance3 = max(0,log(geodist_3))
keep _ID t5day huanan_label ldistance* nearest_*
reshape wide ldistance* nearest*, i(_ID t5day) j(huanan_label) string

* Compute lagged values of key variables
xtset _ID t5day, daily delta(5)
foreach ilabel in "linked" "unlinked" {
  forvalues ii = 1/3 {
  quietly gen L1_ldist`ii'_`ilabel' = L1.ldistance`ii'_`ilabel'
  }
}
save "Datasets/Wuhan_narrowcore_distances_by_link_status.dta", replace
