* Identify hidden spot underneath legend
local leg_X = 114.25825
local leg_Y = 30.6192

* Create point dataset of external tests with vendor cases 
use "Datasets/external_test_locations.dta", clear
gen type_flag = 0
append using "Datasets/vendor_case_locations.dta"
replace type_flag = ncases if missing(type_flag)
expand 2 if type_flag > 0, gen(extra_flag)
replace type_flag = type_flag + 3 if extra_flag
replace _CX = `leg_X' if extra_flag
replace _CY = `leg_Y' if extra_flag				
save "Temp/cases_and_external_tests.dta", replace

* Create polygon dataset showing WHO list of live animal vendors
* along with outlines of building walls and restaurants 
* (excluding northeast outlying buildings)
import excel using "Rawdata/WHO list of wildlife shops.xlsx", ///
  clear firstrow 
gen mammal_flag = cond(missing(live_mammals), 0, 1)
merge 1:m _ID using "Maps/Huanan_market_map_shp.dta"
keep if _merge==3
append using "Maps/Huanan_main_buildings_shp.dta"
gen structure = real(substr(string(_ID),1,2))
drop if inlist(structure,30,31,44) ///
      | inlist(_ID,1001030,1001031,1001044)
gen type_flag = cond(!missing(mammal_flag), 3 + mammal_flag, ///
                cond(_ID==1001029, 2, 1))
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

* Tabulate total tests per shop
quietly colorpalette HTML, global
use "Datasets/environmental_test_vendor_index.dta", replace
gen structure = real(substr(string(_ID),1,2))
drop if inlist(structure,30,31,44)
gen vnum = totpos + totneg
gen vclass = cond(inlist(vnum,1,2), 1, ///
             cond(vnum < 5, 3, ///
             cond(inrange(vnum,5,10), 5, ///
			 cond(inrange(vnum,11,20), 11, ///
			 cond(inrange(vnum,21,45),vnum, .)))))
label define VCLASS 1 "1-2" 3 "3-4" 5 "5-10" 11 "11-20" 
label values vclass VCLASS			 

* Make illustrative map of tests per shop
grmap vclass ///
  using "Maps/Huanan_streamlined_map_shp.dta", ///
  id(_ID) clmethod(unique) ///
  fcolor($Gainsboro $LemonChiffon $DarkKhaki $Gold $Magenta $Red ) ///
  osize(vthin ..) ocolor(black ..) ndsize(vthin) ndocolor(black) ///
  polygon(data("Temp/enhanced_building_map_shp.dta") ///
	by(type_flag) fcolor(none ..) opattern(solid ..) legenda(on) ///
	ocolor(gray $MediumPurple $LightBlue $CadetBlue ) osize(thick medthick 0.75 thick)) ///
  point(data("Temp/cases_and_external_tests.dta") ///
    xcoord(_CX) ycoord(_CY) legenda(on) ///
	by(type_flag) ocolor(black ..) osize(medthick none ..) ///
	fcolor($Gainsboro $DarkViolet ..) ///
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
  legend(ring(0) pos(5) col(4) colfirst holes(9) colgap(3) ///
    subtitle("{bf:Swab Samples              Live Animals             Cases}", ///
	  just(left) size(vsmall)) ///
    bmargin(0 4 2 0) order(2 3 4 5 6 7 11 10 16 17 18) ///
    label(10 "Birds/Reptiles") label(11 "Mammals") ///
    label(16 " N = 1") ///
	label(17 " N = 2") ///
	label(18 " N = 3") ///
    region(lcolor(black) fcolor($White))) ///
  plotregion(margin(0 0 0 0)) name(Tests_Per_Shop, replace) 
graph export "Figures/Tests_Per_Shop.tif", replace
