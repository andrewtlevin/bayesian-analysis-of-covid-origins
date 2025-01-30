* Identify initial cases within narrow core of Wuhan
use "Maps/Wuhan_narrowcore_1km_grid_shp.dta", clear
keep if shape_order==1
keep _ID
count
merge 1:m _ID ///
  using "Datasets/Wuhan_gridded_cases.dta"

* List cluster cases outside narrow core of Wuhan area
list cluster onset_period _ID if _merge==2 & !missing(cluster)
  
* Drop cases outside narrow core of Wuhan area
keep if _merge==3
drop _merge
count
save "Datasets/Wuhan_narrowcore_cases.dta", replace

* Confirm that no cases are at edges of core grid
use "Maps/Wuhan_narrowcore_1km_grid_shp.dta", clear
egen topy = max(_Y)
egen boty = min(_Y)
egen leftx = min(_X)
egen rightx = max(_X)
sort _ID shape_order
gen left_flag = cond(_X==leftx, 1, 0)
gen right_flag = cond(_X==rightx, 1, 0)
gen top_flag = cond(_Y==topy, 1, 0)
gen bot_flag = cond(_Y==boty, 1, 0)
by _ID: egen left_cell = max(left_flag)
by _ID: egen right_cell = max(right_flag)
by _ID: egen top_cell = max(top_flag)
by _ID: egen bot_cell = max(bot_flag)
keep if shape_order==1 & (left_cell | right_cell | top_cell | bot_cell)
table, stat(total left_cell right_cell top_cell bot_cell)
merge m:m _ID using "Datasets/Wuhan_narrowcore_cases.dta"

