clear
use "Datasets/Raccoon Dog Major Farm Cities.dta", clear
keep if city_name=="Wuhan"
rename _X _CX
rename _Y _CY
save "Temp/Wuhan_location.dta", replace
gen lstring = "{bf:Wuhan}"
keep lstring _CX _CY
gen wuhan_flag = 1
save "Temp/Wuhan_label.dta", replace

use "Datasets/PRC_pop_by_province.dta", clear
drop if province=="Macau"
replace _CX = 202 if province=="Gansu"
replace _CY = -101 if province=="Gansu"
replace _CX = 211 if province=="Hebei"
replace _CY = -95.5 if province=="Hebei"
replace _CX = 207 if province=="Hubei"
replace _CY = -104 if province=="Hubei"
replace _CY = -102 if province=="Shaanxi"
replace _CX = 212 if province=="Tianjin"
replace _CY = -97.75 if province=="Tianjin"
gen lstring = province
keep lstring _CX _CY 
append using "Temp/Wuhan_label.dta"
replace wuhan_flag = 0 if missing(wuhan_flag)
save "Temp/China_province_labels.dta", replace

* Make illustrative map
colorpalette HTML, global
use "Datasets/PRC_pop_by_province.dta", clear
gen pop_flag = cond(pop_2020 < 2.5e7, 1, ///
               cond(pop_2020 < 7.5e7, 2, 3)) 
grmap pop_flag using "Maps/gadm41_PRC_shp.dta", ///
  id(_ID) clmethod(unique) fcolor(YlOrRd) legend(on) ///
  osize(thin) ocolor(black) ///
  line(data("Datasets/IUCN_RaccoonDog_China_shp.dta") ///
    color(eltblue) size(vthick)) ///
  point(data("Temp/Wuhan_location.dta") ///
    xcoord(_CX) ycoord(_CY) ///
    shape(circle) size(small) fcolor($Blue) ocolor(none)) ///
  label(data("Temp/China_province_labels.dta") ///
    xcoord(_CX) ycoord(_CY) label(lstring) ///
	by(wuhan_flag) color(black $Blue) ///
	pos(0 9) gap(0 0.6) size(tiny tiny)) ///
  legend(pos(11) bmargin(0 0 0 2) ring(0) order(2 3 4 5) ///
    title("{bf:   Province Population}", size(vsmall) pos(11)) ///
	cols(2) colfirst holes(6 7) ///
    label(2 "Less than 25 million") label(3 "25-75 million") ///
	label(4 "More than 75 million") label(5 "Wild Raccoon Dogs") ///
	region(lcolor(black))) ///
  plotregion(margin(0 0 0 5)) ///
  name(PRC_wild_raccoondogs, replace)
graph export "Figures/Wild_Raccoon_Dogs.tif", replace
