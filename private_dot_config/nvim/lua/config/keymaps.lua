-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- =========================
-- Terminal Font
-- =========================

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
  local size = is_font_big and 12.5 or 9.5
  scale_alacritty(size)
  print("Font set to: " .. size)
end)

-- NAVIGTION AND SNIPPETS

local ls = require("luasnip")
local blink = require("blink.cmp")

-- ====================================================================
-- 1. THE TRULY DUMB GLOBAL STRUCTURAL SEEKER (Cache-Synced)
-- ====================================================================

local function jump_to_delimiter(direction)
  local bufnr = vim.api.nvim_get_current_buf()

  -- Force an internal layout flush so Neovim knows exactly where
  -- the cursor sits immediately after snippet expansion.
  vim.cmd("redraw")

  local cursor = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor[1]
  local start_col = cursor[2] -- 0-indexed column

  local current_line_text = vim.api.nvim_get_current_line()
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local target_pos = nil
  local delimiters = "{}[%]$%(%)"

  if direction == 1 then
    -- FORWARD SEARCH
    local char_right = current_line_text:sub(start_col + 1, start_col + 1)

    if char_right:match("[" .. delimiters .. "]") then
      target_pos = { start_line, start_col + 1 }
    else
      for l = start_line, total_lines do
        local line_text = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
        local search_start = (l == start_line) and (start_col + 1) or 1

        for i = search_start, #line_text do
          if line_text:sub(i, i):match("[" .. delimiters .. "]") then
            target_pos = { l, i - 1 }
            break
          end
        end
        if target_pos then
          break
        end
      end
    end
  else
    -- BACKWARD SEARCH
    local char_left = current_line_text:sub(start_col, start_col)

    if char_left:match("[" .. delimiters .. "]") then
      target_pos = { start_line, start_col - 1 }
    else
      for l = start_line, 1, -1 do
        local line_text = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
        local search_start = (l == start_line) and start_col or #line_text

        for i = search_start, 1, -1 do
          if line_text:sub(i, i):match("[" .. delimiters .. "]") then
            target_pos = { l, i - 1 }
            break
          end
        end
        if target_pos then
          break
        end
      end
    end
  end

  if target_pos then
    vim.api.nvim_win_set_cursor(0, target_pos)
  else
    local key = (direction == 1) and "<Tab>" or "<S-Tab>"
    local feed = vim.api.nvim_replace_termcodes(key, true, false, true)
    vim.api.nvim_feedkeys(feed, "n", false)
  end
end

-- ====================================================================
-- 2. ALL UNTANGLED KEYMAPS (Your Ground Truth)
-- ====================================================================

-- TAB / S-TAB: Purely structural navigation
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  jump_to_delimiter(1)
end, { silent = true, noremap = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  jump_to_delimiter(-1)
end, { silent = true, noremap = true })

-- ALT+TAB: Snippet Expansion & Forward Placeholder Jumps
vim.keymap.set({ "i", "s" }, "<M-Tab>", function()
  if ls.expand_or_locally_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true, noremap = true })

-- ALT+Q: Snippet Backward Placeholder Jumps
vim.keymap.set({ "i", "s" }, "<M-q>", function()
  if ls.locally_jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true, noremap = true })

-- ENTER (<CR>): Dedicated to Blink Selections & Menu Accepts
vim.keymap.set("i", "<CR>", function()
  if blink.is_visible() then
    blink.accept()
  else
    local feed = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    vim.api.nvim_feedkeys(feed, "n", false)
  end
end, { silent = true, noremap = true })

-- ====================================================================
-- 3. UTILITY BINDINGS
-- ====================================================================

-- vim.keymap.set({ "i", "s" }, "<C-E>", function()
--   if ls.choice_active() then
--     ls.change_choice(1)
--   end
-- end)
--
-- vim.keymap.set("i", "<C-J>", function()
--   if blink.is_visible() then
--     blink.select_next()
--   end
-- end)
--
-- vim.keymap.set("i", "<C-K>", function()
--   if blink.is_visible() then
--     blink.select_prev()
--   end
-- end)

-- -- Command-line mode
-- vim.keymap.set("c", "<C-J>", "<C-N>", { desc = "Next command-line completion" })
-- vim.keymap.set("c", "<C-K>", "<C-P>", { desc = "Previous command-line completion" })

