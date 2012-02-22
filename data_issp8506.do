// SETUP

* Options.
global graphs=0
set scheme set1 // Edwin Leuven's conversion of Color Brewer Set1

* Path.
cd "~/Documents/Research/Data/ISSP/"

* Log.
cap log close _all
log using data_issp8506.log, replace

* Data.
use "rog/ZA4747_F1.dta", clear

// VARIABLES

* Structure:
ren V4 yr
ren V6 cty
ren V7 ctyr
ren WEIGHT wgt

* Variables:
* exp = expenditure (should spend, 5-point scale)
* lic = license (should do, 4-point scale)
ren V36 exp1 // health
ren V52 lic1
ren V40 exp2 // pensions
ren V53 lic2
ren V41 exp3 // unemployment
ren V55 lic3
ren V35 exp4 // environment (control)
ren V59 lic4

* Recode: License.
foreach v of varlist lic* {
	ren `v' x`v'
	qui recode x`v' (1/2=1) (3/4=0) (else=.), gen(`v') // rescaled [0,1]
}

* Recode: Expenditure.
foreach v of varlist exp* {
	ren `v' x`v'
	qui recode x`v' (1/2=1) (3=0) (4/5=-1) (else=.), gen(`v') // rescaled [-1,0,1]
}

// SAVE

* Collapse.
collapse lic* exp* cty yr [pw=wgt], by(ctyr)
la val cty V6

* Figures.
if $graphs {
	global opts = "by(yr, note('') legend(pos(3))) scale(.75) ylab(0 1) xlab(-1 1)"
	sc lic1 exp1, ms(O) || sc lic2 exp2, ms(O) || sc lic3 exp3, ms(O) || sc lic4 exp4, ms(O) ///
		legend(col(1) lab(1 "Health") lab(2 "Pensions") lab(3 "Unemployment") lab(4 "Environment")) ///
		 name(hpue, replace) $opts
	sc lic1 exp1, ms(O) || sc lic2 exp2, ms(O) || sc lic3 exp3, ms(O) ///
		legend(col(1) lab(1 "Health") lab(2 "Pensions") lab(3 "Unemployment")) ///
		name(hpu, replace) $opts
	sc lic1 exp1, ms(O) || sc lic3 exp3, ms(O) ///
		legend(col(1) lab(1 "Health") lab(2 "Unemployment")) ///
		name(hpu, replace) $opts
}

* Correlates.
corr lic*, m
corr exp*, m

* Time correlates.
gen yr2=(yr>1991) // cluster 1985-1990 and 1996-2006 for larger n
bysort yr2: pwcorr lic*, star(.05) obs sig
bysort yr2: pwcorr exp*, star(.05) obs sig

reg lic1 lic2 i.cty i.yr, beta // mock xtreg, cluster(cty)

* Reshape.
reshape long lic exp, i(ctyr) j(issue)
la de issue 1 "Health" 2 "Pensions" 3 "Unemployment" 4 "Environment"
la val issue issue

* Export.
sort cty yr
order cty yr ctyr issue lic* exp*
outsheet using data_issp8506.csv, replace
