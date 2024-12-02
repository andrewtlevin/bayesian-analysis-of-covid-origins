* Tabulate RT-qPCR tests by surface
use "Datasets/environmental_test_stall_index.dta", clear
gen pos_test = cond(sarscov2=="Positive",1,0)
gen sampinfo = lower(sampleinfo)
gen surface = cond(strpos(sampinfo,"floor") > 0, "floor", ///
  cond(strpos(sampinfo,"ground") > 0, "floor", ///
  cond(strpos(sampinfo,"wall") > 0, "wall", ///
  cond(strpos(sampinfo,"shutter") > 0, "shutters", ///
  cond(strpos(sampinfo,"door") > 0, "door", ///
  cond(strpos(sampinfo,"shelf") > 0, "counter/shelf", ///
  cond(strpos(sampinfo,"table") > 0, "counter/shelf", ///
  cond(strpos(sampinfo,"refrigerator") > 0, "refrigerator/freezer", ///
  cond(strpos(sampinfo,"freezer") > 0, "refrigerator/freezer", ///
  cond(strpos(sampinfo,"machine") > 0, "machine", ///
  cond(strpos(sampinfo,"cashier") > 0, "machine", ///
  cond(strpos(sampinfo,"monitor") > 0, "machine", ///
  cond(strpos(sampinfo,"scale") > 0, "machine", ///
  cond(strpos(sampinfo,"lift") > 0, "machine", ///
  cond(strpos(sampinfo,"chopping board") > 0, "board", ///
  cond(strpos(sampinfo,"chopping block") > 0, "board", ///
  cond(strpos(sampinfo,"container") > 0, "container", ///
  cond(strpos(sampinfo,"basin") > 0, "container", ///
  cond(strpos(sampinfo,"bag") > 0, "container", ///
  cond(strpos(sampinfo,"cup") > 0, "container", ///
  cond(strpos(sampinfo,"box") > 0, "container", ///
  cond(strpos(sampinfo,"basket") > 0, "container", ///
  cond(strpos(sampinfo,"bucket") > 0, "container", ///
  cond(strpos(sampinfo,"fishbowl") > 0, "container", ///
  cond(strpos(sampinfo,"pool") > 0, "container", "other")))))))))))))))))))))))))
quietly replace surface = "cart" if strpos(sampinfo,"cart") > 0
quietly replace surface = "cage" if strpos(sampinfo,"cage") > 0
quietly replace surface = "food items" if strpos(sampinfo,"food") ///
   + strpos(sampinfo,"mushroom") + strpos(sampinfo,"package") > 0
quietly replace surface = "kitchen utensil" if strpos(sampinfo,"knife") ///
   + strpos(sampinfo,"knief") + strpos(sampinfo,"knier") ///
   + strpos(sampinfo,"scissors") + strpos(sampinfo,"tongs") > 0
quietly replace surface = "fishing item" ///
   if strpos(sampinfo,"net") + strpos(sampinfo,"fishbow") > 0 
quietly replace surface = "cleaning item" if strpos(sampinfo,"mop") ///
  + strpos(sampinfo,"dustpan") + strpos(sampinfo,"filter") > 0
quietly replace surface = "clothing" if strpos(sampinfo,"shoe") ///
   + strpos(sampinfo,"glove") + strpos(sampinfo,"cloth") ///
   + strpos(sampinfo,"towel") + strpos(sampinfo,"apron") ///
   + strpos(sampinfo,"white foam") > 0
quietly replace surface = "gas/water tank" ///
  if strpos(sampinfo,"gas") + strpos(sampinfo,"water") > 0
quietly replace surface = "chair" if strpos(sampinfo,"chair") //
quietly replace surface = "stair" if strpos(sampinfo,"stair") > 0
quietly replace surface = "ladder" if strpos(sampinfo,"ladder") > 0
quietly replace surface = "sink/drain" if strpos(sampinfo,"sink") ///
   + strpos(sampinfo,"drain") + strpos(sampinfo,"sewage") > 0
quietly replace surface = "machine" ///
  if strpos(sampinfo,"calculator") + strpos(sampinfo,"phone") ///
   + strpos(sampinfo,"light") > 0
quietly replace surface = "motorcycle" if sampinfo=="motorcycle"  
quietly replace surface = "trash cans" ///
  if strpos(sampinfo,"trash cans") + strpos(sampinfo,"trush cans") > 0
quietly replace surface = "not specified" if sampinfo=="environmental swab"
gen surface_type = cond(surface=="not specified", "not specified", ///
  cond(inlist(surface,"floor","door","shutters","wall","counter/shelf", ///
                      "stair","sink/drain"), "fixed", ///
  cond(inlist(surface,"machine","refrigerator/freezer","motorcycle","cart") ///
     | inlist(surface,"ladder","cage","chair","gas/water tank"), "large items", ///
       "small items")))
sort surface_type surface
by surface_type surface: gen isurf = _n
by surface_type surface: gen nsurf = _N
by surface_type surface: egen npos_surf = total(pos_test)
gsort surface_type - nsurf
table surface_type if isurf==1, stat(total nsurf npos_surf) 
list surface_type surface nsurf npos_surf if isurf==1, noobs
table if isurf==1, stat(total nsurf npos_surf)

gen surface_cat = cond(inlist(surface,"floor","door","container","clothing"), surface, ///
  cond(surface_type=="fixed", "wall/shutters", ///
  cond(surface_type=="machine"|surface=="refrigerator/freezer", "machine/appliance", ///
  cond(surface_type=="large items", "other large items", "miscellaneous items"))))
