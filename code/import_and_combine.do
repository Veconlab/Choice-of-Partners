**********************
* Erica Sprott
* Choice of Partners Trust Game
* Import and combine data for analysis
* Outputs new dataset with combined sessions
* 2022-10-26
**********************


clear all

global cop_folder "C:\Users\ers725\Documents\Choice of Partners\\"

forvalues s=4/9{
	import excel "${cop_folder}mgc`s'.xlsx", firstrow
	tempfile mgc`s'
	save `mgc`s''
	clear
}

use `mgc4', clear

forvalues s=5/9{
	append using `mgc`s''
}

save "${cop_folder}combined_session.dta", replace