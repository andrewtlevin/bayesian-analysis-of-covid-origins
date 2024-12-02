**************************************
* Table S6A (NCBI Nucleotide database)
**************************************
* Import lineage information
import excel using "Rawdata/Liu et al. 2023 Supplementary Data", ///
  clear sheet("Table S6A") firstrow cellrange(A2) case(lower)
keep genus lineage
replace lineage = "Viruses>Coronaviruses>SARS-CoV-2" ///
  if substr(genus,1,12)=="Severe acute" 
replace lineage = "Viruses>Deltavirus" if lineage=="Viruses" & genus=="Deltavirus"
gen cellular_flag = cond(substr(lineage,1,8)=="cellular", 1, 0)
gen viruses_flag = cond(substr(lineage,1,7)=="Viruses", 1, 0)
tab cellular_flag viruses_flag
quietly replace lineage = substr(lineage,25,.) if cellular_flag==1
gen domain = substr(lineage,1,strpos(lineage,">")-1)
tab domain
gen mammal_flag = cond(strpos(lineage,"Mammalia")>0, 1, 0)
keep if mammal_flag==1
keep genus lineage 
save "Temp/Liu_NCBI_mammal_genera.dta", replace

* Import NCBI readings, reshape into one observation per test/genus,
* and keep observations with positive NCBI readings
* Note: two genera in Table 6A (Parocnus and Xenothrix) are extinct
* but both of those genera had zero NCBI readings 
import excel using "Rawdata/Liu et al. 2023 Supplementary Data", ///
  clear sheet("Table S6A") firstrow cellrange(A2) case(lower)
gen domain = cond(strpos(lineage,"Eukaryota") > 0, "Eukaryota","Other Domains")
drop lineage
reshape long env, i(genus) j(env_code) string
rename env NCBI
keep if NCBI > 0

* Tabulate total reads for each environmental test
gen sampleid = "Env" + env_code
sort sampleid
by sampleid: egen tot_allreads = total(NCBI)
gen NCBI_mil = (10^6)*NCBI/tot_allreads

* Merge with lineage information and keep observations for mammalian genera
* Note: _merge = 1 for non-mammalians, 2 for mammal genera with zero NCBI readings
merge m:1 genus using "Temp/Liu_NCBI_mammal_genera.dta"
keep if _merge==3
keep sampleid genus NCBI NCBI_mil tot_allreads 

* Merge with environmental sample info 
* Note: _merge = 1 for samples from sewers, external locations, or other markets
*       _merge = 2 for samples with insufficient quality for BOLD analysis
merge m:1 sampleid using "Datasets/environmental_test_stall_index.dta"
keep if _merge==3
drop sampletype _merge

* Merge with mammal genus information (order, family, genus, common name)
* Note: _merge==2 for mammalian genera which had no positive NCBI readings
merge m:1 genus using "Datasets/mammal_genera_list.dta"  
drop if _merge==2
drop _merge
save "Datasets/Liu_Table_S6A_NCBI.dta", replace

* Tabulate genera with NCBI readings > threshold of 100 per million reads
use "Datasets/Liu_Table_S6A_NCBI.dta", clear
keep if !missing(NCBI_mil) & NCBI_mil > 100

* Endangered Species
list genus sampleid samplingdate NCBI_mil building vendor_street vendor_address sampleinfo ///
  if inlist(genus,"Acinonyx","Ailuropoda","Enhydra","Loxodonta","Lontra","Lutra","Lynx","Panthera","Sarcophilus")
* Primates
list genus sampleid samplingdate NCBI_mil building vendor_street vendor_address sampleinfo ///
  if inlist(genus,"Callithrix","Macaca","Pan") 
* Mammals observed at Huanan Market 
list genus sampleid samplingdate NCBI_mil building vendor_street vendor_address sampleinfo ///
   if inlist(genus,"Erinaceus","Meles","Melogale","Mustela","Nyctereutes","Rhizomys")

* Tabulate key statistics by genus
gen ncbi100 = cond(NCBI_mil > 100, 1, 0)
gen ncbi1000 = cond(NCBI_mil > 1000, 1, 0)
gen exotic_flag = cond(inlist(genus,"Ailuropoda","Loxodonta","Panthera","Lynx", ///
                           "Lontra","Enhydra","Lutra","Acinonyx", "Sarcophilus") ///
                     | inlist(genus,"Pan","Macaca","Callithrix"), 1, 0)
sort genus
by genus: gen igenus = _n
by genus: egen gmaxreads = max(NCBI_mil)
by genus: egen gcount100 = total(ncbi100)
by genus: egen gcount1000 = total(ncbi1000)
gsort igenus - gmaxreads
gen glabel = string(_n,"%03.0f") + " " + genus + ": " + genus_desc
table (glabel) (var result) (exotic_flag) ///
  if igenus==1 & (exotic_flag | gmaxreads > 1000), ///
  stat(max gmaxreads) stat(max gcount100) stat(max gcount1000) nototals
  
* Tabulate key statistics by vendor  
sort genus _ID 
by genus _ID: gen ivflag = _n
by genus _ID: egen vncbi100_flag = max(ncbi100)
by genus _ID: egen vncbi1000_flag = max(ncbi1000)
gen vncbi100 = cond(ivflag==1,vncbi100_flag,0)
gen vncbi1000 = cond(ivflag==1,vncbi1000_flag,0)
by genus: gen iflag = _n
by genus: egen totvendors100 = total(vncbi100)
by genus: egen totvendors1000 = total(vncbi1000)
gen vstreet = cond(strlen(vendor_street)==1, "0"+vendor_street, vendor_street)
gen vaddress = cond(strpos(vendor_address,"-")==0, vendor_address, ///
                    substr(vendor_address,1,strpos(vendor_address,"-")-1))
replace vaddress = "26" if _ID==12102 & vaddress=="28"					
gen vlabel = building + " " + vstreet + "-" + vaddress
table (genus) (var) if ivflag==1 & gmaxreads > 1000, ///
  stat(total vncbi100 vncbi1000)
gsort - gmaxreads  

* List stalls with raccoon dogs  
list _ID vlabel vncbi100 vncbi1000 if ivflag==1 & genus=="Nyctereutes" & vncbi100 > 0  


