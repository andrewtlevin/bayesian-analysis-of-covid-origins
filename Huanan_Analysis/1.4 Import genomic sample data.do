* Import genomic data from Liu et al. (2023) NCBI Repository
* https://www.ncbi.nlm.nih.gov/bioproject/PRJNA948658 
import excel using "Rawdata/Liu et al. 2023 Genomic Samples.xlsx", ///
  clear sheet("Data") firstrow case(lower)
drop if missing(samplename)  
keep if inlist(isolation_source,"East Wing of HSM","West Wing of HSM")
gen sampleid = substr(samplename,1,8)
rename librarylayout layout
rename avgspotlen avglen
gen mfrags = cond(layout=="SINGLE", mbases/avglen, 0.5*mbases/avglen)
keep sampleid instrument layout mfrags avglen

* Reshape into one record per sampleid
sort sampleid layout
by sampleid: gen tid = _n
reshape wide instrument layout avglen mfrags, i(sampleid) j(tid)
replace instrument2 = "MIXED" if !missing(instrument3) & instrument2!=instrument3
replace layout2 = "MIXED" if !missing(layout3) & layout2!=layout3
replace mfrags2 = mfrags2+mfrags3 if !missing(mfrags3)
replace avglen2 = (mfrags2*avglen2+mfrags3*avglen3)/(mfrags2+mfrags3) ///
  if !missing(avglen3) 
gen mfrags = cond(missing(mfrags2), mfrags1, mfrags1 + mfrags2)
gen instrument = cond(missing(instrument2) | instrument1==instrument2, ///
                      instrument1, "MIXED")
gen layout = cond(missing(layout2) | layout1==layout2, layout1, "MIXED")
gen avglen = cond(missing(avglen2), avglen1, ///
                      (mfrags1*avglen1 + mfrags2*avglen2)/mfrags)
drop instrument1-instrument3 layout1-layout3 mfrags1-mfrags3 avglen1-avglen3  

* Merge with vendor index and drop three external samples
* Note: sample Env_0033 is garbage cart on Street 7, and 
*       Env_0839 and Env_0842 are from Street 5 (wall & ground, vendor NA)	 
* Note: we keep stalls with RT-qPCR but no DNA analysis (_merge==2)
merge 1:1 sampleid using "Datasets/environmental_test_stall_index.dta"
drop if _merge==1

* Tabulate DNA sampling by date
gen dna_flag = cond(_merge==3, 1, 0)
gen pos_flag = cond(sarscov2=="Positive", 1, 0)
gen tsample = cond(samplingdate==mdy(1,1,2020), 1, ///
              cond(samplingdate==mdy(1,12,2020), 2, ///
			  cond(inrange(samplingdate,mdy(1,13,2020),mdy(1,31,2020)), 3, 4)))
label define TSAMPLE 1 "01jan2020" 2 "12jan2020" 3 "13-31jan2020" 4 "feb-mar2020"
label values tsample TSAMPLE			  
sort tsample _ID
by tsample _ID: gen svid = _n
by tsample _ID: gen sv_flag = 1
by tsample _ID: egen svpos_flag = max(pos_flag)
by tsample _ID: egen svdna_flag = max(dna_flag)
by tsample _ID: egen svdna_count = total(dna_flag)
table tsample (var), stat(total sv_flag pos_flag dna_flag)
table tsample (var) if svid==1, stat(total svid svpos_flag svdna_flag)

* Tabulate information by vendor
keep if _merge==3
gen nreads_sarscov2 = real(readsaligned)
sort _ID
by _ID: gen vvid = _n
by _ID: egen vsarscov2 = max(nreads_sarscov2)
by _ID: egen mindate = min(samplingdate)
by _ID: egen maxdate = max(samplingdate)
by _ID: egen meanfrags = mean(mfrags)
by _ID: egen meanlen = mean(avglen)
format mindate maxdate %td
tab maxdate if vvid==1 
summ meanfrags, detail
summ meanlen, detail

