# 📁 Move Android Studio and Related Files to E: Drive
# This script moves Android Studio installation and all related files to E: drive

Write-Host "🔄 Moving Android Studio to E: Drive" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Create E:\Android directory structure
Write-Host "`n📁 Creating directory structure on E: drive..." -ForegroundColor Green

$androidRoot = "E:\Android"
$directories = @(
    "$androidRoot\Studio",           # Android Studio installation
    "$androidRoot\SDK",              # Android SDK
    "$androidRoot\AVD",              # Android Virtual Devices
    "$androidRoot\Gradle",           # Gradle cache
    "$androidRoot\AndroidStudio",    # Android Studio config
    "$androidRoot\Projects"          # Android projects
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✅ Created: $dir" -ForegroundColor Green
    }
}

# Function to move directory with progress
function Move-DirectoryWithProgress {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )
    
    if (Test-Path $Source) {
        Write-Host "`n🔄 Moving $Description..." -ForegroundColor Yellow
        Write-Host "From: $Source"
        Write-Host "To: $Destination"
        
        try {
            # Use robocopy for better performance with large directories
            $result = robocopy $Source $Destination /E /MOVE /R:3 /W:5 /MT:8 /NP
            if ($LASTEXITCODE -le 8) {
                Write-Host "✅ Successfully moved $Description" -ForegroundColor Green
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

# Function to create symbolic link
function Create-SymbolicLink {
    param(
        [string]$Link,
        [string]$Target,
        [string]$Description
    )
    
    Write-Host "`n🔗 Creating symbolic link for $Description..." -ForegroundColor Yellow
    
    try {
        if (Test-Path $Link) {
            Remove-Item $Link -Force -Recurse
        }
        
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        Write-Host "✅ Created symbolic link: $Link -> $Target" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to create symbolic link: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n🛑 IMPORTANT: Close Android Studio and any running emulators before proceeding!" -ForegroundColor Red
$confirm = Read-Host "Have you closed Android Studio and emulators? (y/n)"

if ($confirm -ne "y") {
    Write-Host "❌ Please close Android Studio and emulators first, then run this script again." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 1. Move Android Studio Installation
Write-Host "`n📦 Moving Android Studio Installation..." -ForegroundColor Cyan

$studioPaths = @(
    "C:\Program Files\Android\Android Studio",
    "C:\Program Files (x86)\Android\Android Studio"
)

foreach ($studioPath in $studioPaths) {
    if (Test-Path $studioPath) {
        $moved = Move-DirectoryWithProgress -Source $studioPath -Destination "$androidRoot\Studio" -Description "Android Studio Installation"
        if ($moved) {
            Create-SymbolicLink -Link $studioPath -Target "$androidRoot\Studio" -Description "Android Studio"
        }
        break
    }
}

# 2. Move Android SDK
Write-Host "`n📱 Moving Android SDK..." -ForegroundColor Cyan

$sdkPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:APPDATA\Local\Android\Sdk",
    "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
)

foreach ($sdkPath in $sdkPaths) {
    if (Test-Path $sdkPath) {
        $moved = Move-DirectoryWithProgress -Source $sdkPath -Destination "$androidRoot\SDK" -Description "Android SDK"
        if ($moved) {
            Create-SymbolicLink -Link $sdkPath -Target "$androidRoot\SDK" -Description "Android SDK"
        }        
        break
    }
}

# 3. Move Android Virtual Devices (AVD)
Write-Host "`n📱 Moving Android Virtual Devices..." -ForegroundColor Cyan

$avdPath = "$env:USERPROFILE\.android\avd"
if (Test-Path $avdPath) {
    $moved = Move-DirectoryWithProgress -Source $avdPath -Destination "$androidRoot\AVD" -Description "Android Virtual Devices"
    if ($moved) {
        Create-SymbolicLink -Link $avdPath -Target "$androidRoot\AVD" -Description "Android AVD"
    }
}

# 4. Move Gradle Cache
Write-Host "`n⚙️  Moving Gradle Cache..." -ForegroundColor Cyan

$gradlePath = "$env:USERPROFILE\.gradle"
if (Test-Path $gradlePath) {
    $moved = Move-DirectoryWithProgress -Source $gradlePath -Destination "$androidRoot\Gradle" -Description "Gradle Cache"
    if ($moved) {
        Create-SymbolicLink -Link $gradlePath -Target "$androidRoot\Gradle" -Description "Gradle Cache"
    }
}

# 5. Move Android Studio Configuration
Write-Host "`n⚙️  Moving Android Studio Configuration..." -ForegroundColor Cyan

$configPaths = @(
    "$env:USERPROFILE\.AndroidStudio*",
    "$env:APPDATA\Google\AndroidStudio*"
)

foreach ($configPattern in $configPaths) {
    $configDirs = Get-ChildItem $configPattern -Directory -ErrorAction SilentlyContinue
    foreach ($configDir in $configDirs) {
        $targetPath = "$androidRoot\AndroidStudio\$($configDir.Name)"
        $moved = Move-DirectoryWithProgress -Source $configDir.FullName -Destination $targetPath -Description "Android Studio Config ($($configDir.Name))"
        if ($moved) {
            Create-SymbolicLink -Link $configDir.FullName -Target $targetPath -Description "Android Studio Config"
        }
    }
}

# 6. Update Environment Variables
Write-Host "`n🌍 Updating Environment Variables..." -ForegroundColor Cyan

# Set ANDROID_HOME
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "$androidRoot\SDK", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "$androidRoot\SDK", [EnvironmentVariableTarget]::User)

# Update PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
$newPaths = @(
    "$androidRoot\SDK\platform-tools",
    "$androidRoot\SDK\tools",
    "$androidRoot\SDK\tools\bin",
    "$androidRoot\Studio\bin"
)

foreach ($newPath in $newPaths) {
    if ($currentPath -notlike "*$newPath*") {
        $currentPath += ";$newPath"
    }
}

[Environment]::SetEnvironmentVariable("PATH", $currentPath, [EnvironmentVariableTarget]::User)

Write-Host "✅ Environment variables updated:" -ForegroundColor Green
Write-Host "   ANDROID_HOME = $androidRoot\SDK"
Write-Host "   ANDROID_SDK_ROOT = $androidRoot\SDK"
Write-Host "   PATH updated with Android tools"

# 7. Create Desktop Shortcut
Write-Host "`n🖥️  Creating Desktop Shortcut..." -ForegroundColor Cyan

$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = "$desktopPath\Android Studio (E Drive).lnk"
$studioExePath = "$androidRoot\Studio\bin\studio64.exe"

if (Test-Path $studioExePath) {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $studioExePath
    $Shortcut.WorkingDirectory = "$androidRoot\Studio\bin"
    $Shortcut.IconLocation = $studioExePath
    $Shortcut.Description = "Android Studio (Moved to E: Drive)"
    $Shortcut.Save()
    
    Write-Host "✅ Desktop shortcut created: $shortcutPath" -ForegroundColor Green
}

# 8. Create Configuration Summary
Write-Host "`n📄 Creating Configuration Summary..." -ForegroundColor Cyan

$summaryContent = @"
# Android Studio Migration to E: Drive - Summary
Generated on: $(Get-Date)

## New Locations:
- Android Studio: $androidRoot\Studio
- Android SDK: $androidRoot\SDK  
- AVD (Emulators): $androidRoot\AVD
- Gradle Cache: $androidRoot\Gradle
- Studio Config: $androidRoot\AndroidStudio
- Projects: $androidRoot\Projects (recommended location)

## Environment Variables:
- ANDROID_HOME = $androidRoot\SDK
- ANDROID_SDK_ROOT = $androidRoot\SDK

## Symbolic Links Created:
All original locations now point to E: drive through symbolic links.

## Next Steps:
1. Restart your computer to ensure environment variables take effect
2. Launch Android Studio from desktop shortcut or E:\Android\Studio\bin\studio64.exe
3. Verify SDK location in Android Studio settings
4. Test building and running your Flutter projects
5. Consider moving your project files to E:\Android\Projects

## Troubleshooting:
If you encounter issues:
1. Check that symbolic links are working: dir /AL "C:\Users\$env:USERNAME"
2. Verify environment variables: echo %ANDROID_HOME%
3. Ensure Android Studio can find SDK in settings
4. Rebuild Flutter projects: flutter clean && flutter pub get

## Rollback (if needed):
To revert changes, delete symbolic links and move directories back to original locations.
"@

$summaryPath = "$androidRoot\MIGRATION_SUMMARY.txt"
$summaryContent | Out-File -FilePath $summaryPath -Encoding UTF8

Write-Host "✅ Summary saved to: $summaryPath" -ForegroundColor Green

# Final Summary
Write-Host "`n🎉 Android Studio Migration Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Space Analysis:" -ForegroundColor Yellow

try {
    $eSpace = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "E:"}
    $cSpace = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "C:"}
    
    if ($eSpace) {
        $eSpaceGB = [math]::Round($eSpace.FreeSpace / 1GB, 2)
        Write-Host "E: Drive Free Space: $eSpaceGB GB" -ForegroundColor Green
    }
    
    if ($cSpace) {
        $cSpaceGB = [math]::Round($cSpace.FreeSpace / 1GB, 2)
        Write-Host "C: Drive Free Space: $cSpaceGB GB" -ForegroundColor Green
    }
}
catch {
    Write-Host "Could not retrieve disk space information" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Restart your computer" -ForegroundColor White
Write-Host "2. Use the new desktop shortcut to launch Android Studio" -ForegroundColor White
Write-Host "3. Verify SDK location in Android Studio settings" -ForegroundColor White
Write-Host "4. Test your Flutter project: flutter doctor" -ForegroundColor White
Write-Host "5. Consider moving projects to E:\Android\Projects" -ForegroundColor White

Write-Host ""
Write-Host "📋 Summary file location: $summaryPath" -ForegroundColor Yellow

Read-Host "`nPress Enter to exit"