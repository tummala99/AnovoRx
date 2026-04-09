	# --------------------------------------------------
	# Define path parameters and assign values
	# --------------------------------------------------

	[string]$DatavantExePath = "D:\Anovo\Projects\Misc\36760\CT1\Tokenization"
	[string]$DatavantCLI = "D:\Anovo\Projects\Misc\36760\CT1\Tokenization\Datavant_Win.exe"
	[string]$CredentialFilePath = "D:\Anovo\Projects\Misc\36760\CT1\Tokenization\Credentials\credentials_Catalyst.txt"
	[string]$TokenSRCPath="D:\Anovo\Projects\Misc\36760\CT1\FeedFiles\temp"
	[string]$DestinationPath="D:\Anovo\Projects\Misc\36760\CT1\FeedFiles\SFTPSharePath"
	[string]$DatavantLogPath="$DatavantExePath\DatavantLogs"
	
	[string]$PHIFilepath = ""
	[string]$OutoutFilepath = ""
	
	# --------------------------------------------------
	# Define email parameters 
	# --------------------------------------------------
	
	$smtpServer = "smtp.office365.com"
	$emailFrom = "QASupport@anovorx.com"
	$emailTo = "stummala@anovorx.com"
	$subject = ""
	$body = ""
	$UserName = "QASupport@anovorx.com"
	$MailPwd = "whyISthis501notworking"
	$ErrorMessage = ""

	Write-Host "Datavant Exe Path: $DatavantExePath"
	Write-Host "Source folder Path is: $TokenSRCPath"
	Write-Host "Destination folder Path is: $DestinationPath"

