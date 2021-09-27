<#
	.SYNOPSIS
	This script will create the Test Zones, DNS Entries and then delete and add the new DNS Entries just like the real script
	.DESCRIPTION
	This script will do the following
        - Create 4 test zones
        - Create the DNS entries in the test zones
        - Test to make sure that the entries are created
        - Cleans up the zones after the script is done
	.OUTPUTS
	Will output a display of the DNS records after they are created and then email the script user the results of the test
	
	.EXAMPLE
	
	.NOTES
		ScriptName	: TestDNSChanges.ps1
		Created by  : Winston Ruttan
		Date Coded  : 09/09/2021
#>


$Users = Import-Csv -path ".\Lib\UserUpdate1.csv" -Header "LegalName","Username","Country","Complete" | Select-Object -Skip 1

foreach ($u in $Users)
{
    try {
        $ADUser = Get-ADUser -Identity $u.Username -ErrorAction Stop
    }
    catch {
        if($_ -like "*Cannot find an object with identity: '$u.Username'*"){
            $u.Username + "Doesn't exist"
        }
        continue
    }
    
    $Enabled = Get-ADUser -Identity $u.Username -Properties * 

    if($Enabled.Enabled -eq $True){
        if($Enabled.Country -eq $null){
            $u.Username + " will be updated"
            set-aduser -Identity $u.Username -Country "CA"
        }
    }
}