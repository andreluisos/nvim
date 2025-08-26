-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.mouse = "a"       -- Enable mouse in all modes (optional, but scroll needs this)
vim.opt.mousefocus = true -- Optional: Allow window focus changes via mouse

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
