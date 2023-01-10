**************************
* Erica Sprott
* Choice of Partners Trust Game
* Written 2022-10-26
* Updated 2023-01-09
**************************
clear all
// Change these globals to match your file paths //
global cop_folder "C:\Users\ers725\Documents\Choice of Partners\\"
global figures "C:\Users\ers725\Documents\Choice of Partners\figures\\"

***********************
* Import and combine
***********************
forvalues s=4/11{
	import excel "${cop_folder}mgc`s'.xlsx", firstrow
	tempfile mgc`s'
	save `mgc`s''
	clear
}

use `mgc4', clear
forvalues s=5/11{
	append using `mgc`s''
}
save "${cop_folder}combined_session.dta", replace

**********************
* Figures
**********************

use "${cop_folder}combined_session.dta", clear
isid session round id partner_id

* Data prep:
gen cross_pass = cond(session == "mgc4" | session == "mgc5" | session == "mgc8" | session == "mgc10", 1, 0)
gen new_pair = cond(is_new_pair == "y", 1, 0)
drop is_new_pair
keep if inrange(id, 1, 6)


**Statistics of Interest*****
* 1. Percent of Active Links
* 2. Average Pass Amounts
* 3. Average Return Amounts
*****************************

* Jefferson Blue  "35 45 75"
* Virginia Orange "248 76 30"

gen ones = 1
collapse (sum) potential_active_links = ones ///
	total_active = scale ///
	total_passed = amount_passed ///
	total_returned = amount_passed_back ///	
	(firstnm) cross_pass, by(session round) 
		
* Note: potential links are capped at 18 -- 
replace potential_active_links = 18 if potential_active_links > 18

***********************
* Collapse by session: Bar Graphs
***********************
preserve

collapse (rawsum) potential_active_links total_active total_passed total_returned ///
	(firstnm) cross_pass, ///
	by(session)

	gen percent_active = total_active / potential_active_links * 100
	
* Split into two treatment groups
	gen percent_active_cross = cond(cross_pass == 1, percent_active, .)
	gen percent_active_nocross = cond(cross_pass == 0, percent_active, .)
	gen total_passed_cross = cond(cross_pass == 1, total_passed, .)
	gen total_passed_nocross = cond(cross_pass == 0, total_passed, .)
	

graph bar percent_active_cross percent_active_nocross, over(session, label(nolab)) ///
	ylabel(, axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	blabel(total, format(%4.2f)) ///
	ytitle("Average percent active links") ///
	title("Session-level percent of active links", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	bar(1, color("248 76 30") fintensity(80)) ///
	bar(2, color("35 45 75") fintensity(80)) ///
	bargap(-100) 

	graph export "${figures}pp_active_links_by_session.pdf", replace
		
	
graph bar total_passed_cross total_passed_nocross, over(session, label(nolab)) ///
	ylabel(, axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	blabel(total, format(%4.2f)) ///
	ytitle("Total pass amount") ///
	title("Session-level total pass amounts", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	bar(1, color("248 76 30") fintensity(80)) ///
	bar(2, color("35 45 75") fintensity(80)) ///
	bargap(-100)

	graph export "${figures}total_pass_by_session.pdf", replace
		
restore

**********************
* Collapse by round
**********************

collapse (rawsum) potential_active_links total_active total_passed total_returned, ///
	by(round cross_pass)

sort cross_pass round	
gen percent_active = total_active / potential_active_links * 100
	
twoway connected percent_active round if cross_pass == 1, mcolor("248 76 30") lcolor("248 76 30") ///
	|| connected percent_active round if cross_pass == 0, ///
	mcolor("35 45 75") lcolor("35 45 75") ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	ytitle("Percent active links") ///
	xtitle("Round") ///
	title("Percent active links in each round", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	xlabel(1(1)10) ///
	ylabel(0(10)100)
	
	graph export "${figures}pp_active_links_by_round.pdf", replace

	
	twoway connected total_pass round if cross_pass == 1, mcolor("248 76 30") lcolor("248 76 30") ///
	|| connected total_pass round if cross_pass == 0, ///
	mcolor("35 45 75") lcolor("35 45 75") ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	ytitle("Total pass amount") ///
	xtitle("Round") ///
	title("Total pass amount in each round", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	xlabel(1(1)10) ///
	ylabel(0(15)150)
	
	graph export "${figures}total_pass_by_round.pdf", replace


global cop_folder "C:\Users\ers725\Documents\Choice of Partners\\"
global figures "C:\Users\ers725\Documents\Choice of Partners\figures\\"

use "${cop_folder}combined_session.dta", clear
isid session round id partner_id

* Data prep:
gen cross_pass = cond(session == "mgc4" | session == "mgc5" | session == "mgc8" | session == "mgc10", 1, 0)
gen new_pair = cond(is_new_pair == "y", 1, 0)
drop is_new_pair
keep if inrange(id, 1, 6)
keep if scale == 1

collapse (sum) amount_passed amount_passed_back ///
	(firstnm) cross_pass, by(session round id)
collapse (mean) amount_passed amount_passed_back /// 
	, by(round cross_pass)
sort cross_pass round
gen max_pass = cond(round == 1, 3, cond(round == 2, 6, 9))	
	
	
twoway connected amount_passed round if cross_pass == 1, mcolor("248 76 30") lcolor("248 76 30") ///
	|| connected amount_passed round if cross_pass == 0, mcolor("35 45 75") lcolor("35 45 75")  ///
	|| connected max_pass round if cross_pass == 0, mcolor(gray) ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") label(3 "Maximum pass") col(1) region(lwidth(none))) ///
	ytitle("Average pass amount") ///
	xtitle("Round") ///
	title("Average pass amount in each round", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	xlabel(1(1)10) ///
	ylabel(0(1)10)
	
	graph export "${figures}avg_pass_by_round.pdf", replace
	
	
	twoway connected amount_passed_back round if cross_pass == 1, mcolor("248 76 30") lcolor("248 76 30") ///
	|| connected amount_passed_back round if cross_pass == 0, mcolor("35 45 75") lcolor("35 45 75")  ///
	|| connected max_pass round if cross_pass == 0, mcolor(gray) ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") lab(3 "Maximum pass") col(1) region(lwidth(none))) ///
	ytitle("Average return amount") ///
	xtitle("Round") ///
	title("Average return amount in each round", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	xlabel(1(1)10) 
	
	graph export "${figures}avg_return_by_round.pdf", replace