if not vim.g.neovide then
  return
end

-- Font Setup (Must be a GUI font installed on your system)
vim.o.guifont = "JetBrainsMono Nerd Font:h11"

-- Global UI Scaling
vim.g.neovide_scale_factor = 1.0

-- -- Cursor Animations & Particles
-- vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_vfx_mode = "" -- Options: "railgun", "torpedo", "pixiedust", "wireframe", "sonicboom"
-- vim.g.neovide_cursor_vfx_opacity = 200.0

-- -- Window Transparency
-- vim.g.neovide_opacity = 0.95
-- vim.g.neovide_normal_opacity = 0.95

-- Smooth Scrolling & Padding
vim.g.neovide_scroll_animation_length = 0.3
vim.g.neovide_padding_top = 10
vim.g.neovide_padding_left = 10
vim.g.neovide_cursor_trail_size = 0.0
vim.g.neovide_cursor_animation_length = 0.08

-- Dynamic Rescaling Keymaps (LazyVim keymap wrapper)
local map = vim.keymap.set
map({ "n", "v" }, "<C-=>", function()
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
end, { desc = "Increase Neovide Scale" })

map({ "n", "v" }, "<C-->", function()
  vim.g.neovide_scale_factor = math.max(vim.g.neovide_scale_factor - 0.1, 0.1)
end, { desc = "Decrease Neovide Scale" })

map({ "n", "v" }, "<C-0>", function()
  vim.g.neovide_scale_factor = 1.0
end, { desc = "Reset Neovide Scale" })
