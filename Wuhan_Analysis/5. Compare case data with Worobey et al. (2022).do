* Import case data from Worobey et al. (2022)
clear
import delimited ///
  using "Rawdata/Worobey_et_al_2022_case_data.csv", delim(",") 
duplicates drop longitude latitude, force  
gen worobey_flag = 1
gen linked_flag = cond(huanan_linked=="TRUE",1,0)
save "Datasets/Worobey_et_al_2022_case_data.dta", replace

* Append to WHO data
use "Datasets/Wuhan_case_data.dta", clear
gen worobey_flag = 0
append using "Datasets/Worobey_et_al_2022_case_data.dta"
replace worobey_flag = 1 if missing(worobey_flag)
replace _X = longitude if missing(_X)
replace _Y = latitude if missing(_Y)
save "Datasets/Case_data_comparison.dta", replace

* Compare geocoordinates
use "Maps/gadm41_Wuhan_index.dta", clear
grmap _ID using "Maps/gadm41_Wuhan_shp.dta", ///
  id(_ID) legend(off) ocolor(black) fcolor(none) ///
  point(data("Datasets/Case_data_comparison.dta") ///
        xcoord(_X) ycoord(_Y) by(worobey_flag) ///
		size(0.6 0.4) shape(square circle) ///
		fcolor(none none) ocolor(blue green)) ///
  name(Worobey_comparison, replace)

* Identify key points in Worobey data
use "Maps/gadm41_Wuhan_index.dta", clear
grmap _ID using "Maps/gadm41_Wuhan_shp.dta", ///
  id(_ID) legend(off) ocolor(black) fcolor(none) ///
  label(data("Datasets/Case_data_comparison.dta") ///
        xcoord(_X) ycoord(_Y) select(keep if worobey_flag==1) ///
		by(linked_flag) label(id) size(1 1) color(blue red)) ///
  name(Worobey_cases, replace)