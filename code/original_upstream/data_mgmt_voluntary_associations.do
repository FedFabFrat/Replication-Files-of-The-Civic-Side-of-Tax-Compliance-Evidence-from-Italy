clear all
set more off

*********** HERE YOU TYPE 1 ON YOUR NAME AND 0 OTHERWISE *****************
global federico 1
global francesca 0
**************************************************************************

if("$federico" == "1") {
global dropbox "C:\path\to\mafia_social_capital"
global data "C:\path\to\mafia_social_capital\dati"
global mafia "C:\path\to\mafia_social_capital\dati\mafia"
global social_capital "C:\path\to\mafia_social_capital\dati\social capital"
global output "C:\path\to\mafia_social_capital\output"
global tables_pres "C:\path\to\mafia_social_capital\presentations\Al Capone\update_tables"
global draft "C:\path\to\mafia_social_capital\draft\tables"
}

if("$francesca" == "1") {
global data "C:\path\to\mafia_social_capital\dati"
global mafia "C:\path\to\mafia_social_capital\dati\mafia"
global social_capital "C:\path\to\mafia_social_capital\dati\social capital"
global output "C:\path\to\mafia_social_capital\output"
 
}
*


** open pinotti aer municipality data **
use "$social_capital\replication pinotti_durante aer\data_DPT\municipality-level_data.dta", clear

* keep if year == 2001, choice of year is irrelevant (it is!!!!) *
bys istat: gen asd = _n == 1
keep if asd == 1

* drop southern regions *
drop if reg >= 13

* rename istat codcom and comune for merge *
rename istat codcom
rename comune comune_vol_ass

* keep relevant variables *
keep codcom comune_vol_ass provcapital longitude latitude sll2001 district area area2 altitude altitude2 ruggedness highschool_college81 civic81 lnincome income firmspop81 workers81 civic91 civic01

* save dataset *
save "$social_capital\n_voluntary_associations_wide.dta", replace
