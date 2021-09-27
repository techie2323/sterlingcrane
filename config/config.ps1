#Our Configuration file root location
$configRoot = ".\Config"

#Our Library root location
$libRoot = ".\Lib"

#The location of the Common Library of functions
$commonLib = "$libRoot\CommonLib.psm1"

#Email address used to send email
$from="no-reply@sterlingcrane.com"

#Email address to send the emails to
$to="wruttan@sterlingcrane.com"

#Subject of the email sent
$subject="Test email to see if new relay is working"

#Host name of the server sending the message
$smtpServer="relay.sterlingcrane.com"

#Relay Server Changes Project
#Sterling Crane .CA DNS Zone name
$sterlingDotCa = "sterlingcrane.ca"

#Sterling Crane .COM DNS Zone name
$sterlingDotCom = "sterlingcrane.com"

#The old IP address of the relay server
$oldIP = "192.168.5.250"

#The new IP address of the relay servers
$newIP = "192.168.5.55"

#The old hostname of the relay server
$hostAlias ="edmsmail.sterlingcrane.ca"

#The hostnames of the DNS Servers
$dc="edmsdc0"
$dc3="edmsdc3"
$dc9="edmsdc9"

#These are used for the TestDNSChanges.ps1 script
#Name of the test .CA DNS Zone
#$tsterlingDotCa = "testzone.ca"

#Name of the test .COM DNS Zone
#$tsterlingDotCom = "testzone.com"

#A test hostname of the relay server
$hostAlias1 = "edmsmail.testzone.ca"

#A test hostname of the relay server
$hostAlias2 = "edmsdutil3.testzone.ca"
