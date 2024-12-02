* Tabulate index of bats carrying betacoronaviruses
import excel ///
  using "Excel/IUCN Data on Bats with Betacoronaviruses.xlsx", ///
  clear firstrow case(preserve)
tab extant_status
sort _ID
save "Datasets/Chiroptera_betacov_index.dta", replace

* Use IUCN information to produce shapefile for range of Mops plicata in India
* (since IUCN range shapefile only has a circular label for each India state)
import excel ///
  using "Excel/IUCN Range of M. plicata & R. pusillus in India.xlsx", ///
  clear firstrow case(preserve)
merge 1:m _ID using "Datasets/gadm41_IND_1_streamlined_shp.dta"
keep if _merge==3
sort _ID shape_order
replace shape_order = _n
replace _ID = 633 if rhinolophus_pusillus==1
replace _ID = 1136 if rhinolophus_pusillus==0 & mops_plicata==1
expand 2 if rhinolophus_pusillus==1 & mops_plicata==1, gen(new_flag)
replace _ID = 1136 if new_flag
replace shape_order = 1000000 + shape_order if new_flag
sort _ID shape_order
keep _ID shape_order _X _Y
save "Temp/mplicata_rpusillus_India_range_shp.dta", replace

* Illustrative map
use "Datasets/gadm41_IND_1_streamlined_index.dta", clear
grmap _ID using "Datasets/gadm41_IND_1_streamlined_shp.dta", ///
  id(_ID) clmethod(unique) fcolor(eggshell ..) legend(off) ///
  polygon(data("Temp/mplicata_rpusillus_India_range_shp.dta") ///
          by(_ID) fcolor(green blue) ocolor(none ..)) ///
  name(test_map, replace)

* Import shapefile for bats carrying betacovs, 

import delimited ///
  using "Excel/IUCN Shapefile for Bats with Betacoronaviruses.csv", ///
  clear delim(",") varnames(1) case(preserve) asdouble

* Remove polar regions and switch to Mercator projection
sort _ID shape_order
by _ID: egen max_y = max(_Y)
drop if max_y < -55
replace _Y = -55 if _Y < -55
replace _Y = 65 if _Y > 65
rename _X longitude
rename _Y latitude
geo2xy latitude longitude, gen(_Y _X)
sort _ID shape_order
keep _ID shape_order _X _Y 

* Substitute India state-level range for R. pusillus & M. plicata 
drop if inlist(_ID, 633, 1136) & _X < 198 & _Y > -120
drop if _ID==633 & _ID[_n-1]==633 & missing(_X) & missing(_X[_n-1])
drop if _ID==1136 & _ID[_n-1]==1136 & missing(_X) & missing(_X[_n-1])
append using "Temp/mplicata_rpusillus_India_range_shp.dta"

* Save shapefile dataset
drop shape_order
gen shape_order = _n
sort _ID shape_order
save "Datasets/Chiroptera_betacov_adj_shp.dta", replace  
