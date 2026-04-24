local telescope_builtin = require("telescope.builtin")

local M = {}

-- Toggle for textwidth

vim.keymap.set('n', '<F1>', function()
    if vim.opt.textwidth:get() == 70 then
        vim.opt.textwidth = 90
        print("Textwidth: 90")
    else
        vim.opt.textwidth = 70
        print("Textwidth: 70")
    end
end, { desc = "Toggle textwidth between 70 and 90" })

-- Switch for themes

function ToggleDarkMode()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end

-- Helper: wrap or toggle wrapper around selection

local function toggle_wrapper(wrapper)
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local start_line = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_line = end_pos[2] - 1
  local end_col = end_pos[3] - 1

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
  if #lines == 0 then return end

  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col + 1, end_col + 1)
  else
    lines[1] = string.sub(lines[1], start_col + 1)
    lines[#lines] = string.sub(lines[#lines], 1, end_col + 1)
  end

  local text = table.concat(lines, "\n")

  if wrapper == "toggle_emph" then
    local inner = text:match("^\\emph{%s*(.-)%s*}$")
    text = inner or "\\emph{" .. text .. "}"
  elseif wrapper == "toggle_textit" then
    local inner = text:match("^\\textit{%s*(.-)%s*}$")
    text = inner or "\\textit{" .. text .. "}"
  elseif wrapper == "toggle_dollar" then
    local inner = text:match("^%$(.-)%$")
    text = inner or "$" .. text .. "$"
  elseif wrapper == "curly" then
    local inner = text:match("^{(.*)}$")
    text = inner or "{" .. text .. "}"
  elseif wrapper == "square" then
    local inner = text:match("^%[(.*)%]$")
    text = inner or "[" .. text .. "]"
  elseif wrapper == "paren" then
    local inner = text:match("^%((.*)%)$")
    text = inner or "(" .. text .. ")"
  else
    text = wrapper .. text .. wrapper
  end

  local new_lines = {}
  for s in text:gmatch("[^\n]+") do
    table.insert(new_lines, s)
  end

  vim.api.nvim_buf_set_text(bufnr, start_line, start_col, end_line, end_col + 1, new_lines)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

-- Assuming toggle_wrapper is defined somewhere accessible in your config

vim.keymap.set('v', '<leader>e', function() toggle_wrapper("toggle_emph") end, { silent = true, noremap = true, desc = "Toggle \\emph{} wrapper" })
vim.keymap.set('v', '<leader>i', function() toggle_wrapper("toggle_textit") end, { silent = true, noremap = true, desc = "Toggle \\textit{} wrapper" })
vim.keymap.set('v', '<leader>m', function() toggle_wrapper("toggle_dollar") end, { silent = true, noremap = true, desc = "Toggle $...$ wrapper" })
vim.keymap.set('v', '<leader>1{', function() toggle_wrapper("curly") end, { silent = true, noremap = true, desc = "Toggle { } wrapper" })
vim.keymap.set('v', '<leader>2', function() toggle_wrapper("square") end, { silent = true, noremap = true, desc = "Toggle [ ] wrapper" })
vim.keymap.set('v', '<leader>3', function() toggle_wrapper("paren") end, { silent = true, noremap = true, desc = "Toggle ( ) wrapper" })
vim.keymap.set('v', '<leader>"', function() toggle_wrapper('"') end, { silent = true, noremap = true, desc = "Toggle \" \" wrapper" })
vim.keymap.set('v', "<leader>'", function() toggle_wrapper("'") end, { silent = true, noremap = true, desc = "Toggle ' ' wrapper" })

-- Unwrapping function

local function unwrap_wrapper(wrapper)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local start_pat, end_pat, inner_start_offset, inner_end_offset

  if wrapper == "toggle_emph" then
    start_pat = "\\emph{"
    end_pat = "}"
    inner_start_offset = #start_pat
    inner_end_offset = 1
  elseif wrapper == "toggle_textit" then
    start_pat = "\\textit{"
    end_pat = "}"
    inner_start_offset = #start_pat
    inner_end_offset = 1
  elseif wrapper == "toggle_dollar" then
    start_pat = "%$"
    end_pat = "%$"
    inner_start_offset = 1
    inner_end_offset = 1
  elseif wrapper == "curly" then
    start_pat = "{"
    end_pat = "}"
    inner_start_offset = 1
    inner_end_offset = 1
  elseif wrapper == "square" then
    start_pat = "%["
    end_pat = "%]"
    inner_start_offset = 1
    inner_end_offset = 1
  elseif wrapper == "paren" then
    start_pat = "%("
    end_pat = "%)"
    inner_start_offset = 1
    inner_end_offset = 1
  elseif wrapper == '"' then
    start_pat = '"'
    end_pat = '"'
    inner_start_offset = 1
    inner_end_offset = 1
  elseif wrapper == "'" then
    start_pat = "'"
    end_pat = "'"
    inner_start_offset = 1
    inner_end_offset = 1
  else
    print("Unknown wrapper: " .. tostring(wrapper))
    return
  end

  -- Escape patterns for Lua pattern matching
  local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
  end

  local start_esc = escape_pattern(start_pat)
  local end_esc = escape_pattern(end_pat)

  -- Find start position of wrapper before or at cursor
  local search_start = 1
  local start_pos, s, e
  while true do
    s, e = line:find(start_esc, search_start)
    if not s then break end
    if s - 1 <= col then
      start_pos = s
      search_start = e + 1
    else
      break
    end
  end

  if not start_pos then
    print("No starting wrapper '" .. start_pat .. "' found before or at cursor")
    return
  end

  -- Find end position of wrapper after cursor
  local end_pos = line:find(end_esc, col + 1)
  if not end_pos then
    print("No ending wrapper '" .. end_pat .. "' found after cursor")
    return
  end

  -- Extract inner text
  local inner = line:sub(start_pos + inner_start_offset, end_pos - inner_end_offset)

  -- Replace the whole wrapper with inner text
  local new_line = line:sub(1, start_pos - 1) .. inner .. line:sub(end_pos + 1)

  vim.api.nvim_set_current_line(new_line)

  -- Restore cursor roughly inside inner text (start_pos - 1 + length of inner)
  local new_col = start_pos - 1 + #inner
  if new_col < 0 then new_col = 0 end
  vim.api.nvim_win_set_cursor(0, {row, new_col})
end

vim.keymap.set('n', '<leader>e', function() unwrap_wrapper("toggle_emph") end, { silent = true, noremap = true, desc = "Unwrap \\emph{} wrapper" })
vim.keymap.set('n', '<leader>i', function() unwrap_wrapper("toggle_textit") end, { silent = true, noremap = true, desc = "Unwrap \\textit{} wrapper" })
vim.keymap.set('n', '<leader>m', function() unwrap_wrapper("toggle_dollar") end, { silent = true, noremap = true, desc = "Unwrap $...$ wrapper" })
vim.keymap.set('n', '<leader>1', function() unwrap_wrapper("curly") end, { silent = true, noremap = true, desc = "Unwrap { } wrapper" })
vim.keymap.set('n', '<leader>2', function() unwrap_wrapper("square") end, { silent = true, noremap = true, desc = "Unwrap [ ] wrapper" })
vim.keymap.set('n', '<leader>3', function() unwrap_wrapper("paren") end, { silent = true, noremap = true, desc = "Unwrap ( ) wrapper" })
vim.keymap.set('n', '<leader>"', function() unwrap_wrapper('"') end, { silent = true, noremap = true, desc = "Unwrap \" \" wrapper" })
vim.keymap.set('n', "<leader>'", function() unwrap_wrapper("'") end, { silent = true, noremap = true, desc = "Unwrap ' ' wrapper" })

-- Telescope

local function find_root_dir()
  local util = require("lspconfig.util")
  return util.root_pattern("main.tex")(vim.fn.expand("%:p")) or vim.fn.getcwd()
end

function M.setup()
  --
  vim.keymap.set('n', '\\ff', telescope_builtin.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '\\fg', telescope_builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '\\fb', telescope_builtin.buffers, { desc = 'Telescope buffers' })
  vim.keymap.set('n', '\\fh', telescope_builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set('n', '\\cb', function()
  require('telescope').extensions.bibtex.bibtex()
end, { desc = 'Telescope BibTeX picker' })

vim.keymap.set('i', '<C-t>', function()
  vim.cmd("stopinsert")
  vim.schedule(function()
    require('telescope').extensions.bibtex.bibtex()
  end)
end, { desc = 'Telescope BibTeX picker (insert mode)' })

local builtin = require('telescope.builtin')
-- \fr : Search through recently opened files (oldfiles)
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = "Telescope recent files" })

