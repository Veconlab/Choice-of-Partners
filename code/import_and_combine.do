**********************
* Erica Sprott
* Choice of Partners Trust Game
* Import and combine data for analysis
* Outputs new dataset with combined sessions
* Written 2022-10-26
* Updated 2025-06-23
**********************


clear all

*define user and filepaths
global cop_folder "/Users/ericasprott/Documents/with_charlie_holt/trust_paper/"
global data "${cop_folder}data/"

forvalues s=4/13{
	import excel "${data}mgc`s'.xlsx", firstrow
	tempfile mgc`s'
	save `mgc`s''
	clear
}

use `mgc4', clear

forvalues s=5/13{
	append using `mgc`s''
}


* Data prep:
gen cross_pass = cond(session == "mgc4" | session == "mgc5" | session == "mgc8" | session == "mgc10" | session == "mgc13", 1, 0) // treatment assignment 
gen new_pair = cond(is_new_pair == "y", 1, 0)
drop is_new_pair

* keep only first movers (ID 1-6 in most sessions, ID 5 in session mgc12)
keep if inrange(id, 1, 6) 
drop if session=="mgc12" & id == 6 

isid session round id partner_id
compress
save "${data}S1_combined_session.dta", replace
