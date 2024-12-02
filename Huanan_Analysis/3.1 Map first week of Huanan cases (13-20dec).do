* Identify cluster cases
use "Datasets/all_case_locations.dta", clear
sort _ID 
by _ID: gen inum = _n
by _ID: gen cluster_flag = cond(_N>1, 1, 0)
keep if inum==1
drop inum
save "Temp/huanan_clusters.dta", replace

* Identify hidden spot underneath legend
local leg_X = 114.25625
local leg_Y = 30.6192

* Tabulate number of cases for t <= 20Dec
* Note: case_flag = 0 for 13dec, 1 or 2 for cases on 20dec
use "Datasets/all_case_locations.dta", clear
gen dec20_key = cond(date <= mdy(12,20,2019), 1, 2)
sort _ID dec20_key case_idate
by _ID dec20_key: gen icase=_n
by _ID dec20_key: gen newcases=_N
keep if dec20_key==1 & icase==1
gen case_flag = cond(case_idate==1, 0, ///
                cond(case_idate==2, newcases, case_idate))
expand 2 if case_flag==2, gen(extra_flag)
replace case_flag = 2.5 if extra_flag
replace case_X = `leg_X' if extra_flag
replace case_Y = `leg_Y' if extra_flag				
drop icase
save "Temp/pre20dec_huanan_cases.dta", replace

* Keep west-side stalls 
use "Maps/Huanan_market_map_index.dta"
keep if building=="West"
keep _ID
merge 1:m _ID using "Maps/Huanan_market_map_shp.dta"
keep if _merge==3
drop _merge
sort _ID shape_order
save "Temp/western_vendor_map_shp.dta", replace

* Create polygon dataset combining raccoon dog stalls 
* with map of west building and restaurants 
use "Datasets/raccoondog_dna_locations_shp.dta", clear
replace _ID = 123456
replace shape_order = _n
append using "Maps/Huanan_main_buildings_shp.dta"
keep if inlist(_ID,1001001,1001029,123456)
gen type_flag = cond(_ID==1001001, 0, cond(_ID==1001029, 1, 2))
sort _ID shape_order
save "Temp/enhanced_building_map_shp.dta", replace

* Prepare compass arrow and scalebar segments
clear
input _ID _X1 _Y1 _X2 _Y2 
  0 114.25705 30.6201 114.25705 30.62035
  1 114.25679 30.61898 114.25639 30.61898
  2 114.25679 30.61898 114.25719 30.61898
  end
save "Temp/huanan_compass_scale.dta", replace

* Prepare labels for restaurants, buildings, compass & scalebar
clear
input keyflag _CX _CY
  1 114.25710 30.61914
  2 114.25641 30.62031
  3 114.25705 30.62035
  4 114.25639 30.61894
  5 114.25679 30.61894
  6 114.25719 30.61894
  end
gen labeltxt = cond(keyflag==1, "{bf:Restaurants}", ///
               cond(keyflag==2, "{bf:West Building}", ///
               cond(keyflag==3, "{bf:North}", ///
			   cond(keyflag==4, "0", ///
			   cond(keyflag==5, "25m", "50m")))))
save "Temp/huanan_labels.dta", replace

* Make illustrative maps showing new cases for each date  
quietly colorpalette HTML, global
use "Maps/Huanan_market_map_index.dta"
keep if building=="West"
merge 1:1 _ID using "Temp/huanan_clusters.dta"
drop _merge
gen map_flag = cond(cluster_flag==1, 1, 0)
grmap map_flag ///
  using "Temp/western_vendor_map_shp.dta", ///
  id(_ID) clmethod(unique) ///
  fcolor(none $PaleGreen) osize(vthin ..) ocolor(black ..) ///
  polygon(data("Temp/enhanced_building_map_shp.dta") ///
	by(type_flag) fcolor(none none) ///
	ocolor(gray $Green $Blue) osize(thick medthick medthick)) ///
  label(data("Temp/huanan_labels.dta") ///
	xcoord(_CX) ycoord(_CY) label(labeltxt) ///
	by(keyflag) length(18 24 12 5 5 5) ///
	pos(10 12 ..) angle(12 12 0 ..) gap(-1 0 ..) ///
	size(small medsmall medsmall small ..) ///
	color($Green $DodgerBlue ..)) ///
  arrow(data("Temp/huanan_compass_scale.dta") ///
	by(_ID) direction(1 1 2) lsize(medium thin thin) ///
	hsize(vlarge vsmall vsmall) hbarbsize(vlarge medium medium) ///
	hangle(30 80 80) hosize(thick thick vvthick) ///
	lcolor($DodgerBlue $DodgerBlue $DodgerBlue) hfcolor($Blue none)) ///
  point(data("Temp/pre20dec_huanan_cases.dta") ///
    xcoord(case_X) ycoord(case_Y) legenda(on) ///
	by(case_flag) fcolor($Magenta $DarkViolet ..) ///
	shape(diamond circle ..) size(0.5 0.6 1.1 1.6) ocolor(none ..)) ///
  legend(ring(0) pos(7) col(1) colfirst bmargin(5 0 9 0) ///
	order(7 8 9 3 6) ///
	title("{bf:New Confirmed Cases}", ///
	       size(vsmall) pos(11) justification(left)) ///
	label(7 "11-13 Dec {it:(N=1)}") ///
	label(8 "14-20 Dec {it:(N=1)}") ///
	label(9 "14-20 Dec {it:(N=2)}") ///
	label(3 "{it:Cluster Shop}") ///
	label(6 "{it:Raccoon Dog DNA}") ///
    region(lcolor(black) fcolor($White))) ///
  plotregion(margin(0 2 2 0)) ///		
  name(case_map_asof20Dec, replace)
graph export "Figures/Casemap_asof20Dec.tif", replace	
  
