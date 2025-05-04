# Hướng dẫn phím tắt nvim 
| Phím tắt                   | Chức năng                                                                 |
|----------------------------|--------------------------------------------------------------------------|
| `Space + t`                | Mở/tắt terminal                                                          |
| `gcc`                      | Comment 1 dòng                                                           |
| `gc`                       | Comment 1 khối                                                           |
| `Ctrl + Space`             | Mở menu gợi ý (❌ không hoạt động)                                      |
| `Ctrl + e`                 | Đóng menu autocomplete                                                   |
| `Ctrl + j`                 | Di chuyển xuống danh sách gợi ý                                          |
| `Ctrl + k`                 | Di chuyển lên danh sách gợi ý                                            |
| `Ctrl + b` / `Ctrl + f`    | Cuộn lên xuống |
| `K`                        | Hover hiển thị thông tin hàm, biến dưới con trỏ                         |
| `gd`                       | Nhảy đến hàm đã được khai báo (Go to definition)                        |
| `gD`                       | Nhảy đến declaration                                                     |
| `gi`                       | Nhảy đến implementation                                                  |
| `gr`                       | Tìm tất cả nơi tham chiếu                                                |
| `Space + rn`               | Đổi tên tất cả tên biến/hàm trong dự án (Rename)                        |
| `Space + ca`               | Gợi ý sửa lỗi (Code action) (❌ không hoạt động)                         |
| `Space + e`                | Hover lỗi, thông tin biến, hàm dưới con trỏ                              |
| `Space + fm`               | Hiển thị danh sách hàm theo filetype (dùng telescope)                   |
| `Space + gf`               | Format file hiện tại                                                     |
| `:TimerStart`              | Bắt đầu 1 chu kỳ Pomodoro                                                |
| `:TimerRepeat`             | Lặp lại chu kỳ Pomodoro                                                  |
| `:TimerSessionpomo`        | Chạy Pomodoro đã định nghĩa                                              |
| `Visual mode + Space + s` | Bọc từ đã chọn, ví dụ `(quang)`                                          |
| `Space + ff`               | Tìm file trong thư mục hiện tại                                          |
| `Space + pf`               | Tìm file được git quản lý                                                |
| `Space + fb`               | Liệt kê tất cả buffer đang mở                                            |
| `Space + fh`               | Tìm help tag                                                             |
| `Space + u`                | Bật/tắt undo tree (⚠️ lỗi)                                               |
| `Space + uf`               | Focus vào undo tree (❌ không hoạt động)                                 |



# Cần cài 
| Công cụ    | Mục đích                          | Cài đặt                                  |
|------------|-----------------------------------|-------------------------------------------|
| `pyright`  | Hỗ trợ ngôn ngữ Python            | `npm install -g pyright`                  |
| `stylua`   | Định dạng code Lua                | `cargo install stylua`                    |
| `prettier` | Định dạng HTML/CSS/JS,...         | `npm install -g prettier`                 |
| `black`    | Định dạng code Python             | `pip install black`                       |
| `isort`    | Sắp xếp thứ tự import trong Python| `pip install isort`                       |
