import excel using Shapedata/gadm41_China_shp.xlsx, ///
  clear firstrow case(preserve)
save Maps/gadm41_China_shp.dta, replace
  
import excel using Shapedata/gadm41_Hubei_shp.xlsx, ///
  clear firstrow case(preserve)
save Maps/gadm41_Hubei_shp.dta, replace

import excel using Shapedata/gadm41_Wuhan_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/gadm41_Wuhan_shp.dta, replace

import excel using Shapedata/gadm41_Wuhan_index.xlsx, ///
  clear firstrow case(preserve)
sort _ID
save Maps/gadm41_Wuhan_index.dta, replace

import excel using Shapedata/Hubei_1km_grid_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Hubei_1km_grid_shp.dta, replace

import excel using Shapedata/Hubei_1km_popdensity.xlsx, ///
  clear firstrow case(preserve)
sort _ID
save Maps/Hubei_1km_popdensity.dta, replace

import excel using Shapedata/Hubei_streamlined_waterways_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Hubei_streamlined_waterways_shp.dta, replace

import excel using Shapedata/Wuhan_1km_grid_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Wuhan_1km_grid_shp.dta, replace

import excel using Shapedata/Wuhan_core_1km_grid_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Wuhan_core_1km_grid_shp.dta, replace
  
import excel using Shapedata/Wuhan_core_metro_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Wuhan_core_metro_shp.dta, replace
  
import excel using Shapedata/Wuhan_core_popdensity.xlsx, ///
  clear firstrow case(preserve)
sort _ID
save Maps/Wuhan_core_popdensity.dta, replace
  
import excel using Shapedata/Wuhan_core_waterways_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Wuhan_core_waterways_shp.dta, replace
  
import excel using Shapedata/Wuhan_narrowcore_1km_grid_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Wuhan_narrowcore_1km_grid_shp.dta, replace

import excel using Shapedata/Wuhan_narrowcore_metro_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Wuhan_narrowcore_metro_shp.dta, replace
  
import excel using Shapedata/Wuhan_narrowcore_popdensity.xlsx, ///
  clear firstrow case(preserve)
sort _ID 
save Maps/Wuhan_narrowcore_popdensity.dta, replace
  
import excel using Shapedata/Wuhan_narrowcore_waterways_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Wuhan_narrowcore_waterways_shp.dta, replace
  
import excel using Shapedata/Wuhan_eastbank_flag.xlsx, ///
  clear firstrow case(preserve)
sort _ID 
save Maps/Wuhan_eastbank_flag.dta, replace

import excel using Shapedata/Wuhan_key_coordinates.xlsx, ///
  clear firstrow case(preserve)
save Maps/Wuhan_key_coordinates.dta, replace
  