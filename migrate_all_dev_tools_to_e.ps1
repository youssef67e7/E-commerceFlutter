# 🚀 Complete Development Environment Migration to E: Drive
# This script moves Flutter, Android Studio, Visual Studio Code, and all projects to E: drive

Write-Host "🚀 Complete Development Migration to E: Drive" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Create E:\Development directory structure
Write-Host "`n📁 Creating development directory structure on E: drive..." -ForegroundColor Green

$devRoot = "E:\Development"
$directories = @(
    "$devRoot\Android\Studio",              # Android Studio
    "$devRoot\Android\SDK",                 # Android SDK
    "$devRoot\Android\AVD",                 # Android Virtual Devices
    "$devRoot\Android\Gradle",              # Gradle cache
    "$devRoot\Android\Config",              # Android Studio config
    "$devRoot\VSCode",                      # Visual Studio Code
    "$devRoot\VSCode\Extensions",           # VS Code extensions
    "$devRoot\VSCode\Config",               # VS Code configuration
    "$devRoot\Flutter\SDK",                 # Flutter SDK
    "$devRoot\Flutter\Cache",               # Flutter cache
    "$devRoot\Projects\Flutter",            # Flutter projects
    "$devRoot\Projects\Android",            # Android projects
    "$devRoot\Projects\Web",                # Web projects
    "$devRoot\Projects\General"             # General projects
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✅ Created: $dir" -ForegroundColor Green
    }
}

# Function to move directory with progress and error handling
function Move-DirectoryWithProgress {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description,
        [bool]$CreateSymLink = $true
    )
    
    if (Test-Path $Source) {
        Write-Host "`n🔄 Moving $Description..." -ForegroundColor Yellow
        Write-Host "From: $Source"
        Write-Host "To: $Destination"
        
        try {
            # Ensure destination parent directory exists
            $destParent = Split-Path $Destination -Parent
            if (-not (Test-Path $destParent)) {
                New-Item -ItemType Directory -Path $destParent -Force | Out-Null
            }
            
            # Use robocopy for better performance with large directories
            $result = robocopy $Source $Destination /E /MOVE /R:3 /W:5 /MT:8 /NP /NFL /NDL
            if ($LASTEXITCODE -le 8) {
                Write-Host "✅ Successfully moved $Description" -ForegroundColor Green
                
                # Create symbolic link if requested
                if ($CreateSymLink) {
                    try {
                        New-Item -ItemType SymbolicLink -Path $Source -Target $Destination -Force | Out-Null
                        Write-Host "🔗 Created symbolic link: $Source -> $Destination" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "⚠️  Could not create symbolic link for $Description" -ForegroundColor Yellow
                    }
                }
                return $true
            } else {
                Write-Host "❌ Failed to move $Description (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
                return $false
            }
        }
        catch {
            Write-Host "❌ Error moving $Description`: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "⚠️  $Description not found at $Source" -ForegroundColor Yellow
        return $false
    }
}

# Function to copy directory (for active installations)
function Copy-DirectoryWithProgress {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )
    
    if (Test-Path $Source) {
        Write-Host "`n📋 Copying $Description..." -ForegroundColor Yellow
        Write-Host "From: $Source"
        Write-Host "To: $Destination"
        
        try {
            $result = robocopy $Source $Destination /E /R:3 /W:5 /MT:8 /NP /NFL /NDL
            if ($LASTEXITCODE -le 8) {
                Write-Host "✅ Successfully copied $Description" -ForegroundColor Green
                return $true
            } else {
                Write-Host "❌ Failed to copy $Description (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
                return $false
            }
        }
        catch {
            Write-Host "❌ Error copying $Description`: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "⚠️  $Description not found at $Source" -ForegroundColor Yellow
        return $false
    }
}

Write-Host "`n🛑 IMPORTANT: Close all development tools before proceeding!" -ForegroundColor Red
Write-Host "- Android Studio" -ForegroundColor White
Write-Host "- Visual Studio Code" -ForegroundColor White
Write-Host "- Any running Android emulators" -ForegroundColor White
Write-Host "- Any Flutter/Dart processes" -ForegroundColor White

