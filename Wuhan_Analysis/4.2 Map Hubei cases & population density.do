* Specify coordinates for streamlined Hubei map
local minx = 112.8
local maxx = 115.25
local miny =  29.25
local maxy = 32.25

* Make scalebar
clear
input _ID _X1 _Y1 _X2 _Y2 
  1 113.0000 31.15 113.2575 31.15
  2 113.2575 31.15 113.5150 31.15
  end
replace _X1 = _X1 - 0.1
replace _X2 = _X2 - 0.1
save "Temp/Hubei_scalebar.dta", replace

* Make scalebar labels
clear
input _ID _PX _PY str10 scale_label 
  1 112.91 31.2 "0"
  2 113.16 31.2 "25"
  2 113.42 31.2 "50km"
  end
save "Temp/Hubei_scalelabels.dta", replace

* Streamline Hubei administrative boundaries
use "Maps/gadm41_China_shp.dta", clear
keep if inlist(_ID,12,14,15,17)
append using "Maps/gadm41_Hubei_shp.dta"
sort _ID shape_id shape_num
by _ID shape_id: egen minx = min(_X)
by _ID shape_id: egen maxx = max(_X)
by _ID shape_id: egen miny = min(_Y)
by _ID shape_id: egen maxy = max(_Y)
replace _X = `minx' if _X < `minx'
replace _Y = `miny' if _Y < `miny'
replace _X = `maxx' if _X > `maxx' & !missing(_X)
replace _Y = `maxy' if _Y > `maxy' & !missing(_Y)
sort _ID shape_id shape_num
gen borders_flag = cond(_ID==161, 2, cond(_ID==14, 1, 0))
save "Temp/gadm41_Hubei_streamlined_shp.dta", replace

* Streamline Hubei natural water
use "Maps/Hubei_streamlined_waterways_shp.dta", clear
replace _X = `minx' if _X < `minx'
replace _X = `maxx' if _X > `maxx' & !missing(_X)
replace _Y = `miny' if _Y < `miny'
replace _Y = `maxy' if _Y > `maxy' & !missing(_Y)
save "Temp/Hubei_streamlined_waterways_shp.dta", replace

* Identify cases > 25km from Huanan Market (30.6197,114.2573)
use "Datasets/Wuhan_case_data.dta", clear
geodist _Y _X 30.6197 114.2573, gen(huanan_dist)
replace huanan_flag = huanan_flag + 2 if huanan_dist > 25
save "Temp/Hubei_case_data.dta", replace

* Map cases in Hubei
quietly colorpalette HTML, globals
use "Maps/Hubei_1km_popdensity.dta", clear
grmap d3_flag using "Maps/Hubei_1km_grid_shp.dta", ///
   id(_ID) clmethod(unique) fcolor(Purples) ndfcolor(eggshell) ///
   osize(0 ..) ndsize(0) ///
   polygon(data("Temp/Hubei_streamlined_waterways_shp.dta") ///
     ocolor($LightSkyBlue) fcolor($LightSkyBlue)) ///
   line(data("Temp/gadm41_Hubei_streamlined_shp.dta") ///
     by(borders_flag) legenda(on) size(vthin medium thin) ///
	 color($SlateGray $MidnightBlue $MediumBlue)) ///
   point(data("Temp/Hubei_case_data.dta") ///
         by(huanan_flag) xcoord("_X") ycoord("_Y") legenda(on) ///
		 size(0.35 0.35 0.7 0.7) shape(triangle ..) ///
		 fcolor($Green $Crimson $Green $Crimson)) ///
   arrow(data("Temp/Hubei_scalebar.dta") ///
         by(_ID) direction(2 1) lcolor($Blue ..) ///
		 hosize(vvthick vvthick) hangle(80 80)) ///
   label(data("Temp/Hubei_scalelabels.dta") ///
         xcoord(_PX) ycoord(_PY) ///
		 color($Blue) label(scale_label)) ///
   legend(ring(0) pos(2) order(15 14 10 11) bmargin(0 3 0 3) ///
         label(10 "{bf: Hubei border}") ///
		 label(11 "{bf: Wuhan border}") ///
	     label(14 "{bf:No Known Link to Huanan Market}") ///
   	     label(15 "{bf:Linked to Huanan Market}") ///
         region(lcolor(black) fcolor(white))) ///
  plotregion(margin(-5 -5 -5 -5)) ///		
  name(Hubei_cases, replace)
graph export "Figures/Hubei Case Map.tif", replace  
