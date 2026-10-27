********************************************************************************
***                                                                          ***
*** Replication package for:                                                 ***
***   "The civic side of tax compliance: Evidence from Italy"                ***
***   Economics Letters 252 (2025) 112346                                    ***
***   doi:10.1016/j.econlet.2025.112346                                      ***
***                                                                          ***
*** Authors: Francesca Maria Calamunci & Federico Fabio Frattini             ***
***                                                                          ***
*** This master file rebuilds every dataset from the raw files in data/raw,  ***
*** then produces every table and figure of the paper in output/.            ***
*** See README.md for data sources, software and the exhibit-to-file map.    ***
***                                                                          ***
********************************************************************************
version 18
clear all
set more off
set maxvar 32676 // inherited from the original code; not strictly needed


***********************************
**# ***	  	  DIRECTORIES 	    ***
***********************************
* >>> THE ONLY LINE YOU NEED TO EDIT <<<
* Set the path to the folder that contains this master.do. Use forward slashes.
global root "C:/path/to/package"

* R is used for the maps (Figures 3, A.1 and A.2). Set the path to Rscript, or
* set run_R to 0 to skip the maps and run the three R scripts by hand later.
global run_R   1
global Rscript "C:/Program Files/R/R-4.4.2/bin/Rscript.exe"

* sub-folders (do not edit)
global code    "$root/code"
global raw     "$root/data/raw"
global derived "$root/data/derived"
global tables  "$root/output/tables"
global figures "$root/output/figures"
global logs    "$root/output/logs"
cd "$root"

* create output folders if they do not exist
foreach d in "$derived" "$root/output" "$tables" "$figures" "$logs" {
	cap mkdir "`d'"
}

cap log close _all
log using "$logs/master.log", text replace name(master)
di "Run started: `c(current_date)' `c(current_time)'  -  Stata `c(stata_version)' (`c(edition_real)')"


***********************************
**# ***	  USER-WRITTEN PACKAGES	***
***********************************
* The package was verified with the versions below (see README.md):
*   reghdfe 6.12.5, ftools 2.49.1, estout 3.31 (esttab 2.1.1, estpost 1.2.2),
*   binscatter 7.02, mipolate 1.2.0, carryforward 4.5
* Missing packages are installed from SSC; installed ones are left untouched.
* (recent versions of reghdfe, 6.13 and later, also need the -require- package)
foreach p in ftools require reghdfe estout binscatter mipolate carryforward {
	cap which `p'
	if _rc {
		di as txt "Installing `p' from SSC"
		ssc install `p'
	}
}
* ftools must be compiled once after installation
cap ftools, compile
* print the versions actually used in this run
foreach p in reghdfe ftools require estout esttab estpost binscatter mipolate carryforward {
	cap noi which `p'
}


***********************************
**# ***	   DATA CONSTRUCTION	***
***********************************
* one do-file per data source, then the merge
do "$code/01_controls_istat.do"            // ISTAT census controls 1951-2011
do "$code/02_referendum_turnout.do"        // Eligendo referendum turnout
do "$code/03_european_turnout.do"          // Eligendo European elections turnout
do "$code/04_voluntary_associations.do"    // Durante, Pinotti & Tesei (2019) voluntary associations
do "$code/05_merge.do"                     // merge all sources -> data/derived/tv_tax_social_capital.dta


***********************************
**# ***	   TABLES AND FIGURES	***
***********************************
do "$code/table_1.do"      // Table 1   - municipality-level regressions
do "$code/figure_1.do"     // Figure 1  - municipality-level binscatters
do "$code/table_2.do"      // Table 2   - province-level regressions
do "$code/figure_2.do"     // Figure 2  - province-level binscatters
do "$code/figure_4.do"     // Figure 4  - TV fee compliance by decade and macro-area
do "$code/table_A2.do"     // Table A.2 - descriptive statistics
* Table A.1 (description of variables) is text only and has no code.

* maps (R)
if $run_R == 1 {
	* erase the maps of a previous run first, so that a failed R step cannot
	* pass unnoticed (Stata's -shell- does not return R's exit status)
	foreach f in figure_3 figure_A1a figure_A1b figure_A1c figure_A2a figure_A2b figure_A2c figure_A2d {
		cap erase "$figures/`f'.png"
	}
	foreach f in figure_3 figure_A1 figure_A2 {
		di as txt "Running `f'.R"
		shell "$Rscript" "$code/`f'.R" "$root" > "$logs/`f'_R.log" 2>&1
	}
	* stop if a map was not produced (see output/logs/figure_*_R.log)
	foreach f in figure_3 figure_A1a figure_A1b figure_A1c figure_A2a figure_A2b figure_A2c figure_A2d {
		confirm file "$figures/`f'.png"
	}
}

di "Run ended: `c(current_date)' `c(current_time)'"
log close master