try{
	Set-Location -Path $DatavantExePath	
	
	# --------------------------------------------------
	# Validate file paths and fail step if not found
	# --------------------------------------------------
	if (!(Test-Path $DatavantExePath)) {
			$IsPathsvalidFlag = $false
			
			$body += "`r`nThe Datavant Token generation step for the SQL job failed due to Datavant exec path not found."
		}	
		if (!(Test-Path $DatavantCLI)){
			$IsPathsvalidFlag = $false
			$subject = "$Environment (Firdapse): Datavant CLI failed"
			$body += "`r`nThe Datavant Token generation step for the SQL job failed due to DatavantCLI not found."
		}			
		if (!(Test-Path $CredentialFilePath)){
			$IsPathsvalidFlag = $false
			$subject = "$Environment (Firdapse): Datavant CLI failed"
			$body += "`r`nThe Datavant Token generation step for the SQL job failed due to Credential file not found."
		}
		if (!(Test-Path $TokenSRCPath)){
			$IsPathsvalidFlag = $false
			$subject = "$Environment (Firdapse): Datavant CLI failed"
			$body += "`r`nThe Datavant Token generation step for the SQL job failed due to feed source path not found."
		}
		if (!(Test-Path $DestinationPath)){
			$IsPathsvalidFlag = $false
			$subject = "$Environment (Firdapse): Datavant CLI failed"
			$body += "`r`nThe Datavant Token generation step for the SQL job failed due to feed destination path not found."
		}
		
		if ($IsPathsvalidFlag -eq $false) {
			Write-Output "File check validation failed."
			
			# --------------------------------------------------
			# Send validation failure mail.
			# --------------------------------------------------
			$subject = "$Environment (Firdapse): Datavant CLI failed"			
			$fullBody = "Validation Error: $body"
	
			$smtp = New-Object System.Net.Mail.SmtpClient($smtpServer)
			# Configure credentials/SSL if required by your SMTP server (see source 1.1.5 for examples)
			$smtp.EnableSsl = $true
			$smtp.Credentials = New-Object System.Net.NetworkCredential($UserName, $MailPwd);
			$smtp.Send($emailFrom, $emailTo, $subject, $fullBody)
			
			throw "Validation Error: $body"
		}
		else{
			Write-Output "File check validation succeeded."
		}	
	
	# --------------------------------------------------
	# Create folder if not exists.
	# --------------------------------------------------
	
	if (!(Test-Path $DatavantLogPath)) {
			New-Item $DatavantLogPath -ItemType Directory | Out-Null
		}
		
	# --------------------------------------------------
	# Loop through the stage (temp) folder to find feed 
	# file start with Patient to generate tokens
	# --------------------------------------------------
	$pattern = "Patient_*.txt"
	
	$files = Get-ChildItem -Path $TokenSRCPath -Filter $pattern -File
	foreach ($file in $files) {
		Write-Host "Processing file:" $file.Name
		Write-Host "Processing file:" $file.FullName
		
		$PHIFilepath = $file.FullName
		$PHIFileBaseName = $file.BaseName
		#$PHIFileName = $file.Name	
		$PHIFileName = $PHIFileBaseName+"_tokenize_output.txt"
		$PHIFileName_Tranform = $PHIFileBaseName+ "_transform_output.txt"
		Write-Host "PHI File Path is: $PHIFilepath"
		Write-Host "PHI File Name is: $PHIFileName"
		Write-Host "PHI Tranform File Name is: $PHIFileName_Tranform"
		$PHIOutputFolderName="$TokenSRCPath\Encrypted"
		#$PHIOutputFileName=!TokenSRCPath!\Encrypted\!PHIFileName!"
		$OutoutFilepath = "$PHIOutputFolderName\$PHIFileName"
		$OutoutFilepath_Tranform = "$PHIOutputFolderName\$PHIFileName_Tranform"
		
		# --------------------------------------------------
		# Create folder if not exists to place generated tokenized files
		# --------------------------------------------------
		
		if (!(Test-Path $PHIOutputFolderName)) {
			New-Item $PHIOutputFolderName -ItemType Directory | Out-Null
		}
		
		# --------------------------------------------------
		# Run Datavant CLI
		# --------------------------------------------------
	
		Write-Host "PHI Output file path is: $OutoutFilepath"
		
		#$cmd = "type $CredentialFilePath | $DatavantCLI tokenize -s anovorx -c PatientEncryptedTable --input `"$PHIFilepath`" --output `"$OutoutFilepath`""
		$cmd = "type $CredentialFilePath | $DatavantCLI tokenize -s anovorx -c FirdapseDailyFeed --input `"$PHIFilepath`" --output `"$OutoutFilepath`""
		
		Write-Host "Executing Datavant command"
		Write-Host $cmd
		
		$process = Start-Process powershell `
        -ArgumentList "-Command $cmd" `
        -NoNewWindow `
        -Wait `
        -PassThru
		
		$cmd = "type $CredentialFilePath | $DatavantCLI transform-tokens -s anovorx --to catalyst_pharma_firdapse --input `"$OutoutFilepath`" --output `"$OutoutFilepath_Tranform`""
		
		$process = Start-Process powershell `
        -ArgumentList "-Command $cmd" `
        -NoNewWindow `
        -Wait `
        -PassThru		
		
		# --------------------------------------------------
		# Delete the original PHI file from stage and move 
		# the Tokenized file to Stage location.
		# --------------------------------------------------
		Remove-Item $PHIFilepath
		Write-Host "PHI File deleted successfully."
		
		Remove-Item $OutoutFilepath
		Write-Host "PHI Token File deleted successfully."
		
		Write-Host "Move Encrypted File:" $OutoutFilepath		
		# Added to fix the New line issue
		(Get-Content $OutoutFilepath_Tranform) | Set-Content $OutoutFilepath_Tranform -Encoding UTF8		
		Move-Item -Path $OutoutFilepath_Tranform -Destination $PHIFilepath
		Write-Host "File moved successfully."
		
				
		# --------------------------------------------------
		# Capture Exit Code
		# --------------------------------------------------
		if ($process.ExitCode -ne 0) {
			Write-Host "ERROR: Datavant CLI failed with exit code $($process.ExitCode)"
			
			# --------------------------------------------------
			# Validate log files for validation
			# --------------------------------------------------
			
			# Define the directory path and file pattern
			$path = $DatavantExePath
			$pattern = "datavant_tokenize_*.log" # Use wildcards (*, ?) or a regular expression			

			$SearchString = "- ERROR -"
			# 1. Get the latest file matching the pattern
			# Get-ChildItem -File ensures only files are returned (not directories)
			# -Filter uses wildcard matching for efficiency

			$latestFile = Get-ChildItem -Path $path -Filter $pattern -File | 
						  Sort-Object -Property LastWriteTime -Descending | 
						  Select-Object -First 1

			# 2. Check if a file was found and search for the string
			if ($latestFile) {
				#Write-Host "The latest file is: $($latestFile.FullName)"
				#Write-Host "Searching for '$SearchString' in the latest file: $($latestFile.FullName)"
				# Use Select-String to find the "Error" string within the file
				# -SimpleMatch ensures a literal string search (not regex)
				$matches = Select-String -Path $latestFile.FullName -Pattern $SearchString -SimpleMatch

				if ($matches) {
					Write-Host "Found '$SearchString' string in the file."
					# Display the match details (filename, line number, line content)
					#$matches | Format-Table FileName, LineNumber, Line -AutoSize
					$ErrorMessage = $matches | Select-Object FileName, LineNumber, Line | Out-String
				} else {
					Write-Host "Did not find '$SearchString' string in the file."
				}			
				
			} else {
				Write-Host "No files found matching the pattern in the specified directory."
			}
			
			# --------------------------------------------------
			# Send failure mail.
			# --------------------------------------------------
			$subject = "$Environment (Firdapse): Datavant CLI failed"
			$body = "The Datavant Token generation step for the SQL job failed."
			$fullBody = "$body `nError Details: $ErrorMessage"
	
			$smtp = New-Object System.Net.Mail.SmtpClient($smtpServer)
			# Configure credentials/SSL if required by your SMTP server (see source 1.1.5 for examples)
			$smtp.EnableSsl = $true
			$smtp.Credentials = New-Object System.Net.NetworkCredential($UserName, $MailPwd);
			$smtp.Send($emailFrom, $emailTo, $subject, $fullBody)
			Write-Output "Failure email sent successfully."
	
			#exit $process.ExitCode
			throw "`nError Details: $ErrorMessage"
		}

		
		
		# --------------------------------------------------
		# Validate log files for validation
		# --------------------------------------------------
		
		# Define the directory path and file pattern
		$path = $DatavantExePath
		$pattern = "datavant_tokenize_*.log" # Use wildcards (*, ?) or a regular expression
		#$pattern = "token_errors_tokenize_*.log" # Use wildcards (*, ?) or a regular expression

		$SearchString = "- ERROR -"

		# 1. Get the latest file matching the pattern
		# Get-ChildItem -File ensures only files are returned (not directories)
		# -Filter uses wildcard matching for efficiency

		$latestFile = Get-ChildItem -Path $path -Filter $pattern -File | 
					  Sort-Object -Property LastWriteTime -Descending | 
					  Select-Object -First 1

		# 2. Check if a file was found and search for the string
		if ($latestFile) {
			Write-Host "The latest file is: $($latestFile.FullName)"
			Write-Host "Searching for '$SearchString' in the latest file: $($latestFile.FullName)"
			# Use Select-String to find the "Error" string within the file
			# -SimpleMatch ensures a literal string search (not regex)
			$matches = Select-String -Path $latestFile.FullName -Pattern $SearchString -SimpleMatch

			if ($matches) {
				Write-Host "Found '$SearchString' string in the file."
				# Display the match details (filename, line number, line content)
				#$matches | Format-Table FileName, LineNumber, Line -AutoSize
				$ErrorMessage = $matches | Select-Object FileName, LineNumber, Line | Out-String
				
				# --------------------------------------------------
				# Send failure mail.
				# --------------------------------------------------
				$subject = "$Environment (Firdapse): Datavant CLI failed"
				$body = "The Datavant Token generation step for the SQL job failed."
				$fullBody = "$body `nError Details: $ErrorMessage"
		
				$smtp = New-Object System.Net.Mail.SmtpClient($smtpServer)
				# Configure credentials/SSL if required by your SMTP server (see source 1.1.5 for examples)
				$smtp.EnableSsl = $true
				$smtp.Credentials = New-Object System.Net.NetworkCredential($UserName, $MailPwd);
				$smtp.Send($emailFrom, $emailTo, $subject, $fullBody)
				Write-Output "Failure email sent successfully."
		
				#exit 1				
				throw "`nError Details: $ErrorMessage"
				
			} else {
				Write-Host "Did not find '$SearchString' string in the file."
			}
		} else {
			Write-Host "No files found matching the pattern in the specified directory."
		}
		
		Write-Host "Datavant CLI executed successfully"	
		# --------------------------------------------------
		# Move the Datavant log file to specified folder.
		# --------------------------------------------------
			
		Get-ChildItem "$DatavantExePath\datavant_tokenize_*.log" | Move-Item -Destination "$DatavantLogPath" -Force
		Get-ChildItem "$DatavantExePath\token_errors_tokenize_*.log" | Move-Item -Destination "$DatavantLogPath" -Force
		Get-ChildItem "$DatavantExePath\data_quality_*.log" | Move-Item -Destination "$DatavantLogPath" -Force
		
		Get-ChildItem "$DatavantExePath\datavant_transform-tokens_*.log" | Move-Item -Destination "$DatavantLogPath" -Force
		Get-ChildItem "$DatavantExePath\token_errors_transform-tokens_*.log" | Move-Item -Destination "$DatavantLogPath" -Force	
		
	}
	
		
	# --------------------------------------------------
	# Move the feed files to final shared location.
	# --------------------------------------------------
	Get-ChildItem "$TokenSRCPath\*.txt" | Move-Item -Destination "$DestinationPath" -Force
	
	# --------------------------------------------------
	# Send success mail.
	# --------------------------------------------------
	
	$subject = "$Environment (Firdapse): Datavant CLI executed successfully."
	$body = "The Datavant Token generation step for the SQL job succeeded."
	$fullBody = "$body"

	$smtp = New-Object System.Net.Mail.SmtpClient($smtpServer)
	# Configure credentials/SSL if required by your SMTP server (see source 1.1.5 for examples)
	$smtp.EnableSsl = $true
	$smtp.Credentials = New-Object System.Net.NetworkCredential($UserName, $MailPwd);
	$smtp.Send($emailFrom, $emailTo, $subject, $fullBody)		
	exit 0
}
catch {
    # Log the error details
    Write-Error "An error occurred: $($_.Exception.Message)"
    ## Throw the error to the standard error stream
    #throw "Script failed due to an error"
    ## Set the exit code to a non-zero value to indicate failure
	##throw "An error occurred: $($_.Exception.Message)"
	throw
    exit 1
}
finally {
    # Code that always runs, regardless of whether an error occurred (e.g., cleanup)
    Write-Host "Execution completed."
}

<#
Usage:
CD D:\Anovo\Projects\JiraTasks\CAT-281\Tokenization
.\GenerateDatavantTokens.ps1 'D:\Anovo\Projects\JiraTasks\CAT-281\Tokenization' 'D:\Anovo\Projects\JiraTasks\CAT-281\Tokenization\Files\Patient_Encryption_20260121203042.txt' 'D:\Anovo\Projects\JiraTasks\CAT-281\Tokenization\Encrypted\Test.txt'

Or
CD D:\Anovo\Projects\JiraTasks\CAT-281\Tokenization
.\GenerateDatavantTokens.ps1 -- Enter Paramters
$DatavantExePath 	-- D:\Anovo\Projects\Misc\36760\CT1\Tokenization
$CredentialFilePath	-- D:\Anovo\Projects\Misc\36760\CT1\Tokenization\Credentials\credentials_Catalyst.txt
$PHIFilepath		-- D:\Anovo\Projects\Misc\36760\CT1\FeedFiles\temp\Patient_20260309161152.txt
$OutoutFilepath		-- D:\Anovo\Projects\Misc\36760\CT1\FeedFiles\temp\Encrypted\Patient_20260309161152.txt

#>