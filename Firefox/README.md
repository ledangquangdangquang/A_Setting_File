# Firefox 

> This is browser i am using now. 
---
- Helium: `helium://flags/#helium-cat-ui`
- tampermonkey: The extension (addons Firefox) javascript in web realtime:
    - Dashboard -> Utilities -> Import from file 
    - Upload .zip file in folder tampermonkey

- bookmark: upload file `firefox-bookmarks.html` in bookmarks bar setting (Ctrl + J)
- authenticator: The extension (addons Firefox):
    - Use `code authen.jpg`
- Firefox Css file: enter the folder `FireFoxOneLinerCSS-main` and read README.md
---
"Browser Toolbox" là DevTools đặc biệt của Firefox để inspect luôn UI của trình duyệt (tab bar, navbar, menu…), không chỉ nội dung web.
Nó bị ẩn mặc định, nên phải bật lên trước.

---

**Cách bật và mở Browser Toolbox:**

### 1. Bật trong `about:config`

1. Gõ vào thanh địa chỉ:

   ```
   about:config
   ```
2. Tìm và bật (`true`) hai khóa:

   ```
   devtools.chrome.enabled
   devtools.debugger.remote-enabled
   ```
3. (Tùy chọn) Nếu muốn bỏ cảnh báo khi mở:

   ```
   devtools.debugger.prompt-connection
   ```

   → Đặt `false` để không hỏi lại.

---

### 2. Mở Browser Toolbox
  Nhấn tổ hợp phím:

  ```
  Ctrl + Alt + Shift + I   (Windows / Linux)
  Cmd + Option + Shift + I (macOS)
  ```

---
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
