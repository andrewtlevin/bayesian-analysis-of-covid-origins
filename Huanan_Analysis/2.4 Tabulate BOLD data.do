* Import list of mammal genera
import excel using "Rawdata/List of Mammal Genera.xlsx", ///
  clear firstrow case(lower)
save "Datasets/mammal_genera_list.dta", replace
  
* Import data and keep positive BOLD readings
import excel using "Rawdata/Liu et al. 2023 Supplementary Data", ///
  clear sheet("Table S8") firstrow cellrange(A2) case(lower)
reshape long env, i(genus) j(env_code) string
rename env bold
drop if bold==0
gen sampleid = "Env" + env_code

* Merge with environmental sample info 
* Note: _merge = 1 for samples from sewers, external locations, or other markets
*       _merge = 2 for samples with insufficient quality for BOLD analysis
merge m:1 sampleid using "Datasets/environmental_test_stall_index.dta"
keep if _merge==3 | sampleid=="Env_0033"
replace samplingdate = mdy(1,1,2020) if sampleid=="Env_0033"
replace labcode = "A33" if sampleid=="Env_0033"
replace sarscov = "Positive" if sampleid=="Env_0033"
replace readsaligned = "8" if sampleid=="Env_0033"
replace sampleinformation = "garbage cart" if sampleid=="Env_0033"
replace vendor_street = "7" if sampleid=="Env_0033"
replace vendor_address = "0" if sampleid=="Env_0033"
drop sampletype _merge

* Merge with list of mammal genera (order, family, genus, common name)
* Note: some entries in Table S8 specify order or family instead of genus
*       (presumably when genus is not clear) and are excluded here:
*       artiodactyla, chiroptera, didelphimorphia, eulipotyphla, 
*       hylobatidae, mammalia, primates, and rodentia
* Note: Table S8 also includes two exinct genera (homotherium and mammuthus)
*       and numerous avian genera
merge m:1 genus using "Datasets/mammal_genera_list.dta"
keep if _merge==3 | inlist(genus,"Homotherium","Mammuthus")
drop _merge
replace genus_desc = "saber-tooth cat (extinct)" if genus=="Homotherium"
replace genus_desc = "mammoth (extinct)" if genus=="Mammuthus"
save "Datasets/Liu_Table_S8_BOLD.dta", replace

* Identify genera with BOLD readings 
keep if !missing(bold) & (bold > 20 | inlist(genus,"Mammuthus","Homotherium"))

* Extinct species
list genus sampleid samplingdate bold building vendor_street vendor_address sampleinfo ///
  if inlist(genus,"Mammuthus","Homotherium")
  
* Endangered Species
list genus sampleid samplingdate bold building vendor_street vendor_address sampleinfo ///
  if inlist(genus,"Ailurus","Dicerorhinus","Elephas","Loxodonta","Panthera","Profelis", ///
                  "Puma","Rhinoceros")
* Primates
list genus sampleid samplingdate bold building vendor_street vendor_address sampleinfo ///
  if inlist(genus,"Callimico","Callithrix","Cercopithecus","Hylobates","Macaca", ///
    "Sapajus","Semnopithecus","Symphalangus","Trachypithecus") 

* Mammals observed at Wuhan markets 
list genus sampleid samplingdate bold building vendor_street vendor_address sampleinfo ///
   if inlist(genus,"Erinaceus","Meles","Melogale","Mustela","Nyctereutes","Rhizomys")

* Tabulate key statistics by genus
gen bold20 = cond(bold > 20, 1, 0)
gen bold1200 = cond(bold > 1200, 1, 0)
gen exotic_flag = cond(inlist(genus,"Mammuthus","Homotherium") ///
  | inlist(genus,"Ailurus","Dicerorhinus","Elephas","Loxodonta", ///
                 "Panthera","Profelis","Puma","Rhinoceros") ///
  | inlist(genus,"Callimico","Callithrix","Cercopithecus","Hylobates","Macaca") ///
  | inlist(genus,"Arctonyx", "Muntiacus", "Myocaster", "Paguma", "Vulpes") /// 
  | inlist(genus,"Sapajus","Semnopithecus","Symphalangus","Trachypithecus"), 1, 0)
sort genus
by genus: gen igenus = _n
by genus: egen gmaxreads = max(bold)
by genus: egen gcount20 = total(bold20)
by genus: egen gcount1200 = total(bold1200)
gsort igenus - gmaxreads
gen glabel = string(_n,"%03.0f") + " " + genus + ": " + genus_desc
table (glabel) (var result) (exotic_flag) ///
  if igenus==1 & (exotic_flag | gmaxreads > 20), ///
  stat(max gmaxreads) stat(max gcount20) stat(max gcount1200) nototals
table (glabel) (var result) if igenus==1 ///
  & (inlist(genus,"Erinaceus","Hystrix","Meles","Melogale","Marmota") ///
   | inlist(genus,"Arctonyx", "Muntiacus", "Myocaster", "Neovison", "Paguma", "Vulpes") /// 
   | inlist(genus,"Lepus","Mustela","Myocastor","Nyctereutes","Rhizomys")), ///
  stat(max gmaxreads) stat(max gcount20) stat(max gcount1200) nototals

* Tabulate key statistics by vendor  
sort _ID genus
by _ID genus: gen ivflag = _n
by _ID genus: egen vbold20 = max(bold20)
by _ID genus: egen vbold1200 = max(bold1200)
gen vstreet = cond(strlen(vendor_street)==1, "0"+vendor_street, vendor_street)
gen vaddress = cond(strpos(vendor_address,"-")==0, vendor_address, ///
                    substr(vendor_address,1,strpos(vendor_address,"-")-1))				
replace vaddress = "26" if _ID==12102 & vaddress=="28"					
gen vlabel = building + " " + vstreet + "-" + vaddress
table (genus) (var) if ivflag==1 & gmaxreads > 1200, ///
  stat(total vbold20 vbold1200)
  
* List stalls with raccoon dogs    
list _ID vlabel vbold20 vbold1200 if ivflag==1 & genus=="Nyctereutes" & vbold20 > 0  
  
* Save list of vendors with BOLD reads > 1200 for at least one mammal genus
keep if ivflag==1 & vbold1200==1 & genus!="Homo"
gen rdkey = cond(genus=="Nyctereutes", 1, 0)
sort _ID genus
by _ID: gen vid = _n
by _ID: egen rdflag = max(rdkey)
keep _ID building vendor_street vendor_address rdflag vid genus
reshape wide genus, i(_ID) j(vid)
save "Datasets/bold1200_mammal_shop_list.dta", replace
gsort - rdflag building vendor_street vendor_address
list _ID building vendor_street vendor_address rdflag