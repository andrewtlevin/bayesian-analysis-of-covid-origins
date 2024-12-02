***************************
* Table S6B (SARS-CoV-2 NGS data)
***************************
* Liu et al. (2023) consider non-3'-polyA reads as valid
* and 3'-poly-A reads as invalid
import excel sampleid all_reads valid_reads invalid_reads ///
  using "Rawdata/Liu et al. 2023 Supplementary Data", ///
  clear sheet("Table S6B") cellrange(A2:D173) 

summ invalid_reads if invalid_reads > 0, detail
count if invalid_reads > 100  
summ valid_reads if valid_reads > 0, detail
gen pos_dna = cond(valid_reads > 0, 1, 0)
keep sampleid pos_dna
  
* Merge with environmental sample info 
* Note: _merge = 1 for trash cart (Env_0033), storage units (Env_0872 & 0868), 
*        and sewage samples (Env_0788, 0815-0821 & 0830) 
*       _merge = 2 for samples with insufficient quality for NGS analysis
merge m:1 sampleid using "Datasets/environmental_test_stall_index.dta"
drop if _merge==1
drop _merge
replace pos_dna = -1 if missing(pos_dna)
tab sarscov2 pos_dna
tab sarscov2 pos_dna if pos_dna >= 0
table sarscov2 (pos_dna result) if pos_dna >= 0, stat(freq) stat(percent, across(pos_dna))
exit

* Tabulate results by vendor
sort _ID
by _ID: gen tid = _n
by _ID: egen vpos_qpcr = max(cond(sarscov2=="Positive", 1, 0))
by _ID: egen vpos_dna = max(pos_dna)
tab vpos_qpcr vpos_dna if tid==1 
table vif tid==1 & vpos_dna >= 0
keep if tid==1
* Merge with case data
merge 1:1 _ID using "Maps/vendor_case_locations.dta"
tab vpos_qpcr vpos_dna if _merge==3 

