<#
.SYNOPSIS
    Automates the setup of a complete development environment on Windows using Scoop.

.DESCRIPTION
    This script performs the following actions:
    1. Installs Scoop and its core dependency, Git.
    2. Configures Scoop buckets and displays the current list for verification.
    3. Batch-installs essential development tools.
    4. Separately installs FiraCode font and provides a path for manual setup.
    5. Precisely finds and applies 'install-context.reg' files from each installed Scoop app.
    6. Configures Git, clones a settings repository, and deploys configuration files.

.NOTES
    Author: Gemini (based on user's script)
    Version: 3.4
    Improvements:
    - Changed font package identifier for FiraCode.
    - Replaced 'tree' with 'tree-sitter' for modern development needs.
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
Write-Log "Starting the automated development environment setup (v3.4 - Precision Fixes)..." "Info"

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

# FIX: Display the final bucket list for verification right after configuration.
Write-Log "Displaying current bucket list..." "Info"
scoop bucket list

Write-Log "--- Scoop configuration complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 4: Batch Install Applications ---
Write-Log "--- Section 4: Application Installation ---" "Info"

# Centralized list of all packages to install (fonts are handled separately).
$packages = @(
    "python", "tree-sitter", "starship", "neovim", "alacritty",
    "yazi", "komorebi", "whkd", "firefox", "vcredist2022"
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


# --- Section 5: Post-Install System Setup ---
Write-Log "--- Section 5: Post-Installation System Setup ---" "Info"

# --- Part 5.1: Install and Guide Font Setup ---
Write-Log "Handling FiraCode font installation..." "Info"
$fontPackageName = "FiraCode"
$fontPackageIdentifier = "FiraCode"
$fontInstallPath = "$(scoop prefix)\apps\$fontPackageName\current"

# Install the font package if it's not already installed.
if (-not (Test-Path $fontInstallPath)) {
    Write-Log "FiraCode package not found. Installing with explicit identifier..." "Info"
    try {
        scoop install $fontPackageIdentifier
        Write-Log "FiraCode package downloaded successfully." "Success"
    } catch {
        Write-Log "Error downloading FiraCode package: $($_.Exception.Message)" "Error"
    }
} else {
    Write-Log "FiraCode package is already installed." "Warning"
}

# Provide the path for manual installation.
if (Test-Path $fontInstallPath) {
    Write-Log "ACTION REQUIRED: Fonts for 'FiraCode' are downloaded." "Warning"
    Write-Log "To install, please go to the following folder, select all font files, right-click and choose 'Install':" "Warning"
    Write-Log "$fontInstallPath" -Type "Success"
} else {
    Write-Log "FiraCode package directory not found after installation attempt. Skipping manual setup guide." "Error"
}


# --- Part 5.2: Apply Context Menu Registry Files ---
Write-Log "Searching for and applying context menu registry files..." "Info"
# FIX: Iterate through each installed package to find its specific context file.
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


# --- Section 6: Configure Git ---
Write-Log "--- Section 6: Git Configuration ---" "Info"
$gitUserName = Read-Host "Enter your Git username (e.g., Your Name)"
$gitUserEmail = Read-Host "Enter your Git email (e.g., your.email@example.com)"

git config --global user.name "$gitUserName"
git config --global user.email "$gitUserEmail"
git config --global alias.acp '!f() { git add . && git commit -m "$1" && git push; }; f'

Write-Log "Git user.name, user.email, and 'acp' alias configured." "Success"
Write-Log "--- Git configuration complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 7: Clone Settings Repository & Deploy Configurations ---
Write-Log "--- Section 7: Deploying Configurations from Repository ---" "Info"
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
Deploy-Config -Source "$repoPath\komorebic\startup-komo.bat" -Destination $userStartupDir

Write-Log "--- Configuration deployment complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Section 8: Firefox Configuration Note ---
Write-Log "--- Section 8: Firefox Note ---" "Info"
Write-Log "Automatic Firefox configuration (like extensions) is complex." "Warning"
Write-Log "Please configure Firefox manually or by copying an existing profile if needed." "Info"
Write-Log "--- Firefox note complete ---`n" "Info"
Write-Host '------------------------------------------------------------'


# --- Final Message ---
Write-Log "All setup and configuration steps have been completed successfully!" "Success"
Write-Log "Please RESTART your terminal (or computer) for all changes to take full effect." "Info"

