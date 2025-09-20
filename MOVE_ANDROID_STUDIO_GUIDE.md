# 📁 Move Android Studio to E: Drive - Complete Guide

## 🎯 Overview
This guide helps you move Android Studio and all related files from C: drive to E: drive to free up space.

## ⚠️ **Before You Start**
1. **Close Android Studio** completely
2. **Stop all Android emulators**
3. **Backup important projects** (optional but recommended)
4. **Run PowerShell as Administrator**

---

## 🚀 **Method 1: Automated Script (Recommended)**

### Step 1: Run the PowerShell Script
```powershell
# Navigate to your project directory
cd E:\Android\E-commerce\E-commerce\ecommerce_app

# Run the migration script as Administrator
.\move_android_studio_to_e.ps1
```

The script will:
- ✅ Move Android Studio installation
- ✅ Move Android SDK
- ✅ Move AVD (Android Virtual Devices)
- ✅ Move Gradle cache
- ✅ Move Android Studio configuration
- ✅ Create symbolic links
- ✅ Update environment variables
- ✅ Create desktop shortcut

---

## 🛠️ **Method 2: Manual Migration**

### Step 1: Create Directory Structure
```powershell
# Create main Android directory on E: drive
New-Item -ItemType Directory -Path "E:\Android" -Force
New-Item -ItemType Directory -Path "E:\Android\Studio" -Force
New-Item -ItemType Directory -Path "E:\Android\SDK" -Force
New-Item -ItemType Directory -Path "E:\Android\AVD" -Force
New-Item -ItemType Directory -Path "E:\Android\Gradle" -Force
New-Item -ItemType Directory -Path "E:\Android\Projects" -Force
```

### Step 2: Move Android Studio Installation
```powershell
# Move Android Studio (if installed in Program Files)
Move-Item "C:\Program Files\Android\Android Studio" "E:\Android\Studio" -Force

# Create symbolic link
New-Item -ItemType SymbolicLink -Path "C:\Program Files\Android\Android Studio" -Target "E:\Android\Studio"
```

### Step 3: Move Android SDK
```powershell
# Move Android SDK
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
if (Test-Path $sdkPath) {
    Move-Item $sdkPath "E:\Android\SDK" -Force
    New-Item -ItemType SymbolicLink -Path $sdkPath -Target "E:\Android\SDK"
}
```

### Step 4: Move AVD (Android Virtual Devices)
```powershell
# Move AVD
$avdPath = "$env:USERPROFILE\.android\avd"
if (Test-Path $avdPath) {
    Move-Item $avdPath "E:\Android\AVD" -Force
    New-Item -ItemType SymbolicLink -Path $avdPath -Target "E:\Android\AVD"
}
```

### Step 5: Move Gradle Cache
```powershell
# Move Gradle cache
$gradlePath = "$env:USERPROFILE\.gradle"
if (Test-Path $gradlePath) {
    Move-Item $gradlePath "E:\Android\Gradle" -Force
    New-Item -ItemType SymbolicLink -Path $gradlePath -Target "E:\Android\Gradle"
}
```

### Step 6: Update Environment Variables
```powershell
# Set Android environment variables
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "E:\Android\SDK", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "E:\Android\SDK", [EnvironmentVariableTarget]::User)

# Add to PATH
$path = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
$newPath = "$path;E:\Android\SDK\platform-tools;E:\Android\SDK\tools;E:\Android\Studio\bin"
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::User)
```

---

## 🔧 **Post-Migration Steps**

### 1. Restart Your Computer
```
Restart to ensure environment variables take effect
```

### 2. Verify Android Studio
1. Launch Android Studio from `E:\Android\Studio\bin\studio64.exe`
2. Go to **File** → **Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**
3. Verify SDK location is `E:\Android\SDK`

### 3. Update Flutter Configuration
```powershell
# Check Flutter doctor
flutter doctor

# If needed, set Flutter Android SDK path
flutter config --android-sdk E:\Android\SDK
```

### 4. Test Your Project
```powershell
cd E:\Android\E-commerce\E-commerce\ecommerce_app
flutter clean
flutter pub get
flutter run -d web-server --web-port=3000
```

---

## 📂 **New Directory Structure**

After migration, your Android files will be organized as:

```
E:\Android\
├── Studio\                 # Android Studio installation
├── SDK\                    # Android SDK and tools
├── AVD\                    # Android Virtual Devices
├── Gradle\                 # Gradle cache and dependencies
├── Projects\               # Recommended location for new projects
└── MIGRATION_SUMMARY.txt   # Migration details and settings
```

---

## 🚨 **Troubleshooting**

### Issue: Android Studio can't find SDK
**Solution:**
1. Open Android Studio
2. Go to **File** → **Settings** → **Android SDK**
3. Set SDK location to `E:\Android\SDK`

### Issue: Flutter can't find Android SDK
**Solution:**
```powershell
flutter config --android-sdk E:\Android\SDK
flutter doctor
```

### Issue: Environment Variables not working
**Solution:**
1. Restart computer
2. Open new PowerShell window
3. Check: `echo $env:ANDROID_HOME`

### Issue: Symbolic links not working
**Solution:**
1. Run PowerShell as Administrator
2. Enable Developer Mode in Windows Settings
3. Recreate symbolic links

---

## 📈 **Benefits After Migration**

✅ **Freed C: Drive Space** - Several GB reclaimed  
✅ **Better Organization** - All Android files in one location  
✅ **Improved Performance** - Less fragmentation on system drive  
✅ **Easier Backup** - Single directory to backup  
✅ **Project Organization** - Dedicated projects folder  

---

## 🔄 **Rollback Instructions**

If you need to move back to C: drive:

1. **Delete symbolic links:**
   ```powershell
   Remove-Item "C:\Program Files\Android\Android Studio" -Force
   Remove-Item "$env:LOCALAPPDATA\Android\Sdk" -Force
   # ... repeat for other links
   ```

2. **Move directories back:**
   ```powershell
   Move-Item "E:\Android\Studio" "C:\Program Files\Android\Android Studio"
   Move-Item "E:\Android\SDK" "$env:LOCALAPPDATA\Android\Sdk"
   # ... repeat for other directories
   ```

3. **Reset environment variables** to original C: drive paths

---

## 📞 **Support**

If you encounter issues:
1. Check the `MIGRATION_SUMMARY.txt` file in `E:\Android\`
2. Verify all symbolic links exist: `dir /AL "C:\Users\$env:USERNAME"`
3. Run `flutter doctor` to check Flutter configuration
4. Ensure you have Administrator permissions

**Happy coding! 🚀**