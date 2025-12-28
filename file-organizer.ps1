#File Organizer Script
#sorts the files into categories folders by extensions


param (
    [string]$TargetFolder = $(Get-Location).Path,
    [switch]$DryRun,
    [switch]$CreateLog,
    [switch]$ListCategories,
    [switch]$Help
)
Write-Host "PSBoundParameters: $($PSBoundParameters.Keys -join ', ')"


#File types and categories mapping
$categories = @{
    'Documents' = @('.doc', '.docx', '.odt', '.rtf', '.tex', '.txt', '.wpd', '.pages')
    'PDFs' = @('.pdf')
    'Books_epub' = @('.epub')
    'Comics' = @('.cbz', '.cbr', '.cb7', '.cbt')
    'Spreadsheets' = @('.xls', '.xlsx', '.xlsm', '.ods', '.csv', '.tsv', '.numbers')
    'Presentations' = @('.ppt', '.pptx', '.odp', '.key')
    'TextFiles' = @('.txt', '.log', '.ini', '.cfg', '.conf', '.xml', '.json', '.yaml', '.yml')
    'Images' = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.svg', '.webp', '.ico', '.psd', '.ai', '.eps')
    'Videos' = @('.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv', '.webm', '.m4v', '.mpg', '.mpeg')
    'Audio' = @('.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a')
    'Archives' = @('.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz')
    'Executables' = @('.exe', '.msi', '.bat', '.cmd', '.ps1', '.sh', '.app', '.apk')
    'Code' = @('.py', '.js', '.html', '.css', '.php', '.java', '.cpp', '.c', '.cs', '.rb', '.go', '.rs', '.ts', '.sql')
    'Data' = @('.db', '.sqlite', '.mdb', '.accdb', '.json', '.xml', '.csv', '.tsv')
    'Fonts' = @('.ttf', '.otf', '.woff', '.woff2', '.eot')
    'Others' = @()  # Everything else goes here
}