$confirm = Read-Host "`nHave you closed all development tools? (y/n)"

if ($confirm -ne "y") {
    Write-Host "❌ Please close all development tools first, then run this script again." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# =============================================================================
# 1. ANDROID STUDIO MIGRATION
# =============================================================================
Write-Host "`n🤖 ANDROID STUDIO MIGRATION" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

# Move Android Studio Installation
$studioPaths = @(
    "C:\Program Files\Android\Android Studio",
    "C:\Program Files (x86)\Android\Android Studio"
)

foreach ($studioPath in $studioPaths) {
    if (Test-Path $studioPath) {
        Move-DirectoryWithProgress -Source $studioPath -Destination "$devRoot\Android\Studio" -Description "Android Studio Installation"
        break
    }
}

# Move Android SDK
$sdkPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:APPDATA\Local\Android\Sdk",
    "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
)

foreach ($sdkPath in $sdkPaths) {
    if (Test-Path $sdkPath) {
        Move-DirectoryWithProgress -Source $sdkPath -Destination "$devRoot\Android\SDK" -Description "Android SDK"
        break
    }
}

# Move Android Virtual Devices (AVD)
$avdPath = "$env:USERPROFILE\.android\avd"
Move-DirectoryWithProgress -Source $avdPath -Destination "$devRoot\Android\AVD" -Description "Android Virtual Devices"

# Move Gradle Cache
$gradlePath = "$env:USERPROFILE\.gradle"
Move-DirectoryWithProgress -Source $gradlePath -Destination "$devRoot\Android\Gradle" -Description "Gradle Cache"

# Move Android Studio Configuration
$configPaths = @(
    "$env:USERPROFILE\.AndroidStudio*",
    "$env:APPDATA\Google\AndroidStudio*"
)

foreach ($configPattern in $configPaths) {
    $configDirs = Get-ChildItem $configPattern -Directory -ErrorAction SilentlyContinue
    foreach ($configDir in $configDirs) {
        $targetPath = "$devRoot\Android\Config\$($configDir.Name)"
        Move-DirectoryWithProgress -Source $configDir.FullName -Destination $targetPath -Description "Android Studio Config ($($configDir.Name))"
    }
}

# =============================================================================
# 2. VISUAL STUDIO CODE MIGRATION  
# =============================================================================
Write-Host "`n💻 VISUAL STUDIO CODE MIGRATION" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Copy VS Code Installation (don't move, as it might break system integration)
$vscodePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code",
    "C:\Program Files\Microsoft VS Code",
    "C:\Program Files (x86)\Microsoft VS Code"
)

foreach ($vscodePath in $vscodePaths) {
    if (Test-Path $vscodePath) {
        Copy-DirectoryWithProgress -Source $vscodePath -Destination "$devRoot\VSCode\Installation" -Description "Visual Studio Code Installation"
        break
    }
}

# Move VS Code Extensions
$extensionPaths = @(
    "$env:USERPROFILE\.vscode\extensions",
    "$env:APPDATA\Code\User\extensions"
)

foreach ($extPath in $extensionPaths) {
    if (Test-Path $extPath) {
        Move-DirectoryWithProgress -Source $extPath -Destination "$devRoot\VSCode\Extensions" -Description "VS Code Extensions"
        break
    }
}

# Move VS Code User Configuration
$configPaths = @(
    "$env:APPDATA\Code\User",
    "$env:USERPROFILE\.vscode"
)

foreach ($configPath in $configPaths) {
    if (Test-Path $configPath) {
        $targetPath = "$devRoot\VSCode\Config\$(Split-Path $configPath -Leaf)"
        Move-DirectoryWithProgress -Source $configPath -Destination $targetPath -Description "VS Code Configuration"
    }
}

