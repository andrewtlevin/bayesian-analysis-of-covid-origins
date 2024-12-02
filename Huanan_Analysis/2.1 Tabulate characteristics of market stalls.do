* Remove northeast outlying structures from vendor map
use "Maps/Huanan_market_map_index.dta", clear
drop if inlist(structure,29,30,31,44)
keep _ID building structure 
merge 1:m _ID using "Maps/Huanan_market_map_shp.dta"
keep if _merge==3
drop _merge

* Compute width of typical corridor
list _ID _Y _X if (_ID==15201 & shape_order==2) | (_ID==16101 & shape_order==3)

* Tabulate approximate area of west building
gen x1t = _X if _ID==13101 & shape_order==3
gen y1t = _Y if _ID==13101 & shape_order==3
gen x2t = _X if _ID==13114 & shape_order==4
gen y2t = _Y if _ID==13114 & shape_order==4
gen x3t = _X if _ID==28201 & shape_order==2
gen y3t = _Y if _ID==28201 & shape_order==2
gen x4t = _X if _ID==1101 & shape_order==3
gen y4t = _Y if _ID==1101 & shape_order==3
gen x5t = _X if _ID==25201 & shape_order==2
gen y5t = _Y if _ID==25201 & shape_order==2

egen _x1 = max(x1t)  
egen _y1 = max(y1t)  
egen _x2 = max(x2t)  
egen _y2 = max(y2t)  
egen _x3 = max(x3t)  
egen _y3 = max(y3t)  
egen _x4 = max(x4t)  
egen _y4 = max(y4t)  
egen _x5 = max(x5t)  
egen _y5 = max(y5t)  
local x1 = _x1[1]
local y1 = _y1[1]
local x2 = _x2[1]
local y2 = _y2[1]
local x3 = _x3[1]
local y3 = _y3[1]
local x4 = _x4[1]
local y4 = _y4[1]
local x5 = _x5[1]
local y5 = _y5[1]
geodist `y1' `x1' `y2' `x2'
geodist `y1' `x1' `y3' `x3'
geodist `y1' `x1' `y4' `x4'
geodist `y1' `x1' `y5' `x5'

sort _ID shape_order
by _ID: gen shape_count = _N
list _ID shape_count ///
  if shape_count>5 & shape_order==1
keep if shape_count==5 & shape_order > 1
gen west_section = cond(inrange(structure,2,12), 1, ///
                   cond(inrange(structure,13,27), 2, 3))
sort building west_section _ID
by building west_section: gen ii = _n
by building west_section: egen double bminx = min(_X)
by building west_section: egen double bminy = min(_Y)
by building west_section: egen double bmaxx = max(_X)
by building west_section: egen double bmaxy = max(_Y)
geodist bminy bminx bmaxy bminx, gen(building_length)
geodist bminy bminx bminy bmaxx, gen(building_width)
gen double building_area = (1000*building_length) * (1000*building_width)
list building west_section bminy bminx bmaxy bmaxx if ii==1
list building_length building_width building_area if ii==1

* Tabulate approximate dimension and area of vendors with rectangular polygons
keep _ID building west_section _X _Y shape_order
reshape wide _X _Y, i(_ID) j(shape_order)
geodist _Y2 _X2 _Y3 _X3, gen(vendor_long)
geodist _Y2 _X2 _Y5 _X5, gen(vendor_wide)
gen double vendor_length = 1000*vendor_long
gen double vendor_width = 1000*vendor_wide
gen double vendor_area = vendor_length * vendor_width
table building west_section, stat(total vendor_area) stat(median vendor_length)

