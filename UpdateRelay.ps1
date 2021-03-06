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

#Email address used to send email
$from="no-reply@sterlingcrane.com"

#Email address to send the emails to
$to="wruttan@sterlingcrane.com"

#Subject of the email sent
$subject="Test email to see if new relay is working"

#Host name of the server sending the message
$smtpServer="relay.sterlingcrane.com"

#Temp path where the results file will be created
$path = "C:\temp"

#Get the hostname
$hostname = [System.Net.Dns]::GetHostName()

#Sets the attachment file name using the hostname
$filename = $hostname+"-results.txt"

function UpdateResults {
	<#
	.SYNOPSIS
	This function updates the results file
	.DESCRIPTION
	This function receives a string and appends that information to the results file
	.OUTPUTS
		
	.NOTES
		FunctionName: UpdateResults
		Created by  : Winston Ruttan
		Date Coded  : 09/31/2021
#>
	
	param(
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
		$results,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
		$type

	)
	
	switch($type)
	{
		"Start"{$header = "`n==========================================================================="
				Add-Content -Path $attachment -Value $header
				$header = "`n+						Current DNS Cache									+"
				Add-Content -Path $attachment -Value $header
				$header = "`n===========================================================================`n"
				Add-Content -Path $attachment -Value $header
			}
		"Middle"{$header = "`n==========================================================================="
				Add-Content -Path $attachment -Value $header
				$header = "`n+					    	 Ping results									+"
				Add-Content -Path $attachment -Value $header
				$header = "`n==========================================================================="
				Add-Content -Path $attachment -Value $header
			}
		"End"{	$header = "`n=========================================================================="
				Add-Content -Path $attachment -Value $header
				$header = "`n+					 DNS Cache After Ping 								+"
				Add-Content -Path $attachment -Value $header
				$header = "`n==========================================================================`n"
				Add-Content -Path $attachment -Value $header
			}
				
	}
	
	Add-Content -Path $attachment -Value $results
	
}



function UpdateCache {
	<#
	.SYNOPSIS
	This function does all the heavy lifting in the script
	.DESCRIPTION
	This function does the following
        - Gets the current DNS cache on the server and stores it in a file
        - Clears the DNS cache on the server
        - Pings the relay server to get the new IP and stores that in a file
        - Shows the DNS cache on the server after the ping
		- Emails the results of the three actions to the user
	It will call the UpdateResults function a few times to update the results file that is emailed at the end
	.OUTPUTS
	This function will email out the results file as an attachment to the user in the $to variable
	.NOTES
	FunctionName: UpdateCache
	Created by  : Winston Ruttan
	Date Coded  : 09/31/2021
#>
	#Checks to see if there is a "temp folder"
	try{
		$exists = Test-Path -Path $path -ErrorAction Stop

	}catch{
		
		#if the folder doesn't exist
		if($exists -eq $false){
			
			#Folder is created
			New-Item -Path "c:\" -Name "temp" -ItemType "directory"
			
			#File is created
			New-Item -Path $path -ItemType "file" -Name $filename

			$attachment = $path + "\" + $filename
		
		#If the folder exists
		}else{
			try {
				$exists = New-Item -Path $path -ItemType "file" -Name $filename -ErrorAction Stop
			}
			catch {
				if ($exists -eq $null) {
					
					
				}
				
			}
			#File is created
			New-Item -Path $path -ItemType "file" -Name $attachment
			
			$attachment = $path + $hostname + "-results.txt"
		}

		continue
	}

	#Gets the Hostname of he server and adds it to the results
	$heading = "Hostname:"
	$resultsContent = $heading + "`n" + $hostname
	UpdateResults($resultsContent) 

	#Gets the current DNS Cache and saves that to the results file
	
	$resultsContent = Get-DnsClientCache | Out-String
	$heading = "Start"
	UpdateResults($resultsContent,$heading) 
	
	#Clears the DNS Cache
	Clear-DnsClientCache

	#Pings the new relay server and saves the result to file
	$heading = "Middle"
	$resultsContent = Test-Connection -ComputerName $smtpServer  | Out-String
	UpdateResults($resultsContent,$heading) 

	#Gets the current DNS Cache again and save results to file
	$heading = "End"
	$resultsContent = Get-DnsClientCache  | Out-String
	UpdateResults($resultsConverted,$heading) 

	#Sends the email with the results files attached
	#Send-MailMessage -From $from -To $to -Subject $subject -Body "Just trying to send and email using the new relay server" -SmtpServer $smtpServer -Attachments $attachment

}

UpdateCache


Get-ADUser -Identity wruttan -Properties proxyaddresses | Select-Object name, @{L='ProxyAddress'; E={$_.proxyaddresses -split "; "}}