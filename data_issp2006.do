// SETUP

* Options.
global graphs=1
set scheme set1 // Edwin Leuven's conversion of Color Brewer Set1

* Path.
cd "~/Documents/Research/Data/ISSP/"

* Log.
cap log close _all
log using data_issp2006.log, replace

* Data.
use "issp2006/ZA4700_F1.dta", clear

// VARIABLES

* Structure:
ren V3a cty
ren WEIGHT wgt

* Variables:
* exp = expenditure (should spend, 5-point scale)
* lic = license (should do, 4-point scale)
ren V18 exp1 // health
ren V27 lic1
ren V35 eff1
ren V22 exp2 // pensions
ren V28 lic2
ren V36 eff2
ren V23 exp3 // unemployment
ren V30 lic3
ren V39 eff3
ren V17 exp4 // environment
ren V34 lic4
ren V40 eff4

* Recode: license
foreach v of varlist lic* {
	ren `v' x`v'
	qui recode x`v' (1/2=1) (3/4=0) (else=.), gen(`v') // rescaled [0,1]
}

* Recode: expenditure, efficiency 
foreach v of varlist exp* eff* {
	ren `v' x`v'
	qui recode x`v' (1/2=1) (3=0) (4/5=-1) (else=.), gen(`v') // rescaled [-1,0,1]
}

* Collapse.
gen year=2006
collapse lic* exp* eff* [pw=wgt], by(cty)

* Generate: mandate = license [0,1] * expenditure [-1,0,1]
forvalues i=1/4 {
	gen man`i'=lic`i'*exp`i'
}

if $graphs {
	gr mat lic1 exp1 man1 eff1, maxes(ylab(-1 1) xlab(-1 1)) name(h, replace)
	gr mat lic2 exp2 man2 eff2, maxes(ylab(-1 1) xlab(-1 1)) name(p, replace)
	gr mat lic3 exp3 man3 eff3, maxes(ylab(-1 1) xlab(-1 1)) name(u, replace)
	gr mat lic4 exp4 man4 eff4, maxes(ylab(-1 1) xlab(-1 1)) name(e, replace)
}

* Correlates.
corr lic*
corr exp*

* Figures.
if $graphs {
	global opts = "legend(pos(3)) scale(.75) ylab(-1 1) xlab(-1 1)"
	// fig.1 (all)
	sc man1 eff1, ms(O) || sc man2 eff2, ms(O) || sc man3 eff3, ms(O) || sc man4 eff4, ms(O) $opts ///
		legend(col(1) lab(1 "Health") lab(2 "Pensions") lab(3 "Unemployment") lab(4 "Environment"))
}

* reshape
reshape long lic exp eff man, i(cty) j(issue)
la de issue 1 "Health" 2 "Pensions" 3 "Unemployment" 4 "Environment"
la val issue issue

outsheet using data_issp2006.csv, replace
