********************************************************************************
*** figure_2.do                                                              ***
*** Figure 2: Correlates of TV fee compliance and other provincial social    ***
***           capital measures (binned scatter plots).                       ***
*** Output:   output/figures/figure_2a.png (blood donations)                 ***
***           output/figures/figure_2b.png (CONI)                            ***
***           output/figures/figure_2c.png (newspapers sold)                 ***
***           output/figures/figure_2d.png (trust)                           ***
*** Source:   original economics_letters_2.do, lines 332-453                 ***
*** The regression in each block re-estimates the Table 2 model only to      ***
*** print its coefficient and stars in the figure caption.                   ***
********************************************************************************
version 18
do "$code/06_analysis_setup.do"


**# (b) N. CONI associations and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) coni_registered, by(prov)
eststo coni: reghdfe coni_registered d100f_tv_ popolazione_residente, noa vce(cl prov)
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
binscatter coni_registered d100f_tv_, controls(popolazione_residente) n(100) ///
		legend(order(1 "Scatter" 3 "Fitted values" 2 "CI") size(medium)) ///
		mcolor(navy) lcolor(cranberry) ///
		xtitle("TV tax compliance", size(medsmall) margin(medsmall)) ytitle("N. CONI associations / 1000 people", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small)) ///
		caption("N. CONI.{subscript:p} = {&alpha} + `fsc2'TV tax compl.{subscript:p} + {&gamma}X{subscript:p} + {&epsilon}{subscript:p}")
graph export "$figures/figure_2b.png", replace
restore


**# (a) N. blood donations and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) donation, by(prov)
eststo dona: reghdfe donation d100f_tv_ popolazione_residente, noa vce(cl prov)
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
binscatter donation d100f_tv_, controls(popolazione_residente) n(100) ///
		legend(order(1 "Scatter" 3 "Fitted values" 2 "CI") size(medium)) ///
		mcolor(navy) lcolor(cranberry) ///
		xtitle("TV tax compliance", size(medsmall) margin(medsmall)) ytitle("N. blood donations", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small)) ///
		caption("N. Blood Don.{subscript:p} = {&alpha} + `fsc2'TV tax compl.{subscript:p} + {&gamma}X{subscript:p} + {&epsilon}{subscript:p}")
graph export "$figures/figure_2a.png", replace
restore


**# (c) N. sold newspaper and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) daily_newsp, by(prov)
eststo news: reghdfe daily_newsp d100f_tv_ popolazione_residente, noa vce(cl prov)
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
binscatter daily_newsp d100f_tv_, controls(popolazione_residente) n(100) ///
		legend(order(1 "Scatter" 3 "Fitted values" 2 "CI") size(medium)) ///
		mcolor(navy) lcolor(cranberry) ///
		xtitle("TV tax compliance", size(medsmall) margin(medsmall)) ytitle("N. of non-sport newspapers sold / 1000", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small)) ///
		caption("N. Sold Newsp.{subscript:p} = {&alpha} + `fsc2'TV tax compl.{subscript:p} + {&gamma}X{subscript:p} + {&epsilon}{subscript:p}")
graph export "$figures/figure_2c.png", replace
restore


**# (d) Trust and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) trust, by(prov decade)
eststo trus: reghdfe trust d100f_tv_ popolazione_residente, noa vce(cl prov)
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
binscatter trust d100f_tv_, controls(popolazione_residente) n(100) ///
		legend(order(1 "Scatter" 3 "Fitted values" 2 "CI") size(medium)) ///
		mcolor(navy) lcolor(cranberry) ///
		xtitle("TV tax compliance", size(medsmall) margin(medsmall)) ytitle("Trust (WVS)", size(medsmall) margin(medsmall)) ///
		xlabel(, nogrid labsize(small) glc(gs10%25)) ylabel(, labsize(small)) ///
		caption("Trust{subscript:p} = {&alpha} + `fsc2'TV License{subscript:p} + {&gamma}X{subscript:p} + {&epsilon}{subscript:p}")
graph export "$figures/figure_2d.png", replace
restore
* (original also exported each figure to the authors' Overleaf folder; removed)
