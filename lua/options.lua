local INDENT_WIDTH = 2
local MAPPING_TIMEOUT_MILLISECONDS = 300
local MOUSE_DISABLED = ""

vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = INDENT_WIDTH
vim.o.softtabstop = INDENT_WIDTH
vim.o.shiftwidth = INDENT_WIDTH
vim.o.signcolumn = "yes"
vim.o.undofile = true
vim.o.autoread = true
vim.o.laststatus = 3
vim.o.cmdheight = 0
vim.o.timeoutlen = MAPPING_TIMEOUT_MILLISECONDS
vim.o.mouse = MOUSE_DISABLED
