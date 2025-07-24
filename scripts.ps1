function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "Info" # Info, Success, Warning, Error
    )
    switch ($Type) {
        "Info"    { Write-Host "INFO: $Message" -ForegroundColor Cyan }
        "Success" { Write-Host "SUCCESS: $Message" -ForegroundColor Green }
        "Warning" { Write-Host "WARNING: $Message" -ForegroundColor Yellow }
        "Error"   { Write-Host "ERROR: $Message" -ForegroundColor Red }
        default   { Write-Host "${Type}: $Message" }
    }
}

# --- Start Script ---
Write-Log "Starting the automated development environment setup..." "Info"

# --- 1. Install Scoop ---
Write-Log "--- Starting Scoop installation ---" "Info"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Log "Scoop is not installed. Proceeding with installation..." "Info"
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force | Out-Null
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        Write-Log "Scoop installed successfully!" "Success"
        scoop bucket add extras
        Write-Log "Added 'extras' bucket to Scoop." "Success"
    } catch {
        Write-Log "Error installing Scoop: $($_.Exception.Message)" "Error"
        Write-Log "Please check your network connection or permissions and rerun the script." "Error"
        exit 1
    }
} else {
    Write-Log "Scoop is already installed. Updating Scoop..." "Warning"
    scoop update
    Write-Log "Scoop updated." "Success"
    if (-not (scoop bucket list | Select-String -Pattern "extras" -Quiet)) {
        scoop bucket add extras
        Write-Log "Added 'extras' bucket to Scoop." "Success"
    }
}
Write-Log "--- Scoop installation complete ---`n" "Info"

# --- 2. Install Python and Tree ---
Write-Log "--- Starting Python and Tree installation ---" "Info"

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Python..." "Info"
    scoop install python
    Write-Log "Python installed successfully!" "Success"
} else {
    Write-Log "Python is already installed." "Warning"
}

if (-not (Get-Command tree -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Tree..." "Info"
    scoop install tree
    Write-Log "Tree installed successfully!" "Success"
} else {
    Write-Log "Tree is already installed." "Warning"
}
Write-Log "--- Python and Tree installation complete ---`n" "Info"

# --- 3. Install Git ---
Write-Log "--- Starting Git installation ---" "Info"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Git..." "Info"
    scoop install git
    Write-Log "Git installed successfully!" "Success"
} else {
    Write-Log "Git is already installed." "Warning"
}
Write-Log "--- Git installation complete ---`n" "Info"

# --- 4. Configure Git ---
Write-Log "--- Starting Git configuration ---" "Info"

$gitUserName = Read-Host "Enter your Git username (e.g., Your Name)"
$gitUserEmail = Read-Host "Enter your Git email (e.g., your.email@example.com)"

git config --global user.name "$gitUserName"
git config --global user.email "$gitUserEmail"

Write-Log "Git user.name and user.email configured." "Success"
Write-Log "--- Git configuration complete ---`n" "Info"

# --- 5. Clone A_Setting_File Repository ---
Write-Log "--- Cloning A_Setting_File repository ---`n" "Info"
git clone https://github.com/ledangquangdangquang/A_Setting_File.git
$gitRepo = "A_Setting_File"
Write-Log "--- Clone complete ---`n" "Info"

# --- 6. Setup .bashrc (for Git Bash/WSL) ---
Write-Log "--- Setting up .bashrc (for Git Bash/WSL) ---" "Info"
Copy-Item -Path "./$gitRepo/git-bash/.bashrc" -Destination "$env:USERPROFILE" -Force
Write-Log "--- .bashrc setup complete ---`n" "Info"

# --- 7. Install Starship ---
Write-Log "--- Installing Starship ---" "Info"
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Starship..." "Info"
    scoop install starship
    Write-Log "Starship installed successfully!" "Success"
} else {
    Write-Log "Starship is already installed." "Warning"
}
Write-Log "--- Starship installation complete ---`n" "Info"

# --- 8. Configure Starship ---
Write-Log "--- Configuring Starship ---" "Info"
Copy-Item -Path "./$gitRepo/starship/starship.toml" -Destination "$env:USERPROFILE/.config" -Force
Write-Log "--- Starship configuration complete ---`n" "Info"

