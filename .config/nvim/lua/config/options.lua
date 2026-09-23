-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.filetype.add({ extension = { ino = "cpp" } })

-- Запрещаем плагинам проектов принудительно восстанавливать последний буфер
vim.g.auto_session_enabled = false
vim.g.rooter_silent_chdir = 1
vim.opt.mousescroll = "ver:1,hor:1"
