$Users = Import-Csv -path "c:\powershell\sterlingcrane\Lib\UserUpdate.csv" -Header "LegalName","Username","Country","Complete" | Select-Object -Skip 1

foreach ($u in $Users)
{
    try {
        $ADUser = Get-ADUser -Identity $u.Username -ErrorAction Stop
    }
    catch {
        if($_ -like "*Cannot find an object with identity: '$u.Username'*"){
            $u.Username + "Doesn't exist"
        }else{
            "An error: $_"
        }

        continue
    }
    
    Get-ADUser -Identity $u.Username -Properties co | select co 
    
}