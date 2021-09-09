$sterlingDotCa = "sterlingcrane.ca"
$sterlingDotCom = "sterlingcrane.com"
$oldIP = "192.168.5.250"
$newIP = "192.168.5.55"


Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCa -RRType "A" -Name "spam" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCa -RRType "A" -Name "edmsmail" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCa -RRType "MX" -Name "edmsmail" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCom -RRType "CNAME" -Name "webmail.sterlingcrane.com." 

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCom -RRType "CNAME" -Name "spam.sterlingcrane.com." 

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCom -RRType "CNAME" -Name "smtp.sterlingcrane.com." 

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCom -RRType "A" -Name "relay" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCom -RRType "CNAME" -Name "intrelay" -Name "edmsdutil3.sterling.sterlingcrane.ca."

Remove-DnsServerResourceRecord -ComputerName EDMSDC0 -ZoneName $sterlingDotCom -RRType "A" -Name "mail" -RecordData $oldIP

Remove-DnsServerZone "mail.sterlingcrane.ca" -PassThru -Verbose

Start-Sleep -Seconds 240

Clear-DnsServerCache -ComputerName EDMSDC3

Clear-DnsServerCache -ComputerName EDMSDC9

Sync-DnsServerZone -ComputerName EDMSDC3 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName EDMSDC3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName EDMSDC9 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName EDMSDC9 -Name $sterlingDotCom

Start-Sleep -Seconds 120

Add-DnsServerResourceRecordA -Name "relay" -ZoneName $sterlingDotCom -IPv4Address $newIP

Add-DnsServerResourceRecordA -Name "mail" -ZoneName $sterlingDotCom -IPv4Address $newIP

Add-DnsServerResourceRecordA -Name "spam" -ZoneName $sterlingDotCom -IPv4Address $newIP

Add-DnsServerResourceRecordA -Name "relay" -ZoneName $sterlingDotCa -IPv4Address $newIP

Add-DnsServerResourceRecordA -Name "mail" -ZoneName $sterlingDotCa -IPv4Address $newIP

Add-DnsServerResourceRecordA -Name "spam" -ZoneName $sterlingDotCa -IPv4Address $newIP

Start-Sleep -Seconds 240

Clear-DnsServerCache -ComputerName EDMSDC3

Clear-DnsServerCache -ComputerName EDMSDC9

Sync-DnsServerZone -ComputerName EDMSDC3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName EDMSDC9 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName EDMSDC3 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName EDMSDC9 -Name $sterlingDotCa

Start-Sleep -Seconds 240

$DNSRecords = Import-Csv -path "c:\scripting\powershell\newdns.csv" -Header "name","type","data" | Select-Object -Skip 1

$DNSServers = Import-Csv -path "c:\scripting\powershell\dnsservers.csv" 

foreach ($DNSServer in $DNSServers){
    
   foreach($DNSRecord in $DNSRecords){
        write-host "Checking to see if $($DNSRecord.name) exists in DNS on $DNSServer"          
        $DNSCheck = $(resolve-DnsName -name $DNSRecord.name -Type $DNSRecord.type -Server $DNSServer.server -erroraction 'silentlycontinue' | select-object Name)
        write-host "DNS Lookup Result [blank if not found]: $($DNSCheck.Name)"
        if ($($DNSCheck.Name) -match $($DNSRecord.name)) {         
            write-host "$DNSRecord.name exists in DNS" -ForegroundColor "Green" 
            #write-output "$($DNSRecord.name) $($DNSRecord.ip)" | out-file $ExistsInDNS -Append
        }else{
            Write-Host("$DNSRecord.name does not exist in DNS") -ForegroundColor "Red" 
        }
    }
}


<#
spam.sterlingcrane.ca (A) 192.168.5.250
edmsmail.sterlingcrane.ca  (A) (MX)  192.168.5.250
webmail.sterlingcrane.com (CNAME)  192.168.5.250
relay.sterlingcrane.com (A)  192.168.5.250
smtp.sterlingcrane.com (CNAME)  192.168.5.250
spam.sterlingcrane.com (CNAME)  192.168.5.250
mail.sterlingcrane.com (A)  192.168.5.250
#>