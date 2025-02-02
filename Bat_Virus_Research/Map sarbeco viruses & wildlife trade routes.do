* Import locations of sarbeco viruses
import excel ///
  using "Excel/Sarbeco Virus Locations in Southeast Asia.xlsx", ///
  clear firstrow case(lower) 
geo2xy latitude longitude, gen(_Y _X)
gen vtype = cond(type=="SARS-CoVr", 1, 2)
gen pop_wt = 0.4
save "Temp/sarbeco_virus_locations.dta", replace

* Import list of largest PRC metro areas
import excel using "Excel/PRC Largest Urban Areas.xlsx", ///
  clear sheet("Top20") firstrow case(lower) 
geo2xy latitude longitude, gen(_Y _X)
drop if _Y > -95
gen vtype = cond(urban_area=="Wuhan", 4, 3)
gen pop_wt = pop_2020^0.5
append using "Temp/sarbeco_virus_locations.dta"
save "Temp/sarbeco_and_urban_areas.dta", replace

* Make labels for large metro areas
use "Temp/sarbeco_and_urban_areas.dta", clear
keep if inlist(urban_area,"Beijing","Chengdu","Chongqing","Guangzhou","Jinan","Nanjing") ///
  | inlist(urban_area,"Dalian","Qingdao","Shanghai","Shenyang","Xi'an")
sort urban_area
gen keyflag = 5 + _n
gen labeltxt = "{bf:" + urban_area + "}"
rename _X _CX
rename _Y _CY
keep keyflag labeltxt _CX _CY
save "Temp/urban_area_labels.dta", replace

* Prepare compass arrow and scalebar segments
clear
input _ID long1 lat1 long2 lat2 arrow_type
  0 126 34 126 37 3
  1 87 41  82 41 4
  2 87 41  92 41 5
  3 92 41  97 41 5
  4 97 41 102 41 5
  end
geodist lat1 long1 lat2 long2, gen(dist)
geo2xy lat1 long1, gen(_Y1 _X1)
geo2xy lat2 long2, gen(_Y2 _X2)
keep _ID _X* _Y* arrow_type
save "Temp/wildlife_compass_scale.dta", replace

* Import wildlife trade routes
import excel ///
  using "Excel/Wildlife Trade Routes.xlsx", ///
  clear firstrow case(lower)
gen _ID = 100 + _n  
foreach v in o d {  
  gen double `v'latitude = real(substr(`v'coords, 1, strpos(`v'coords,",")-1))
  gen double `v'longitude = real(substr(`v'coords, strpos(`v'coords,",")+2, .))  
}
geo2xy olatitude olongitude, gen(_Y1 _X1) 
geo2xy dlatitude dlongitude, gen(_Y2 _X2) 

* Shorten arrows incrementally
replace _X2 = 0.25*_X1 + 0.75*_X2
replace _Y2 = 0.25*_Y1 + 0.75*_Y2
keep _ID _X* _Y* arrow_type
append using "Temp/wildlife_compass_scale.dta"
save "Temp/wildlife_arrows_compass_scale.dta", replace

* Prepare labels for compass & scalebar
clear
input _ID longitude latitude
  1 126 37 
  2  82 41
  3  87 41
  4  92 41
  5  97 41
  6 102 41
  end
geo2xy latitude longitude, gen(_CY _CX)
gen labeltxt = cond(_ID==1, "{bf:North}", ///
			   cond(_ID==2, "{bf: 0}", ///
			   cond(_ID==3, "{bf:500km}", ///
			   cond(_ID==4, "{bf:1000km}", ///
			   cond(_ID==5, "{bf:1500km}", "{bf:2000km}")))))
gen keyflag = cond(_ID==1, 1, 2)			   
keep keyflag _CX _CY labeltxt
save "Temp/compass_scalebar_labels.dta", replace

* Prepare labels for country names
clear
input _ID str8(country) longitude latitude
  21 Cambodia  104.9 12.7
  22 Laos      102.4 19.5
  23 Myanmar    95.8 21.0
  24 Thailand  101.4 15.3
  25 Vietnam   105.9 21.3
  end
geo2xy latitude longitude, gen(_CY _CX)
gen labeltxt = "{bf:" + country + "}"
gen keyflag = 5
keep keyflag _CX _CY labeltxt
save "Temp/wildlife_country_labels.dta", replace

* Prepare labels for province names
import excel using "Excel/PRC_wildlife_trade_provinces.xlsx", ///
  clear firstrow case(preserve)
gen labeltxt = "{bf:" + NAME_1 + "}"
gen keyflag = 4
keep labeltxt _CX _CY keyflag
save "Temp/wildlife_province_labels.dta", replace