-- LuaSnip choice selection
vim.keymap.set({ "i", "s" }, "<C-E>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

-- Blink: next completion
vim.keymap.set({ "i", "c" }, "<C-J>", function()
  if blink.is_visible() then
    blink.select_next()
  end
end)

-- Blink: previous completion
vim.keymap.set({ "i", "c" }, "<C-K>", function()
  if blink.is_visible() then
    blink.select_prev()
  end
end)

-- Blink: manually trigger completion
vim.keymap.set({ "i", "c" }, "<C-Space>", function()
  blink.show()
end)

-- ====================================================================
-- 4. AUTO-UNLINK FOR ESCAPING TRACKS
-- ====================================================================

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    local session = require("luasnip").session
    if session and session.current_nodes[vim.api.nvim_get_current_buf()] and not ls.locally_jumpable() then
      ls.unlink_current()
    end
  end,
})

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

local set = vim.keymap.set

-- =========================
-- Quick Spell-Check Corrections
-- =========================

local spell_state = {
  typo_pos = nil, -- { row, col } (0-indexed)
  orig_len = 0, -- Length of the current word segment being swapped
  suggestions = nil, -- Table of matching spelling replacements
  current_idx = 1, -- Track where we are in the list
}

local function navigate_spell_suggestions(step)
  -- 1. Save where we're actively typing (1-indexed for row/col)
  local insert_pos = vim.api.nvim_win_get_cursor(0)

  -- 2. First invocation: locate previous spelling error
  if spell_state.typo_pos == nil then
    -- Explicitly jump back to normal mode briefly to run the movement command
    vim.cmd("normal! [s")

    local row = vim.fn.line(".") - 1
    local col = vim.fn.col(".") - 1
    local bad_word = vim.fn.expand("<cword>")

    spell_state.typo_pos = { row, col }
    spell_state.orig_len = #bad_word
    spell_state.suggestions = vim.fn.spellsuggest(bad_word, 15) -- Fetch up to 15 items for better scrolling
    spell_state.current_idx = 1
  else
    -- Update the index based on directional step (1 for next, -1 for previous)
    local num_suggestions = #spell_state.suggestions
    if num_suggestions == 0 then
      print("No suggestions available")
      return
    end

    -- Calculate next index with clean 1-based wrapping logic
    local next_idx = spell_state.current_idx + step
    if next_idx > num_suggestions then
      next_idx = 1
    elseif next_idx < 1 then
      next_idx = num_suggestions
    end
    spell_state.current_idx = next_idx
  end

  local replacement = spell_state.suggestions[spell_state.current_idx]
  if not replacement then
    print("No suggestion found")
    return
  end

  -- Notify user of current item and list total
  print(string.format("Spell: [%d/%d] → %s", spell_state.current_idx, #spell_state.suggestions, replacement))

  -- 3. Replace the text cleanly via API using our tracked coordinates
  local start_row, start_col = spell_state.typo_pos[1], spell_state.typo_pos[2]
  local old_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1] or ""
  local old_total_len = #old_line

  vim.api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col + spell_state.orig_len, { replacement })

  -- Update our tracking length to match the current replacement length
  spell_state.orig_len = #replacement

  -- 4. Calculate cursor shift for where you were typing
  local new_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1] or ""
  local delta = #new_line - old_total_len

  local ins_row, ins_col = insert_pos[1], insert_pos[2]
  if ins_row == start_row + 1 and ins_col >= start_col then
    ins_col = math.max(0, ins_col + delta)
  end

  vim.api.nvim_win_set_cursor(0, { ins_row, ins_col })
end

local function reset_spell_state()
  spell_state.typo_pos = nil
  spell_state.orig_len = 0
  spell_state.suggestions = nil
  spell_state.current_idx = 1
end

-- Keymaps
-- <C-l> initiates/resets and applies suggestion #1
vim.keymap.set("i", "<C-l>", function()
  reset_spell_state()
  navigate_spell_suggestions(0)
end, { desc = "Previous typo → suggest first option" })

-- <C-g> cycles forward (next suggestion)
vim.keymap.set("i", "<C-g>", function()
  navigate_spell_suggestions(1)
end, { desc = "Next spelling suggestion" })

-- <C-h> cycles backward (previous suggestion)
vim.keymap.set("i", "<C-h>", function()
  navigate_spell_suggestions(-1)
end, { desc = "Previous spelling suggestion" })

-- FORMATTING

vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", function()
  -- 1. Display eco notification before formatting starts
  vim.api.nvim_echo({
    { " Prettier ", "String" },
    { "Formatting and saving...", "MoreMsg" },
  }, false, {})
  vim.cmd("redraw")

  -- 2. Trigger LazyVim's default format pipeline (unchanged)
  LazyVim.format({ force = true })

  -- 3. Save the file silently
  vim.cmd("silent write")

  -- 4. Display eco success state and fade out after 1.5 seconds
  vim.api.nvim_echo({
    { " Prettier ", "String" },
    { "Formatted and saved!", "DiagnosticOk" },
  }, false, {})

  vim.defer_fn(function()
    vim.cmd("echo ''")
  end, 1500)
end, { desc = "Format and Save with Eco Echo" })