function Show-Banner {
    $banner = @"
  █████▒██▓ ██▓    ▓█████     ▒█████   ██▀███    ▄████  ▄▄▄       ███▄    █  ██▓▒███████▒▓█████  ██▀███  
▓██   ▒▓██▒▓██▒    ▓█   ▀    ▒██▒  ██▒▓██ ▒ ██▒ ██▒ ▀█▒▒████▄     ██ ▀█   █ ▓██▒▒ ▒ ▒ ▄▀░▓█   ▀ ▓██ ▒ ██▒
▒████ ░▒██▒▒██░    ▒███      ▒██░  ██▒▓██ ░▄█ ▒▒██░▄▄▄░▒██  ▀█▄  ▓██  ▀█ ██▒▒██▒░ ▒ ▄▀▒░ ▒███   ▓██ ░▄█ ▒
░▓█▒  ░░██░▒██░    ▒▓█  ▄    ▒██   ██░▒██▀▀█▄  ░▓█  ██▓░██▄▄▄▄██ ▓██▒  ▐▌██▒░██░  ▄▀▒   ░▒▓█  ▄ ▒██▀▀█▄  
░▒█░   ░██░░██████▒░▒████▒   ░ ████▓▒░░██▓ ▒██▒░▒▓███▀▒ ▓█   ▓██▒▒██░   ▓██░░██░▒███████▒░▒████▒░██▓ ▒██▒
 ▒ ░   ░▓  ░ ▒░▓  ░░░ ▒░ ░   ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ░▒   ▒  ▒▒   ▓▒█░░ ▒░   ▒ ▒ ░▓  ░▒▒ ▓░▒░▒░░ ▒░ ░░ ▒▓ ░▒▓░
 ░      ▒ ░░ ░ ▒  ░ ░ ░  ░     ░ ▒ ▒░   ░▒ ░ ▒░  ░   ░   ▒   ▒▒ ░░ ░░   ░ ▒░ ▒ ░░░▒ ▒ ░ ▒ ░ ░  ░  ░▒ ░ ▒░
 ░ ░    ▒ ░  ░ ░      ░      ░ ░ ░ ▒    ░░   ░ ░ ░   ░   ░   ▒      ░   ░ ░  ▒ ░░ ░ ░ ░ ░   ░     ░░   ░ 
        ░      ░  ░   ░  ░       ░ ░     ░           ░       ░  ░         ░  ░    ░ ░       ░  ░   ░     
                                                                                ░                        
"@
 $colors = @('Red', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta')
    $colorIndex = 0
    
    $banner -split "`n" | ForEach-Object {
        $line = $_
        $i = 0
        $line.ToCharArray() | ForEach-Object {
            $currentColor = $colors[$colorIndex % $colors.Count]
            Write-Host $_ -ForegroundColor $currentColor -NoNewline
            $colorIndex++
            $i++
        }
        Write-Host ""  # New line after each banner line
    }
    Write-Host ""  # Extra spacing
}

function Initialize-Script {
    Show-Banner
    Write-Host "Target Folder: $TargetFolder"
    Write-Host "Dry Run: $DryRun"
    Write-Host "Create Log: $CreateLog"
    Write-Host ""

    if(-not (Test-Path $TargetFolder)){
        Write-Host "Error: Target folder doesn't Exist!" -ForegroundColor Red
        exit 1
    }

    #create log files if requested
    if($CreateLog){
        $logFile = Join-Path $TargetFolder "FileOrganizer_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        Start-Transcript -Path $logFile -Append | Out-Null
        Write-Host "Logginf to: $logFile"
    }
}


function Get-FileCategory {
    param([string]$extension)

    foreach($category in $categories.Keys) {
        if($categories[$category] -contains $extension.ToLower()){
            return $category
        }
    }
    return "Others"
}

function Get-File-Organizer {
    $allFiles = Get-ChildItem -Path $TargetFolder -File

    if($allFiles.Count -eq 0){
        Write-Host "No files found to organize." -ForegroundColor Yellow
        return
    }

    Write-Host "Found $($allFiles.Count) files to process..." -ForegroundColor Green
    
    $organizedCount = 0
    $skippedCount = 0
    $categoryStats = @{}
    $dryRunMoves = @{}
    $dryRunFolders = @{}

    foreach($file in $allFiles) {
        $extension = $file.Extension
        $category = Get-FileCategory -extension $extension

        #skip if file is in its correct category folder
        if ($file.Directory.Name -eq $category) {
            Write-Host "  Skipping: $($file.Name) (already in $category folder)" -ForegroundColor Gray
            $skippedCount++
            continue
        }

        if($DryRun -and -not (Test-Path (Join-Path $TargetFolder $category))) {
            $dryRunFolders[$category] = $true
        }

        #create category folder if it doesn't exist
        $categoryPath = Join-Path $TargetFolder $category
        # if(-not (Test-Path $categoryPath)) {
        #     if(-not $DryRun){
        #         New-Item -Path $categoryPath -ItemType Directory -Force | Out-Null
        #         Write-Host "Created folder: $category" -ForegroundColor Green
        #     } else {
        #         Write-Host "[DRY RUN] Would create folder: $category" -ForegroundColor Gray
        #     }
        # }

        #Update statistics
         if (-not $categoryStats.ContainsKey($category)) {
            $categoryStats[$category] = 0
        }
        $categoryStats[$category]++

        #Move file
        
        if ($DryRun) {
            # Write-Host "[DRY RUN] Would move: $($file.Name) -> $category\" -ForegroundColor Gray
            if(-not $dryRunMoves.ContainsKey($category)) {
                $dryRunMoves[$category] = @()
            }
            $dryRunMoves[$category] += $file.Name
        } else {
            # folder creation + move
            if(-not (Test-Path $categoryPath)) {
                New-Item -Path $categoryPath -ItemType Directory -Force | Out-Null
                Write-Host "Created folder: $category" -ForegroundColor Green
            }
            $destination = Join-Path $categoryPath $file.Name
            try {
                Move-Item -Path $file.FullName -Destination $destination -Force -ErrorAction Stop
                Write-Host "Moved: $($file.Name) -> $category\" -ForegroundColor Green
                $organizedCount++
            }
            catch {
                 Write-Host "  Error moving $($file.Name): $_" -ForegroundColor Red
            }
        }
    }

    # NEW: Folders Summary (dry run only)
    if($DryRun -and $dryRunFolders.Count -gt 0) {
        Write-Host ""
        Write-Host "=== FOLDERS TO CREATE ===" -ForegroundColor Magenta
        Write-Host "These folders would be created:" -ForegroundColor Yellow
        $dryRunFolders.Keys | Sort-Object | ForEach-Object {
            Write-Host "  -> $_\" -ForegroundColor Cyan
        }
        Write-Host ""
    }

    #DryRun Summary
    if($DryRun -and $dryRunMoves.Count -gt 0){
         Write-Host ""
        Write-Host "=== DRY RUN SUMMARY ===" -ForegroundColor Cyan
        Write-Host "These files would be moved:" -ForegroundColor Yellow

        foreach($category in ($dryRunMoves.Keys | Sort-Object)) {
             Write-Host ""
            Write-Host "  -> $category\ ($($dryRunMoves[$category].Count) files):" -ForegroundColor Green
            $dryRunMoves[$category] | ForEach-Object { 
                Write-Host "     $_" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }

     # Display summary
    Write-Host ""
    Write-Host "=== Organization Summary ===" -ForegroundColor Cyan
    Write-Host "Total files processed: $($allFiles.Count)"
    Write-Host "Files organized: $organizedCount"
    Write-Host "Files skipped: $skippedCount"
    Write-Host ""

    if($categoryStats.Count -gt 0) {
         Write-Host "Files by category:" -ForegroundColor Yellow
         foreach($category in ($categoryStats.Keys |  Sort-Object)) {
            Write-Host "  $category`: $($categoryStats[$category]) files"
         }
    }
}

function Show-CategoryInfo {
    Write-Host ""
    Write-Host "=== Category Information ===" -ForegroundColor Cyan
    foreach ($category in ($categories.Keys | Sort-Object)) {
        $extensions = $categories[$category] -join ', '
        Write-Host "$category`: $extensions" -ForegroundColor Gray
    }
}

function Show-Categories {
    Write-Host "=== File Categories ===" -ForegroundColor Cyan
    Write-Host ""
    
    $totalExtensions = 0
    foreach ($category in ($categories.Keys | Sort-Object)) {
        if ($category -ne 'Others') {
            $extensionCount = $categories[$category].Count
            $totalExtensions += $extensionCount
            Write-Host "$category ($extensionCount extensions):" -ForegroundColor Yellow
            Write-Host "  $($categories[$category] -join ', ')" -ForegroundColor Gray
            Write-Host ""
        }
    }
    
    Write-Host "Others:" -ForegroundColor Yellow
    Write-Host "  Files with extensions not listed above" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Total file types recognized: $totalExtensions" -ForegroundColor Green
}


function Show-Help {
    Write-Host "=== File Organizer Help ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  Organizes files in a folder into categorized subfolders based on file extensions."
    Write-Host ""
    Write-Host "SYNTAX:" -ForegroundColor Yellow
    Write-Host "  .\Organize-Files.ps1 [-TargetFolder <path>] [-DryRun] [-CreateLog] [-Help] [-ListCategories]"
    Write-Host ""
    Write-Host "PARAMETERS:" -ForegroundColor Yellow
    Write-Host "  -TargetFolder <path>" -ForegroundColor Green
    Write-Host "      Specifies the folder to organize. Default is current directory."
    Write-Host ""
    Write-Host "  -DryRun" -ForegroundColor Green
    Write-Host "      Preview what would happen without actually moving files."
    Write-Host ""
    Write-Host "  -CreateLog" -ForegroundColor Green
    Write-Host "      Creates a log file of all actions taken."
    Write-Host ""
    Write-Host "  -Help" -ForegroundColor Green
    Write-Host "      Shows this help message."
    Write-Host ""
    Write-Host "  -ListCategories" -ForegroundColor Green
    Write-Host "      Lists all file categories and their extensions."
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\Organize-Files.ps1" -ForegroundColor Gray
    Write-Host "      Organizes files in the current folder."
    Write-Host ""
    Write-Host "  .\Organize-Files.ps1 -TargetFolder C:\Downloads -DryRun" -ForegroundColor Gray
    Write-Host "      Shows what would be organized in the Downloads folder."
    Write-Host ""
    Write-Host "  .\Organize-Files.ps1 -TargetFolder C:\MyFiles -CreateLog" -ForegroundColor Gray
    Write-Host "      Organizes files and creates a log."
    Write-Host ""
    Write-Host "  .\Organize-Files.ps1 -ListCategories" -ForegroundColor Gray
    Write-Host "      Lists all available categories."
    Write-Host ""
    Write-Host "NOTES:" -ForegroundColor Yellow
    Write-Host "  - Run PowerShell as Administrator if you encounter permission issues"
    Write-Host "  - Test with -DryRun first to preview changes"
    Write-Host "  - Empty category folders will remain after organization"
    Write-Host "  - A Bug I found was, files that are the age of more than a year are not being moved"
    Write-Host ""
}



# Main execution
if($Help){
    Show-Help
    exit 0
}

if($ListCategories){
    Show-Categories
    exit 0
}

Initialize-Script

Write-Host "Starting organization process..." -ForegroundColor Cyan
Write-Host ""

Get-File-Organizer


if($CreateLog) {
    Stop-Transcript
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green