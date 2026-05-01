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

-- -- =========================
-- -- Snippets
-- -- =========================
--
-- local ls = require("luasnip")
--
-- -- 1. LUASNIP CONFIGURATION
-- ls.config.set_config({
--   -- Must be true for auto-expanding snippets to function
--   enable_autosnippets = true,
--   -- History allows the engine to track active nodes for expansion
--   history = true,
--   -- This ensures that as soon as you jump out using your custom logic,
--   -- LuaSnip "forgets" the snippet so you don't get trapped in old nodes.
--   region_check_events = "InsertEnter,CursorMoved",
-- })
--
-- -- 2. THE STRUCTURAL SEEKER LOGIC
-- local function jump_to_delimiter(direction)
--   local line = vim.api.nvim_get_current_line()
--   local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-indexed
--   local delimiters = "{}[%]$%(%)"
--   local target_col = nil
--
--   if direction == 1 then
--     -- FORWARD (Tab)
--     local char_right = line:sub(col + 1, col + 1)
--
--     -- If we are right before a delimiter (Position 2), hop inside (Position 3)
--     if char_right:match("[" .. delimiters .. "]") then
--       target_col = col + 1
--     else
--       -- If we are far away (Position 1), jump to the position right before the delimiter (Position 2)
--       for i = col + 2, #line do
--         if line:sub(i, i):match("[" .. delimiters .. "]") then
--           target_col = i - 1
--           break
--         end
--       end
--     end
--   else
--     -- BACKWARD (Shift-Tab)
--     local char_left = line:sub(col, col)
--
--     -- If we are right after a delimiter, hop back to before it
--     if char_left:match("[" .. delimiters .. "]") then
--       target_col = col - 1
--     else
--       -- If we are far away, jump to the position right after the previous delimiter
--       for i = col - 1, 1, -1 do
--         if line:sub(i, i):match("[" .. delimiters .. "]") then
--           target_col = i
--           break
--         end
--       end
--     end
--   end
--
--   if target_col and target_col >= 0 and target_col <= #line then
--     vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], target_col })
--   else
--     -- Fallback: Regular Tab/S-Tab
--     local key = (direction == 1) and "<Tab>" or "<S-Tab>"
--     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
--   end
-- end
--
-- -- 3. KEYMAPS
--
-- -- TAB: Snippet Jump -> Structural Seeker -> Normal Tab
-- vim.keymap.set({ "i", "s" }, "<Tab>", function()
--   if ls.expand_or_jumpable() then
--     ls.jump(1)
--   else
--     jump_to_delimiter(1)
--   end
-- end, { silent = true })
--
-- -- S-TAB: Snippet Back -> Structural Seeker Back -> Normal S-Tab
-- vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
--   if ls.jumpable(-1) then
--     ls.jump(-1)
--   else
--     jump_to_delimiter(-1)
--   end
-- end, { silent = true })
--
-- -- Manual Expand (Ctrl+S)
-- vim.keymap.set({ "i" }, "<C-S>", function()
--   if ls.expandable() then
--     ls.expand()
--   end
-- end, { silent = true })
--
-- -- Choice Node Cycling (Ctrl+E)
-- vim.keymap.set({ "i", "s" }, "<C-E>", function()
--   if ls.choice_active() then
--     ls.change_choice(1)
--   end
-- end, { silent = true })
--
-- -- =========================
-- -- Blink completion
-- -- =========================
--
-- local blink = require("blink.cmp")
--
-- vim.keymap.set("i", "<C-J>", function()
--   if blink.is_visible() then
--     blink.select_next()
--     return ""
--   end
--   return ""
-- end, { expr = true, silent = true })
--
-- vim.keymap.set("i", "<C-K>", function()
--   if blink.is_visible() then
--     blink.select_prev()
--     return ""
--   end
--   return ""
-- end, { expr = true, silent = true })
--
-- vim.keymap.set("i", "<C-Space>", function()
--   blink.show()
-- end, { silent = true })
--
-- vim.keymap.set("i", "<C-e>", function()
--   blink.hide()
-- end, { silent = true })

local ls = require("luasnip")
local blink = require("blink.cmp")

-- 1. LUASNIP CONFIGURATION
ls.config.set_config({
  enable_autosnippets = true,
  history = true,
  region_check_events = "InsertEnter,CursorMoved",
})

-- 2. THE STRUCTURAL SEEKER LOGIC (Keep as is)
local function jump_to_delimiter(direction)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local delimiters = "{}[%]$%(%)"
  local target_col = nil
  if direction == 1 then
    local char_right = line:sub(col + 1, col + 1)
    if char_right:match("[" .. delimiters .. "]") then
      target_col = col + 1
    else
      for i = col + 2, #line do
        if line:sub(i, i):match("[" .. delimiters .. "]") then
          target_col = i - 1
          break
        end
      end
    end
  else
    local char_left = line:sub(col, col)
    if char_left:match("[" .. delimiters .. "]") then
      target_col = col - 1
    else
      for i = col - 1, 1, -1 do
        if line:sub(i, i):match("[" .. delimiters .. "]") then
          target_col = i
          break
        end
      end
    end
  end
  if target_col and target_col >= 0 and target_col <= #line then
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], target_col })
  else
    local key = (direction == 1) and "<Tab>" or "<S-Tab>"
    local feed = vim.api.nvim_replace_termcodes(key, true, false, true)
    vim.api.nvim_feedkeys(feed, "n", false)
  end
end

-- 3. UNIFIED KEYMAPS (Snippet Priority -> Blink Accept -> Seeker)
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if ls.expand_or_locally_jumpable() then
    -- 1. Always prioritize Snippets
    ls.expand_or_jump()
  elseif blink.is_visible() then
    -- 2. If no snippet, but menu is open, accept the selection
    blink.accept()
  else
    -- 3. Otherwise, use seeker or default tab
    jump_to_delimiter(1)
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  elseif blink.is_visible() then
    blink.select_prev()
  else
    jump_to_delimiter(-1)
  end
end, { silent = true })

-- Utility bindings
vim.keymap.set({ "i", "s" }, "<C-E>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)
vim.keymap.set("i", "<C-J>", function()
  if blink.is_visible() then
    blink.select_next()
  end
end)
vim.keymap.set("i", "<C-K>", function()
  if blink.is_visible() then
    blink.select_prev()
  end
end)

-- =========================
-- Textwidth Adjustment
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
