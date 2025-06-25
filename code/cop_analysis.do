**************************
* Erica Sprott
* Choice of Partners Trust Game Figures
* Written 2022-10-26
* Updated 2025-06-23
**************************
clear all

*define user and filepaths

global cop_folder "/Users/ericasprott/Documents/with_charlie_holt/trust_paper/"
global data "${cop_folder}data/"
global figures "${cop_folder}figures/"
global jefferson_blue  "35 45 75"
global virginia_orange "248 76 30"
global img pdf


* FIGURES 
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*

use "${data}S1_combined_session.dta", clear
isid session round id partner_id
tab session


**Statistics of Interest*****
* 1. Percent of Active Links
* 2. Average Pass Amounts
* 3. Average Return Amounts
*****************************

gen ones = 1
collapse (sum) potential_active_links = ones ///
	total_active = scale ///
	total_passed = amount_passed ///
	total_returned = amount_passed_back ///	
	(firstnm) cross_pass, by(session round) 
		
* Cap potential links in later rounds based on session population
replace potential_active_links = 18 if potential_active_links > 18 // 12 people sessions
replace potential_active_links = 15 if potential_active_links > 15 & session == "mgc12" // 10 person session


* BAR GRAPHS: COLLAPSE BY SESSION 
*------------------------------------------------------------------------------*

preserve

collapse (rawsum) potential_active_links total_active total_passed total_returned ///
	(firstnm) cross_pass, ///
	by(session)

gen percent_active = total_active / potential_active_links * 100
	
* scale up session-level pass amounts for mgc12, which only had 10 participants instead of the usual 12
replace total_passed = total_passed * (6/5) if session == "mgc12"
replace total_returned = total_returned * (6/5) if session == "mgc12"
	
	
* put no cross pass sessions on the left
gen sess_num = cond(session == "mgc11", 1, cond(session == "mgc12", 2, cond(session == "mgc6", 3, cond(session == "mgc7", 4, cond(session == "mgc9", 5, cond(session == "mgc10", 6, cond(session == "mgc13", 7, cond(session == "mgc4", 8, cond(session == "mgc5", 9, 10)))))))))


* percent active links by session
twoway (bar percent_active sess_num if cross_pass == 0, barwidth(0.75) color("${jefferson_blue}")) ///
	(bar percent_active sess_num if cross_pass == 1, barwidth(0.75) color("${virginia_orange}")) ///
	, ///
	ylabel(, axis(1) angle(0) nogrid) ///		
	ytitle("Average Active Links") ///
	legend(off) ///
	ylabel(0 "0%" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%") ///
	xlabel(3 "No Cross Pass" 8 "Cross Pass") ///
	xtitle("")
	graph export "${figures}pp_active_links_by_session.${img}", replace
		
* total pass by session
twoway (bar total_passed sess_num if cross_pass == 0, barwidth(0.75) color("${jefferson_blue}")) ///
	(bar total_passed sess_num if cross_pass == 1, barwidth(0.75) color("${virginia_orange}")) ///
	, ///
	ylabel(, axis(1) angle(0) nogrid) ///		
	ytitle("Total Pass Amount for All Rounds") ///
	legend(off) ///
	ylabel(0(100)500) ///
	xlabel(3 "No Cross Pass" 8 "Cross Pass") ///
	xtitle("")
	graph export "${figures}total_pass_by_session.${img}", replace
	
* total return by session 
twoway (bar total_returned sess_num if cross_pass == 0, barwidth(0.75) color("${jefferson_blue}")) ///
	(bar total_returned sess_num if cross_pass == 1, barwidth(0.75) color("${virginia_orange}")) ///
	, ///
	ylabel(, axis(1) angle(0) nogrid) ///		
	ytitle("Total Return Amount for All Rounds") ///
	legend(off) ///
	ylabel(0(100)900) ///
	xlabel(3 "No Cross Pass" 8 "Cross Pass") ///
	xtitle("")
	graph export "${figures}total_return_by_session.${img}", replace		
		
	
restore


* TW CONNECTED: COLLAPSE BY ROUND 
*------------------------------------------------------------------------------*

collapse (rawsum) potential_active_links total_active total_passed total_returned, ///
	by(round cross_pass)

sort cross_pass round	
gen percent_active = total_active / potential_active_links * 100
	
* percent active by round
twoway (connected percent_active round if cross_pass == 1, color("${virginia_orange}")) ///
	(connected percent_active round if cross_pass == 0, color("${jefferson_blue}")) ///
	, ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross Pass") label(2 "No Cross Pass") col(1) ring(0) pos(2)) ///
	ytitle("Percent Active Links") ///
	xtitle("Round") ///
	xlabel(1(1)10) ///
	ylabel(50 "50%" 60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%")
	graph export "${figures}pp_active_links_by_round.${img}", replace

* total passed by round 
twoway (connected total_pass round if cross_pass == 1, color("${virginia_orange}")) ///
	(connected total_pass round if cross_pass == 0, color("${jefferson_blue}")) ///
	, ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross Pass") label(2 "No Cross Pass") col(1) ring(0) pos(4)) ///
	ytitle("Total Pass Amount") ///
	xtitle("Round") ///
	xlabel(1(1)10) 
	graph export "${figures}total_pass_by_round.${img}", replace
	
* total returned by round 
twoway (connected total_returned round if cross_pass == 1, color("${virginia_orange}")) ///
	(connected total_returned round if cross_pass == 0, color("${jefferson_blue}")) ///
	, ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross Pass") label(2 "No Cross Pass") col(1) ring(0) pos(4)) ///
	ytitle("Total Return Amount") ///
	xtitle("Round") ///
	xlabel(1(1)10) 
	graph export "${figures}total_return_by_round.${img}", replace

	
	
use "${data}S1_combined_session.dta", clear

collapse (sum) amount_passed amount_passed_back ///
	(firstnm) cross_pass, by(session round id)
collapse (mean) amount_passed amount_passed_back /// 
	, by(round cross_pass)
sort cross_pass round
gen max_pass = cond(round == 1, 3, cond(round == 2, 6, 9))	
	
* average pass by round 
twoway (connected amount_passed round if cross_pass == 1, color("${virginia_orange}")) ///
	(connected amount_passed round if cross_pass == 0, color("${jefferson_blue}"))  ///
	(connected max_pass round if cross_pass == 0, color(gray) lpattern(dash)) ///
	, ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross Pass") label(2 "No Cross Pass") label(3 "Maximum Possible Pass") col(1) ring(0) pos(4)) ///
	ytitle("Average Pass Amount") ///
	xtitle("Round") ///
	xlabel(1(1)10) ///
	ylabel(0 "$0" 2 "$2" 4 "$4" 6 "$6" 8 "$8" 10 "$10")
	graph export "${figures}avg_pass_by_round.${img}", replace
	
	
* average return by round 
twoway (connected amount_passed_back round if cross_pass == 1, color("${virginia_orange}")) ///
	(connected amount_passed_back round if cross_pass == 0, color("${jefferson_blue}"))  ///
	(connected max_pass round if cross_pass == 0, color(gray) lpattern(dash)) ///
	, ///
	ylabel( ,axis(1) angle(0) nogrid) ///
	legend(label(1 "Cross Pass") label(2 "No Cross Pass") lab(3 "Maximum Pass") ring(0) pos(4) col(1)) ///
	ytitle("Average Return Amount") ///
	xtitle("Round") ///
	xlabel(1(1)10) 
	graph export "${figures}avg_return_by_round.${img}", replace
	

	  