table surface_cat, stat(count pos_test) stat(percent) stat(total pos_test) ///
   stat(mean pos_test) nformat(%5.3f mean)			  

* Illustrative list for shop at West 7-26 (with 20 swabs collected on three dates)
sort _ID sampleid
by _ID: gen tid = _n
list building vendor_street vendor_address if _ID==9204 & tid==1, noobs
list sampleid sampinfo sarscov2 if _ID==9204 & samplingdate==mdy(1,1,2020), noobs
list sampleid sampinfo sarscov2 if _ID==9204 & samplingdate==mdy(2,3,2020), noobs
list sampleid sampinfo sarscov2 if _ID==9204 & samplingdate==mdy(3,2,2020), noobs

* Illustrative list for shop at 6-29 (with 33 swabs)
list building vendor_street vendor_address if _ID==11104 & tid==1, noobs
list sampleid samplingdate sampinfo sarscov2 if _ID==11104, noobs
drop tid

* Tabulate RT-qPCR tests by sampling date
gen sample_timing = cond(samplingdate<=mdy(1,31,2020), samplingdate, mdy(2,1,2020))
format sample_timing %td
table sample_timing sarscov2
sort sample_timing sarscov2 _ID
by sample_timing sarscov2 _ID: gen tid = _n
by sample_timing sarscov2 _ID: gen tcount = _N
table sample_timing sarscov2 if tid==1, stat(total tid)

* Tabulate tests by market shop, 01 & 12 Jan 2020
gen early_flag = cond(samplingdate<=mdy(1,12,2020), 1, 0)
sort early_flag _ID
by early_flag _ID: gen ttid = _n
by early_flag _ID: egen pos_flag = max(pos_test)
table if early_flag==1 & ttid==1, stat(total ttid pos_flag)

* Tabulate tests by market shop, all dates
sort _ID surface_cat pos_test
by _ID: gen vid = _n
by _ID: gen vnum = _N
by _ID: egen vpos_flag = max(pos_test)
by _ID: egen vpos_num = total(pos_test)
by _ID surface_cat: gen vsid = _n
by _ID surface_cat: egen surf_poscount = total(pos_test) 
by _ID surface_cat: gen surf_testflag = cond(_n==1, 1, 0)
by _ID surface_cat pos_test: gen surf_posflag = cond(_n==1 & pos_test==1, 1, 0)
by _ID: egen surf_totpos = total(surf_posflag)
gen vpos_pct = 100*vpos_num/vnum
format vpos_pct %4.1f

* List info for 7 positive samples collected after 12 Jan 2020
sort _ID samplingdate
list _ID building vendor_street vendor_address vnum vpos_num sampleid samplingdate sampinfo ///
  if samplingdate > mdy(1,12,2020) & sarscov2=="Positive", noobs
 
* Tabulate shops by number of tests & positive results
gen vclass = cond(inrange(vnum,1, 4), 1, ///
             cond(inrange(vnum,5,9), 5, ///
			 cond(inrange(vnum,10,20), 10, vnum)))
label define VCLASS 1 "1-4" 5 "5-9" 10 "10-20" 
label values vclass VCLASS			 
table if vid==1, stat(total vid vpos_flag)
sort building vendor_street vstall_address
list _ID building vendor_street vstall_address vnum vpos_num if vid==1 & vpos_num > 1, noobs
tab vpos_num if vid==1
table vclass if vid==1, ///
   stat(total vid vnum vpos_num vpos_flag) nformat(%3.0f total) ///
   stat(median vnum vpos_num) nformat(%2.0f median) ///
   stat(mean vpos_pct) nformat(%3.1f mean)
   
* Tabulate shops by type of test (fixed surface or miscellaneous item)
tab surf_testflag surf_totpos if vid==1   
table surface_cat, ///
   stat(total surf_testflag surf_posflag)
   
list _ID building vendor_street vstall_address samplingdate sampinfo ///
  if surface_type=="fixed" & surf_poscount > 0, noobs
list _ID building vendor_street vstall_address samplingdate sampinfo ///
  if surface_type!="fixed" & sarscov2=="Positive", noobs
list _ID building vendor_street vstall_address surface_type ///
  if vsid==1 & surf_totpos > 1 & surf_poscount > 0, noobs
list _ID building vendor_street vstall_address sampinfo ///
  if inlist(_ID,12102,11104,22103,9106) & surface_type!="fixed" ///
      & sarscov2=="Positive", noobs

* Tabulate shops by date of tests
sort _ID samplingdate
by _ID: egen vfirstdate = min(samplingdate) 	  
by _ID: egen vlastdate = max(samplingdate) 	  
by _ID: egen vmeandate = mean(samplingdate) 	  
format v*date %td	  
tab vfirstdate if vid==1
tab vlastdate if vid==1
summ vmeandate if vid==1, detail
   
* Tabulate tests and confirmed cases
* Note: _merge = 1 for market shops where no confirmed case was identified
*       _merge = 2 for confirmed cases in shops where no test was conducted
keep if vid==1
keep _ID building vendor_street vstall_address vpos_flag vnum vpos_num vpos_pct
merge 1:1 _ID using "Maps/vendor_case_locations.dta"
gen vtest_flag = cond(_merge==2, 0, 1)
tab vtest_flag if _merge>1
tab vpos_flag if _merge==3
