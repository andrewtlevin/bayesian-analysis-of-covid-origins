* Import case data
clear
import excel ///
  using "Rawdata/Huanan Vendor Cases.xlsx", firstrow 
egen case_idate = group(date)
format date %td
save "Datasets/all_case_locations.dta", replace

* For stalls with multiple cases, only keep first case
use "Datasets/all_case_locations.dta", clear
sort _ID case_idate
by _ID: gen icase = _n
by _ID: gen ncases = _N
keep if icase==1
drop icase
sort _ID
tab ncases
gen dec20_key = cond(case_idate<=2 , 1, 2)
label define DEC20_KEY 1 "11-20Dec2019" 2 "21-31Dec2019"
label values dec20_key DEC20_KEY
save "Datasets/vendor_case_locations.dta", replace

* Map showing total number of cases per vendor
use "Datasets/vendor_case_locations.dta", clear
grmap ncases using "Maps/Huanan_market_map_shp.dta", ///
  id(_ID) clmethod(unique) fcolor(purple orange cranberry) ///
  ocolor(black ..) ///
  polygon(data("Maps/Huanan_market_map_shp.dta") ///
          ocolor(black) fcolor(none)) ///
  legend(on) name(Cases_by_Stall, replace) 
graph export "Figures/Huanan vendors with multiple cases.tif", replace  
  
* Maps showing new cases for each date  
local date_list = "Dec13 Dec20 Dec27 Dec31"
local color_list = "green purple orange red"
use "Maps/Huanan_market_map_index.dta", clear
forvalues idate = 1/4 {
  local fcolor = word("`color_list'", `idate')
  local datetxt = word("`date_list'", `idate')
  grmap _ID using "Maps/Huanan_market_map_shp.dta", ///
    id(_ID) clmethod(quantile) fcolor(none ..) ocolor(black ..) ///
    point(data("Datasets/vendor_case_locations.dta") ///
      xcoord(case_X) ycoord(case_Y) ///
	  fcolor(`fcolor') ocolor(none) shape(circle) size(0.75) ///
	  select(keep if case_idate==`idate')) ///
    legend(off) name(New_Cases_as_of_`datetxt', replace)
  graph export "Figures/Huanan cases as of `datetxt'.tif", replace
}

