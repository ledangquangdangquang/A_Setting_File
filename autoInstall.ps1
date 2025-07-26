<#
.SYNOPSIS
    Automates the setup of a complete development environment on Windows using Scoop.

.DESCRIPTION
    This script performs the following actions:
    1. Installs Scoop package manager.
    2. Installs Git as a core dependency for Scoop's bucket management.
    3. Configures Scoop buckets (like 'extras').
    4. Batch-installs the remaining essential development tools, including vcredist2022.
    5. Configures Git, clones a settings repository, and deploys configuration files.

.NOTES
    Author: Gemini (based on user's script)
    Version: 2.5
    Improvements:
    - Fixed "Permission Denied" error by copying startup files to the current user's Startup folder instead of the system-wide one.
    - Added 'vcredist2022' to the installation list.
    - Added visual separators for better readability.
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
Write-Log "Starting the automated development environment setup (v2.5 - Startup Permission Fix)..." "Info"

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
Write-Log "Updating Scoop and ensuring 'extras' bucket is added..." "Info"
scoop update
if (-not (scoop bucket list | Select-String -Pattern "extras" -Quiet)) {
    scoop bucket add extras
    Write-Log "Added 'extras' bucket to Scoop." "Success"
} else {
    Write-Log "'extras' bucket already exists." "Warning"
}
Write-Log "--- Scoop configuration complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 4: Batch Install Remaining Applications ---
Write-Log "--- Section 4: Application Installation ---" "Info"

# Centralized list of all remaining packages.
$packages = @(
    "python", "tree", "starship", "neovim", "alacritty",
    "yazi", "komorebi", "whkd", "firefox", "vcredist2022"
)

# Filter out packages that are already installed.
$packagesToInstall = $packages | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }

if ($packagesToInstall.Count -gt 0) {
    $packageListForDisplay = $packagesToInstall -join ", "
    Write-Log "The following packages will be installed: $packageListForDisplay" "Info"
    try {
        scoop install $packagesToInstall
        Write-Log "All remaining applications installed successfully!" "Success"
    } catch {
        Write-Log "Error during batch installation: $($_.Exception.Message)" "Error"
        exit 1
    }
} else {
    Write-Log "All remaining applications are already installed." "Warning"
}
Write-Log "--- Application installation complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 5: Configure Git ---
Write-Log "--- Section 5: Git Configuration ---" "Info"
$gitUserName = Read-Host "Enter your Git username (e.g., Your Name)"
$gitUserEmail = Read-Host "Enter your Git email (e.g., your.email@example.com)"

git config --global user.name "$gitUserName"
git config --global user.email "$gitUserEmail"
git config --global alias.acp '!f() { git add . && git commit -m "$1" && git push; }; f'

Write-Log "Git user.name, user.email, and 'acp' alias configured." "Success"
Write-Log "--- Git configuration complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 6: Clone Settings Repository & Deploy Configurations ---
Write-Log "--- Section 6: Deploying Configurations ---" "Info"
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
# FIX: Use the current user's startup folder, which does not require elevated permissions.
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

# Deploy all configurations
Write-Log "Deploying configuration files..." "Info"
Deploy-Config -Source "$repoPath\git-bash\.bashrc" -Destination $userProfile
Deploy-Config -Source "$repoPath\starship\starship.toml" -Destination $configDir
Deploy-Config -Source "$repoPath\nvim" -Destination $localAppData -Recurse
Deploy-Config -Source "$repoPath\alacritty" -Destination $appData -Recurse
Deploy-Config -Source "$repoPath\yazi" -Destination $appData -Recurse

# Komorebi specific configuration
Deploy-Config -Source "$repoPath\komorebic\komorebi.bar.json" -Destination $userProfile
Deploy-Config -Source "$repoPath\komorebic\komorebi.json" -Destination $userProfile
Deploy-Config -Source "$repoPath\komorebic\whkdrc" -Destination $configDir
# FIX: Deploy to the current user's startup folder.
Deploy-Config -Source "$repoPath\komorebic\startup-komo.bat" -Destination $userStartupDir

Write-Log "--- Configuration deployment complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 7: Firefox Configuration Note ---
Write-Log "--- Section 7: Firefox Note ---" "Info"
Write-Log "Automatic Firefox configuration (like extensions) is complex." "Warning"
Write-Log "Please configure Firefox manually or by copying an existing profile if needed." "Info"
Write-Log "--- Firefox note complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Final Message ---
Write-Log "All setup and configuration steps have been completed successfully!" "Success"
Write-Log "Please RESTART your terminal (or computer) for all changes to take full effect." "Info"

