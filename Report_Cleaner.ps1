# Prompt the user for the path to the main HTML file
$MainHtmlFilePath = Read-Host "Please enter the full path to the main report HTML file (e.g., C:\path\to\BaselineReports.html)"

# Automatically determine the folder path for individual reports
$FolderPath = Join-Path -Path (Split-Path -Path $MainHtmlFilePath -Parent) -ChildPath "IndividualReports"

# Function to update an HTML file
function Update-HTMLFile {
    param (
        [string]$HtmlFilePath
    )

    # Read the content of the HTML file
    try {
        $HtmlContent = Get-Content -Path $HtmlFilePath -Raw
    } catch {
        Write-Host "Error reading file: $HtmlFilePath. Skipping this file." -ForegroundColor Red
        return
    }

    # Remove the entire <header> element
    $HtmlContent = $HtmlContent -replace '(?is)<header>.*?</header>', ''

    # Save the modified HTML back to the original file
    try {
        Set-Content -Path $HtmlFilePath -Value $HtmlContent
        Write-Host "HTML file updated successfully: $HtmlFilePath"
    } catch {
        Write-Host "Error writing to file: $HtmlFilePath." -ForegroundColor Red
    }
}

# Check if the main HTML file exists
if (Test-Path -Path $MainHtmlFilePath) {
    # Remove the header from the main report
    Update-HTMLFile -HtmlFilePath $MainHtmlFilePath
} else {
    Write-Host "Main HTML file not found at: $MainHtmlFilePath" -ForegroundColor Red
}

# Check if the folder containing individual reports exists
if (Test-Path -Path $FolderPath) {
    # Loop through all sub-reports in the folder and remove the header from them
    Get-ChildItem -Path $FolderPath -Filter "*.html" | ForEach-Object {
        Update-HTMLFile -HtmlFilePath $_.FullName
    }
    Write-Host "All individual report files have been updated!"
} else {
    Write-Host "IndividualReports folder not found at: $FolderPath" -ForegroundColor Red
}

# Final message
Write-Host "Script execution complete!"
