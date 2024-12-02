* Create polygon dataset combining raccoon dog stalls with
* building walls (excluding northeast outlying buildings)
use "Datasets/raccoondog_dna_locations_shp.dta", clear
replace _ID = 123456
replace shape_order = _n
append using "Maps/Huanan_main_buildings_shp.dta"
gen structure = real(substr(string(_ID),1,2))
drop if inlist(structure,30,31,44) ///
      | inlist(_ID,1001030,1001031,1001044)
gen type_flag = cond(_ID==123456, 2, 1)
sort _ID shape_order
save "Temp/enhanced_building_map_shp.dta", replace

* Create building labels 
clear
input keyflag _CX _CY
  1 114.25645 30.620321
  2 114.25770 30.620360
  end
gen labeltxt = cond(keyflag==1, "{bf:West Building}", ///
			                    "{bf:East Building}") 
save "Temp/huanan_labels.dta", replace

* Merge choropleth data with complete vendor map
use "Maps/Huanan_market_map_index.dta", clear
drop if inlist(structure,30,31,44)
expand 4
sort _ID
by _ID: gen idate = _n
merge 1:1 _ID idate using "Datasets/spatiotemporal_choropleth_data.dta"
xtset _ID idate
	  
* Make choropleths comparing hypothesis A vs. hypothesis Z
* at each specified date
*	  fcolor($Beige $Cranberry $Mocassin $DarkSeaGreen ///
*	         $Gold $DarkOrange) 
quietly colorpalette HTML, global
forvalues idate = 2/4 {
  foreach imodel in A Z {
    grmap pphat`imodel' ///
      using "Maps/Huanan_streamlined_map_shp.dta", ///
      id(_ID) t(`idate') clmethod(custom) ///
	  clbreaks(0 0.01 0.02 0.03 0.04 0.05 0.10) ///
	  fcolor($Beige $Moccasin $MistyRose $BurlyWood $Gold $DarkOrange) ///
      ocolor(black ..) ndocolor(black) ///
      polygon(data("Temp/enhanced_building_map_shp.dta") ///
	    by(type_flag) fcolor(none ..)  ///
	    ocolor(gray $Blue) osize(medthick medthick)) ///
      arrow(data("Maps/Huanan_lane_lines_shp.dta") ///
  	    by(solidline) direction(2 2) lsize(vthin ..) hsize(small ..) ///
		hbarbsize(medium ..) hangle(0 0) hosize(thick ..) hfcolor(none ..) ///
	    lcolor($SlateGray $Gray) lpattern(dash solid)) ///
      point(data("Datasets/vendor_case_locations.dta") ///
	    xcoord(case_X) ycoord(case_Y) ///
	    shape(diamond) size(0.5) fcolor($DarkViolet) ocolor(none) ///
	    select(keep if case_idate==`idate')) ///   
      label(data("Temp/huanan_labels.dta") ///
	    xcoord(_CX) ycoord(_CY) label(labeltxt) ///
	    by(keyflag) length(24 24) pos(12 12) angle(12 12) gap(0 0) ///
	    size(medsmall medsmall) color($DodgerBlue $DodgerBlue)) ///
      legend(ring(0) pos(7) col(1) colfirst bmargin(1 1 0 0) ///
        title("{bf:Estimated Probability}", size(vsmall) pos(11) just(left)) ///
        rowgap(1.05) region(lcolor(black) fcolor($White)) ///
        order(2 3 4 5 6 7 10 9) ///
		label(2 "Less than 1%") label(3 "1 - 2%") label(4 "2 - 3%") ///
		label(5 "3 - 4%") label(6 "4 - 5%") label(7 "More than 5%") ///
  	    label(9 "{it:Raccoon Dog mtDNA}") ///
        label(10 "{bf:New Confirmed Case}")) ///
      plotregion(margin(14 0 0 0)) ///		
	  name(Huanan_phat`imodel'_date`idate', replace)
    graph export "Figures/Hypothesis_`imodel'_date`idate'.tif", replace
  }
}
