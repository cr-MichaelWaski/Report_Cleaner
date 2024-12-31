# Prompt the user for the directory containing the main report and subfolder
$BaseDirectory = Read-Host "Please enter the full path to the main report directory (e.g., C:\path\to\Directory)"

# Validate the base directory path
if (-Not (Test-Path -Path $BaseDirectory -PathType Container)) {
    Write-Host "The provided directory path does not exist: $BaseDirectory" -ForegroundColor Red
    exit
}

# Define the main report file path
$MainHtmlFilePath = Join-Path -Path $BaseDirectory -ChildPath "BaselineReports.html"

# Validate the main report file
if (-Not (Test-Path -Path $MainHtmlFilePath -PathType Leaf)) {
    Write-Host "The main report file does not exist at: $MainHtmlFilePath" -ForegroundColor Red
    exit
}

# Define the path to the subfolder containing individual reports
$FolderPath = Join-Path -Path $BaseDirectory -ChildPath "IndividualReports"

# Validate the subfolder path
if (-Not (Test-Path -Path $FolderPath -PathType Container)) {
    Write-Host "The IndividualReports subfolder does not exist at: $FolderPath" -ForegroundColor Red
    exit
}

# Debugging log to confirm paths
Write-Host "Base directory: $BaseDirectory"
Write-Host "Main HTML file path: $MainHtmlFilePath"
Write-Host "IndividualReports folder path: $FolderPath"

# Define the custom styles to include
$CustomStyles = @"
    /* Enforce blue background and title color */
    body {
        background-color: var(--background-color) !important;
        color: var(--text-color);
    }
    h1 {
        text-align: center;
        font-family: "Barlow Condensed", Arial, sans-serif;
        font-size: 36pt;
        color: var(--primary-color) !important; /* Yellow title */
    }

    /* Table Customization */
    table tr:nth-child(even) {
        background-color: white; /* Clean row background */
    }
    table tr:hover {
        background-color: #FFD700; /* Optional highlight color */
    }
    table, th, td {
        border: 0.125em solid var(--primary-color);
    }
    th {
        background-color: var(--secondary-color); /* Grey background for headers */
        color: white;
        text-transform: uppercase;
        font-weight: bold;
        padding: 0.5em;
    }
</style>
"@

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

    # Fully remove the toggle container, including nested elements
    $HtmlContent = $HtmlContent -replace '(?is)<div id="toggle-container">.*?</div>', ''

    # Ensure the CSS variables are updated
    $HtmlContent = $HtmlContent -replace '(:root\s*{)', '$1 --primary-color: #FFC628; --secondary-color: #575854; --background-color: #0e2438; --text-color: black; --border-color: black;'

    # Insert the custom styles before the closing </style> tag
    $HtmlContent = $HtmlContent -replace '(</style>)', "$CustomStyles"

    # Save the modified HTML back to the original file
    try {
        Set-Content -Path $HtmlFilePath -Value $HtmlContent
        Write-Host "HTML file updated successfully: $HtmlFilePath"
    } catch {
        Write-Host "Error writing to file: $HtmlFilePath." -ForegroundColor Red
    }
}

# Remove the header and update colors in the main report
Update-HTMLFile -HtmlFilePath $MainHtmlFilePath

# Loop through all sub-reports in the folder and update them
Get-ChildItem -Path $FolderPath -Filter "*.html" | ForEach-Object {
    Update-HTMLFile -HtmlFilePath $_.FullName
}

# Final message
Write-Host "All HTML files have been updated successfully!"
