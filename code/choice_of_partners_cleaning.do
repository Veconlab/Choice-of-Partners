*******************************************
* Erica Sprott
* Cleans choice of partners data from Veconlab website
* Originally 2022-09-22
* Updated 
*******************************************


global cop_folder "C:\Users\ers725\Documents\Choice of Partners\\"

clear all

import excel "${cop_folder}choice_of_partners_data.xlsx", firstrow
drop OtherHistory MarkedInkBombString
rename Session session
rename Round round
rename NewPairing is_new_pair
rename PairNumber pair_number
rename ID id
rename OtherID partner_id
rename OwnScale own_scale
rename OtherScale partner_scale
rename Scale scale
rename Decision amount_passed
rename OtherDecision amount_passed_back
rename PairEarnings pair_earnings
rename Earnings earnings
rename CumulativeEarnings total_earnings
rename InkBombBoxesMarked risk
rename InkBombBoxEarnings inkbomb_earnings


* Get rid of empty observations
drop if session == ""

replace risk = "" if risk == "****"
destring risk, replace
ereplace risk = mean(risk), by (id)


* Replace -1 with 0

replace own_scale = 0 if own_scale == -1
replace scale = 0 if scale == -1
replace partner_scale = 0 if partner_scale == -1

* Gender: 0 if male, 1 if female

gen gender = 0
replace gender = 1 if id == 1| id == 2 | id == 4 | id == 6 | id == 7 | id == 11

local sess = "session[1]"
local sess2: display `sess'


export excel "${cop_folder}`sess2'.xlsx", firstrow(var) replace