$Users = Import-Csv -path "c:\powershell\sterlingcrane\Lib\UserUpdate.csv" -Header "LegalName","Username","Country","Complete" | Select-Object -Skip 1

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
    
    $Enabled = Get-ADUser -Identity $u.Username -Properties co | Where-Object {$_.Enabled -eq $true}

    if($Enabled.co -eq $null){
        $u.Username + "Will be updated"
        set-aduser -Identity $u.Username -Country "CA"
    }
}