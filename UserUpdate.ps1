


$Users = Import-Csv -path "c:\powershell\sterlingcrane\Lib\UserUpdate1.csv" -Header "LegalName","Username","Country","Complete" | Select-Object -Skip 1

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