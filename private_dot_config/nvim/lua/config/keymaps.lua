-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- =========================
-- Terminal Font
-- =========================
--

local function scale_alacritty(size)
  -- We use the full path to the property and ensure it's treated as an override
  local cmd = string.format("alacritty msg config -o font.size=%s", size)

  -- Use vim.loop.spawn for a more 'detached' execution if jobstart is being weird
  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code ~= 0 then
        -- If -o fails again, fall back to the standard version
        vim.fn.jobstart(string.format("alacritty msg config font.size=%s", size))
      end
    end,
  })
end

local is_font_big = true

vim.keymap.set("n", "<F2>", function()
  is_font_big = not is_font_big
  local size = is_font_big and 11.5 or 9.5
  scale_alacritty(size)
  print("Font set to: " .. size)
end)

-- =========================
-- Snippets
-- =========================

local ls = require("luasnip")

vim.keymap.set({ "i" }, "<C-S>", function()
  ls.expand()
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  ls.jump(1)
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  ls.jump(-1)
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })

-- =========================
-- Blink completion
-- =========================

local blink = require("blink.cmp")

vim.keymap.set("i", "<C-J>", function()
  if blink.is_visible() then
    blink.select_next()
    return ""
  end
  return ""
end, { expr = true, silent = true })

vim.keymap.set("i", "<C-K>", function()
  if blink.is_visible() then
    blink.select_prev()
    return ""
  end
  return ""
end, { expr = true, silent = true })

vim.keymap.set("i", "<C-Space>", function()
  blink.show()
end, { silent = true })

vim.keymap.set("i", "<C-e>", function()
  blink.hide()
end, { silent = true })

-- =========================
-- Blink completion
-- =========================

vim.keymap.set("n", "<F1>", function()
  if vim.opt.textwidth:get() == 70 then
    vim.opt.textwidth = 90
    print("Textwidth: 90")
  else
    vim.opt.textwidth = 70
    print("Textwidth: 70")
  end
end, { desc = "Toggle textwidth between 70 and 90" })
