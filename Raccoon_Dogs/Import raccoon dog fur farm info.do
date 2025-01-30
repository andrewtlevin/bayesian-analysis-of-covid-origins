* Import list of major raccoondog fur-producing cities
* and convert coordinates to Mercator projection
import excel using "Excel/Raccoon Dog Fur Farms.xlsx", ///
  clear sheet("Cities") firstrow 
drop if city_flag==0  
geo2xy _Y _X, replace
save "Datasets/Raccoon Dog Major Farm Cities.dta", replace

* Import list of raccoondog fur-producing states
* and merge with GADM41 info (excluding contested border regions)
import excel using "Excel/Raccoon Dog Fur Farms.xlsx", ///
  clear sheet("States") firstrow 
drop if missing(_ID) & missing(state_name)
gen farm_flag = cond(state_name=="Hebei", 1, ///
                cond(state_name=="Shandong", 2, ///
                cond(state_name=="Heilongjiang", 3, ///
                cond(state_name=="Jiangsu", 4, ///
                cond(state_name=="Jilin", 5, ///
                cond(state_name=="Liaoning", 6, ///
				cond(state_name=="Nei Mongol", 7, ///
				cond(state_name=="Sichuan", 8, .))))))))
label define FARM_FLAG ///
   1 "Hebei (62%)" 2 "Shandong (22%)" 3 "Heilongjiang (10%)" ///
   4 "Jiangsu (~1%)" 5 "Jilin (~1%)" 6 "Liaoning (~1%)" ///
   7 "Nei Mongol (~1%)" 8 "Sichuan (~1%)"
label values farm_flag FARM_FLAG
merge 1:1 _ID using "Datasets/gadm41_CHN_1_index.dta"
drop if _merge < 3
drop _merge
sort _ID
save "Datasets/Raccoon Dog Fur Farms.dta", replace

* Import PRC national and provincial boundaries
import excel using Shapedata/gadm41_PRC_shp.xlsx, ///
  clear firstrow case(preserve)
gen shape_order = _n
sort _ID shape_order  
geo2xy latitude longitude, gen(_Y _X)
save "Maps/gadm41_PRC_shp.dta", replace

* Import PRC provincial population in 2020
import excel using "Excel/PRC_population_by_province.xlsx", ///
  firstrow case(preserve) clear
save "Datasets/PRC_pop_by_province.dta", replace

