* Identify hidden spot underneath legend
local leg_X = 114.25825
local leg_Y = 30.6192

* Create point dataset of external tests with vendor cases 
use "Datasets/external_test_locations.dta", clear
rename _CX case_X
rename _CY case_Y
gen type_flag = 0
append using "Datasets/vendor_case_locations.dta"
replace type_flag = ncases if missing(type_flag)
expand 2 if type_flag > 0, gen(extra_flag)
replace type_flag = type_flag + 3 if extra_flag
replace case_X = `leg_X' if extra_flag
replace case_Y = `leg_Y' if extra_flag				
save "Temp/cases_and_external_tests.dta", replace

* Create polygon dataset showing shops with BOLD > 1200
* for raccoon dogs and other mammals, 
* along with outlines of building walls and restaurants 
* (excluding northeast outlying buildings)
use "Datasets/bold1200_mammal_shop_list.dta", clear
merge 1:m _ID using "Maps/Huanan_market_map_shp.dta"
keep if _merge==3
append using "Maps/Huanan_main_buildings_shp.dta"
drop if inlist(_ID,1001030,1001031,1001044)
gen type_flag = cond(rdflag==1, 4, ///
                cond(rdflag==0, 3, ///
                cond(_ID==1001029, 2, 1)))
sort _ID shape_order
save "Temp/enhanced_building_map_shp.dta", replace

* Create arrow dataset for compass and external street lanes
clear
input _ID _X1 _Y1 _X2 _Y2 
  0 114.25845 30.62020 114.25845 30.62036
  end
append using "Maps/Huanan_lane_lines_shp.dta"
replace _ID = 10 + solidline if _ID > 2
save "Temp/huanan_compass_scale_lanes.dta", replace

* Create labels for restaurants, buildings, compass & scalebar
* and then append labels for trash cart & staircase
clear
input keyflag _CX _CY
  1 114.25710 30.61914
  2 114.25645 30.620321
  3 114.25770 30.620360
  4 114.25845  30.62036
  end
gen labeltxt = cond(keyflag==1, "{bf:Restaurants}", ///
               cond(keyflag==2, "{bf:West Building}", ///
               cond(keyflag==3, "{bf:East Building}", ///
               cond(keyflag==4, "{bf:North}", ""))))
append using "Datasets/external_test_locations.dta"
replace labeltxt = "{bf:Staircase}" if env_code=="0838"
replace keyflag = _n if missing(keyflag)			   
expand 2 if env_code=="0033", gen(dup_flag)
replace _CY = _CY + 0.00001 if env_code=="0033" & dup_flag==0
replace _CY = _CY - 0.00001 if env_code=="0033" & dup_flag==1
replace labeltxt = "{bf:Trash}" if env_code=="0033" & dup_flag==0
replace labeltxt = "{bf:Cart}" if env_code=="0033" & dup_flag==1
save "Temp/huanan_labels.dta", replace

* Map tests vs. all confirmed cases 
quietly colorpalette HTML, global
use "Datasets/environmental_test_vendor_index.dta", clear
drop if inlist(_ID,30101,44101) | inrange(_ID,31100,31299)
grmap sarscov2_flag ///
  using "Maps/Huanan_streamlined_map_shp.dta", ///
  id(_ID) clmethod(unique) ///
  fcolor(none $DarkSeaGreen $LightPink) ///
  osize(vthin ..) ocolor(black ..) ndsize(vthin) ndocolor(black) ///
  polygon(data("Temp/enhanced_building_map_shp.dta") ///
	by(type_flag) fcolor(none ..) opattern(solid ..) ///
	ocolor(gray $MediumPurple $Green $Blue) osize(thick medthick ..)) ///
  point(data("Temp/cases_and_external_tests.dta") ///
    xcoord(case_X) ycoord(case_Y) legenda(on) ///
	by(type_flag) ocolor($Green none ..) osize(medthick none ..) ///
	fcolor($LightPink $DarkViolet ..) ///
	shape(square triangle circle diamond triangle circle diamond) ///
	size(0.75 0.5 0.5 0.4 1 1 1)) ///   
  label(data("Temp/huanan_labels.dta") ///
	xcoord(_CX) ycoord(_CY) label(labeltxt) ///
	by(keyflag) length(18 24 24 12 20 20) ///
	pos(10 12 12 12 9 6) angle(12 12 12 0 0 0) gap(-1 0 0 0 1 0) ///
	size(small medsmall medsmall small 1.5 1.5) ///
	color($MediumPurple $DodgerBlue $DodgerBlue $DodgerBlue $Black ..)) ///
  arrow(data("Temp/huanan_compass_scale_lanes.dta") ///
	by(_ID) direction(1 2 2) lsize(medium vthin vthin) ///
	hsize(vlarge 0 0) hbarbsize(vlarge 0 0) ///
	hangle(30 0 0) hosize(thick 0 0) ///
	hfcolor($DodgerBlue none none) ///
	lcolor($DodgerBlue $SlateGray $Gray) lpattern(solid dash solid)) ///
  legend(ring(0) pos(5) col(2) colfirst colgap(7) ///
    bmargin(0 10 0.5 0) ///
	order(- "{bf:Swab Samples}" 4 3 8 7 - "{bf:Vendor Cases}" 13 14 15) ///
	label(4 "Positive RT-qPCR") ///
	label(3 "Negative RT-qPCR") ///
	label(8 "Raccoon Dog DNA") ///
	label(7 "Other Mammal DNA") ///
	label(13 "   N = 1") ///
	label(14 "   N = 2") ///
	label(15 "   N = 3") ///
    region(lcolor(black) fcolor($White))) ///
  plotregion(margin(2 2 2 2)) name(Tests_vs_Cases, replace) 
graph export "Figures/Tests_versus_Cases.tif", replace
  
