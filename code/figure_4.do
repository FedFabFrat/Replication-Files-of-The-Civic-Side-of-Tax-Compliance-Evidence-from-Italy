********************************************************************************
*** figure_4.do                                                              ***
*** Figure 4: TV fee compliance by decade and macro-area.                    ***
*** Output:   output/figures/figure_4.png                                    ***
*** Source:   original economics_letters_2.do, lines 232-243                 ***
********************************************************************************
version 18
do "$code/06_analysis_setup.do"


**# TV tax overtime by macro areas **
preserve
collapse (mean) d100f_tv_, by(mac_area decade)
twoway 	(connected d100f_tv_ decade if mac_area == "N", lc(navy) ms(O) lp(solid) mc(navy) lw(medthick) msize(medlarge)) ///
		(connected d100f_tv_ decade if mac_area == "C", lc(cranberry) ms(D) lp(dash) mc(cranberry) lw(medthick) msize(medlarge)) ///
		(connected d100f_tv_ decade if mac_area == "S", lc(gs8) ms(T) lp(dash_dot) mc(gs8) lw(medthick) msize(medlarge)), ///
		legend(pos(6) cols(3) order(1 "North" 2 "Centre" 3 "South") size(medium)) 	///
		xtitle("Decades", size(medsmall) margin(medsmall)) ytitle("TV tax compliance compliance", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small))
graph export "$figures/figure_4.png", replace
restore
* (original also exported the figure to the authors' Overleaf folder; removed)
