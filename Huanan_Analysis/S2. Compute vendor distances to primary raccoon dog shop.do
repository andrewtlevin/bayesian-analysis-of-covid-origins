* Keep info for primary raccoon dog shop (Street 6/29-31-33)
use "Datasets/raccoondog_dna_locations_index.dta", clear
keep if _ID == 11104
rename _ID raccoondog_ID
destring _CX, replace
destring _CY, replace
rename _CX RD_CX 
rename _CY RD_CY 
keep raccoondog_ID RD_CX RD_CY
gen RD_num = 1
save "Temp/primary_raccoondog_shop.dta", replace

* Compute distance of each Huanan vendor from raccoondog shop
use "Maps/Huanan_market_map_index.dta", clear
gen RD_num = 1
merge m:1 RD_num using "Temp/primary_raccoondog_shop.dta"
geodist _CY _CX RD_CY RD_CX, gen(geodist_RD629) 
  
* Now expand to time dimension  
expand 4
sort _ID 
by _ID: gen idate = _n
keep _ID idate geodist_RD629 _CX _CY 
save "Datasets/Huanan vendor to RD629 distances.dta", replace

* Make illustrative map
use "Datasets/Huanan vendor to RD629 distances.dta", clear
gen neg_dist = -geodist_RD629
grmap neg_dist if idate==1 ///
    using "Maps/Huanan_market_map_shp.dta", ///
    id(_ID) clmethod(quantile) clnumber(9) ///
    ocolor(none ..) fcolor(YlOrRd) ///
    line(data("Maps/Huanan_market_map_shp.dta") color(black)) ///
	point(data("Temp/primary_raccoondog_shop.dta") ///
	      xcoord(RD_CX) ycoord(RD_CY) ///
		  shape(circle) size(0.75) fcolor(magenta) ocolor(none)) ///
    legend(off) name(Huanan_RD629_distances, replace)
graph export "Figures/Vendor Distances to Primary Raccoon Dog Shop.tif", replace  
