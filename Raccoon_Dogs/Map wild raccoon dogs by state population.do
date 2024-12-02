clear
use "Datasets/gadm41_CHN_2_geocenters.dta", clear
keep if NAME_1=="Hubei" & NAME_2=="Wuhan"
gen lstring = "{bf:Wuhan}"
keep lstring _CX _CY
gen wuhan_flag = 1
save "Temp/Wuhan_label.dta", replace

use "Datasets/China_pop_by_province.dta", clear
drop if NAME_1=="Macau"
replace _CX = 202 if NAME_1=="Gansu"
replace _CY = -101 if NAME_1=="Gansu"
replace _CX = 211 if NAME_1=="Hebei"
replace _CY = -95.5 if NAME_1=="Hebei"
replace _CX = 207 if NAME_1=="Hubei"
replace _CY = -104 if NAME_1=="Hubei"
replace _CY = -102 if NAME_1=="Shaanxi"
replace _CX = 212 if NAME_1=="Tianjin"
replace _CY = -97.75 if NAME_1=="Tianjin"
gen lstring = NAME_1
keep lstring _CX _CY 
append using "Temp/Wuhan_label.dta"
replace wuhan_flag = 0 if missing(wuhan_flag)
save "Temp/China_province_labels.dta", replace

* Make illustrative map
colorpalette HTML, global
use "Datasets/China_pop_by_province.dta", clear
gen pop_flag = cond(un_2020_e < 2.5e7, 1, ///
               cond(un_2020_e < 7.5e7, 2, 3)) 
grmap pop_flag using "Datasets/gadm41_CHN_1_streamlined_shp.dta", ///
  id(_ID) clmethod(unique) fcolor(YlOrRd) legend(on) ///
  osize(thin) ocolor(black) ///
  line(data("Datasets/IUCN_RaccoonDog_China_shp.dta") ///
    color(eltblue) size(vthick)) ///
  polygon(data("Datasets/gadm41_CHN_2_streamlined_shp.dta") ///
    select(keep if _ID==161) fcolor($Blue) ocolor(none)) ///
  label(data("Temp/China_province_labels.dta") ///
    xcoord(_CX) ycoord(_CY) label(lstring) ///
	by(wuhan_flag) color(black $Blue) ///
	pos(0 9) gap(0 0.6) size(tiny tiny)) ///
  legend(pos(11) bmargin(0 0 0 2) ring(0) order(2 3 4 6) ///
    title("{bf:      State Population}", size(vsmall) pos(11)) ///
	cols(2) colfirst holes(7 8) ///
    label(2 "Less than 25 million") label(3 "25-75 million") ///
	label(4 "More than 75 million") label(6 "Wild Raccoon Dogs") ///
	region(lcolor(black))) ///
  plotregion(margin(0 0 0 5)) ///
  name(China_states_raccoondog, replace)
graph export "Figures/Wild_Raccoon_Dogs.tif", replace
