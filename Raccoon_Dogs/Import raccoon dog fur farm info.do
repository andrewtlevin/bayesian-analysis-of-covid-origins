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
drop if missing(state_name) & missing(farm_pct)
gen farm_flag = cond(state_name=="Hebei", 1, ///
                cond(state_name=="Shandong", 2, ///
                cond(state_name=="Heilongjiang", 3, ///
                cond(state_name=="Henan", 4, ///
                cond(state_name=="Jiangsu", 5, ///
                cond(state_name=="Jilin", 6, ///
                cond(state_name=="Liaoning", 7, 8))))))) 
label define FARM_FLAG ///
   1 "Hebei (62%)" 2 "Shandong (22%)" 3 "Heilongjiang (10%)" ///
   4 "Henan (~1%)" 5 "Jiangsu (~1%)" 6 "Jilin (~1%)" 7 "Liaoning (~1%)" 
label values farm_flag FARM_FLAG
merge 1:1 _ID using "Datasets/gadm41_CHN_1_index.dta"
drop if _merge < 3
drop _merge
sort _ID
save "Datasets/Raccoon Dog Fur Farms.dta", replace
