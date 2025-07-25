<#
.SYNOPSIS
    Automates the setup of a complete development environment on Windows using Scoop.

.DESCRIPTION
    This script performs the following actions:
    1. Checks for and installs/updates Scoop package manager.
    2. Batch-installs a list of essential development tools like Git, Python, Neovim, etc., for improved performance.
    3. Configures Git with user-provided credentials.
    4. Clones a settings repository.
    5. Deploys configuration files for all installed tools (.bashrc, starship, nvim, alacritty, etc.).
    6. Provides clear logging for each step.

.NOTES
    Author: Gemini (based on user's script)
    Version: 2.0
    Improvements:
    - Massively improved performance by batch-installing packages with a single Scoop command.
    - Refactored code for readability and maintainability using arrays and loops.
    - Centralized package list for easy addition or removal of tools.
    - Clearer variable definitions for file paths.
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
Write-Log "Starting the automated development environment setup (v2 - Optimized)..." "Info"

# --- 1. Install or Update Scoop ---
Write-Log "--- Section 1: Scoop Package Manager ---" "Info"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Log "Scoop not found. Proceeding with installation..." "Info"
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        Write-Log "Scoop installed successfully!" "Success"
        scoop bucket add extras
        Write-Log "Added 'extras' bucket to Scoop." "Success"
    } catch {
        Write-Log "Critical error installing Scoop: $($_.Exception.Message)" "Error"
        Write-Log "Please check your network connection or permissions and rerun the script." "Error"
        exit 1
    }
} else {
    Write-Log "Scoop is already installed. Updating Scoop and apps..." "Warning"
    scoop update
    Write-Log "Scoop updated." "Success"
    if (-not (scoop bucket list | Select-String -Pattern "extras" -Quiet)) {
        scoop bucket add extras
        Write-Log "Added 'extras' bucket to Scoop." "Success"
    }
}
Write-Log "--- Scoop setup complete ---`n" "Info"


# --- 2. Batch Install Applications ---
# This is the main performance improvement. We check all apps first, then run ONE command.
Write-Log "--- Section 2: Application Installation ---" "Info"

# Centralized list of all required packages. Easy to add/remove tools here.
$packages = @(
    "git", "python", "tree", "starship", "neovim", "alacritty",
    "yazi", "komorebi", "whkd", "firefox"
)

# Filter out packages that are already installed.
$packagesToInstall = $packages | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }

if ($packagesToInstall.Count -gt 0) {
    $packageList = $packagesToInstall -join " "
    Write-Log "The following packages will be installed: $packageList" "Info"
    try {
        # Install all missing packages in a single command for maximum efficiency.
        scoop install $packageList
        Write-Log "All required applications installed successfully!" "Success"
    } catch {
        Write-Log "Error during batch installation: $($_.Exception.Message)" "Error"
        exit 1
    }
} else {
    Write-Log "All required applications are already installed." "Warning"
}
Write-Log "--- Application installation complete ---`n" "Info"


# --- 3. Configure Git ---
Write-Log "--- Section 3: Git Configuration ---" "Info"
$gitUserName = Read-Host "Enter your Git username (e.g., Your Name)"
$gitUserEmail = Read-Host "Enter your Git email (e.g., your.email@example.com)"

git config --global user.name "$gitUserName"
git config --global user.email "$gitUserEmail"
git config --global alias.acp '!f() { git add . && git commit -m "$1" && git push; }; f'

Write-Log "Git user.name, user.email, and 'acp' alias configured." "Success"
Write-Log "--- Git configuration complete ---`n" "Info"


# --- 4. Clone Settings Repository & Configure Applications ---
Write-Log "--- Section 4: Deploying Configurations ---" "Info"
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
$startupDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"

# Create .config directory if it doesn't exist
if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory | Out-Null
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
Deploy-Config -Source "$repoPath\komorebic\startup-komo.bat" -Destination $startupDir

Write-Log "--- Configuration deployment complete ---`n" "Info"

# --- 5. Firefox Configuration Note ---
Write-Log "--- Section 5: Firefox Note ---" "Info"
Write-Log "Automatic Firefox configuration (like extensions) is complex." "Warning"
Write-Log "Please configure Firefox manually or by copying an existing profile if needed." "Info"
Write-Log "--- Firefox note complete ---`n" "Info"

# --- Final Message ---
Write-Log "All setup and configuration steps have been completed successfully!" "Success"
Write-Log "Please RESTART your terminal (or computer) for all changes to take full effect." "Info"

