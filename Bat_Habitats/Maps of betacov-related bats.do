* Zoom chiroptera shapefile to eastern hemisphere
use "Datasets/Chiroptera_betacov_adj_shp.dta", clear
replace _X = 112 if _X < 112 | (_X < 120 & _Y > -70)
replace _Y = -160 if _Y < -160 
save "Temp/IUCN_betacovs_easternhemisphere_shp.dta", replace

* Zoom chiroptera shapefile to southern Asia
use "Datasets/Chiroptera_betacov_shp.dta", clear
replace _X = 170 if _X < 170
replace _X = 230 if _X > 230 & !missing(_X)
replace _Y = -80 if _Y > -80 & !missing(_Y)
replace _Y = -140 if _Y < -140 
save "Temp/IUCN_betacovs_southernasia_shp.dta", replace
  
* Add PRC provincial borders to shapefile of southern Asia borders
use "Datasets/gadm41_CHN_1_streamlined_shp.dta", clear
replace _ID = _ID + 10000
gen PRC_flag = 1
append using "Datasets/gadm41_southern_asia_borders_shp.dta"
replace PRC_flag = 0 if missing(PRC_flag)
save "Temp/southern_asia_PRC_borders_shp.dta", replace

* Create label for Wuhan
use "Datasets/gadm41_CHN_2_geocenters.dta", clear
keep if NAME_1=="Hubei" & NAME_2=="Wuhan"
gen wuhan_label = "{bf:Wuhan}"
save "Temp/Wuhan_label.dta", replace

* Make global map of merbeco viruses
quietly colorpalette HTML, global
use "Datasets/Chiroptera_betacov_index.dta", clear
grmap merbeco_flag ///
  using "Datasets/Chiroptera_betacov_adj_shp.dta", ///
  id(_ID) clmethod(unique) polyfirst ///
  fcolor(none teal) ocolor(none none) ///
  polygon(data("Datasets/gadm41_world_streamlined_shp.dta") ///
          fcolor(eggshell) ocolor(black) osize(vthin)) ///
  plotregion(margin(0 0 0 -5)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(IUCN_merbeco_map, replace)		  
graph export "Figures/merbeco_map.tif", replace  

* Map SARS-related bats in eastern hemisphere
use "Datasets/Chiroptera_betacov_index.dta", clear
grmap sarbeco_flag ///
  using "Temp/IUCN_betacovs_easternhemisphere_shp.dta", ///
  id(_ID) clmethod(unique) fcolor(none maroon) ///
  ocolor(none none) polyfirst ///
  polygon(data("Datasets/gadm41_eastern_hemisphere_shp.dta") ///
          fcolor(eggshell) ocolor(black) osize(vthin)) ///
  plotregion(margin(-5 0 0 -5)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(sars_bats_eastern_hemisphere, replace)
graph export "Figures/sarbeco_map2.tif", replace  

* Map COVID-related bats in southeast asia
quietly colorpalette HTML, global
use "Datasets/Chiroptera_betacov_index.dta", clear
grmap sarscov2r_flag using "Temp/IUCN_betacovs_southernasia_shp.dta", ///
  id(_ID) clmethod(unique) fcolor(none cranberry) legend(off) ///
  ocolor(none none) polyfirst ///
  polygon(data("Temp/southern_asia_PRC_borders_shp.dta") ///
       by(PRC_flag) fcolor(eggshell ..) ocolor(black gray) osize(thin vvthin)) ///
  line(data("Datasets/gadm41_CHN_2_streamlined_shp.dta") ///
    select(keep if _ID==161) color($Blue)) ///
  label(data("Temp/Wuhan_label.dta") ///
        xcoord(_CX) ycoord(_CY) label(wuhan_label) ///
		pos(12) color($Blue) size(tiny)) ///	   
  plotregion(margin(-20 -15 -5 -10)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(covid_bats_southern_asia, replace)  
graph export "Figures/sarscov2r_map2.tif", replace  
  