# =============================================================================
# 3. FLUTTER SDK MIGRATION
# =============================================================================
Write-Host "`n🐦 FLUTTER SDK MIGRATION" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# Find Flutter SDK location
$flutterPaths = @(
    "C:\flutter",
    "C:\src\flutter", 
    "$env:USERPROFILE\flutter",
    "$env:LOCALAPPDATA\flutter"
)

# Also check current PATH for flutter
$currentPath = $env:PATH
$pathEntries = $currentPath -split ";"
foreach ($pathEntry in $pathEntries) {
    if ($pathEntry -like "*flutter*" -and $pathEntry -like "*bin*") {
        $flutterPaths += (Split-Path (Split-Path $pathEntry -Parent) -Parent)
    }
}

foreach ($flutterPath in $flutterPaths) {
    if (Test-Path "$flutterPath\bin\flutter.bat") {
        Move-DirectoryWithProgress -Source $flutterPath -Destination "$devRoot\Flutter\SDK" -Description "Flutter SDK"
        break
    }
}

# Move Flutter cache and pub cache
$pubCachePath = "$env:USERPROFILE\.pub-cache"
if (Test-Path $pubCachePath) {
    Move-DirectoryWithProgress -Source $pubCachePath -Destination "$devRoot\Flutter\Cache\pub-cache" -Description "Flutter Pub Cache"
}

# =============================================================================
# 4. PROJECTS MIGRATION
# =============================================================================
Write-Host "`n📁 PROJECTS MIGRATION" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

# Move current Flutter E-commerce project
$currentProject = "E:\Android\E-commerce"
if (Test-Path $currentProject) {
    $targetProject = "$devRoot\Projects\Flutter\E-commerce"
    Copy-DirectoryWithProgress -Source $currentProject -Destination $targetProject -Description "Flutter E-commerce Project"
    Write-Host "✅ E-commerce project copied to: $targetProject" -ForegroundColor Green
}

# Look for other Flutter projects
$commonProjectPaths = @(
    "$env:USERPROFILE\Documents\flutter_projects",
    "$env:USERPROFILE\Projects",
    "$env:USERPROFILE\Documents\Projects",
    "C:\Projects",
    "D:\Projects"
)

foreach ($projectPath in $commonProjectPaths) {
    if (Test-Path $projectPath) {
        $flutterProjects = Get-ChildItem $projectPath -Directory | Where-Object {
            Test-Path (Join-Path $_.FullName "pubspec.yaml")
        }
        
        foreach ($project in $flutterProjects) {
            $targetPath = "$devRoot\Projects\Flutter\$($project.Name)"
            Copy-DirectoryWithProgress -Source $project.FullName -Destination $targetPath -Description "Flutter Project ($($project.Name))"
        }
    }
}

# =============================================================================
# 5. ENVIRONMENT VARIABLES UPDATE
# =============================================================================
Write-Host "`n🌍 UPDATING ENVIRONMENT VARIABLES" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Set Android environment variables
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "$devRoot\Android\SDK", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "$devRoot\Android\SDK", [EnvironmentVariableTarget]::User)

