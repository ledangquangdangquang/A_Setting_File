function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "Info" # Info, Success, Warning, Error
    )
    switch ($Type) {
        "Info"    { Write-Host "INFO: $Message" -ForegroundColor Cyan }
        "Success" { Write-Host "THÀNH CÔNG: $Message" -ForegroundColor Green }
        "Warning" { Write-Host "CẢNH BÁO: $Message" -ForegroundColor Yellow }
        "Error"   { Write-Host "LỖI: $Message" -ForegroundColor Red }
        default   { Write-Host "$Type: $Message" }
    }
}

# --- Bắt đầu script ---
Write-Log "Bắt đầu quá trình cài đặt môi trường phát triển tự động..." "Info"

# --- 1. Cài đặt Scoop ---
Write-Log "--- Bắt đầu cài đặt Scoop ---" "Info"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Log "Scoop chưa được cài đặt. Đang tiến hành cài đặt..." "Info"
    try {
        # Đặt ExecutionPolicy để cho phép chạy script từ xa (chỉ cho người dùng hiện tại)
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force | Out-Null
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        Write-Log "Scoop đã cài đặt thành công!" "Success"
        # Thêm bucket 'extras' để có thêm nhiều ứng dụng
        scoop bucket add extras
        Write-Log "Đã thêm bucket 'extras' cho Scoop." "Success"
    } catch {
        Write-Log "Lỗi khi cài đặt Scoop: $($_.Exception.Message)" "Error"
        Write-Log "Vui lòng kiểm tra kết nối mạng hoặc quyền hạn và chạy lại script." "Error"
        exit 1 # Thoát nếu Scoop không cài được
    }
} else {
    Write-Log "Scoop đã được cài đặt. Đang cập nhật Scoop..." "Warning"
    scoop update
    Write-Log "Đã cập nhật Scoop." "Success"
    # Đảm bảo bucket 'extras' được thêm
    if (-not (scoop bucket list | Select-String -Pattern "extras" -Quiet)) {
        scoop bucket add extras
        Write-Log "Đã thêm bucket 'extras' cho Scoop." "Success"
    }
}
Write-Log "--- Kết thúc cài đặt Scoop ---`n" "Info"

# --- 2. Cài đặt Python và Tree ---
Write-Log "--- Bắt đầu cài đặt Python và Tree ---" "Info"

# Cài Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Python..." "Info"
    scoop install python
    Write-Log "Python đã cài đặt thành công!" "Success"
} else {
    Write-Log "Python đã được cài đặt." "Warning"
}

