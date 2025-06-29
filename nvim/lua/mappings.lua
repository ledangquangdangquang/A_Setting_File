require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

local map = vim.keymap.set

local function create_note()
  local ts = os.date("%d-%m-%Y %H:%M:%S")
  local fname = os.date("note_%y-%m-%d.md")
  local notes_dir = vim.fn.expand("./notes/")
  local full = notes_dir .. fname

  -- Tạo thư mục nếu chưa có
  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, "p")
  end

  -- Nếu file chưa tồn tại, thêm header
  if vim.fn.filereadable(full) == 0 then
    vim.fn.writefile({ "--- note " .. ts .. " ---", "" }, full)
  end

  vim.cmd("edit " .. full)
end

-- Gán phím tắt
map("n", "<leader>no", create_note, { desc = "Tạo file note theo ngày" })