# --- 9. Install Neovim ---
Write-Log "--- Installing Neovim ---" "Info"
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Neovim..." "Info"
    scoop install neovim
    Write-Log "Neovim installed successfully!" "Success"
} else {
    Write-Log "Neovim is already installed." "Warning"
}
Write-Log "--- Neovim installation complete ---`n" "Info"

# --- 10. Configure Neovim ---
Write-Log "--- Configuring Neovim ---" "Info"
$nvimConfigDir = "$env:LOCALAPPDATA\nvim"
Copy-Item -Path "./$gitRepo/nvim" -Destination "$nvimConfigDir" -Recurse -Force
Write-Log "--- Neovim configuration complete ---`n" "Info"

# --- 11. Install Alacritty ---
Write-Log "--- Installing Alacritty ---" "Info"
if (-not (Get-Command alacritty -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Alacritty..." "Info"
    scoop install alacritty
    Write-Log "Alacritty installed successfully!" "Success"
} else {
    Write-Log "Alacritty is already installed." "Warning"
}
Write-Log "--- Alacritty installation complete ---`n" "Info"

# --- 12. Configure Alacritty ---
Write-Log "--- Configuring Alacritty ---" "Info"
Copy-Item -Path "./$gitRepo/alacritty" -Destination "$env:APPDATA" -Recurse -Force
Write-Log "--- Alacritty configuration complete ---`n" "Info"

# --- 13. Install Yazi ---
Write-Log "--- Installing Yazi ---" "Info"
if (-not (Get-Command yazi -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Yazi..." "Info"
    scoop install yazi
    Write-Log "Yazi installed successfully!" "Success"
} else {
    Write-Log "Yazi is already installed." "Warning"
}
Write-Log "--- Yazi installation complete ---`n" "Info"

# --- 14. Configure Yazi ---
Write-Log "--- Configuring Yazi ---" "Info"
Copy-Item -Path "./$gitRepo/yazi" -Destination "$env:APPDATA" -Recurse -Force
Write-Log "--- Yazi configuration complete ---`n" "Info"

# --- 15. Install Komorebic ---
Write-Log "--- Installing Komorebic ---" "Info"
if (-not (Get-Command komorebic -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Komorebic..." "Info"
    scoop install komorebi whkd
    Write-Log "Komorebic installed successfully!" "Success"
} else {
    Write-Log "Komorebic is already installed." "Warning"
}
Write-Log "--- Komorebic installation complete ---`n" "Info"

# --- 16. Configure Komorebic ---
Write-Log "--- Configuring Komorebic ---" "Info"
Copy-Item -Path "./$gitRepo/komorebic/komorebi.bar.json" -Destination "$env:USERPROFILE" -Force
Copy-Item -Path "./$gitRepo/komorebic/komorebi.json" -Destination "$env:USERPROFILE" -Force
Copy-Item -Path "./$gitRepo/komorebic/whkdrc" -Destination "$env:USERPROFILE/.config" -Force
Copy-Item -Path "./$gitRepo/komorebic/startup-komo.bat" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" -Force
Write-Log "--- Komorebic configuration complete ---`n" "Info"

# --- 17. Install Firefox ---
Write-Log "--- Installing Firefox ---" "Info"
if (-not (Get-Command firefox -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Firefox..." "Info"
    scoop install firefox
    Write-Log "Firefox installed successfully!" "Success"
} else {
    Write-Log "Firefox is already installed." "Warning"
}
Write-Log "--- Firefox installation complete ---`n" "Info"

# --- 18. Configure Firefox ---
Write-Log "--- Starting Firefox configuration ---" "Info"
Write-Log "Automatically configuring Firefox (e.g., extensions, user.js, etc.) is complex and often requires manual interaction or copying an existing profile." "Warning"
Write-Log "You may need to copy an existing Firefox profile or manually install required extensions after installation." "Info"
Write-Log "--- Firefox configuration complete ---`n" "Info"

# --- Final Message ---
Write-Log "All setup and configuration steps have been completed!" "Success"
Write-Log "Please restart your terminal or computer for all changes to take full effect." "Info"

