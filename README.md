# Config app in my window 10

---
## There are all the app:
- Alacritty terminal
- Window terminal 
- Wezterm terminal 
- Bash shell
- Window powershell
- Clink
- Oh my posh
- Starship
- Browser Firefox
- Matlab 
- Komorebic 
- Nvim
- Visual studio code 
- Yazi

> [!TIP]
> Enter the folder to see detail README.

> [!NOTE]
> `%USERPROFILE%` is `C:\Users\{UserName}` 
> 
> `Window + R` and enter `%USERPROFILE%` to see exactly location.
> 
> `%APPDATA%` is `C:\Users\{UserName}\AppData\Roaming` 
> 
> `Window + R` and enter `%AppData%` to see exactly location.
> 
> `%LOCALAPPDATA%` is `C:\Users\{UserName}\AppData\local` 
> 
> `Window + R` and enter `%LOCALAPPDATA%` to see exactly location.

---
Run `ps1` file 
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ledangquangdangquang/A_Setting_File/refs/heads/main/autoInstall.ps1" -OutFile "$env:USERPROFILE\Downloads\autoInstall.ps1"; Unblock-File "$env:USERPROFILE\Downloads\autoInstall.ps1"; & "$env:USERPROFILE\Downloads\autoInstall.ps1"
```
