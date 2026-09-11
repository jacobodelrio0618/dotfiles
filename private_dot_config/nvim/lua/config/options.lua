-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.spell = true
vim.opt.spelllang = { "it", "en_gb" }
vim.opt.textwidth = 90
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↳ "
vim.opt.statuscolumn = " %l "
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

require("config.neovide")

-- -- Function to open neo-tree on startup.
-- vim.api.nvim_create_autocmd("VimEnter", {
--   desc = "Open Neo-tree on startup without disrupting dashboard",
--   callback = function()
--     -- Only run if Neovim was launched cleanly without a specific file or folder argument
--     if vim.fn.argc() == 0 then
--       vim.schedule(function()
--         -- 1. Open Neo-tree silently
--         vim.cmd("Neotree show")
--         -- 2. Force focus back to the right window (the Dashboard)
--         vim.cmd("wincmd l")
--       end)
--     end
--   end,
-- })
