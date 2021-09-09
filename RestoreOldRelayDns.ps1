$sterlingDotCa = "sterlingcrane.ca"
$sterlingDotCom = "sterlingcrane.com"
$oldIP = "192.168.5.250"
$newIP = "192.168.5.55"
$hostAlias ="edmsmail.sterlingcrane.ca"
$dc="edmsdc0"
$dc3="edmsdc3"
$dc9="edmsdc9"

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "A" -Name "relay" -RecordData $newIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "A" -Name "mail" -RecordData $newIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCom -RRType "A" -Name "spam" -RecordData $newIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCa -RRType "A" -Name "relay" -RecordData $newIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCa -RRType "A" -Name "mail" -RecordData $newIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $sterlingDotCa -RRType "A" -Name "spam" -RecordData $newIP

Clear-DnsServerCache -ComputerName $dc3

Clear-DnsServerCache -ComputerName $dc9

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCa

Start-Sleep -Seconds 240

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCa

Start-Sleep -Seconds 120

Add-DnsServerResourceRecordCName -ComputerName $dc -Name "webmail" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias

Add-DnsServerResourceRecordA -ComputerName $dc -Name "relay" -ZoneName $sterlingDotCom -IPv4Address $oldIP

Add-DnsServerResourceRecordCName -ComputerName $dc -Name "smtp" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias

Add-DnsServerResourceRecordCName -ComputerName $dc -Name "spam" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias

Add-DnsServerResourceRecordA -ComputerName $dc -Name "relay" -ZoneName $sterlingDotCom -IPv4Address $oldIP

Add-DnsServerResourceRecordCName -ComputerName $dc -Name "intrelay" -ZoneName $sterlingDotCom -HostNameAlias $hostAlias

Add-DnsServerResourceRecordMX -ComputerName $dc -Name "edmsmail" -ZoneName $sterlingDotCa -IPv4Address $oldIP -Preference 10 

Add-DnsServerResourceRecordA -ComputerName $dc -Name "edmsmail" -ZoneName $sterlingDotCa -IPv4Address $oldIP

Add-DnsServerResourceRecordA -ComputerName $dc -Name "spam" -ZoneName $sterlingDotCa -IPv4Address $oldIP

Add-DnsServerPrimaryZone -ComputerName $dc -Name "mail.sterlingcrane.ca" -ReplicationScope "Forest" -DynamicUpdate Secure -PassThru

Clear-DnsServerCache -ComputerName $dc3

Clear-DnsServerCache -ComputerName $dc9

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc3 -Name $sterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCa

Sync-DnsServerZone -ComputerName $dc9 -Name $sterlingDotCom




<#
spam.sterlingcrane.ca (A) 192.168.5.250
edmsmail.sterlingcrane.ca  (A) (MX)  192.168.5.250
webmail.sterlingcrane.com (CNAME)  192.168.5.250
relay.sterlingcrane.com (A)  192.168.5.250
smtp.sterlingcrane.com (CNAME)  192.168.5.250
spam.sterlingcrane.com (CNAME)  192.168.5.250
mail.sterlingcrane.com (A)  192.168.5.250
#>