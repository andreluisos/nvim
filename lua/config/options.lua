-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Get the user's home directory
local home = vim.env.HOME
local paths_to_add = {
  home .. "/bin",
  home .. "/.local/bin",
  "/usr/local/bin",
  home .. "/.cargo/bin",
  home .. "/.opencode/bin:",
}

vim.env.PATH = table.concat(paths_to_add, ":") .. ":" .. vim.env.PATH

vim.o.mouse = "a" -- Enable mouse in all modes (optional, but scroll needs this)
vim.o.mousefocus = true -- Optional: Allow window focus changes via mouse
vim.o.clipboard = "unnamedplus"
vim.o.linespace = 1
vim.o.showtabline = 2
vim.o.termguicolors = true

vim.g.rust_recommended_style = 0

-- Neovide settings
vim.g.neovide_fullscreen = true
vim.g.neovide_padding_top = 0
vim.g.neovide_padding_bottom = 0
vim.g.neovide_padding_left = 0
vim.g.neovide_padding_right = 0
vim.g.neovide_cursor_smooth_blink = true
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animation_length = 0.300
vim.g.neovide_cursor_smooth_blink = true

-- Disable mouse clicks (left, right, middle click) but keep scrolling
vim.cmd([[
  nnoremap <LeftMouse> <Nop>
  nnoremap <RightMouse> <Nop>
  nnoremap <MiddleMouse> <Nop>
  nnoremap <2-LeftMouse> <Nop>
  nnoremap <3-LeftMouse> <Nop>
  nnoremap <4-LeftMouse> <Nop>

  inoremap <LeftMouse> <Nop>
  inoremap <RightMouse> <Nop>
  inoremap <MiddleMouse> <Nop>
  inoremap <2-LeftMouse> <Nop>
  inoremap <3-LeftMouse> <Nop>
  inoremap <4-LeftMouse> <Nop>
]])
