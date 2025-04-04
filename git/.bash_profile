# Kiểm tra xem file ~/.profile và ~/.bashrc có tồn tại không, và tải chúng nếu có
test -f ~/.profile && source ~/.profile
test -f ~/.bashrc && source ~/.bashrc

# Khởi tạo Oh My Posh với cấu hình (đảm bảo đường dẫn đúng cho Git Bash trên Windows)
eval "$(oh-my-posh init bash --config ~/Oh-my-posh-config.json)"
