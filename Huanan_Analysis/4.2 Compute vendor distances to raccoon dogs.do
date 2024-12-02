* Tabulate list of raccoon dog stalls
use "Datasets/raccoondog_dna_locations_index.dta", clear
rename _ID raccoondog_ID
destring _CX, replace
destring _CY, replace
rename _CX RD_CX 
rename _CY RD_CY 
gen raccoondog_vendornum = _n
keep raccoondog_vendornum raccoondog_ID RD_CX RD_CY
local num_rd_vendors = _N
save "Temp/raccoondog_vendor_list.dta", replace

* Expand dimensions and merge with raccoondog stalls so that
* every stall is paired with every raccoondog stall
use "Maps/Huanan_market_map_index.dta", clear
expand `num_rd_vendors'
sort _ID 
by _ID: gen raccoondog_vendornum = _n
merge m:1 raccoondog_vendornum ///
  using "Temp/raccoondog_vendor_list.dta"

* Compute distance between each stall to each raccoondog stall 
geodist _CY _CX RD_CY RD_CX, gen(geodist_RD) 
  
* For each stall, find nearest raccoondog stall
sort _ID geodist_RD
by _ID: gen idt = _n
by _ID: gen tnearest_1 = cond(_n==1, raccoondog_ID, 9999) 
by _ID: gen tdist_1 = cond(_n==1, geodist_RD, 9999) 
by _ID: egen vendorid_nearestRD = min(tnearest_1)
by _ID: egen geodist_nearestRD = min(tdist_1)
replace vendorid_nearestRD = . if vendorid_nearestRD==9999
replace geodist_nearestRD = . if geodist_nearestRD==9999
keep if idt==1

* Now expand to time dimension  
expand 4
sort _ID 
by _ID: gen idate = _n
keep _ID idate vendorid_nearestRD geodist_nearestRD _CX _CY 
save "Datasets/Huanan vendor-raccoondog distances.dta", ///
  replace

* Make illustrative map
use "Datasets/Huanan vendor-raccoondog distances.dta", clear
gen neg_dist = -geodist_nearestRD
grmap neg_dist if idate==1 ///
    using "Maps/Huanan_market_map_shp.dta", ///
    id(_ID) clmethod(quantile) clnumber(9) ///
    ocolor(none ..) fcolor(YlOrRd) ///
    line(data("Maps/Huanan_market_map_shp.dta") color(black)) ///
	point(data("Temp/raccoondog_vendor_list.dta") ///
	      xcoord(RD_CX) ycoord(RD_CY) ///
		  shape(circle) size(0.75) fcolor(magenta) ocolor(none)) ///
    legend(off) name(Huanan_raccoondog_distances, replace)
graph export "Figures/Vendor Distance to RaccoonDogs.tif", replace  
