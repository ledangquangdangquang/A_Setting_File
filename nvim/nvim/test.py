import os

def export_lua_files_to_txt(root_folder, output_file):
    with open(output_file, 'w', encoding='utf-8') as out_f:
        for folder_path, _, files in os.walk(root_folder):
            for file_name in files:
                if file_name.endswith('.lua'):
                    file_path = os.path.join(folder_path, file_name)
                    # Định dạng lại đường dẫn cho đẹp
                    relative_path = os.path.relpath(file_path, root_folder).replace("\\", "/")
                    
                    out_f.write(f'"{relative_path}".text = \'\' \n')
                    try:
                        with open(file_path, 'r', encoding='utf-8') as lua_file:
                            for line in lua_file:
                                out_f.write(f'\t{line}')
                    except Exception as e:
                        out_f.write(f'\t-- Lỗi khi đọc file: {e}\n')
                    out_f.write("'';\n\n")  # Kết thúc block
    print(f"Hoàn tất. Đã ghi ra: {output_file}")

# 🟢 Ví dụ sử dụng
folder_chinh = "./"
file_xuat = "output.lua"
export_lua_files_to_txt(folder_chinh, file_xuat)