* Tabulate DNA samples per vendor
keep if vvid==1
keep _ID building vendor_street vendor_address svpos_flag svdna_flag svdna_count ///
     vsarscov2 mindate maxdate meanfrags meanlen 
table svpos_flag, stat(median vsarscov2) stat(min vsarscov2) stat(max vsarscov2)	 

gen nsamples = cond(svdna_count==0, 0, ///
               cond(svdna_count==1, 1, ///
               cond(svdna_count<=5, 2, ///
			   cond(svdna_count<=10, 3, 4))))
tab nsamples
tab svpos_flag svdna_flag

* List vendors where samples were collected on multiple dates
gen vstreet = cond(inlist(vendor_street,"Accessory Street","Back Street"), 0, ///
                   real(vendor_street))
gen tloc = strpos(vendor_address,"-")
gen xflag = cond(substr(vendor_address,1,1)=="X", 1, 0)
gen vaddress = cond(tloc > 0 & xflag==1, real(substr(vendor_address,2,tloc-2)), ///
               cond(tloc==0 & xflag==1, real(substr(vendor_address,2,.)), ///
               cond(tloc > 0, real(substr(vendor_address,1,tloc-1)), real(vendor_address)))) 
sort building vstreet vaddress
list _ID building vendor_street vendor_address svpos_flag svdna_count mindate maxdate ///
  if mindate < maxdate
			   
* Make illustrative map of DNA samples by vendor location
quietly colorpalette HTML, global			   
grmap nsamples ///
  using "Maps/Huanan_market_map_shp.dta", ///
  id(_ID) clmethod(unique) ndocolor(black) ndfcolor(none) ///
  ocolor(none ..) fcolor($Lime $Coral $Orange $Red $Maroon) ///
  polygon(data("Maps/Huanan_market_map_shp.dta") ///
          fcolor(none) ocolor(black)) ///
  legend(order(- "# DNA Samples" 2 3 4 5 6) ///
         label(2 "None") ///
         label(3 "1") ///
         label(4 "2 to 5") ///
		 label(5 "6 to 10") ///
		 label(6 "11 to 25")) ///
  name(dnasamples_map, replace)	
graph export "Figures/DNA Samples Per Vendor.tif", ///
  replace  
  
* Make illustrative map of latest collection date for DNA samples

grmap maxdate if svdna_flag > 0 ///
  using "Maps/Huanan_market_map_shp.dta", ///
  id(_ID) clmethod(unique) ndocolor(black) ndfcolor(none) ///
  ocolor(none ..) fcolor(Rainbow) ///
  polygon(data("Maps/Huanan_market_map_shp.dta") ///
          fcolor(none) ocolor(black)) ///
  legend(order(- "Date" 2 3 4 5 6 7 8) ///
         label(2 "01 Jan") ///
         label(3 "12 Jan") ///
		 label(4 "29 Jan") ///
		 label(5 "03 Feb") ///
		 label(6 "20 Feb") ///
		 label(7 "25 Feb") ///
		 label(8 "02 Mar")) ///
  name(dnasampledates_map, replace)	
graph export "Figures/DNA Samples By Date.tif", ///
  replace  
  
* Make map of RT-qPCR results for vendors with DNA samples
grmap svpos_flag if svdna_flag > 0 ///
  using "Maps/Huanan_market_map_shp.dta", ///
  id(_ID) clmethod(unique) ndocolor(black) ndfcolor(none) ///
  ocolor(none ..) fcolor(green cranberry) ///
  polygon(data("Maps/Huanan_market_map_shp.dta") ///
          fcolor(none) ocolor(black)) ///
  legend(order(- "RT-qPCR Test" 2 3) ///
         label(2 "Negative") label(3 "Positive")) ///		  
  name(dna_vs_rtqpcr_map, replace)	
graph export "Figures/DNA vs. RT-qPCR Results.tif", ///
  replace  