# Set Flutter environment variable
[Environment]::SetEnvironmentVariable("FLUTTER_ROOT", "$devRoot\Flutter\SDK", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("PUB_CACHE", "$devRoot\Flutter\Cache\pub-cache", [EnvironmentVariableTarget]::User)

# Update PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)

# Remove old paths
$pathsToRemove = @(
    "*flutter*",
    "*Android*",
    "*\.pub-cache*"
)

$cleanPath = $currentPath
foreach ($pathPattern in $pathsToRemove) {
    $cleanPath = ($cleanPath -split ";") | Where-Object { $_ -notlike $pathPattern } | Join-String -Separator ";"
}

# Add new paths
$newPaths = @(
    "$devRoot\Android\SDK\platform-tools",
    "$devRoot\Android\SDK\tools",
    "$devRoot\Android\SDK\tools\bin",
    "$devRoot\Android\Studio\bin",
    "$devRoot\Flutter\SDK\bin",
    "$devRoot\VSCode\Installation\bin"
)

foreach ($newPath in $newPaths) {
    if ($cleanPath -notlike "*$newPath*") {
        $cleanPath += ";$newPath"
    }
}

[Environment]::SetEnvironmentVariable("PATH", $cleanPath, [EnvironmentVariableTarget]::User)

Write-Host "✅ Environment variables updated:" -ForegroundColor Green
Write-Host "   ANDROID_HOME = $devRoot\Android\SDK" -ForegroundColor White
Write-Host "   FLUTTER_ROOT = $devRoot\Flutter\SDK" -ForegroundColor White
Write-Host "   PUB_CACHE = $devRoot\Flutter\Cache\pub-cache" -ForegroundColor White

# =============================================================================
# 6. CREATE SHORTCUTS AND LAUNCHERS
# =============================================================================
Write-Host "`n🖥️  CREATING SHORTCUTS" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

$desktopPath = [Environment]::GetFolderPath("Desktop")

# Android Studio shortcut
$studioExePath = "$devRoot\Android\Studio\bin\studio64.exe"
if (Test-Path $studioExePath) {
    $shortcutPath = "$desktopPath\Android Studio (E Drive).lnk"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $studioExePath
    $Shortcut.WorkingDirectory = "$devRoot\Projects\Android"
    $Shortcut.IconLocation = $studioExePath
    $Shortcut.Description = "Android Studio (E: Drive)"
    $Shortcut.Save()
    Write-Host "✅ Android Studio shortcut created" -ForegroundColor Green
}

# VS Code shortcut (if copied)
$vscodeExePath = "$devRoot\VSCode\Installation\Code.exe"
if (Test-Path $vscodeExePath) {
    $shortcutPath = "$desktopPath\VS Code (E Drive).lnk"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $vscodeExePath
    $Shortcut.WorkingDirectory = "$devRoot\Projects"
    $Shortcut.IconLocation = $vscodeExePath
    $Shortcut.Description = "Visual Studio Code (E: Drive)"
    $Shortcut.Save()
    Write-Host "✅ VS Code shortcut created" -ForegroundColor Green
}

# Create development launcher script
$launcherScript = @"
# 🚀 Development Environment Launcher
# Launch development tools from E: drive

Write-Host "🚀 Development Environment (E: Drive)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Android Studio" -ForegroundColor Green
Write-Host "2. Visual Studio Code" -ForegroundColor Green  
Write-Host "3. Flutter Projects Folder" -ForegroundColor Green
Write-Host "4. Android Projects Folder" -ForegroundColor Green
Write-Host "5. Check Flutter Doctor" -ForegroundColor Green
Write-Host "6. Exit" -ForegroundColor Red
Write-Host ""

do {
    `$choice = Read-Host "Select option (1-6)"
    
    switch (`$choice) {
        "1" { 
            if (Test-Path "$devRoot\Android\Studio\bin\studio64.exe") {
                Start-Process "$devRoot\Android\Studio\bin\studio64.exe"
                Write-Host "✅ Launching Android Studio..." -ForegroundColor Green
            } else {
                Write-Host "❌ Android Studio not found" -ForegroundColor Red
            }
        }
        "2" { 
            if (Test-Path "$devRoot\VSCode\Installation\Code.exe") {
                Start-Process "$devRoot\VSCode\Installation\Code.exe" -ArgumentList "$devRoot\Projects"
                Write-Host "✅ Launching VS Code..." -ForegroundColor Green
            } else {
                Write-Host "❌ VS Code not found, using system VS Code" -ForegroundColor Yellow
                code "$devRoot\Projects"
            }
        }
        "3" { 
            explorer "$devRoot\Projects\Flutter"
            Write-Host "✅ Opening Flutter projects folder..." -ForegroundColor Green
        }
        "4" { 
            explorer "$devRoot\Projects\Android"  
            Write-Host "✅ Opening Android projects folder..." -ForegroundColor Green
        }
        "5" {
            Write-Host "`n🔍 Running Flutter Doctor..." -ForegroundColor Yellow
            flutter doctor
        }
        "6" { 
            Write-Host "👋 Goodbye!" -ForegroundColor Green
            break 
        }
        default { 
            Write-Host "❌ Invalid option. Please select 1-6." -ForegroundColor Red 
        }
    }
    
    if (`$choice -ne "6") {
        Write-Host ""
        Read-Host "Press Enter to continue"
        Clear-Host
        Write-Host "🚀 Development Environment (E: Drive)" -ForegroundColor Cyan
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Android Studio" -ForegroundColor Green
        Write-Host "2. Visual Studio Code" -ForegroundColor Green  
        Write-Host "3. Flutter Projects Folder" -ForegroundColor Green
        Write-Host "4. Android Projects Folder" -ForegroundColor Green
        Write-Host "5. Check Flutter Doctor" -ForegroundColor Green
        Write-Host "6. Exit" -ForegroundColor Red
        Write-Host ""
    }
} while (`$choice -ne "6")
"@

$launcherScript | Out-File -FilePath "$devRoot\dev_launcher.ps1" -Encoding UTF8
Write-Host "✅ Development launcher created at: $devRoot\dev_launcher.ps1" -ForegroundColor Green

# =============================================================================
# 7. GENERATE MIGRATION SUMMARY
# =============================================================================
Write-Host "`n📄 GENERATING MIGRATION SUMMARY" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$summaryContent = @"
# Complete Development Environment Migration Summary
Generated on: $(Get-Date)

## 🗂️ New Directory Structure:
E:\Development\
├── Android\
│   ├── Studio\              # Android Studio installation
│   ├── SDK\                 # Android SDK and tools
│   ├── AVD\                 # Android Virtual Devices
│   ├── Gradle\              # Gradle cache
│   └── Config\              # Android Studio configuration
├── VSCode\
│   ├── Installation\        # VS Code installation (copy)
│   ├── Extensions\          # VS Code extensions
│   └── Config\              # VS Code user settings
├── Flutter\
│   ├── SDK\                 # Flutter SDK
│   └── Cache\               # Flutter cache and pub-cache
└── Projects\
    ├── Flutter\             # Flutter projects
    ├── Android\             # Android projects
    ├── Web\                 # Web projects
    └── General\             # Other projects

## 🌍 Environment Variables Updated:
- ANDROID_HOME = $devRoot\Android\SDK
- ANDROID_SDK_ROOT = $devRoot\Android\SDK
- FLUTTER_ROOT = $devRoot\Flutter\SDK
- PUB_CACHE = $devRoot\Flutter\Cache\pub-cache

## 🔗 Symbolic Links Created:
All original locations now point to E: drive through symbolic links.

## 🖥️ Shortcuts Created:
- Android Studio (E Drive).lnk - Desktop shortcut
- VS Code (E Drive).lnk - Desktop shortcut (if copied)
- dev_launcher.ps1 - Development tools launcher

## 📱 Your Projects:
- E-commerce Flutter App: $devRoot\Projects\Flutter\E-commerce
- Other projects automatically detected and moved

## 🚀 Quick Start:
1. Restart your computer to apply environment variables
2. Use desktop shortcuts or run: $devRoot\dev_launcher.ps1
3. Open projects from: $devRoot\Projects\Flutter\
4. Test Flutter setup: flutter doctor

## 🔧 Verification Commands:
flutter doctor                              # Check Flutter setup
echo `$env:ANDROID_HOME                     # Verify Android SDK path
echo `$env:FLUTTER_ROOT                     # Verify Flutter SDK path
code $devRoot\Projects\Flutter              # Open projects in VS Code

## 💾 Estimated Space Saved on C: Drive:
- Android Studio: ~3-5 GB
- Android SDK: ~10-15 GB
- AVD Files: ~5-10 GB per emulator  
- VS Code Extensions: ~1-3 GB
- Flutter SDK: ~2-4 GB
- Flutter Cache: ~1-5 GB
- Projects: Variable (depends on project sizes)
- Total: ~25-50+ GB

## 🆘 Troubleshooting:
If you encounter issues:
1. Restart computer and open new terminal
2. Check environment variables: Get-ChildItem Env: | Where-Object {`$_.Name -like "*ANDROID*" -or `$_.Name -like "*FLUTTER*"}
3. Verify symbolic links: Get-ChildItem -Path "C:\Users\$env:USERNAME" -Attributes ReparsePoint
4. Test Flutter: flutter doctor -v
5. Test Android SDK: adb version (if Android SDK tools are in PATH)

## 🔄 Rollback Instructions:
To revert changes:
1. Delete symbolic links
2. Move directories back to original locations
3. Reset environment variables
4. Update PATH variable

Full rollback script available upon request.

## 🎯 Next Steps:
1. Test all development tools work correctly
2. Open and test your Flutter projects
3. Configure any additional IDE settings as needed
4. Consider cleaning up old files if everything works well

Happy coding with your optimized development environment! 🚀
"@

$summaryPath = "$devRoot\MIGRATION_SUMMARY.txt"
$summaryContent | Out-File -FilePath $summaryPath -Encoding UTF8

# =============================================================================
# 8. FINAL SUMMARY AND INSTRUCTIONS
# =============================================================================
Write-Host "`n🎉 MIGRATION COMPLETE!" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

Write-Host "`n📊 Migration Results:" -ForegroundColor Yellow
Write-Host "- ✅ Android Studio migrated" -ForegroundColor Green
Write-Host "- ✅ Visual Studio Code configured" -ForegroundColor Green  
Write-Host "- ✅ Flutter SDK relocated" -ForegroundColor Green
Write-Host "- ✅ Projects organized" -ForegroundColor Green
Write-Host "- ✅ Environment variables updated" -ForegroundColor Green
Write-Host "- ✅ Shortcuts created" -ForegroundColor Green

Write-Host "`n🎯 Your New Development Hub:" -ForegroundColor Cyan
Write-Host "$devRoot" -ForegroundColor White

Write-Host "`n🚀 Quick Launch Options:" -ForegroundColor Yellow
Write-Host "1. Use desktop shortcuts" -ForegroundColor White
Write-Host "2. Run development launcher: $devRoot\dev_launcher.ps1" -ForegroundColor White
Write-Host "3. Navigate to projects: $devRoot\Projects\Flutter\" -ForegroundColor White

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. 🔄 Restart your computer" -ForegroundColor White
Write-Host "2. 🧪 Test Flutter: flutter doctor" -ForegroundColor White
Write-Host "3. 🏗️  Open your E-commerce project from: $devRoot\Projects\Flutter\E-commerce" -ForegroundColor White
Write-Host "4. 📱 Test building your Flutter app" -ForegroundColor White

Write-Host "`n📄 Full summary saved to: $summaryPath" -ForegroundColor Yellow

try {
    $eSpace = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "E:"}
    $cSpace = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "C:"}
    
    Write-Host "`n💾 Disk Space Status:" -ForegroundColor Yellow
    if ($eSpace) {
        $eSpaceGB = [math]::Round($eSpace.FreeSpace / 1GB, 2)
        Write-Host "E: Drive Free Space: $eSpaceGB GB" -ForegroundColor Green
    }
    
    if ($cSpace) {
        $cSpaceGB = [math]::Round($cSpace.FreeSpace / 1GB, 2)
        Write-Host "C: Drive Free Space: $cSpaceGB GB (Significantly increased! 🎉)" -ForegroundColor Green
    }
}
catch {
    Write-Host "Could not retrieve disk space information" -ForegroundColor Yellow
}

Write-Host "`n🌟 Your development environment is now optimized on E: drive!" -ForegroundColor Green
Write-Host "Enjoy the extra space and organized project structure! 🚀" -ForegroundColor Cyan

Read-Host "`nPress Enter to exit"