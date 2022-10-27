**************************
* Erica Sprott
* Choice of Partners Trust Game
* Analysis exploratory
* 2022-10-26
**************************

global cop_folder "C:\Users\ers725\Documents\Choice of Partners\\"
global figures "C:\Users\ers725\Documents\Choice of Partners\figures\\"

use "${cop_folder}combined_session.dta", clear
isid session round id partner_id

* Data prep:
gen cross_pass = cond(session == "mgc4" | session == "mgc5" | session == "mgc8", 1, 0)
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

* Gen number of potential links

gen ones = 1

collapse (sum) potential_active_links = ones total_active = scale ///
		total_passed = amount_passed total_returned = amount_passed_back ///	
		(firstnm) cross_pass, by(session round) 
		
	* Note: potential links are capped at 18 -- 
	replace potential_active_links = 18 if potential_active_links > 18

***********************
* Collapse on round:
* Bar graphs for session averages
***********************
//preserve

collapse (sum) potential_active_links total_active total_passed total_returned ///
	(firstnm) cross_pass, by(session)

	gen percent_active = total_active / potential_active_links * 100
	gen avg_pass = total_passed / total_active 
	gen avg_return = total_returned / total_active
	
	
* Split into two treatment groups
	gen percent_active_cross = cond(cross_pass == 1, percent_active, .)
	gen percent_active_nocross = cond(cross_pass == 0, percent_active, .)
	gen avg_pass_cross = cond(cross_pass == 1, avg_pass, .)
	gen avg_pass_nocross = cond(cross_pass == 0, avg_pass, .)
	gen avg_return_cross = cond(cross_pass == 1, avg_return, .)
	gen avg_return_nocross = cond(cross_pass == 0, avg_return, .)
 

graph bar percent_active_cross percent_active_nocross, over(session) ///
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
		
		
		
		
graph bar avg_pass_cross avg_pass_nocross, over(session) ///
	ylabel(, axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	blabel(total, format(%4.2f)) ///
	ytitle("Average pass amount") ///
	title("Session-level average pass amounts", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	bar(1, color("248 76 30") fintensity(80)) ///
	bar(2, color("35 45 75") fintensity(80)) ///
	bargap(-100)

	graph export "${figures}avg_pass_by_session.pdf", replace
		
		
	
graph bar avg_return_cross avg_return_nocross, over(session) ///
	ylabel(, axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	blabel(total, format(%4.2f)) ///
	ytitle("Average return amount") ///
	title("Session-level average return amounts", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	bar(1, color("248 76 30") fintensity(80)) ///
	bar(2, color("35 45 75") fintensity(80)) ///
	bargap(-100)

	graph export "${figures}avg_return_by_session.pdf", replace
		
		
restore



**********************
* Collapse on session
**********************

preserve

collapse (sum) potential_active_links total_active total_passed total_returned, ///
	by(round cross_pass)

	
	gen percent_active = total_active / potential_active_links * 100
	gen avg_pass = total_passed / total_active 
	gen avg_return = total_returned / total_active
	
	sort cross_pass round
	
	
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
	xlabel(1(1)10)
	
	graph export "${figures}pp_active_links_by_round.pdf", replace
	
twoway connected avg_pass round if cross_pass == 1, mcolor("248 76 30") lcolor("248 76 30") ///
	|| connected avg_pass round if cross_pass == 0, ///
	mcolor("35 45 75") lcolor("35 45 75") ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	ytitle("Average pass amount") ///
	xtitle("Round") ///
	title("Average pass amount in each round", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	xlabel(1(1)10)
	
	graph export "${figures}avg_pass_by_round.pdf", replace
	
	
	twoway connected avg_return round if cross_pass == 1, mcolor("248 76 30") lcolor("248 76 30") ///
	|| connected avg_return round if cross_pass == 0, ///
	mcolor("35 45 75") lcolor("35 45 75") ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross pass") label(2 "No cross pass") col(1) region(lwidth(none))) ///
	ytitle("Average return amount") ///
	xtitle("Round") ///
	title("Average return amount in each round", col(black) span) ///
	subtitle("By treatment type", col(black) span) ///
	graphregion(color(white)) ///
	xlabel(1(1)10)
	
	graph export "${figures}avg_return_by_round.pdf", replace
	
restore




	