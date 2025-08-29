<#
.SYNOPSIS
    Automates the setup of a complete development environment on Windows using Scoop.

.DESCRIPTION
    This script performs the following actions:
    1. Installs Scoop and its core dependency, Git.
    2. Configures Scoop buckets and displays the current list for verification.
    3. Batch-installs essential development tools, including yasb.
    4. Downloads and silently installs Internet Download Manager (IDM).
    5. Implements a robust, permanent installation for Unikey with auto-startup.
    6. Separately installs FiraCode font and provides a path for manual setup.
    7. Precisely finds and applies 'install-context.reg' files from each installed Scoop app.
    8. Configures Git, clones a settings repository, and deploys configuration files for all apps.
    9. Automatically configures Firefox with custom userChrome.css and user.js.
    10. Creates a summary file on the Desktop with the locations of all deployed configuration files.
    11. Automatically cleans up the installation files (repository and the script itself) upon completion.

.NOTES
    Author: Gemini (based on user's script)
    Version: 4.6
    Improvements:
    - Added a dedicated section to download and silently install Internet Download Manager (IDM).
#>

# --- Helper Function for Logging ---
function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "Info" # Can be Info, Success, Warning, Error
    )
    # Provides colored output for better readability of the script's progress.
    switch ($Type) {
        "Info"    { Write-Host "INFO: $Message" -ForegroundColor Cyan }
        "Success" { Write-Host "SUCCESS: $Message" -ForegroundColor Green }
        "Warning" { Write-Host "WARNING: $Message" -ForegroundColor Yellow }
        "Error"   { Write-Host "ERROR: $Message" -ForegroundColor Red }
        default   { Write-Host "${Type}: $Message" }
    }
}

