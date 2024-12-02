* Geocoordinates of Huanan Market (H) and Hankou Rail Station (R) 
local _HX = 114.2573
local _HY =  30.6197
local _WX = 114.3454
local _WY = 30.5415	

* Remove non-initial cluster cases
use "Datasets/Wuhan_narrowcore_cases.dta", clear
sort cluster onset_period
by cluster: gen drop_flag = cond(_n==1 | missing(cluster), 0, 1)
list cluster onset_period _ID caseid drop_flag if !missing(cluster)
drop if drop_flag==1
count
save "Datasets/Wuhan_non-cluster_narrowcore_cases.dta", replace

* Tabulate cases by gridcell and onset date
* Note: for each gridcell and onset date, 
*       _PX and _PY are averaged across cases (only relevant when 
*       a gridcell has multiple cases on a given onset date) 
use "Datasets/Wuhan_non-cluster_narrowcore_cases.dta", clear    
rename _PX case_X
rename _PY case_Y
gen linked_case = cond(huanan_flag==1,1,0)
gen unlinked_case = cond(huanan_flag==0,1,0)
sort _ID onset_period 
by _ID onset_period: gen icount = _n
by _ID onset_period: gen ncount = _N
by _ID onset_period: egen linked_count = total(linked_case) 
by _ID onset_period: egen unlinked_count = total(unlinked_case) 
by _ID onset_period: egen _PX = mean(case_X)
by _ID onset_period: egen _PY = mean(case_Y)
keep if icount==1
drop case_* huanan_linked notes ///
     icount linked_case unlinked_case yangtze_side
sort onset_period _ID 
by onset_period: gen date_caseid = _n
save "Temp/narrowcore_cases_by_date.dta", replace

* Merge gridfile with Yangtze River eastbank indicator and then 
* expand grid to generate a complete set of cells at each onset date
use "Maps/Wuhan_narrowcore_popdensity.dta", clear
merge m:1 _ID using "Maps/Wuhan_eastbank_flag.dta" 
keep if _merge==3
drop _merge
keep _ID _CX _CY pop_density eastbank_flag
expand 5
sort _ID
by _ID: gen onset_period = cond(_n==1, mdy(12,11,2019), ///
                           cond(_n==2, mdy(12,16,2019), ///
						   cond(_n==3, mdy(12,21,2019), ///
						   cond(_n==4, mdy(12,26,2019), mdy(12,31,2019)))))
merge 1:1 _ID onset_period using "Temp/narrowcore_cases_by_date.dta"
replace ncount = 0 if missing(ncount)
replace linked_count = 0 if missing(linked_count)
replace unlinked_count = 0 if missing(unlinked_count)
gen case_flag = cond(ncount > 0, 1, 0)
gen linked_flag = cond(linked_count > 0, 1, 0)
gen unlinked_flag = cond(unlinked_count > 0, 1, 0)
drop _merge date_caseid _PX _PY huanan_flag 
order _ID onset_period case_flag ncount pop_density

* For each onset date, tabulate total number of positive gridcells 
* and expand grid to three dimensions (Onset_Date, _ID, CaseID)
sort onset_period _ID
by onset_period: egen totcase_date = total(case_flag)
expand totcase_date
sort onset_period _ID
by onset_period _ID: gen date_caseid = _n
merge m:1 onset_period date_caseid ///
  using "Temp/narrowcore_cases_by_date.dta"
drop _merge huanan_flag 
sort _ID onset_period date_caseid
order _ID onset_period date_caseid _CX _CY pop_density case_flag ncount

* For each gridcell, compute distance from key Wuhan locations
geodist _CY _CX `_HY' `_HX', gen(geodist_huanan) 
geodist _CY _CX `_WY' `_WX', gen(geodist_wiv) 
geodist _CY _CX _PY _PX, gen(geodist_gc)

* For each gridcell & onset date, compute distance from 3 nearest cases
sort onset_period _ID geodist_gc
by onset_period _ID: gen tnearest_1 = cond(_n==1, date_caseid, 9999) 
by onset_period _ID: gen tdist_1 = cond(_n==1, geodist_gc, 9999) 
by onset_period _ID: gen tnearest_2 = cond(_n==2, date_caseid, 9999) 
by onset_period _ID: gen tdist_2 = cond(_n==2, geodist_gc, 9999) 
by onset_period _ID: gen tnearest_3 = cond(_n==3, date_caseid, 9999) 
by onset_period _ID: gen tdist_3 = cond(_n==3, geodist_gc, 9999) 
by onset_period _ID: egen nearest_1 = min(tnearest_1)
by onset_period _ID: egen nearest_2 = min(tnearest_2)
by onset_period _ID: egen nearest_3 = min(tnearest_3)
by onset_period _ID: egen geodist_1 = min(tdist_1)
by onset_period _ID: egen geodist_2 = min(tdist_2)
by onset_period _ID: egen geodist_3 = min(tdist_3)
by onset_period _ID: gen oid_id = _n
keep if oid_id == 1
drop oid_id date_caseid _PX _PY geodist_gc tnearest_* tdist_*
forvalues tt=1/3 {
  replace nearest_`tt' = . if nearest_`tt' == 9999
  replace geodist_`tt' = . if geodist_`tt' == 9999
}

* Compute lagged values of key variables
egen t5num = group(onset_period)
rename onset_period t5day 
xtset _ID t5day, daily delta(5)
gen lpopdensity = log(pop_density)
gen ldistance1 = log(geodist_1)
gen ldistance2 = log(geodist_2)
gen ldistance3 = log(geodist_3)
gen ldist_huanan = log(geodist_huanan)
gen ldist_wiv = log(geodist_wiv)
quietly gen L1_ldist1 = L1.ldistance1
quietly gen L1_ldist2 = L1.ldistance2
quietly gen L1_ldist3 = L1.ldistance3
save "Datasets/Wuhan_narrowcore_case_distances.dta", replace
