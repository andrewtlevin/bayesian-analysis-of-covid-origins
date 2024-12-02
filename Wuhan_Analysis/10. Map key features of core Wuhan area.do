* Make illustrative map
quietly colorpalette w3, globals 
quietly colorpalette HTML, globals
use "Maps/Wuhan_core_popdensity.dta", clear
grmap d3_flag using "Maps/Wuhan_core_1km_grid_shp.dta", ///
   id(_ID) clmethod(unique) ocolor(none ..) fcolor(Purples) ///
   ndocolor(none) ndfcolor(eggshell) ///
   polygon(data("Maps/Wuhan_core_waterways_shp.dta") ///
          by(island_flag) ocolor(none none) fcolor($LightCyan $SeaShell)) ///
   point(data("Maps/Wuhan_key_coordinates.dta") ///
        by(loc_num) xcoord(_PX) ycoord(_PY) size(0.8pt ..) ///
		shape(square diamond circle ..) /// 
		fcolor($Blue $Blue $DeepPink ..)) ///
   label(data("Maps/Wuhan_key_coordinates.dta") ///
        by(loc_num) xcoord(_PX) ycoord(_PY) label(loc_label) size(tiny ..) ///
		color($Blue $Blue $DeepPink ..) gap(0 ..) ///
		length(30 ..) pos(2 9 3 3 3 3 3 3 3 9)) ///
   line(data("Maps/Wuhan_core_metro_shp.dta") ///
       by(_ID) legenda(on) color($DarkGreen ..) size(vthin)) ///
   legend(ring(0) pos(4) col(1) colfirst holes(9) bmargin(0 0 2 0) ///
     order(- "{bf:Population Density per KM{sup:2}}" ///
	       2 3 4 5 6 7 10 ///
	       - "{bf:Bat Virus Laboratories}" 22 23 24 25 26 27 28 29) ///
     title(, size(vsmall)) ///
	 label(2 "{it: Rural:}    Less than 300") ///
	 label(3 "{it:Suburban}: 300 to 1,000") ///
	 label(4 "{it:Urban}: 1,000 to 10,000") ///
	 label(5 "{it:Core}: 10,000 to 30,000") ///
	 label(6 "          30,000 to 70,000") ///
	 label(7 "         More than 70,000") ///
	 label(10 "{bf:Wuhan Metro Lines}") ///
	 label(22 "1: Wuhan CDC {it:(BSL-2)}") ///
	 label(23 "   {it:(1* = Prior Location)}") ///
	 label(24 "2: Wuhan Univ. {it:(BSL-3)}") ///
	 label(25 "3: WIV-Wuchang {it:(BSL-2 & 3)}") ///
	 label(26 "4: Hubei CDC {it:(BSL-3)}") ///
	 label(27 "5: Huazhong Univ. {it:(BSL-3)}") ///
	 label(28 "6: WIV-Jiangxia {it:(BSL-4)}") ///
	 label(29 "7: Wuhan Inst. Bio. Products") ///
	 justification(right ..) region(lcolor(black) fcolor(white))) ///
   plotregion(margin(-5 -12 -5 -5)) ///		
   name(Wuhan_Core_Map, replace)
graph export "Figures/Wuhan Key Features.tif", replace   
  
