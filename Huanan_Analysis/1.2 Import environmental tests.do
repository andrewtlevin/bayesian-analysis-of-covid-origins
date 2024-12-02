* Import environmental samples for external tests (trash cart & staircase)
import excel using ///
  "Rawdata/Huanan external test locations.xlsx", ///
  clear sheet("External") firstrow case(preserve)
gen etest_id = _n  
save "Datasets/external_test_locations.dta", replace

* Import environmental sample data from Liu et al. Table S1
import excel using "Rawdata/Liu et al. 2023 Supplementary Data", ///
  clear sheet("Table S1") firstrow cellrange(A3:R1383) case(lower)
replace sampleid = "Env_0002" if substr(sampleid,1,8)=="Env_0002"  
format samplinglocation %-36s
format sampletype %-24s
tab samplinglocation sampletype
tab samplinglocation sarscov2 if substr(sampletype,1,13)=="Environmental"
tab samplinglocation sarscov2 if substr(sampletype,1,6)=="Animal"
  
* Tabulate positive Bowtie2 samples for two vendors (6-29/31/33 and 8-25)
* and one sewer sample; see Liu et al. (p.408) and note in Table S6B
list sampleid sampletype street vendornoa ///
  if inlist(substr(sampleid,5,4), "0552","0576","0585","0788")
  
* Tabulate animal swabs taken from mammals
tab animal if substr(sampletype,1,11)=="Animal swab" ///
  & inlist(animal,"Badger","Bamboo Rat","Hedgehog","Muntjac", ///
                  "Rabbit/Hares","Sheep","Wild boar")
				  
* Focus on environmental swabs (718 samples)
keep if inlist(samplinglocation,"East Wing of HSM","West Wing of HSM") ///
  & sampletype=="Environmental swab" 
gen building = substr(samplingloc,1,4)
drop samplinglocation animalspecies
count
  
* Fix a few address glitches in Liu et al. Table S1
rename street vendor_street
rename vendornoa vendor_address
* glitch: vendor address listed as "NA" but location in Figure 1 = East Bldg Street 2 
replace vendor_address = "52" ///
  if inlist(sampleid,"Env_0285","Env_0286","Env_0287","Env_0288")
* glitch: inconsistent street address for this vendor (44 vs. X44)
replace vendor_address = "X44" if inrange(real(substr(sampleid,5,4)),134,138)

* Tabulate and exclude 32 environmental samples taken outside of market stalls
list sampleid samplingdate building vendor_street sampleinformation sarscov2 ///
  if vendor_address=="NA" | strpos(vendor_address,"stair") > 0
drop if vendor_address=="NA" | strpos(vendor_address,"stair") > 0
  
* For vendors with multiple stalls, use first stall in the specified address
* so we need to identify which stall matches index 
gen vstall_address = cond(strpos(vendor_address,"-")==0, vendor_address, ///
                          substr(vendor_address,1,strpos(vendor_address,"-")-1))
* adjust stall assignments for three idiosyncratic stalls on Street 2
replace vstall_address = "X6" if inlist(sampleid,"Env_0381","Env_0382")
replace vstall_address = "8" if inlist(sampleid,"Env_0360","Env_0361")
replace vstall_address = "11" if inlist(sampleid,"Env_0349","Env_0350","Env_0351","Env_0352")
merge m:1 building vendor_street vstall_address ///
  using "Maps/Huanan_stall_index.dta"
drop if _merge < 3
drop _merge 
save "Datasets/environmental_test_stall_index.dta", replace

* Tabulate test results by vendor (aggregating across individual stalls)
use "Datasets/environmental_test_stall_index.dta", clear
gen dnaflag = cond(readsaligned=="NA", 0, 1)
gen posflag = cond(sarscov2=="Positive", 1, 0)
gen negflag = cond(sarscov2=="Negative", 1, 0)
order _ID building vendor_street vstall_address
sort _ID 
by _ID: gen tid = _n
by _ID: egen totdna = total(dnaflag)
by _ID: egen totpos = total(posflag)
by _ID: egen totneg = total(negflag)
keep if tid==1
replace totneg = 0 if missing(totneg)
replace totpos = 0 if missing(totpos)
replace totdna = 0 if missing(totdna)

* Merge with complete list of vendors
rename _CX stall_X
rename _CY stall_Y
merge 1:1 _ID using "Maps/Huanan_market_map_index.dta"
gen sarscov2_flag = cond(missing(totpos) & missing(totneg), 0, ///
                    cond(totpos > 0, 2, 1))
sort _ID
keep _ID _CX _CY building vendor_street vendor_address ///
  totpos totneg totdna sarscov2_flag
save "Datasets/environmental_test_vendor_index.dta", replace
  
* Make illustrative map
use "Datasets/environmental_test_vendor_index.dta", clear
grmap sarscov2_flag ///
  using "Maps/Huanan_market_map_shp.dta", ///
  id(_ID) clmethod(unique) ndocolor(black) ndfcolor(none) ///
  ocolor(black ..) fcolor(none green red) ///
  point(data("Datasets/external_test_locations.dta") ///
        by(etest_id) xcoord(_CX) ycoord(_CY) ///
		size(small ..) shape(square circle) fcolor(red ..)) ///
  legend(order(4 3 5 6) ///
         label(4 "Positive RT-PCR") ///
		 label(3 "Negative RT-PCR") ///
		 label(5 "Trash Cart") label(6 "Staircase")) ///
  name(envtest_vendor_map, replace)	
