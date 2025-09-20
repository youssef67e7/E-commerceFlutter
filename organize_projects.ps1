# 📁 Project Organizer - Prepare for Development Migration
# This script organizes your existing projects before the main migration

Write-Host "📁 Project Organization for Development Migration" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Create temporary organization structure
$tempRoot = "E:\Development"
if (-not (Test-Path $tempRoot)) {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
}

$projectsRoot = "$tempRoot\Projects"
New-Item -ItemType Directory -Path "$projectsRoot\Flutter" -Force | Out-Null
New-Item -ItemType Directory -Path "$projectsRoot\Android" -Force | Out-Null
New-Item -ItemType Directory -Path "$projectsRoot\Web" -Force | Out-Null
New-Item -ItemType Directory -Path "$projectsRoot\Archive" -Force | Out-Null

Write-Host "`n🔍 Scanning for projects..." -ForegroundColor Yellow

# Function to copy project with progress
function Copy-ProjectSafely {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$ProjectName
    )
    
    Write-Host "📋 Copying $ProjectName..." -ForegroundColor Green
    Write-Host "   From: $Source" -ForegroundColor Gray
    Write-Host "   To: $Destination" -ForegroundColor Gray
    
    try {
        robocopy $Source $Destination /E /R:3 /W:5 /MT:4 /NFL /NDL /NP | Out-Null
        if ($LASTEXITCODE -le 8) {
            Write-Host "   ✅ Successfully copied $ProjectName" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ Failed to copy $ProjectName" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   ❌ Error copying $ProjectName`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 1. Copy current E-commerce project
Write-Host "`n🛒 E-COMMERCE PROJECT" -ForegroundColor Cyan
if (Test-Path "E:\Android\E-commerce") {
    Copy-ProjectSafely -Source "E:\Android\E-commerce" -Destination "$projectsRoot\Flutter\E-commerce-Main" -ProjectName "E-commerce Main Project"
}

# 2. Copy Flutter projects from Documents
Write-Host "`n🐦 FLUTTER PROJECTS FROM DOCUMENTS" -ForegroundColor Cyan
$flutterDocsPath = "C:\Users\DELL\Documents\FlutterProjects"
if (Test-Path $flutterDocsPath) {
    $flutterProjects = Get-ChildItem $flutterDocsPath -Directory
    foreach ($project in $flutterProjects) {
        # Check if it's a Flutter project (has pubspec.yaml)
        if (Test-Path (Join-Path $project.FullName "pubspec.yaml")) {
            $targetPath = "$projectsRoot\Flutter\$($project.Name)-Documents"
            Copy-ProjectSafely -Source $project.FullName -Destination $targetPath -ProjectName "Flutter: $($project.Name)"
        }
    }
}

# 3. Scan for other potential Flutter projects
Write-Host "`n🔍 SCANNING FOR OTHER FLUTTER PROJECTS" -ForegroundColor Cyan
$commonPaths = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop", 
    "C:\Projects",
    "D:\Projects",
    "E:\Projects"
)

foreach ($searchPath in $commonPaths) {
    if (Test-Path $searchPath) {
        Write-Host "   Scanning: $searchPath" -ForegroundColor Gray
        
        $foundProjects = Get-ChildItem $searchPath -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue | 
                        Where-Object { Test-Path (Join-Path $_.FullName "pubspec.yaml") }
        
        foreach ($project in $foundProjects) {
            # Skip if already processed
            $projectName = $project.Name
            if ($projectName -eq "ecommerce_app" -and $project.FullName -like "*Documents\FlutterProjects*") {
                continue # Already processed above
            }
            
            $targetPath = "$projectsRoot\Flutter\$projectName-Found"
            Write-Host "   Found Flutter project: $($project.Name)" -ForegroundColor Yellow
            Copy-ProjectSafely -Source $project.FullName -Destination $targetPath -ProjectName "Found: $projectName"
        }
    }
}

# 4. Create project summary
Write-Host "`n📊 CREATING PROJECT SUMMARY" -ForegroundColor Cyan

$summary = @"
# Flutter Projects Organization Summary
Generated on: $(Get-Date)

## 📁 Organized Projects Location: 
E:\Development\Projects\Flutter\

## 📱 Flutter Projects Found and Copied:

"@

$flutterProjectsPath = "$projectsRoot\Flutter"
if (Test-Path $flutterProjectsPath) {
    $organizedProjects = Get-ChildItem $flutterProjectsPath -Directory
    
    foreach ($project in $organizedProjects) {
        $pubspecPath = Join-Path $project.FullName "pubspec.yaml"
        if (Test-Path $pubspecPath) {
            # Read project name from pubspec.yaml
            $pubspecContent = Get-Content $pubspecPath -Raw
            if ($pubspecContent -match "name:\s*(.+)") {
                $projectName = $matches[1].Trim()
            } else {
                $projectName = $project.Name
            }
            
            $summary += "`n### $($project.Name)`n"
            $summary += "- **Project Name**: $projectName`n"
            $summary += "- **Location**: $($project.FullName)`n"
            $summary += "- **Size**: $([math]::Round((Get-ChildItem $project.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB`n"
            
            # Check for specific files
            if (Test-Path (Join-Path $project.FullName "android")) {
                $summary += "- **Platform**: Android ✅`n"
            }
            if (Test-Path (Join-Path $project.FullName "web")) {
                $summary += "- **Platform**: Web ✅`n"
            }
            if (Test-Path (Join-Path $project.FullName "ios")) {
                $summary += "- **Platform**: iOS ✅`n"
            }
        }
    }
}

$summary += @"

## 🚀 Next Steps:
1. Review the organized projects in: E:\Development\Projects\Flutter\
2. Run the main migration script: .\migrate_all_dev_tools_to_e.ps1
3. After migration, open projects from the new organized location
4. Clean up original project locations if everything works correctly

## 📋 Quick Commands After Migration:
```powershell
# Navigate to Flutter projects
cd E:\Development\Projects\Flutter

# Open in VS Code
code E:\Development\Projects\Flutter

# Test a project
cd E:\Development\Projects\Flutter\E-commerce-Main\E-commerce\ecommerce_app
flutter clean && flutter pub get && flutter run -d web-server
```

## 🔍 Project Verification:
After the main migration, verify each project:
1. Check that pubspec.yaml is intact
2. Run 'flutter clean && flutter pub get' in each project
3. Test building: 'flutter build web' or 'flutter build apk'
4. Ensure all dependencies are resolved

Happy coding with your organized Flutter projects! 🎉
"@

$summaryPath = "$projectsRoot\FLUTTER_PROJECTS_SUMMARY.md"
$summary | Out-File -FilePath $summaryPath -Encoding UTF8

Write-Host "`n✅ PROJECT ORGANIZATION COMPLETE!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "`n📊 Summary:" -ForegroundColor Yellow
if (Test-Path $flutterProjectsPath) {
    $projectCount = (Get-ChildItem $flutterProjectsPath -Directory).Count
    Write-Host "- ✅ $projectCount Flutter projects organized" -ForegroundColor Green
    Write-Host "- 📁 Location: $flutterProjectsPath" -ForegroundColor White
    Write-Host "- 📄 Summary: $summaryPath" -ForegroundColor White
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Review organized projects: explorer '$flutterProjectsPath'" -ForegroundColor White
Write-Host "2. Run main migration: .\migrate_all_dev_tools_to_e.ps1" -ForegroundColor White
Write-Host "3. Test projects after migration" -ForegroundColor White

# Open the organized projects folder
try {
    explorer $flutterProjectsPath
    Write-Host "`n📂 Opened organized projects folder in Explorer" -ForegroundColor Green
}
catch {
    Write-Host "`n⚠️  Please manually open: $flutterProjectsPath" -ForegroundColor Yellow
}

Read-Host "`nPress Enter to continue"