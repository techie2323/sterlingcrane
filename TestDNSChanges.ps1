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

if(!($confPath))
{
	$confPath = ".\config\config.ps1"
}
try
{
	#load the configuration
	. $confPath
}catch{
	Write-Error "Error Unable to load config file $ConfPath check to see if it was there or use -ConfPath to specify the Config file"
}



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

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCa -RRType "A" -Name "spam" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCa -RRType "A" -Name "edmsmail" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCa -RRType "MX" -Name "edmsmail" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCom -RRType "CNAME" -Name "spam.testzone.com." 

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCom -RRType "CNAME" -Name "webmail.testzone.com." 

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCom -RRType "CNAME" -Name "smtp.testzone.com." 

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCom -RRType "A" -Name "relay" -RecordData $oldIP

Remove-DnsServerResourceRecord -ComputerName $dc -ZoneName $tsterlingDotCom -RRType "A" -Name "mail" -RecordData $oldIP

Clear-DnsServerCache -ComputerName $dc3

Clear-DnsServerCache -ComputerName $dc9

Start-Sleep -Seconds 180

Sync-DnsServerZone -ComputerName $dc3 -Name $tsterlingDotCa

Sync-DnsServerZone -ComputerName $dc3 -Name $tsterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $tsterlingDotCa

Sync-DnsServerZone -ComputerName $dc9 -Name $tsterlingDotCom

Start-Sleep -Seconds 180

Write-Host ("DNS entries added tempzone.ca and tempzone.com")
Write-Host ("Check to make sure that the entries have been removed")

Read-Host -Prompt "Press any key to continue"


Add-DnsServerResourceRecordA -Name "relay" -ZoneName $tsterlingDotCom -IPv4Address $newIP -ComputerName $dc

Add-DnsServerResourceRecordA -Name "mail" -ZoneName $tsterlingDotCom -IPv4Address $newIP -ComputerName $dc

Add-DnsServerResourceRecordA -Name "spam" -ZoneName $tsterlingDotCom -IPv4Address $newIP -ComputerName $dc

Clear-DnsServerCache -ComputerName $dc3

Clear-DnsServerCache -ComputerName $dc9

Sync-DnsServerZone -ComputerName $dc3 -Name $tsterlingDotCom

Sync-DnsServerZone -ComputerName $dc9 -Name $tsterlingDotCom

Write-Host ("DNS entries added tempzone.ca and tempzone.com")
Write-Host ("Check to make sure that the new entries are on the server")

Read-Host -Prompt "Press any key to continue"



function CreateTestZones {
    Add-DnsServerPrimaryZone -ComputerName $dc -Name "mail.testzone.ca" -ReplicationScope "Forest" -DynamicUpdate Secure -PassThru

    Add-DnsServerResourceRecordA -ComputerName $dc -Name "." -ZoneName "mail.testzone.ca" -IPv4Address $oldIP

    Add-DnsServerPrimaryZone -ComputerName $dc -Name "legacy.testzone.ca" -ReplicationScope "Forest" -DynamicUpdate Secure -PassThru

    Add-DnsServerResourceRecordA -ComputerName $dc -Name "." -ZoneName "testzone.priv" -IPv4Address $oldIP


}

function CreateTestEntries {


    Add-DnsServerResourceRecordA -ComputerName $dc -Name "edmsmail" -ZoneName $tsterlingDotCa -IPv4Address $oldIP 

    Add-DnsServerResourceRecordA -ComputerName $dc -Name "spam" -ZoneName $tsterlingDotCa -IPv4Address $oldIP

    Add-DnsServerResourceRecordMX -ComputerName $dc -Name "edmsmail" -ZoneName $tsterlingDotCa -MailExchange $thostAlias1 -Preference 10 

    Add-DnsServerResourceRecordA -ComputerName $dc -Name "mail" -ZoneName $tsterlingDotCom -IPv4Address $oldIP

    Add-DnsServerResourceRecordA -ComputerName $dc -Name "relay" -ZoneName $tsterlingDotCom -IPv4Address $oldIP

    Add-DnsServerResourceRecordCName -Name "webmail" -ZoneName $tsterlingDotCom -HostNameAlias $thostAlias1 -ComputerName $dc

    Add-DnsServerResourceRecordCName -Name "smtp" -ZoneName $tsterlingDotCom -HostNameAlias $thostAlias1 -ComputerName $dc

    Add-DnsServerResourceRecordCName -Name "spam" -ZoneName $tsterlingDotCom -HostNameAlias $thostAlias1 -ComputerName $dc

    Add-DnsServerResourceRecordCName -Name "intrelay" -ZoneName $tsterlingDotCom -HostNameAlias $thostAlias2 -ComputerName $dc

    Add-DnsServerResourceRecordCName -Name "spam" -ZoneName $tsterlingDotCom -HostNameAlias $thostAlias1 -ComputerName $dc
    

}

function TestDeleteOldDNS {
    

}

function TestAddNewDNS {
    

}

function TestServers{


}
    
function CleanupTestZones {
    

}

function SyncDNSZone {
    
    Sync-DnsServerZone -ComputerName $dc3 -Name $tsterlingDotCa

    Sync-DnsServerZone -ComputerName $dc3 -Name $tsterlingDotCom

    Sync-DnsServerZone -ComputerName $dc9 -Name $tsterlingDotCa

    Sync-DnsServerZone -ComputerName $dc9 -Name $tsterlingDotCom
}


function TestDNSChanges {
    
    CreateTestZones
    
    CreateTestEntries
    
    TestDeleteOldDNS

    TestAddNewDNS

    TestServers

    CleanupTestZones
    
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