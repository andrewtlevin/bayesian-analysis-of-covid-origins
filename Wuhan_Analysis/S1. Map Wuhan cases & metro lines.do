* Make two illustrative maps of linked cases and unlinked cases
quietly colorpalette HTML, globals
use "Maps/Wuhan_narrowcore_popdensity.dta", clear
grmap d3_flag using "Maps/Wuhan_narrowcore_1km_grid_shp.dta", ///
   id(_ID) clmethod(unique) ocolor(none ..) fcolor(none ..) ///
   ndocolor(none) ndfcolor(eggshell) ///
   line(data("Maps/Wuhan_narrowcore_metro_shp.dta") ///
	 by(_ID) legenda(on) ///
     color(ebblue pink gold olive_teal green orange ///
	       gray khaki purple) /// 
	 size(medthin medthin medthin medthin medthin ///
	      medthin medthin medthin medthin vvthick)) ///
   polygon(data("Maps/Wuhan_narrowcore_waterways_shp.dta") ///
     by(island_flag) ocolor(none none) fcolor($LightCyan $SeaShell)) ///
   point(data("Datasets/Wuhan_narrowcore_cases.dta") ///
        select(keep if huanan_flag==0) xcoord(_PX) ycoord(_PY) ///
		shape(circle) size(0.8pt) fcolor(cranberry)) ///
   plotregion(margin(-5 -5 -5 -5)) ///				
   legend(pos(4) ring(0) order(10 11 12 13 14 15 16 17 18) ///
         title("{bf:Metro Line}", size(small)) ///
		 bmargin(0 5 -2 0) region(lcolor(black) fcolor(white))) ///		
   name(Unlinked_Cases_and_Metro, replace)
graph export "Figures/Unlinked Cases & Metro Lines.tif", replace  

use "Maps/Wuhan_narrowcore_popdensity.dta", clear
grmap d3_flag using "Maps/Wuhan_narrowcore_1km_grid_shp.dta", ///
   id(_ID) clmethod(unique) ocolor(none ..) fcolor(none ..) ///
   ndocolor(none) ndfcolor(eggshell) ///
   line(data("Maps/Wuhan_narrowcore_metro_shp.dta") ///
	 by(_ID) legenda(on) ///
     color(ebblue pink gold olive_teal green orange ///
	       gray khaki purple $LightSkyBlue ) /// 
	 size(medthin medthin medthin medthin medthin ///
	      medthin medthin medthin medthin vvthick)) ///
   polygon(data("Maps/Wuhan_narrowcore_waterways_shp.dta") ///
     by(island_flag) ocolor(none none) fcolor($LightCyan $SeaShell)) ///
   point(data("Datasets/Wuhan_narrowcore_cases.dta") ///
        select(keep if huanan_flag==1) xcoord(_PX) ycoord(_PY) ///
		shape(circle) size(0.8pt) fcolor(blue)) ///
   plotregion(margin(-5 -5 -5 -5)) ///		
   legend(pos(4) ring(0) order(10 11 12 13 14 15 16 17 18) ///
         title("{bf:Metro Line}", size(small)) ///
		 bmargin(0 5 -2 0) region(lcolor(black) fcolor(white))) ///		
  name(Linked_Cases_and_Metro, replace)
graph export "Figures/Linked Cases & Metro Lines.tif", replace  

