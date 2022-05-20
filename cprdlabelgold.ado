/* Program for labelling values in CPRD files using CPRD lookups - PWS 2022

Syntax:
	cprdlabelgold var1 var2 ..., file(cprd_file) location("path_to_CPRD_lookups")
	e.g. cprdlabelgold gender, file(patient) location("D:\Data\Lookups\CPRD Aurum")

*/

capture program drop cprdlabelgold
program define cprdlabelgold
	version 17.0
	syntax varlist, FILE(string) LOCation(string)
	
	quietly {
		
		//Keep case consistent
		local file = lower("`file'")
		
		//Save current dataset
		preserve
		
		capture import delimited "`location'/gold_var_lookup", varnames(1) clear
		if _rc {
			
			local location = subinstr("`location'", "TXTFILES", "", .)
			
			capture import delimited "`location'/gold_var_lookup", varnames(1) clear
			if _rc {
			
				display as error "Lookup file not found. Check directory."
				error
			}
		}
		
		//Define the lookups
		quietly count
		local n = `r(N)'
		
		forvalues i = 1/`n' {
			
			local lookup_`=variable[`i']'_`=file[`i']' = "`=lookup[`i']'"
		}
		
		//Restore dataset
		restore
		
		//For each var sent to the command run cprdlabel using the lookup from 
		//gold_var_lookup
		foreach var of local varlist {
			
			if "`lookup_`var'_`file''" == "" {
				
				noisily display "Lookup not found for `var'. Check that the specified file is correct."
			}
			else {
				
				noisily cprdlabel `var', lookup(`lookup_`var'_`file'') ///
				location("`location'/TXTFILES")
			}
		}
		
	} //End of quietly block

end // End program
	
