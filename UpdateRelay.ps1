<#
	.SYNOPSIS
	The script tests to make sure that the DNS cache on the server is updated with the new relay server IP
	.DESCRIPTION
	This script will do the following
        - Gets the current DNS cache on the server and stores it in a file
        - Clears the DNS cache on the server
        - Pings the relay server to get the new IP and stores that in a file
        - Shows the DNS cache on the server after the ping
		- Emails the results of the three actions to the user
	.OUTPUTS
	Will email the $to user the results of the DNS cache update and ping
	
	.NOTES
		ScriptName	: UpdateRelay.ps1
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


#Get the hostname
$hostname = [System.Net.Dns]::GetHostName()

#Sets the attachment file name using the hostname
$attachment = "c:\temp\"+$hostname+"-results.txt"

#Creates blank txt file for the results
$exists = Test-Path $attachment

if($exists -eq $true){
    Remove-Item -Path $attachemnt -Force
    New-Item $attachment
}else{
    New-Item $attachment
}

$resultsContent= $hostname

Add-Content $attachment $resultsContent

#Gets the current DNS Cache and saves that to the results file
$resultsContent = Get-DnsClientCache | Out-String

Add-Content $attachment $resultsContent


#Clears the DNS Cache
Clear-DnsClientCache

#Pings the new relay server and saves the result to file
$resultsContent = Test-Connection -ComputerName $smtpServer | Out-String

Add-Content $attachment $resultsContent


#Gets the current DNS Cache again and save results to file
$resultsContent = Get-DnsClientCache | Out-String

Add-Content $attachment $resultsContent


#Sends the email with the results files attached
Send-MailMessage -From $from -To $to -Subject $subject -Body "Just trying to send and email using the new relay server" -SmtpServer $smtpServer -Attachments $attachment

