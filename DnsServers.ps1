$DNSServers = Import-Csv -path "c:\scripting\powershell\dnsservers.csv"

foreach($DNSServer in $DNSServers){
    Write-Host($DNSServer)
}


