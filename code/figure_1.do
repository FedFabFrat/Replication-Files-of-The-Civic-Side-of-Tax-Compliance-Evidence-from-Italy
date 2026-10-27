********************************************************************************
*** figure_1.do                                                              ***
*** Figure 1: Correlates of TV fee compliance and other municipality social  ***
***           capital measures (binned scatter plots).                       ***
*** Output:   output/figures/figure_1a.png (referendum turnout)              ***
***           output/figures/figure_1b.png (European elections turnout)      ***
***           output/figures/figure_1c.png (N. voluntary associations)       ***
*** Source:   original economics_letters_2.do, lines 246-329                 ***
*** The regression in each block re-estimates the Table 1 model only to      ***
*** print its coefficient and stars in the figure caption.                   ***
********************************************************************************
version 18
do "$code/06_analysis_setup.do"


**# (a) Referendum turnout and TV tax **
eststo tref: reghdfe turnout_ref d100f_tv_ $controls, a(codcom decade) vce(cl codcom)
local coeff = r(table)[1,1]
local coeff3: display %6.3f `coeff'
scalar pval = r(table)[4,1]
if pval <= 0.10 & pval > 0.05 {
	local star = "*"
}
else if pval <= 0.05 & pval > 0.01 {
	local star = "**"
}
else if pval <= 0.01 {
	local star = "***"
}
else {
	local star = ""
}
local fsc2 `coeff3'`star'
binscatter turnout_ref d100f_tv_, absorb(codcom) controls(i.decade $controls) n(100) ///
		legend(order(1 "Scatter" 3 "Fitted values" 2 "CI") size(medium)) ///
		mcolor(navy) lcolor(cranberry) ///
		xtitle("TV tax compliance compliance", size(medsmall) margin(medsmall)) ytitle("Referendum turnout (100)", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small)) ///
		caption("Turn. Ref{subscript:it} = {&alpha} + `fsc2'TV tax compl.{subscript:it} + {&gamma}X{subscript:it} + {&eta}{subscript:i} + {&tau}{subscript:t} + {&epsilon}{subscript:it}")
graph export "$figures/figure_1a.png", replace


**# (b) European elections turnout and TV tax **
eststo teur: reghdfe turnout_europee d100f_tv_ $controls, a(codcom decade) vce(cl codcom)
local coeff = r(table)[1,1]
local coeff3: display %6.4f `coeff'
scalar pval = r(table)[4,1]
if pval <= 0.10 & pval > 0.05 {
	local star = "*"
}
else if pval <= 0.05 & pval > 0.01 {
	local star = "**"
}
else if pval <= 0.01 {
	local star = "***"
}
else {
	local star = ""
}
local fsc2 `coeff3'`star'
binscatter turnout_europee d100f_tv_, absorb(codcom) controls(i.decade $controls) n(100) ///
		legend(order(1 "Scatter" 3 "Fitted values" 2 "CI") size(medium)) ///
		mcolor(navy) lcolor(cranberry) ///
		xtitle("TV tax compliance compliance", size(medsmall) margin(medsmall)) ytitle("European elections turnout (100)", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small)) ///
		caption("Turn. Euro{subscript:it} = {&alpha} + `fsc2'TV tax compl.{subscript:it} + {&gamma}X{subscript:it} + {&eta}{subscript:i} + {&tau}{subscript:t} + {&epsilon}{subscript:it}")
graph export "$figures/figure_1b.png", replace


**# (c) N. civic associations and TV tax **
eststo civi: reghdfe civic d100f_tv_ $controls, a(codcom decade) vce(cl codcom)
local coeff = r(table)[1,1]
local coeff3: display %6.3f `coeff'
scalar pval = r(table)[4,1]
if pval <= 0.10 & pval > 0.05 {
	local star = "*"
}
else if pval <= 0.05 & pval > 0.01 {
	local star = "**"
}
else if pval <= 0.01 {
	local star = "***"
}
else {
	local star = ""
}
local fsc2 `coeff3'`star'
binscatter civic d100f_tv_, absorb(codcom) controls(i.decade $controls) n(100) ///
		legend(order(1 "Scatter" 3 "Fitted values" 2 "CI") size(medium)) ///
		mcolor(navy) lcolor(cranberry) ///
		xtitle("TV tax compliance compliance", size(medsmall) margin(medsmall)) ytitle("N. civic associations * 1000 people", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small)) ///
		caption("N. Civic Ass.{subscript:it} = {&alpha} + `fsc2'TV tax compl.{subscript:it} + {&gamma}X{subscript:it} + {&eta}{subscript:i} + {&tau}{subscript:t} + {&epsilon}{subscript:it}")
graph export "$figures/figure_1c.png", replace
* (original also exported each figure to the authors' Overleaf folder; removed)
