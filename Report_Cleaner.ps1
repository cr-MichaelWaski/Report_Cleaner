# Define the path to the main HTML file
$MainHtmlFilePath = "C:\Users\MichaelWaski\Desktop\M365BaselineConformance_2024_12_18_20_01_12\BaselineReports.html"

# Define the path to the folder containing sub-reports
$FolderPath = "C:\Users\MichaelWaski\Desktop\M365BaselineConformance_2024_12_18_20_01_12\IndividualReports"

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

# Remove the header from the main report
Update-HTMLFile -HtmlFilePath $MainHtmlFilePath

# Loop through all sub-reports in the folder and remove the header from them
Get-ChildItem -Path $FolderPath -Filter "*.html" | ForEach-Object {
    Update-HTMLFile -HtmlFilePath $_.FullName
}

# Final message
Write-Host "All HTML files have been updated to remove the header!"