-- Formatting mappings

local function get_cursor_byte_offset()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = vim.api.nvim_buf_get_lines(0, 0, row - 1, true)
  local offset = 0
  for _, line in ipairs(lines) do
    offset = offset + #line + 1 -- +1 for newline
  end
  offset = offset + col
  return offset
end

local function set_cursor_byte_offset(offset)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local total = 0
  for i, line in ipairs(lines) do
    local line_len = #line + 1 -- +1 for newline
    if total + line_len > offset then
      local col = offset - total
      vim.api.nvim_win_set_cursor(0, { i, col })
      return
    end
    total = total + line_len
  end

  local last_line = #lines
  vim.api.nvim_win_set_cursor(0, { last_line, #lines[last_line] })
end

local function format_paragraph_preserve_cursor()
  -- your actual formatting command here:
  vim.cmd("normal! gqap")
end

local function format_preserve_cursor_by_offset()
  local offset = get_cursor_byte_offset()
  local top_line = vim.fn.line("w0")

  format_paragraph_preserve_cursor()

  set_cursor_byte_offset(offset)
  vim.fn.winrestview({ topline = top_line })
end

-- vim.keymap.set("n", "<F1>", format_preserve_cursor_by_offset, { noremap = true, silent = true })
-- vim.keymap.set("i", "<F1>", function()
--   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
--   vim.schedule(format_preserve_cursor_by_offset)
-- end, { noremap = true, silent = true })

-- Bindings for writing a file

vim.api.nvim_set_keymap('n', '<F6>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<F6>', '<Esc>:w<CR>a', { noremap = true, silent = true })

-- Buffers with Snipe
vim.keymap.set("n", "<F4>", function()
  require("snipe").open_buffer_menu()
end, { desc = "Open Snipe buffer menu" })

-- Spell with Snipe

vim.api.nvim_set_keymap('n', 'm', ':SnipeSpell<CR>', { noremap = true, silent = true })

-- File explorer

vim.keymap.set("n", "<F5>", function()
  require("telescope").extensions.file_browser.file_browser({
    hidden = true,
  })
end, { noremap = true, desc = "Open file browser" })

-- Compile once

vim.keymap.set('n', '<F7>', function()
  vim.cmd('write')  -- or vim.cmd('w')
  vim.cmd('VimtexCompileSS')
end, { desc = "Vimtex: Save and single-shot compile with <F7>" })

-- Forward search
vim.api.nvim_set_keymap('n', '<F8>', '<Cmd>VimtexView<CR>', { noremap = true, silent = true })


-- Corrects the last spelling mistake

vim.keymap.set('i', '<C-l>', function()
  local win = vim.api.nvim_get_current_win()
  local pos = vim.api.nvim_win_get_cursor(win) -- (row, col)

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
  vim.cmd('normal! [s1z=')
  vim.api.nvim_win_set_cursor(win, pos)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, false, true), 'n', true)
end, { desc = "Fix last spelling mistake and stay in insert mode" })

-- Neogit

vim.keymap.set('n', '<leader>g', ':Neogit<CR>', { desc = 'Open Neogit status buffer' })

-- Conceal toggle

vim.keymap.set('n', '<leader>h', function()
  if vim.o.conceallevel == 0 then
    vim.o.conceallevel = 1
  else
    vim.o.conceallevel = 0
  end
  print('Conceallevel set to: ' .. vim.o.conceallevel)
end, { desc = 'Toggle conceal level (0/1)' })

--
end

return M