# Cài Tree
if (-not (Get-Command tree -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Tree..." "Info"
    scoop install tree
    Write-Log "Tree đã cài đặt thành công!" "Success"
} else {
    Write-Log "Tree đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Python và Tree ---`n" "Info"

# --- 3. Cài đặt Git ---
Write-Log "--- Bắt đầu cài đặt Git ---" "Info"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Git..." "Info"
    scoop install git
    Write-Log "Git đã cài đặt thành công!" "Success"
} else {
    Write-Log "Git đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Git ---`n" "Info"

# --- 4. Thiết lập Git ---
Write-Log "--- Bắt đầu thiết lập Git ---" "Info"

$gitUserName = Read-Host "Nhập tên người dùng Git của bạn (ví dụ: Your Name)"
$gitUserEmail = Read-Host "Nhập email Git của bạn (ví dụ: your.email@example.com)"

git config --global user.name "$gitUserName"
git config --global user.email "$gitUserEmail"

Write-Log "Git user.name và user.email đã được thiết lập." "Success"
Write-Log "--- Kết thúc thiết lập Git ---`n" "Info"
Write-Log "--- Clone A_setting_file ---`n" "Info"
git clone https://github.com/ledangquangdangquang/A_Setting_File.git
$gitRepo = "A_Setting_File" 
Write-Log "--- End Clone A_setting_file ---`n" "Info"

# --- 5. Thiết lập .bashrc (cho Git Bash/WSL) ---
# Phần này chỉ áp dụng nếu bạn sử dụng Git Bash hoặc Windows Subsystem for Linux (WSL).
# Nếu bạn chỉ dùng PowerShell, phần này có thể bỏ qua.
Write-Log "--- Bắt đầu thiết lập .bashrc (cho Git Bash/WSL) ---" "Info"
Copy-Item -Path "./$gitRepo/git-bash/.bashrc" -Destination "$env:USERPROFILE" -Force
Write-Log "--- Kết thúc thiết lập .bashrc ---`n" "Info"

# --- 6. Cài đặt Starship ---
Write-Log "--- Bắt đầu cài đặt Starship ---" "Info"
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Starship..." "Info"
    scoop install starship
    Write-Log "Starship đã cài đặt thành công!" "Success"
} else {
    Write-Log "Starship đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Starship ---`n" "Info"

# --- 7. Thiết lập Starship ---
Write-Log "--- Bắt đầu thiết lập Starship ---" "Info"
Copy-Item -Path "./$gitRepo/starship/starship.toml" -Destination "$env:USERPROFILE/.config" -Force
Write-Log "--- Kết thúc thiết lập Starship ---`n" "Info"

# --- 8. Cài đặt Neovim (Nvim) ---
Write-Log "--- Bắt đầu cài đặt Neovim ---" "Info"
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Neovim..." "Info"
    scoop install neovim
    Write-Log "Neovim đã cài đặt thành công!" "Success"
} else {
    Write-Log "Neovim đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Neovim ---`n" "Info"

# --- 9. Thiết lập Neovim ---
Write-Log "--- Bắt đầu thiết lập Neovim ---" "Info"
$nvimConfigDir = "$env:LOCALAPPDATA\nvim" # Thư mục cấu hình Neovim trên Windows
Copy-Item -Path "./$gitRepo/nvim" -Destination "$nvimConfigDir" -Recurse -Force
Write-Log "--- Kết thúc thiết lập Neovim ---`n" "Info"

# --- 10. Cài đặt Alacritty ---
Write-Log "--- Bắt đầu cài đặt Alacritty ---" "Info"
if (-not (Get-Command alacritty -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Alacritty..." "Info"
    scoop install alacritty
    Write-Log "Alacritty đã cài đặt thành công!" "Success"
} else {
    Write-Log "Alacritty đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Alacritty ---`n" "Info"

# --- 11. Thiết lập Alacritty ---
Write-Log "--- Bắt đầu thiết lập Alacritty ---" "Info"
Copy-Item -Path "./$gitRepo/alacritty" -Destination "$env:APPDATA" -Recurse -Force
Write-Log "--- Kết thúc thiết lập Alacritty ---`n" "Info"

# --- 12. Cài đặt Yazi ---
Write-Log "--- Bắt đầu cài đặt Yazi ---" "Info"
if (-not (Get-Command yazi -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Yazi..." "Info"
    scoop install yazi
    Write-Log "Yazi đã cài đặt thành công!" "Success"
} else {
    Write-Log "Yazi đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Yazi ---`n" "Info"

# --- 13. Thiết lập Yazi ---
Write-Log "--- Bắt đầu thiết lập Yazi ---" "Info"
Copy-Item -Path "./$gitRepo/yazi" -Destination "$env:APPDATA" -Recurse -Force
Write-Log "--- Kết thúc thiết lập Yazi ---`n" "Info"

# --- 14. Cài đặt Komorebic ---
Write-Log "--- Bắt đầu cài đặt Komorebic ---" "Info"
if (-not (Get-Command komorebic -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Komorebic..." "Info"
    # Komorebi thường được cài đặt từ release hoặc Cargo.
    # Giả sử scoop install komorebi hoạt động với extras bucket.
    scoop install komorebi whkd
    Write-Log "Komorebic đã cài đặt thành công!" "Success"
} else {
    Write-Log "Komorebic đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Komorebic ---`n" "Info"

# --- 15. Thiết lập Komorebic ---
Write-Log "--- Bắt đầu thiết lập Komorebic ---" "Info"
Copy-Item -Path "./$gitRepo/komorebic/komorebi.bar.json" -Destination "$env:USERPROFILE" -Force
Copy-Item -Path "./$gitRepo/komorebic/komorebi.json" -Destination "$env:USERPROFILE" -Force
Copy-Item -Path "./$gitRepo/komorebic/whkdrc" -Destination "$env:USERPROFILE/.config" -Force
Copy-Item -Path "./$gitRepo/komorebic/startup-komo.bat" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" -Force
Write-Log "--- Kết thúc thiết lập Komorebic ---`n" "Info"

# --- 16. Cài đặt Firefox ---
Write-Log "--- Bắt đầu cài đặt Firefox ---" "Info"
if (-not (Get-Command firefox -ErrorAction SilentlyContinue)) {
    Write-Log "Đang cài đặt Firefox..." "Info"
    scoop install firefox
    Write-Log "Firefox đã cài đặt thành công!" "Success"
} else {
    Write-Log "Firefox đã được cài đặt." "Warning"
}
Write-Log "--- Kết thúc cài đặt Firefox ---`n" "Info"

# --- 17. Thiết lập Firefox ---
Write-Log "--- Bắt đầu thiết lập Firefox ---" "Info"
Write-Log "Việc tự động thiết lập Firefox (add-on, user.js, etc.) là phức tạp và thường yêu cầu tương tác thủ công hoặc sao chép profile." "Warning"
Write-Log "Bạn có thể cần sao chép một profile Firefox hiện có hoặc cài đặt các tiện ích mở rộng thủ công sau khi cài đặt." "Info"
Write-Log "--- Kết thúc thiết lập Firefox ---`n" "Info"

Write-Log "Tất cả các bước cài đặt và cấu hình đã hoàn tất!" "Success"
Write-Log "Vui lòng khởi động lại terminal hoặc máy tính để các thay đổi có hiệu lực hoàn toàn." "Info"
