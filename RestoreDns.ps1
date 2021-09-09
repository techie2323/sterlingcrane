#———————————————————————-#
# Script_Name : RestoreDNS.ps1
# Description : Perform Restore of DNS Zones of a Windows 2008 DNS SErver 
# Requirements : Windows 2008/R2 + DNS Management console Installed 
# Version : 0.4 
# Date : October 2011
# Created by Griffon 
#———————————————————————–#

#– DEFINE VARIABLE——#
#———————————#

# Get Name of the server with env variable

$DNSSERVER= gc env:computername

#—DEFINE WHERE TO Look for DNS BACKUP FILES —–#

$BkfFolder=”c:\windows\system32\dns\backup”

#—Define file name where Dns Settings are Stored

$StrFile=Join-Path $BkfFolder “input.csv”

#—-  RESTORE ZONES BASED ON SETTINGS FOUND IN INPUT.CSV —— #

$Zone=import-csv $StrFile
$Zone | foreach {

$path=”backup\”+$_.name
$Zone=$_.name
$IP=$_.MasterServers
$Update=$_.AllowUpdate

#—– Checking if AD Integrated or Not ——-#

if ($_.DsIntegrated -eq $True) {
Switch ($_.ZoneType)
{
1 {
#—– Need to Create Zone As Primary to get all records imported ——-#
$cmd0=”dnscmd {0} /ZoneAdd {1} /primary /file {2} /load” -f $DNSSERVER,$Zone,$path
Invoke-Expression $cmd0
$cmd1=”dnscmd {0} /ZoneResetType {1} /dsprimary” -f $DNSSERVER,$Zone

}

3 { $cmd1=”dnscmd {0} /ZoneAdd {1} /dsstub {2} /load” -f $DNSSERVER,$Zone,$IP }
4 { $cmd1=”dnscmd {0} /ZoneAdd {1} /dsforwarder {2} /load” -f $DNSSERVER,$Zone,$IP }
}
} else {

Switch ($_.ZoneType)
{
1 {$cmd1=”dnscmd {0} /ZoneAdd {1} /primary /file {2} /load” -f $DNSSERVER,$Zone,$path}
2 {$cmd1=”dnscmd {0} /ZoneAdd {1} /secondary {2}” -f $DNSSERVER,$Zone,$IP }
3 {$cmd1=”dnscmd {0} /ZoneAdd {1} /stub {2}” -f $DNSSERVER,$Zone,$IP }
4 {$cmd1=”dnscmd {0} /ZoneAdd {1} /forwarder {2}” -f $DNSSERVER,$Zone,$IP }
}
}

 #Restore DNS Zones  
Invoke-Expression $cmd1

Switch ($_.AllowUpdate)
{
#No Update
0 {$cmd2=”dnscmd /Config {0} /allowupdate {1}” -f $Zone,$Update}
#Secure and non secure
1 {$cmd2=”dnscmd /Config {0} /allowupdate {1}” -f $Zone,$Update}
#Only Secure Updates
2 {$cmd2=”dnscmd /Config {0} /allowupdate {1}” -f $Zone,$Update}

}

#Reset DNS Update Settings
Invoke-Expression $cmd2

}

# End of Script
#———————————————————————–#