* Create label for Wuhan
clear
input _CX _CY
  209.33955 -105.06311
  end
gen keyflag = 3
gen labeltxt = "{bf:Wuhan}"
append using "Temp/compass_scalebar_labels.dta" 
append using "Temp/wildlife_province_labels.dta"
append using "Temp/wildlife_country_labels.dta"
append using "Temp/urban_area_labels.dta"
save "Temp/all_wildlife_chart_labels.dta", replace

* Import map shapefiles and index
import delimited ///
  using "Excel/combined_Southeast_Asia_shp.csv", ///
  clear delim(",") 
rename _id _ID
rename _x _X
rename _y _Y
sort _ID shape_order  
save "Temp/combined_Southeast_Asia_shp.dta", replace

import excel ///
  using "Excel/combined_Southeast_Asia_index.xlsx", ///
  clear firstrow case(preserve)
save "Temp/combined_Southeast_Asia_index.dta", replace

import delimited ///
  using "Excel/gadm41_southcentral_PRC_shp.csv", ///
  clear delim(",") 
rename _id _ID
rename _x _X
rename _y _Y
sort _ID shape_order  
save "Temp/gadm41_southcentral_PRC_shp.dta", replace

* Make illustrative map
use "Temp/combined_Southeast_Asia_index.dta", clear
quietly colorpalette HTML, global
gen wildlife_flag = cond(NAME_1=="Guangdong", 4, ///
                    cond(inlist(NAME_1, "Guangxi","Guizhou","Hainan", ///
					"Qinghai","Sichuan","Yunnan"), 3, ///
                    cond(seasia_flag==1, 2, ///
					cond(_ID > 1000, 1, 0))))
grmap wildlife_flag using "Temp/combined_Southeast_Asia_shp.dta", ///
  id(_ID) clmethod(unique) ocolor($Black $Black $DarkViolet $Black $Black) ///
  osize(vvthin none vthin vthin vthin) ///
  fcolor($FloralWhite $Gainsboro $MistyRose $Lavender $Lavender) ///
  polygon(data("Temp/gadm41_southcentral_PRC_shp.dta") ///
          ocolor($Navy) osize(medthin) fcolor(none)) ///
  point(data("Temp/sarbeco_and_urban_areas.dta") ///
        xcoord(_X) ycoord(_Y) by(vtype) ///
		size(0.8) prop(pop_wt) prange(0 7) ///
		shape(square diamond circle circle) ///
		ocolor(none none $Black $Navy) ///
		osize(none none vthin thin) ///
		fcolor($DarkGoldenRod $Crimson $Moccasin $Moccasin)) ///
  arrow(data("Temp/wildlife_arrows_compass_scale.dta") ///
	by(arrow_type) direction(1 1 1 2 1) ///
	lpattern(solid ..) lsize(medthick ..) ///
	hsize(small small vlarge medium medium) ///
	hbarbsize(small small vlarge medlarge medlarge) ///
	hangle(30 30 30 80 80) hosize(medium medium thick ..) ///
	lcolor($ForestGreen $ForestGreen $Navy $Navy $Navy) /// 
	hfcolor($Green $Green $Blue $Blue $Blue)) ///
  label(data("Temp/all_wildlife_chart_labels.dta") ///
    by(keyflag) xcoord(_CX) ycoord(_CY) label(labeltxt) length(14 ..) ///
	pos(12 6 6 0 0 9 12 3 6 5 3 9 3 3 6 6) ///
	gap(0 0.1 1.2 0 0 1.8 1.3 1.2 0.7 1.4 0.9 0.9 1.1 1.7 0.9 1.1) ///
	color($Navy $Navy $Navy $MediumBlue $DarkViolet $FireBrick ..) ///
	size(vsmall tiny 1.4 tiny tiny 2.2 1.4 1.4 1.4 2.2 1.4 1.4 1.4 2.2 1.4 1.4)) ///	   
  legend(order(8 9 12 10) ///
    ring(0) pos(5) bmargin(0 5 5 0) ///
	label(8 "{bf: SARS-related Bat Virus}") ///
	label(9 "{bf: SARS-CoV-2-related Bat Virus}") ///
    label(12 "{bf: Wildlife Trade Route}") ///
	label(10 "{bf: Major Urban Area}") ///
    region(lcolor(black) fcolor(white))) ///
  graphregion(color(ltblue*0.33)) ///
  plotregion(margin(2 -2 0 0)) ///
  name(wildlife_trade_routes, replace)
graph export "Figures/wildlife_trade_routes.tif", replace  
