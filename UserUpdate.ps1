<#
	.SYNOPSIS
	This script will update the Country Code for users in Active Directory
	.DESCRIPTION
	This script does the following:
        - Determines if the user account exists
        - Determines if the user account is enabled
        - Determines if the user account has a country set or not
        - If the country is not set then the script sets the country
	.OUTPUTS
	When run the script will display the user accounts that have been updated.  The script will also update the CSV to say if the account was updated or not
	
	.EXAMPLE
	.\UserUpdate.ps1

	.NOTES
		ScriptName	: UserUpdate.ps1
		Created by  : Winston Ruttan
		Date Coded  : 09/09/2021
#>

#Imports the CSV file
$Users = Import-Csv -path ".\Lib\UserUpdate1.csv" -Header "LegalName","Username","Country","Complete" | Select-Object -Skip 1

#Imports the CSV file again, possibily redenudant I will have to look into that
$table = Import-Csv -Path .\lib\UserUpdate1.csv 

#Looks at the loaded $Users variable and for each of them does the following

function UpdateCountry {
    foreach ($u in $Users)
    {
        #Tries to make sure that the user account exists
        try {
            #Tries to load the user infor from AD into a varialbe
            $ADUser = Get-ADUser -Identity $u.Username -Properties * -ErrorAction Stop
        }
        catch {
            #If it's unable to load the user info it updates the CSV with "Completed" type NA
            $RowIndex = [array]::IndexOf($table.Username,$u.Username)
            if($RowIndex -gt -1)
            {
                if($table[$RowIndex].Complete -eq ""){
                    $table[$RowIndex].Complete = "NA"
                    $table | Export-Csv .\Lib\UserUpdate1.csv -NoTypeInformation 
                }

            continue
            }
        }
        
        #Loads AD User info into a variable
        $Enabled = Get-ADUser -Identity $u.Username -Properties *
        
        #Load the Row index
        $RowIndex = [array]::IndexOf($table.Username,$u.Username)
        
        if($Enabled.Enabled -eq $True -and $Enabled.Country -eq $null){
            $u.Username + " will be updated"

            #set-aduser -Identity $u.Username -Country "CA"

            UpdateCSV

        }else{
            UpdateCSV
        }  
    }
}



function UpdateCSV {

    if($table[$RowIndex].Complete -eq ""){
        $table[$RowIndex].Complete = "Yes"
        $table | Export-Csv .\Lib\UserUpdate1.csv -NoTypeInformation 
    }else{
        $table[$RowIndex].Complete = "Yes"
        $table | Export-Csv .\Lib\UserUpdate1.csv -NoTypeInformation
    }
    
}

UpdateCountry
