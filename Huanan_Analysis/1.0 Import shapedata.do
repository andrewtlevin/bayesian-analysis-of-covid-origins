import excel using Shapedata/Huanan_market_map_index.xlsx, ///
  clear firstrow case(preserve)
sort _ID  
save Maps/Huanan_market_map_index.dta, replace
  
import excel using Shapedata/Huanan_market_map_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Huanan_market_map_shp.dta, replace

import excel using Shapedata/Huanan_streamlined_map_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Huanan_streamlined_map_shp.dta, replace

import excel using Shapedata/Huanan_main_buildings_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID shape_order
save Maps/Huanan_main_buildings_shp.dta, replace
  
import excel using Shapedata/Huanan_lane_lines_shp.xlsx, ///
  clear firstrow case(preserve)
sort _ID 
save Maps/Huanan_lane_lines_shp.dta, replace
  
import excel using Shapedata/Huanan_stall_index.xlsx, ///
  clear firstrow case(preserve)
sort _ID 
save Maps/Huanan_stall_index.dta, replace
  