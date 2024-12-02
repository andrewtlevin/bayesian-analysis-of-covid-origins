
* Make illustrative map
colorpalette HTML, global
use "Datasets/Raccoon Dog Fur Farms.dta", clear
grmap farm_flag using "Datasets/gadm41_CHN_1_streamlined_shp.dta", ///
   id(_ID) polyfirst legend(on) ///
   legend(pos(5) region(fcolor(white) lcolor(black) lwidth(vthin)) ///
          order(2 3 4 5 6 7 8 10) ///
		  title("{bf:Raccoon Dog Fur Production}", ///
		        size(vsmall) just(left) margin(-18pt)) ///
		  label(10 "Top 10 Production Centers")) ///
   clmethod(unique) fcolor($BlueViolet $CadetBlue $DarkSeaGreen ///
               $Beige $PaleGoldenRod $PapayaWhip $Bisque) ///
   ocolor(black black black black black black black) ///
   osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin) ///
   point(data("Datasets/Raccoon Dog Major Farm Cities.dta") ///
         xcoord(_X) ycoord(_Y) by(city_flag) legenda(on) leglabel(Major) ///
		 size(tiny vsmall) shape(diamond circle) fcolor($OrangeRed $Navy)) ///	   
   label(data("Datasets/Raccoon Dog Major Farm Cities.dta") ///
         select(keep if city_name=="Wuhan") label(city_name) ///
         xcoord(_X) ycoord(_Y) ///
		 pos(9) gap(0pt) size(tiny) color($Navy)) ///
   scalebar(units(5) scale(1) label(100km)) ///		 
   graphregion(fcolor(eggshell) margin(t-20 b-20)) ///
   plotregion(margin(r+20)) ///		 
   name(China_raccoondog, replace)
graph export "Figures/raccoon_dog_fur_farms.tif", replace   