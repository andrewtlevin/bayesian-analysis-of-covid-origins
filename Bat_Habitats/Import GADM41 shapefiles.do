********************
* GADM41 Shapefiles
********************
local shpname = "world_streamlined"
import delimited using "Excel/gadm41_`shpname'_shp.csv", ///
  clear delim(",") 
save "Datasets/gadm41_`shpname'_shp.dta", replace

local shpname = "eastern_hemisphere"
import delimited using "Excel/gadm41_`shpname'_shp.csv", ///
  clear delim(",") 
save "Datasets/gadm41_`shpname'_shp.dta", replace

local shpname = "southern_asia_borders"
import delimited using "Excel/gadm41_`shpname'_shp.csv", ///
  clear delim(",") 
save "Datasets/gadm41_`shpname'_shp.dta", replace

local shpname = "CHN_1_streamlined"
import delimited using "Excel/gadm41_`shpname'_shp.csv", ///
  clear delim(",") 
save "Datasets/gadm41_`shpname'_shp.dta", replace

local shpname = "CHN_2_streamlined"
import delimited using "Excel/gadm41_`shpname'_shp.csv", ///
  clear delim(",") 
save "Datasets/gadm41_`shpname'_shp.dta", replace
  
local shpname = "IND_1_streamlined"
import delimited using "Excel/gadm41_`shpname'_shp.csv", ///
  clear delim(",") 
save "Datasets/gadm41_`shpname'_shp.dta", replace

import excel using "Excel/gadm41_CHN_1_index.xlsx", ///
  clear firstrow case(preserve)
save "Datasets/gadm41_CHN_1_index.dta", replace

import excel using "Excel/gadm41_CHN_2_geocenters.xlsx", ///
  clear firstrow case(preserve)
save "Datasets/gadm41_CHN_2_geocenters.dta", replace

import excel using "Excel/gadm41_IND_1_streamlined_index.xlsx", ///
  clear firstrow case(preserve)
save "Datasets/gadm41_IND_1_streamlined_index.dta", replace
