$from="no-reply@sterlingcrane.com"
$to="wruttan@sterlingcrane.com"
$subject="Test email to see if new relay is working"
$smtpServer="relay.sterlingcrane.com"


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

