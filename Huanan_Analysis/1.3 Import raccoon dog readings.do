* Import BOLD results and keep raccoon dog readings
import excel using "Rawdata/Liu et al. 2023 Supplementary Data", ///
  clear sheet("Table S8") firstrow cellrange(A2) case(lower)
keep if genus=="Nyctereutes" 
reshape long env, i(genus) j(env_code) string
rename env bold
drop if bold==0
gen sampleid = "Env" + env_code

* Merge with environmental sample info 
* Note: two samples with potential traces of raccoon dog mitochondrial DNA 
*       are excluded at this stage:
*   Env_0818 (West Wing sewer): BOLD reading = 1
*   Env_0868 (West Wing storage for vendor at Stall 8-25): BOLD reading = 6
merge m:1 sampleid using "Datasets/environmental_test_stall_index.dta"
keep if _merge==3
drop sampletype _merge
rename sampleinformation sampleinfo

* Drop other trace readings below China CDC threshold (BOLD <= 20)
* Note: shops below this threshold: East 11-9; West 7-25, 7-26, 8-25, 8-37)
sort _ID
by _ID: gen tid = _n
by _ID: egen max_bold = max(bold)
list _ID building vendor_street vendor_address max_bold if tid==1 & max_bold < 20
drop if bold < 20

* Drop readings below threshold of BOLD < 300
* Note: one shop is excluded by this threshold: West 8-37, BOLD reading = 88
list building vendor_street vendor_address sampleid sampleinfo bold if max_bold < 300
drop if bold < 300

* Reshape into one record per vendor, with multiple readings sorted by # DNA matches
gsort _ID  - bold
by _ID: gen vid = _n
keep _ID building vendor_street vstall_address _CX _CY ///
     sampleid samplingdate sampleinfo bold vid
reshape wide sampleid samplingdate sampleinfo bold, i(_ID) j(vid)
order _ID building vendor_street vstall_address 
list building vendor_street vstall_address sampleid1 sampleinfo1 bold1 
save "Datasets/raccoondog_dna_locations_index.dta", replace

* Create shapefile of raccoon dog vendor stalls
merge 1:m _ID using "Maps/Huanan_market_map_shp.dta"
drop if _merge < 3
drop _merge _CX _CY
sort _ID shape_order
save "Datasets/raccoondog_dna_locations_shp.dta", replace