# --- Start Script ---
clear
$author= @'
  _          _                                                     _
 | | ___  __| | __ _ _ __   __ _  __ _ _   _  __ _ _ __   __ _  __| | __ _ _ __   __ _  __ _ _   _  __ _ _ __   __ _
 | |/ _ \/ _` |/ _` | '_ \ / _` |/ _` | | | |/ _` | '_ \ / _` |/ _` |/ _` | '_ \ / _` |/ _` | | | |/ _` | '_ \ / _` |
 | |  __/ (_| | (_| | | | | (_| | (_| | |_| | (_| | | | | (_| | (_| | (_| | | | | (_| | (_| | |_| | (_| | | | | (_| |
 |_|\___|\__,_|\__,_|_| |_|\__, |\__, |\__,_|\__,_|_| |_|\__, |\__,_|\__,_|_| |_|\__, |\__, |\__,_|\__,_|_| |_|\__, |
                           |___/    |_|                  |___/                   |___/    |_|                  |___/
'@

Write-Host $author -ForegroundColor Magenta
Write-Log "Starting the automated development environment setup (v4.6 - Added IDM)..." "Info"

# --- Section 1: Install Scoop Package Manager ---
Write-Log "--- Section 1: Installing Scoop ---" "Info"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Log "Scoop not found. Proceeding with installation..." "Info"
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        Write-Log "Scoop installed successfully!" "Success"
    } catch {
        Write-Log "Critical error installing Scoop: $($_.Exception.Message)" "Error"
        Write-Log "Please check your network connection or permissions and rerun the script." "Error"
        exit 1
    }
} else {
    Write-Log "Scoop is already installed." "Warning"
}
Write-Log "--- Scoop installation complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 2: Install Git (Core Dependency for Scoop) ---
# Git MUST be installed before managing Scoop buckets, as buckets are Git repositories.
Write-Log "--- Section 2: Installing Git ---" "Info"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log "Git not found. Installing now as a core dependency..." "Info"
    try {
        scoop install git
        Write-Log "Git installed successfully!" "Success"
    } catch {
        Write-Log "Error installing Git: $($_.Exception.Message)" "Error"
        exit 1
    }
} else {
    Write-Log "Git is already installed." "Warning"
}
Write-Log "--- Git installation complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 3: Configure Scoop Buckets & Update ---
# Now that Git is installed, we can safely manage buckets and update Scoop.
Write-Log "--- Section 3: Configuring Scoop Buckets ---" "Info"
Write-Log "Updating Scoop and ensuring required buckets are added..." "Info"
scoop update

# Add 'extras' bucket
if (-not (scoop bucket list | Select-String -Pattern "extras" -Quiet)) {
    scoop bucket add extras
    Write-Log "Added 'extras' bucket to Scoop." "Success"
} else {
    Write-Log "'extras' bucket already exists." "Warning"
}

# Add 'nerd-fonts' bucket for font installation
if (-not (scoop bucket list | Select-String -Pattern "nerd-fonts" -Quiet)) {
    scoop bucket add nerd-fonts
    Write-Log "Added 'nerd-fonts' bucket to Scoop." "Success"
} else {
    Write-Log "'nerd-fonts' bucket already exists." "Warning"
}

# Display the final bucket list for verification
Write-Log "Displaying current bucket list..." "Info"
scoop bucket list

Write-Log "--- Scoop configuration complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 4: Batch Install Applications ---
Write-Log "--- Section 4: Application Installation ---" "Info"

# Centralized list of all packages to install (fonts and Unikey are handled separately).
$packages = @(
    "python", "tree-sitter", "starship", "neovim", "alacritty",
    "yazi", "komorebi", "whkd", "firefox", "vcredist2022", "yasb"
)

# Filter out packages that are already installed.
$packagesToInstall = $packages | Where-Object { -not (scoop list $_ -q) }

if ($packagesToInstall.Count -gt 0) {
    $packageListForDisplay = $packagesToInstall -join ", "
    Write-Log "The following packages will be installed: $packageListForDisplay" "Info"
    try {
        scoop install $packagesToInstall
        Write-Log "All packages downloaded successfully!" "Success"
    } catch {
        Write-Log "Error during batch installation: $($_.Exception.Message)" "Error"
        exit 1
    }
} else {
    Write-Log "All required packages are already installed." "Warning"
}
Write-Log "--- Package download complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 5: Install Internet Download Manager (IDM) ---
Write-Log "--- Section 5: Installing Internet Download Manager ---" "Info"
try {
    $idmUrl = "https://mirror2.internetdownloadmanager.com/idman642build42.exe"
    $idmInstallerPath = Join-Path -Path $env:TEMP -ChildPath "idm_installer.exe"

    Write-Log "Downloading IDM from $idmUrl..." "Info"
    Invoke-WebRequest -Uri $idmUrl -OutFile $idmInstallerPath

    Write-Log "Starting silent installation of IDM... Please wait." "Info"
    # The /S argument triggers a silent installation for IDM installers.
    Start-Process -FilePath $idmInstallerPath -ArgumentList "/S" -Wait

    Write-Log "IDM installation complete." "Success"

    # Clean up the downloaded installer
    Remove-Item -Path $idmInstallerPath -Force
} catch {
    Write-Log "An error occurred during IDM installation: $($_.Exception.Message)" "Error"
}
Write-Log "--- IDM setup complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 6: Install and Configure Unikey ---
Write-Log "--- Section 6: Installing and Configuring Unikey ---" "Info"

# Define a permanent installation path in the user's profile
$unikeyInstallDir = Join-Path -Path $env:USERPROFILE -ChildPath "Tools\Unikey"
$unikeyExePath = Join-Path -Path $unikeyInstallDir -ChildPath "UniKeyNT.exe"

# Always download and install the latest version of Unikey
Write-Log "Proceeding with Unikey installation/update..." "Info"
try {
    # Ensure the base directory exists
    if (-not (Test-Path -Path $unikeyInstallDir)) {
        New-Item -Path $unikeyInstallDir -ItemType Directory -Force | Out-Null
    }

    $zipPath = "$env:TEMP\unikey.zip"
    $unikeyUrl = "https://www.unikey.org/assets/release/unikey46RC2-230919-win64.zip"

    Write-Log "Downloading Unikey from $unikeyUrl..." "Info"
    Invoke-WebRequest -Uri $unikeyUrl -OutFile $zipPath

    Write-Log "Extracting Unikey to $unikeyInstallDir..." "Info"
    Expand-Archive -Path $zipPath -DestinationPath $unikeyInstallDir -Force

    Write-Log "Unikey installed successfully to $unikeyInstallDir." "Success"

    # Clean up the downloaded zip file
    Remove-Item -Path $zipPath -Force
} catch {
    Write-Log "An error occurred during Unikey installation: $($_.Exception.Message)" "Error"
}

# Configure Unikey to run on startup
try {
    $userStartupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = Join-Path -Path $userStartupDir -ChildPath "Unikey.lnk"

    if (-not (Test-Path -Path $shortcutPath)) {
        Write-Log "Creating Unikey startup shortcut..." "Info"
        $wshell = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $unikeyExePath
        $shortcut.Save()
        Write-Log "Unikey startup shortcut created successfully." "Success"
    } else {
        Write-Log "Unikey startup shortcut already exists." "Warning"
    }
} catch {
    Write-Log "An error occurred while creating the Unikey startup shortcut: $($_.Exception.Message)" "Error"
}

# Finally, start the process if it's not already running
$unikeyProcess = Get-Process -Name "UniKeyNT" -ErrorAction SilentlyContinue
if (-not $unikeyProcess) {
    Write-Log "Starting Unikey process..." "Info"
    Start-Process -FilePath $unikeyExePath
} else {
    Write-Log "Unikey process is already running." "Warning"
}
Write-Log "--- Unikey setup complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 7: Post-Install System Setup ---
Write-Log "--- Section 7: Post-Installation System Setup ---" "Info"

# --- Part 7.1: Install and Guide Font Setup ---
Write-Log "Handling FiraCode font installation..." "Info"
$fontPackageName = "FiraCode-NF"
$fontPackageIdentifier = "nerd-fonts/FiraCode-NF"

# LOGIC FIX: First, check if the package is installed. If not, install it.
if (-not (scoop list $fontPackageName -q)) {
    Write-Log "FiraCode package not found. Installing now..." "Info"
    try {
        scoop install $fontPackageIdentifier
        Write-Log "FiraCode package downloaded successfully." "Success"
    } catch {
        Write-Log "Error downloading FiraCode package: $($_.Exception.Message)" "Error"
    }
} else {
    Write-Log "FiraCode package is already installed." "Warning"
}

# LOGIC FIX: Now that it's installed (or was already), get the path and provide guidance.
try {
    $fontInstallPath = (scoop prefix $fontPackageName 2>$null)
    if ($fontInstallPath -and (Test-Path $fontInstallPath)) {
        Write-Log "ACTION REQUIRED: Fonts for 'FiraCode' are downloaded." "Warning"
        Write-Log "To install, please go to the following folder, select all font files, right-click and choose 'Install'" "Warning"
        Write-Log "$fontInstallPath" -Type "Warning"
        start $fontInstallPath
    } else {
        Write-Log "Could not find FiraCode package directory even after installation attempt. Skipping manual setup guide." "Error"
    }
} catch {
     Write-Log "An error occurred while getting the FiraCode prefix path: $($_.Exception.Message)" "Error"
}


# --- Part 7.2: Apply Context Menu Registry Files ---
Write-Log "Searching for and applying context menu registry files..." "Info"
# Iterate through each installed package to find its specific context file.
$allInstalledPackages = $packages + $fontPackageName
foreach ($pkg in $allInstalledPackages) {
    try {
        # Get the 'current' directory for the app. Suppress errors if prefix not found.
        $appPath = scoop prefix $pkg 2>$null
        if ($appPath -and (Test-Path $appPath)) {
            $regFile = Join-Path -Path $appPath -ChildPath "install-context.reg"
            if (Test-Path $regFile) {
                Write-Log "Found registry file for '$pkg'. Applying..." "Info"
                try {
                    regedit.exe /s $regFile
                    Write-Log "Successfully applied registry file for '$pkg'." "Success"
                } catch {
                    Write-Log "Failed to apply registry file for '$pkg'. Error: $($_.Exception.Message)" "Error"
                }
            }
        }
    } catch {
        # This block will catch any unexpected errors during the prefix check.
        Write-Log "An error occurred while checking for registry file in '$pkg': $($_.Exception.Message)" "Error"
    }
}
Write-Log "Context menu setup complete." "Info"
Write-Log "--- Post-Install setup complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 8: Configure Git ---
Write-Log "--- Section 8: Git Configuration ---" "Info"
$gitUserName = Read-Host "Enter your Git username (e.g., Your Name)"
$gitUserEmail = Read-Host "Enter your Git email (e.g., your.email@example.com)"

git config --global user.name "$gitUserName"
git config --global user.email "$gitUserEmail"
git config --global alias.acp '!f() { git add . && git commit -m "$1" && git push; }; f'

Write-Log "Git user.name, user.email, and 'acp' alias configured." "Success"
Write-Log "--- Git configuration complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 9: Clone Settings Repository & Deploy Configurations ---
Write-Log "--- Section 9: Deploying Configurations from Repository ---" "Info"
$repoUrl = "https://github.com/ledangquangdangquang/A_Setting_File.git"
$repoName = "A_Setting_File"
$repoPath = "./$repoName"

if (-not (Test-Path $repoPath)) {
    Write-Log "Cloning settings repository from $repoUrl..." "Info"
    git clone $repoUrl
    Write-Log "Repository cloned successfully." "Success"
} else {
    Write-Log "Settings repository already exists. Skipping clone." "Warning"
}

# Define common destination paths
$userProfile = $env:USERPROFILE
$appData = $env:APPDATA
$localAppData = $env:LOCALAPPDATA
$configDir = "$userProfile\.config"
$userStartupDir = "$appData\Microsoft\Windows\Start Menu\Programs\Startup"

# Create .config directory if it doesn't exist
if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory | Out-Null
}

# Create user's startup directory if it doesn't exist
if (-not (Test-Path $userStartupDir)) {
    New-Item -Path $userStartupDir -ItemType Directory | Out-Null
}

# Function to safely copy configuration files
function Deploy-Config {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$Recurse
    )
    Write-Log "Copying '$Source' to '$Destination'..." "Info"
    try {
        Copy-Item -Path $Source -Destination $Destination -Recurse:$Recurse -Force -ErrorAction Stop
    } catch {
        Write-Log "Failed to copy '$Source'. Error: $($_.Exception.Message)" "Error"
    }
}

# --- Part 9.1: Deploy Standard Configurations ---
Write-Log "Deploying standard application configurations..." "Info"
Deploy-Config -Source "$repoPath\git-bash\.bashrc" -Destination $userProfile
Deploy-Config -Source "$repoPath\starship\starship.toml" -Destination $configDir
Deploy-Config -Source "$repoPath\nvim" -Destination $localAppData -Recurse
Deploy-Config -Source "$repoPath\alacritty" -Destination $appData -Recurse
Deploy-Config -Source "$repoPath\yazi" -Destination $appData -Recurse
Deploy-Config -Source "$repoPath\yasb" -Destination $configDir -Recurse


# --- Part 9.2: Deploy Komorebi Configurations ---
Write-Log "Deploying Komorebi configurations..." "Info"
# Deploy the main komorebi.json and whkdrc files from the user's repository.
Deploy-Config -Source "$repoPath\komorebic\komorebi.json" -Destination $userProfile
Deploy-Config -Source "$repoPath\komorebic\whkdrc" -Destination $configDir
Deploy-Config -Source "$repoPath\komorebic\komorebi.bar.json" -Destination $userProfile


# --- Part 9.3: Configure Firefox ---
Write-Log "Attempting to configure Firefox..." "Info"
# firefox
# sleep(5)
try {
    # Find the default Firefox profile directory
    # $firefoxProfileDir = Get-ChildItem -Path "$appData\Mozilla\Firefox\Profiles" -Filter "*.default*" -Directory | Select-Object -First 1
    $firefoxProfileDir = $HOME\scoop\persist\firefox\profile 
    
    if ($firefoxProfileDir) {
        $profileFullPath = $firefoxProfileDir.FullName
        Write-Log "Found Firefox profile: $profileFullPath" "Info"

        $sourceChromeDir = Join-Path -Path $repoPath -ChildPath "Firefox\FireFoxOneLinerCSS-main\chrome"
        $sourceUserJs = Join-Path -Path $repoPath -ChildPath "Firefox\FireFoxOneLinerCSS-main\user.js"

        if ((Test-Path $sourceChromeDir) -and (Test-Path $sourceUserJs)) {
            # Deploy chrome directory
            Deploy-Config -Source $sourceChromeDir -Destination $profileFullPath -Recurse
            # Deploy user.js file
            Deploy-Config -Source $sourceUserJs -Destination $profileFullPath
            Write-Log "Firefox custom configuration deployed successfully." "Success"
            Write-Log "Firefox have set in profile Scoop." "Success"
        } else {
            Write-Log "Firefox source configuration files not found in repository. Skipping." "Warning"
        }
    } else {
        Write-Log "Could not find a default Firefox profile. Skipping Firefox configuration." "Warning"
    }
} catch {
    Write-Log "An error occurred during Firefox configuration: $($_.Exception.Message)" "Error"
}


Write-Log "--- Configuration deployment complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 10: Generate Configuration Summary ---
Write-Log "--- Section 10: Generating Configuration Summary ---" "Info"
$summary = @()
$summary += "==============================================="
$summary += "  Deployed Configuration File Locations"
$summary += "==============================================="
$summary += ""
$summary += "Git Bash:"
$summary += "- .bashrc: $userProfile"
$summary += ""
$summary += "Starship (Command Prompt):"
$summary += "- starship.toml: $configDir"
$summary += ""
$summary += "Neovim (Editor):"
$summary += "- nvim config directory: $localAppData\nvim"
$summary += ""
$summary += "Alacritty (Terminal):"
$summary += "- alacritty config directory: $appData\alacritty"
$summary += ""
$summary += "Yazi (File Manager):"
$summary += "- yazi config directory: $appData\yazi"
$summary += ""
$summary += "Yasb (Status Bar):"
$summary += "- yasb config directory: $configDir\yasb"
$summary += ""
$summary += "Komorebi (Window Manager):"
$summary += "- komorebi.json: $userProfile"
$summary += "- komorebi.bar.json: $userProfile"
$summary += "- whkdrc (hotkeys): $configDir"
$summary += ""
$summary += "Unikey (Vietnamese Input):"
$summary += "- Installation directory: $unikeyInstallDir"
$summary += ""
$summary += "Firefox:"
if ($firefoxProfileDir) {
    $summary += "- Custom config deployed to profile: $($firefoxProfileDir.FullName)"
} else {
    $summary += "- No profile found, configuration skipped."
}
$summary += ""
$summary += "==============================================="

# Log summary to console
Write-Log "Configuration summary has been generated:" "Info"
$summary | ForEach-Object { Write-Host $_ }

# Write summary to a file on the Desktop
try {
    $desktopPath = [System.Environment]::GetFolderPath('Desktop')
    $outputFile = Join-Path -Path $desktopPath -ChildPath "setup_config_locations.txt"
    $summary | Out-File -FilePath $outputFile -Encoding utf8
    Write-Log "Summary has been saved to your Desktop: $outputFile" "Success"
} catch {
    Write-Log "Could not save summary file to Desktop. Error: $($_.Exception.Message)" "Error"
}
Write-Host '------------------------------------------------------------'


# --- Final Message ---
Write-Log "All setup and configuration steps have been completed successfully!" "Success"
Write-Log "A summary file of configuration locations has been created on your Desktop." "Info"
Write-Log "A_Setting_File in ~/Downloads" "Info"
Write-Log "Please RESTART your terminal (or computer) for all changes to take full effect." "Info"
Write-Host '------------------------------------------------------------'
