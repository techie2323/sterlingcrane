$sterlingDotCa = "testzone.ca"
$sterlingDotCom = "testzone.com"
$oldIP = "192.168.5.250"
$newIP = "192.168.5.55"
$hostAlias1 = "edmsmail.testzone.ca"
$hostAlias2 = "edmsdutil3.testzone.ca"
$dc = "EDMSDC0"
$dc3 = "EDMSDC3"
$dc9 = "EDMSDC9"



Add-DnsServerResourceRecordA -ComputerName $dc -Name "edmsmail" -ZoneName $sterlingDotCa -IPv4Address $oldIP 

Add-DnsServerResourceRecordA -ComputerName $dc -Name "spam" -ZoneName $sterlingDotCa -IPv4Address $oldIP

Add-DnsServerResourceRecordMX -ComputerName $dc -Name "edmsmail" -ZoneName $sterlingDotCa -MailExchange $hostAlias1 -Preference 10 

Add-DnsServerResourceRecordA -ComputerName $dc -Name "mail" -ZoneName $sterlingDotCom -IPv4Address $oldIP

Add-DnsServerResourceRecordA -ComputerName $dc -Name "relay" -ZoneName $sterlingDotCom -IPv4Address $oldIP

Add-DnsServerResourceRecordCName -Name "webmail" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias1 -ComputerName $dc

Add-DnsServerResourceRecordCName -Name "smtp" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias1 -ComputerName $dc

Add-DnsServerResourceRecordCName -Name "spam" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias1 -ComputerName $dc

Add-DnsServerResourceRecordCName -Name "intrelay" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias2 -ComputerName $dc

Add-DnsServerResourceRecordCName -Name "spam" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias1 -ComputerName $dc

Add-DnsServerPrimaryZone -ComputerName $dc -Name "mail.testzone.ca" -ReplicationScope "Forest" -DynamicUpdate Secure -PassThru

Add-DnsServerResourceRecordA -ComputerName $dc -Name "." -ZoneName "mail.testzone.ca" -IPv4Address $oldIP

Add-DnsServerPrimaryZone -ComputerName $dc -Name "legacy.testzone.ca" -ReplicationScope "Forest" -DynamicUpdate Secure -PassThru

Add-DnsServerResourceRecordA -ComputerName $dc -Name "." -ZoneName "testzone.priv" -IPv4Address $oldIP

Start-Sleep -Seconds 180

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCom

Start-Sleep -Seconds 180

$DNSRecords = Import-Csv -path "c:\scripting\powershell\olddns.csv" -Header "name","type","data" | Select-Object -Skip 1

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

Read-Host -Prompt "Press any key to continue"

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCa -RRType "A" -Name "spam" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCa -RRType "A" -Name "edmsmail" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCa -RRType "MX" -Name "edmsmail" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "CNAME" -Name "spam.testzone.com." 

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "CNAME" -Name "webmail.testzone.com." 

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "CNAME" -Name "smtp.testzone.com." 

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "A" -Name "relay" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "A" -Name "mail" -RecordData $oldIP

Clear-DnsServerCache -ComputerName $dc3

Clear-DnsServerCache -ComputerName $dc9

Start-Sleep -Seconds 180

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCom

Start-Sleep -Seconds 180

Write-Host ("DNS entries added tempzone.ca and tempzone.com")
Write-Host ("Check to make sure that the entries have been removed")

Read-Host -Prompt "Press any key to continue"


Add-DnsServerResourceRecordA -Name "relay" -ZoneName $sterlingDotCom -IPv4Address $newIP -ComputerName $dc

Add-DnsServerResourceRecordA -Name "mail" -ZoneName $sterlingDotCom -IPv4Address $newIP -ComputerName $dc

Add-DnsServerResourceRecordA -Name "spam" -ZoneName $sterlingDotCom -IPv4Address $newIP -ComputerName $dc

Clear-DnsServerCache -ComputerName $dc3

Clear-DnsServerCache -ComputerName $dc9

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCom

Write-Host ("DNS entries added tempzone.ca and tempzone.com")
Write-Host ("Check to make sure that the new entries are on the server")

Read-Host -Prompt "Press any key to continue"

<#
spam.sterlingcrane.ca (A) 192.168.5.250
edmsmail.sterlingcrane.ca  (A) (MX)  192.168.5.250
webmail.sterlingcrane.com (CNAME)  192.168.5.250
relay.sterlingcrane.com (A)  192.168.5.250
smtp.sterlingcrane.com (CNAME)  192.168.5.250
spam.sterlingcrane.com (CNAME)  192.168.5.250
mail.sterlingcrane.com (A)  192.168.5.250
#>