* Identify cluster cases
use "Datasets/all_case_locations.dta", clear
sort _ID 
by _ID: gen inum = _n
by _ID: gen cluster_flag = cond(_N>1, 1, 0)
keep if inum==1
drop inum
save "Temp/huanan_clusters.dta", replace

* Tabulate number of cases for t >= 21Dec
* Note: case_flag = 1 for 27dec, 2 for 31dec 
use "Datasets/all_case_locations.dta", clear
keep if date >= mdy(12,21,2019)
rename case_idate case_flag
save "Temp/post20dec_huanan_cases.dta", replace

* Create polygon dataset combining raccoon dog stalls 
* with map of building walls and restaurants 
* (excluding northeast outlying buildings)
use "Datasets/raccoondog_dna_locations_shp.dta", clear
replace _ID = 123456
replace shape_order = _n
append using "Maps/Huanan_main_buildings_shp.dta"
gen structure = real(substr(string(_ID),1,2))
drop if inlist(structure,30,31,44) ///
      | inlist(_ID,1001030,1001031,1001044)
gen type_flag = cond(_ID==123456, 3, cond(_ID==1001029, 2, 1))
sort _ID shape_order
save "Temp/enhanced_building_map_shp.dta", replace

* Prepare compass and scale and then append street lane lines
clear
input _ID _X1 _Y1 _X2 _Y2 
  0 114.25845 30.62020 114.25845 30.62036
  1 114.25792 30.6190 114.25740 30.6190
  2 114.25792 30.6190 114.25844 30.6190
  end
append using "Maps/Huanan_lane_lines_shp.dta"
replace _ID = 10 + solidline if _ID > 2
save "Temp/huanan_compass_scale_lanes.dta", replace

* Prepare labels for restaurants, buildings, compass & scalebar
clear
input keyflag _CX _CY
  1 114.25710 30.61914
  2 114.25645 30.620321
  3 114.25770 30.620360
  4 114.25845 30.62036
  5 114.25740 30.61902
  6 114.25790 30.61902
  7 114.25840 30.61902
  end
gen labeltxt = cond(keyflag==1, "{bf:Restaurants}", ///
               cond(keyflag==2, "{bf:West Building}", ///
               cond(keyflag==3, "{bf:East Building}", ///
               cond(keyflag==4, "{bf:North}", ///
			   cond(keyflag==5, "{bf:0}", ///
			   cond(keyflag==6, "{bf:50m}", "{bf:100m}"))))))
save "Temp/huanan_labels.dta", replace

* Make illustrative map showing new cases during 21-31 Dec 2019
quietly colorpalette HTML, global
use "Maps/Huanan_market_map_index.dta", clear
drop if inlist(structure,30,31,44)
merge 1:1 _ID using "Temp/huanan_clusters.dta"
gen map_flag = cond(cluster_flag==1, 1, 0)
grmap map_flag ///
  using "Maps/Huanan_streamlined_map_shp.dta", ///
  id(_ID) clmethod(unique) ///
  fcolor(none $PaleGreen) ///
  osize(vthin ..) ocolor(black ..) ndsize(vthin) ndocolor(black) ///
  polygon(data("Temp/enhanced_building_map_shp.dta") ///
	by(type_flag) fcolor(none ..)  ///
	ocolor(gray $Green $Blue) osize(thick medthick medthick)) ///
  label(data("Temp/huanan_labels.dta") ///
	xcoord(_CX) ycoord(_CY) label(labeltxt) ///
	by(keyflag) length(18 24 24 12) ///
	pos(10 12 ..) angle(12 12 12) gap(-1 0 ..) ///
	size(small medsmall medsmall small ..) ///
	color($Green $DodgerBlue ..)) ///
  arrow(data("Temp/huanan_compass_scale_lanes.dta") ///
	by(_ID) direction(1 1 2 ..) lsize(medium medium medium vthin ..) ///
	hsize(vlarge small small small ..) ///
	hbarbsize(vlarge medium medium medium ..) ///
	hangle(30 80 80 0 ..) hosize(thick thick vvthick thick ..) ///
	hfcolor($DodgerBlue none ..) ///
	lcolor($DodgerBlue $DodgerBlue $DodgerBlue $SlateGray $Gray) ///
	lpattern(solid solid solid dash solid)) ///
  point(data("Temp/post20dec_huanan_cases.dta") ///
    xcoord(case_X) ycoord(case_Y) legenda(on) ///
	by(case_flag) fcolor($Magenta $DarkViolet ..) ///
	shape(circle diamond) size(0.5 0.4) ocolor(none ..)) ///
  legend(ring(0) pos(7) col(1) colfirst bmargin(3 0 1.5 0) ///
	order(7 8 3 6) title("{bf:New Confirmed Cases}", ///
		            size(vsmall) pos(11) justification(left)) ///
	label(7 "21-27 Dec {it:(N=1)}") ///
	label(8 "28-31 Dec {it:(N=1)}") /// 
	label(3 "{it:Cluster Shop}") ///
	label(6 "{it:Raccoon Dog DNA}") ///
    region(lcolor(black) fcolor($White))) ///
    plotregion(margin(0 0 2 0)) ///		
  name(case_map_post20dec, replace)
graph export "Figures/Casemap_21to31dec.tif", replace	
