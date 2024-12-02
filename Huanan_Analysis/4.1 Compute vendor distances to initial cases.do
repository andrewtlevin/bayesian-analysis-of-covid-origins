* Count number of cases and cumulate list of case IDs
* Note: this only includes first case at vendors with multiple cases
use "Datasets/vendor_case_locations.dta", clear
local case_list = string(case_id[1],"%2.0f")
local ncases = _N
forvalues icase = 2/`ncases' {
  local case_list = "`case_list'" + " "  + string(case_id[`icase'],"%2.0f")
}
rename _ID casemap_ID
save "Temp/market_cases_with_casemap_IDs.dta", replace

* Import list of vacant stalls
import excel using "Rawdata/Huanan vacant stalls.xlsx", ///
  clear firstrow case(preserve)
drop building vstreet  
save "Maps/vacant_stalls_index.dta", replace

* Remove vacant stalls from index
use "Maps/Huanan_market_map_index.dta", clear
merge 1:1 _ID using "Maps/vacant_stalls_index.dta"
drop if _merge == 3
drop _merge 

* Expand dimensions and merge with initial case data so that
* each vendor at each date is paired with every initial case
expand `ncases'
sort _ID 
gen case_id = .
forvalues icase = 1/`ncases' {
  local case_id = word("`case_list'",`icase')
  by _ID: replace case_id = `case_id' if _n == `icase'
}
expand 4
sort _ID case_id
by _ID case_id: gen idate = _n
merge m:1 case_id ///
  using "Temp/market_cases_with_casemap_IDs.dta"
keep _ID _CX _CY idate case_id case_idate casemap_ID case_X case_Y  

* Flag vendors at dates where a new case occurred at that date
* and then identify 
gen case_tflag = cond(_ID==casemap_ID & idate==case_idate, 1, 0)
sort _ID idate
by _ID idate: egen case_flag = total(case_tflag)

* Compute distance between each vendor and each initial case at each date
geodist _CY _CX case_Y case_X if idate==case_idate, gen(geodist_GC) 
keep _ID idate _CY _CX case_flag case_id case_idate geodist_GC case_X case_Y

* For each gridcell and each date, find closest case
sort _ID idate geodist_GC
by _ID idate: gen idt = _n
by _ID idate: gen tnearest_1 = cond(_n==1, case_id, 9999) 
by _ID idate: gen tdist_1 = cond(_n==1, geodist_GC, 9999) 
by _ID idate: egen caseid_near1 = min(tnearest_1)
by _ID idate: egen geodist_near1 = min(tdist_1)
replace caseid_near1 = . if caseid_near1==9999
replace geodist_near1 = . if geodist_near1==9999
keep if idt==1
keep _ID idate case_flag caseid_near1 geodist_near1 _CX _CY case_X case_Y 

* Create lagged variables
gen ddate = cond(idate==4, mdy(12,31,2019), mdy(12,6,2019) + 7*idate)
format ddate %td
xtset _ID idate, daily
gen lgeodist_near1 = log(geodist_near1)
gen lag1_dist1 = L1.geodist_near1
gen lag1_ldist1 = L1.lgeodist_near1
gen lag2_dist1 = L2.geodist_near1
gen lag2_ldist1 = L2.lgeodist_near1
xtset, clear
save "Datasets/Huanan vendor-case distances.dta", replace

* Make illustrative map of stall-case distances
local date_vec = "20dec2019 27dec2019"
use "Datasets/Huanan vendor-case distances.dta", clear
gen neg_dist = -geodist_near1
forvalues jdate = 1/2 {
  local date_txt = word("`date_vec'",`jdate')	
  local idate = `jdate' + 1
  grmap neg_dist if idate==`idate' ///
    using "Maps/Huanan_market_map_shp.dta", ///
    id(_ID) clmethod(quantile) clnumber(16) ///
    ocolor(none ..) fcolor(Heat) ///
    line(data("Maps/Huanan_market_map_shp.dta") color(black)) ///
	point(data("Datasets/vendor_case_locations.dta") ///
	      xcoord(case_X) ycoord(case_Y) ///
		  shape(circle) size(0.75) fcolor(blue) ocolor(none) ///
		  select(keep if case_idate==`idate')) ///
    legend(off) name(Huanan_distances_`date_txt', replace)
  graph export ///
    "Figures/Vendor distance from prior cases as of `date_txt'.tif", replace
}

