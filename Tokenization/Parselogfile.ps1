# Define the directory path and file pattern
$path = "D:\Anovo\Projects\Misc\36760\CT1\Tokenization"
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
		$matchDetails = $matches | Select-Object FileName, LineNumber, Line | Out-String
		
		Write-Host "Error Details are `n$matchDetails"
    } else {
        Write-Host "Did not find '$SearchString' string in the file."
    }
	
    # You can access other properties like:
    # $latestFile.Name
    # $latestFile.DirectoryName
    # $latestFile.CreationTime
} else {
    Write-Host "No files found matching the pattern in the specified directory."
}