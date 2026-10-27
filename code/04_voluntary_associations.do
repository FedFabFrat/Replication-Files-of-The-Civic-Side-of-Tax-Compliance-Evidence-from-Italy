********************************************************************************
*** 04_voluntary_associations.do                                             ***
*** Number of voluntary associations per inhabitant in 1981, 1991 and 2001,  ***
*** from the replication data of Durante, Pinotti & Tesei (2019, AER).        ***
*** Input:  data/raw/durante_pinotti_tesei_2019/municipality-level_data.dta  ***
*** Output: data/derived/n_voluntary_associations_wide_updt.dta              ***
***                                                                          ***
*** Provenance note: the authors' builder for an earlier, Centre-North-only  ***
*** version of this file is data_mgmt_voluntary_associations.do (kept in     ***
*** code/original_upstream/). The all-Italy file used by the paper           ***
*** ("_updt") had no surviving builder. This do-file reconstructs it: same   ***
*** steps, without the Southern-regions drop, keeping the 12 variables of    ***
*** the file used. Its output is identical to the file used by the paper     ***
*** (Stata -cf-, all 12 variables, 8,086 obs).                               ***
********************************************************************************
version 18

** open DPT municipality-level data (municipality x election year panel) **
use "$raw/durante_pinotti_tesei_2019/municipality-level_data.dta", clear

* keep one row per municipality (the variables used are time-invariant) *
bys istat: gen asd = _n == 1
keep if asd == 1

* rename for the merge *
rename istat codcom

* keep relevant variables *
keep codcom comune reg region prov province sll2001 area altitude civic81 civic91 civic01
order codcom comune reg region prov province sll2001 area altitude civic81 civic91 civic01

* save dataset *
save "$derived/n_voluntary_associations_wide_updt.dta", replace
