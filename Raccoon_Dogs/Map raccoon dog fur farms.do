* Prepare compass arrow and scalebar segments
clear
input _ID long1 lat1 long2 lat2 arrow_type
  0  77 43  77 47 1
  1  98 47  93 47 2
  2  98 47 103 47 3
  3 103 47 108 47 3
  4 108 47 113 47 3
  end
geodist lat1 long1 lat2 long2, gen(dist)
geo2xy lat1 long1, gen(_Y1 _X1)
geo2xy lat2 long2, gen(_Y2 _X2)
keep _ID _X* _Y* arrow_type
save "Temp/furfarms_compass_scale.dta", replace

* Prepare labels for compass & scalebar
clear
input _ID longitude latitude
  1  77 47 
  2  93 47 
  3  98 47
  4 103 47
  5 108 47
  6 113 47
  end
geo2xy latitude longitude, gen(_CY _CX)
gen labeltxt = cond(_ID==1, "{bf:North}", ///
			   cond(_ID==2, "{bf: 0}", ///
			   cond(_ID==3, "{bf:500km}", ///
			   cond(_ID==4, "{bf:1000km}", ///
			   cond(_ID==5, "{bf:1500km}", "{bf:2000km}")))))
gen keyflag = cond(_ID==1, 1, 2)			   
keep keyflag _CX _CY labeltxt
append using "Datasets/Raccoon Dog Major Farm Cities.dta"
keep if city_name=="Wuhan" | missing(city_name)
replace keyflag = 3 if missing(keyflag)
replace labeltxt = "{bf:Wuhan}" if missing(labeltxt)
replace _CX = _X if missing(_CX)
replace _CY = _Y if missing(_CY)
keep keyflag _CX _CY labeltxt
save "Temp/compass_scalebar_labels.dta", replace

* Make illustrative map
colorpalette HTML, global
use "Datasets/Raccoon Dog Fur Farms.dta", clear
grmap farm_flag using "Maps/gadm41_PRC_shp.dta", ///
   id(_ID) legend(on) ///
   clmethod(unique) fcolor($BlueViolet $DarkSeaGreen $DarkKhaki ///
               $Bisque $PaleGoldenRod $Beige $PapayaWhip $Linen) ///
   ocolor($Black ..) osize(vvthin ..) ndocolor($Black) ndsize(vvthin) ///
   polygon(data("Maps/gadm41_PRC_shp.dta") ///
     select(keep if _ID==1) ///
     fcolor(none) ocolor($Maroon) osize(0.2)) ///
   arrow(data("Temp/furfarms_compass_scale.dta") ///
 	 by(arrow_type) direction(1 2 1) ///
	 lpattern(solid ..) lsize(medthick medthin medthin) ///
	 hsize(vlarge medium medium) ///
	 hbarbsize(vlarge medlarge medlarge) ///
	 hangle(30 80 80) hosize(thick ..) ///
	 lcolor($Navy ..) /// 
	 hfcolor($Blue ..)) ///
   point(data("Datasets/Raccoon Dog Major Farm Cities.dta") ///
     xcoord(_X) ycoord(_Y) by(city_flag) legenda(on) leglabel(Major) ///
	 size(tiny vsmall) shape(diamond circle) fcolor($OrangeRed $Navy)) ///	   
   label(data("Temp/compass_scalebar_labels.dta") ///
     xcoord(_CX) ycoord(_CY) label(labeltxt) by(keyflag) ///
	 pos(12 6 9) gap(0 0.1 0) size(vsmall tiny tiny) color($Navy ..)) ///
   legend(pos(3) bmargin(0 5 0 25) ///
     order(2 3 4 5 6 7 8 9 11) ///
     label(11 "Top 10 Production Centers") ///     
	 region(fcolor(white) lcolor(black) lwidth(vthin))) ///
   graphregion(fcolor(eggshell) margin(t-20 b-20)) ///
   plotregion(margin(r+20)) ///		 
   name(PRC_raccoondog, replace)
graph export "Figures/raccoon_dog_fur_farms.tif", replace   