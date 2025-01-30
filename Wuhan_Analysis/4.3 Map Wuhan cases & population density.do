* Create replicates of cases that are only used 
* for producing larger symbols in the legend
use "Datasets/Wuhan_narrowcore_cases.dta", clear
tab huanan_flag
expand 2, gen(new_flag)
replace _PX = 114.15 if new_flag
replace _PY = 30.71 if new_flag
replace huanan_flag = -1 if new_flag
replace onset_period = onset_period + 100 if new_flag
save "Temp/Streamlined_cases.dta", replace

* Append Huanan Market location to case data
use "Maps/Wuhan_key_coordinates.dta", clear
keep if inlist(loc_num,1,3,4,5,6,8)
replace loc_label = "{bf:Wuhan CDC}" if loc_num==3
replace loc_label = "{bf:Wuhan CDC*}" if loc_num==4
replace loc_label = "{bf:Wuhan Univ.}" if loc_num==5
replace loc_label = "{bf:WIV-Wuchang}" if loc_num==6
replace loc_label = "{bf:Huazhong Univ.}" if loc_num==8
gen huanan_flag = -1
gen onset_period = -999 + loc_num
append using "Temp/streamlined_cases.dta"
save "Temp/streamlined_cases_and_coordinates.dta", replace
   
* Make illustrative map of linked cases
quietly colorpalette HTML, globals
use "Maps/Wuhan_narrowcore_popdensity.dta", clear
grmap d3_flag using "Maps/Wuhan_narrowcore_1km_grid_shp.dta", ///
   id(_ID) clmethod(unique) fcolor(Purples) ndfcolor(ltblue) ///
   osize(0 ..) ndsize(0) ///
   polygon(data("Maps/Wuhan_narrowcore_waterways_shp.dta") ///
     by(island_flag) ocolor(none none) fcolor($LightCyan $SeaShell)) ///
   point(data("Temp/Streamlined_cases_and_coordinates.dta") ///
     select(keep if inlist(huanan_flag,-1,1)) ///
     by(onset_period) legenda(on) xcoord(_PX) ycoord(_PY) ///
	 size(0.7 0.5 0.5 0.5 0.5 0.5 0.3 0.3 0.3 0.3 0.3 0.5 0.5 0.5 0.5 0.5) ///
	 shape(square diamond diamond diamond diamond diamond circle ..) ///
	 fcolor($MediumBlue $MediumBlue $MediumBlue $MediumBlue $MediumBlue $MediumBlue ///
	        $YellowGreen $Green $Gold $Orange $Crimson ///
            $YellowGreen $Green $Gold $Orange $Crimson)) ///
   label(data("Temp/Streamlined_cases_and_coordinates.dta") ///
     select(keep if inlist(loc_num,1,3,4,5,6,8)) by(loc_num) ///
	 xcoord(_PX) ycoord(_PY) label(loc_label) size(tiny ..) ///
	 color($Blue ..) gap(0 ..) length(30 ..) angle(0 ..) pos(9 3 10 6 6 6)) ///
   legend(ring(0) pos(10)  bmargin(2 0 0 4) order(16 17 18 19 20) ///
     title("{bf:Onset Period}", size(vsmall)) ///
   	 label(16 "11 Dec 2019") ///
   	 label(17 "16 Dec 2019") ///
   	 label(18 "21 Dec 2019") ///
   	 label(19 "26 Dec 2019") ///
   	 label(20 "31 Dec 2019") ///
     region(lcolor(black) fcolor(white))) ///
   plotregion(margin(-5 -12 -5 -5)) ///
   name(Wuhan_linked_cases, replace)
graph export "Figures/Wuhan Linked Cases.tif", replace

* Make illustrative map of unlinked cases
grmap d3_flag using "Maps/Wuhan_narrowcore_1km_grid_shp.dta", ///
   id(_ID) clmethod(unique) fcolor(Purples) ndfcolor(ltblue) ///
   osize(0 ..) ndsize(0) ///
   polygon(data("Maps/Wuhan_narrowcore_waterways_shp.dta") ///
     by(island_flag) ocolor(none none) fcolor($LightCyan $SeaShell)) ///
   point(data("Temp/Streamlined_cases_and_coordinates.dta") ///
     select(keep if inlist(huanan_flag,-1,0)) ///
     by(onset_period) legenda(on) xcoord(_PX) ycoord(_PY) ///
	 size(0.7 0.5 0.5 0.5 0.5 0.5 0.3 0.3 0.3 0.3 0.3 0.5 0.5 0.5 0.5 0.5) ///
	 shape(square diamond diamond diamond diamond diamond circle ..) ///
	 fcolor($MediumBlue $MediumBlue $MediumBlue $MediumBlue $MediumBlue $MediumBlue ///
	        $YellowGreen $Green $Gold $Orange $Crimson ///
            $YellowGreen $Green $Gold $Orange $Crimson)) ///
   label(data("Temp/Streamlined_cases_and_coordinates.dta") ///
     select(keep if inlist(loc_num,1,3,4,5,6,8)) by(loc_num) ///
	 xcoord(_PX) ycoord(_PY) label(loc_label) size(tiny ..) ///
	 color($Blue ..) gap(0 ..) length(30 ..) angle(0 ..) pos(9 3 10 6 6 6)) ///
   legend(ring(0) pos(10) bmargin(2 0 0 4) order(16 17 18 19 20) ///
         title("{bf:Onset Period}", size(vsmall)) ///
   	     label(16 "11 Dec 2019") ///
   	     label(17 "16 Dec 2019") ///
   	     label(18 "21 Dec 2019") ///
   	     label(19 "26 Dec 2019") ///
   	     label(20 "31 Dec 2019") ///
         region(lcolor(black) fcolor(white))) ///
   plotregion(margin(-5 -12 -5 -5)) ///
   name(Wuhan_unlinked_cases, replace)
graph export "Figures/Wuhan Unlinked Cases.tif", replace   
  
