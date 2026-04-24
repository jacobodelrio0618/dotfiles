-- Plugin manager: vim-plug
vim.cmd [[
  call plug#begin(expand('~/.config/nvim/plugged'))

  Plug 'lervag/vimtex'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-bibtex.nvim'
  Plug 'nvim-telescope/telescope-file-browser.nvim'
  Plug 'leath-dub/snipe.nvim'
  Plug 'kungfusheep/snipe-spell.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'NeogitOrg/neogit'
  Plug('sindrets/diffview.nvim')
  Plug 'metalelf0/black-metal-theme-neovim'
  Plug 'sainnhe/everforest'
  Plug 'EdenEast/nightfox.nvim'
  Plug 'sainnhe/gruvbox-material'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saghen/blink.cmp', { 'do': 'cargo +nightly build --release' }
  Plug 'ribru17/blink-cmp-spell'
  Plug 'erooke/blink-cmp-latex'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'folke/noice.nvim'
  Plug 'MunifTanjim/nui.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'goolord/alpha-nvim'
  Plug 'folke/which-key.nvim'
  Plug 'kylechui/nvim-surround'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'folke/snacks.nvim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'MunifTanjim/prettier.nvim'
  Plug 'xvzc/chezmoi.nvim'
  Plug 'nvimtools/none-ls.nvim'
  call plug#end()
]]

require('keymaps').setup()

-- Enable true color
vim.o.termguicolors = true
-- 1. Configuration for Gruvbox-Material
vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_material_better_performance = 1

-- 2. The Comprehensive Black-Out & Dim Function
local function total_black_out()
    -- Define your colors
    local bg_black = "#000000"
    local dim_white = "#C5C8C6" -- Adjust this hex to go darker or lighter
    local line_gray = "#666666" -- The gray for your line numbers
    local active_line_gray = "#999999" -- Slightly brighter for the current line

    -- Groups that need BOTH black background and dimmed text
    local main_groups = { "Normal", "NormalNC", "TelescopeNormal", "NormalFloat" }
    
    -- Groups that only need black background
    local bg_only_groups = {
        "SignColumn", "LineNr", "CursorLineNr", "EndOfBuffer",
        "TelescopeBorder", "TelescopePromptNormal", "TelescopePromptBorder", 
        "TelescopeResultsNormal", "TelescopeResultsBorder",
        "TelescopePreviewNormal", "TelescopePreviewBorder",
        "FloatBorder", "Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb"
    }

    -- Apply dimmed foreground and black background
    for _, group in ipairs(main_groups) do
        vim.api.nvim_set_hl(0, group, { fg = dim_white, bg = bg_black })
    end

    -- Apply background only
    for _, group in ipairs(bg_only_groups) do
        vim.api.nvim_set_hl(0, group, { bg = bg_black })
    end
    -- Line numbers
    vim.api.nvim_set_hl(0, "LineNr", { fg = line_gray, bg = bg_black })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = active_line_gray, bg = bg_black, bold = true })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = bg_black })
end

-- 3. Apply every time a colorscheme is loaded
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = total_black_out,
})

-- 4. Load the theme
vim.cmd("colorscheme gruvbox-material")
-- LaTeX Icon
-- Override the icon for LaTeX files
require'nvim-web-devicons'.set_icon {
  tex = {
    icon = "",   -- or any icon you want
    color = "#d3c6aa",
    name = "Tex"
  }
}

-- Terminal font config
local function scale_alacritty(size)
    -- Using 'set' explicitly often works better in newer versions
    -- Ensure you are passing the size as a string/float correctly
    local cmd = string.format("alacritty msg config 'font.size=%s'", tostring(size))
    vim.fn.jobstart(cmd)
end

-- Chezmoi

require("chezmoi").setup({
    -- This allows chezmoi.nvim to automatically apply changes on save
    edit = {
        watch = true,
        force = false,
    },
    notification = {
        on_open = true,
        on_apply = true,
    },
})

local is_font_big = false

vim.keymap.set('n', '<F2>', function()
    if is_font_big then
        scale_alacritty(9.5)
        is_font_big = false
        print("Font scaled to Small (9.5)")
    else
        scale_alacritty(11.5)
        is_font_big = true
        print("Font scaled to Big (11.5)")
    end
end, { desc = "Toggle Alacritty Font Size" })

-- GUI config

vim.o.guifont = "JetBrainsMono Nerd Font Mono:h10.5"
vim.opt.linespace = 2
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_no_idle = true
vim.g.neovide_no_vsync = true
vim.g.neovide_refresh_rate = 180
vim.g.neovide_idle_refresh_rate = 5
vim.g.neovide_cursor_short_animation_length=0.130
vim.keymap.set('n', '<F9>', ToggleDarkMode, { noremap = true, silent = true })

-- if vim.g.neovide then
--     -- MSI Monitor (14.5)
--     vim.keymap.set('n', '<leader>jb', ':lua vim.o.guifont = "CaskaydiaCove Nerd Font:h12.5"<CR>', { silent = true, desc = "Font Big (MSI)" })
--
--     -- Laptop Monitor (10.5)
--     vim.keymap.set('n', '<leader>js', ':lua vim.o.guifont = "CaskaydiaCove Nerd Font:h10.5"<CR>', { silent = true, desc = "Font Small (Laptop)" })
-- end

-- Noice

require('noice').setup({
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "echo",
        find = "VimTeX",
      },
      opts = { skip = true },
    },
  },
  cmdline = { enabled = true, view = "cmdline_popup" },
  messages = { enabled = true, view = "mini" }, 
  popupmenu = { enabled = false },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = true,
  },
  views = {
    mini = {
      position = {
        row = -1,
        col = "100%",
      },
      win_options = {
        winblend = 0,
      },
    },
  },
})

-- Neogit Configuration

require('neogit').setup{
  confirm_on_action = false,
}

-- Diffview Configuration (Optional but recommended)
require('diffview').setup{}

-- Snacks indent lines
require("snacks").setup({
  modules = { "indent" },
  indent = {
    priority = 1,
    enabled = true,
    char = "│",
    only_scope = true,
    only_current = true,
    hl = "SnacksIndent",
  },
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "texlab" },
})
-- Prettier Formatter
local null_ls = require("null-ls")

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

null_ls.setup({
  on_attach = function(client, bufnr)
    if client:supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<Leader>jf", function()
        vim.lsp.buf.format({ timeout_ms = 5000, bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })

      -- format on save
      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format({ timeout_ms = 5000, bufnr = bufnr, async = async })
        end,
        desc = "[lsp] format on save",
      })
    end

    if client:supports_method("textDocument/rangeFormatting") then
      vim.keymap.set("x", "<Leader>jf", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })
    end
  end,
})
local prettier = require("prettier")

prettier.setup({
  bin = 'prettier', 
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
    -- ADD THESE FOR LATEX:
    "tex",
    "latex",
    "plaintex",
  },
})

-- Define Texlab in new API
local util = require("lspconfig.util")
local capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.config.texlab = {
    default_config = {
        cmd = { "texlab" },
        filetypes = { "tex" },
        root_dir = util.root_pattern("main.tex", ".git"),
        settings = {
            texlab = {
                build = {
                    executable = "latexmk",
                    args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "main.tex" },
                    onSave = false,
                    forwardSearchAfter = false,
                },
                forwardSearch = {
                    executable = "/usr/bin/zathura",
                    args = { "--unique", "file:%p#src:%l%f" },
                },
                chktex = { onOpenAndSave = false, onEdit = false }, -- MODIFIED ON EDIT
                diagnosticsDelay = 300,
            }
        },
        capabilities = capabilities,
    }
}

-- VimTeX settings

vim.g.vimtex_view_method = 'sioyek'
vim.g.vimtex_view_automatic = 0
vim.g.vimtex_compiler_enabled = 1
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_bibtex_bibfiles = { "bibliography.bib" }
vim.g.vimtex_format_enabled = true
vim.g.vimtex_indent_enabled = false

-- Lualine

local function filename_no_ext()
  local filename = vim.fn.expand('%:t') -- get current file name
  local name_no_ext = filename:match("(.+)%..+$") or filename
  return name_no_ext
end

local function buffer_modified()
  if vim.bo.modified then
    return "●"  -- symbol indicating unsaved changes
  else
    return ""
  end
end

-- global variable to hold status
_G.vimtex_compile_status_icon = ""  -- idle by default

vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventCompileStarted",
  callback = function()
    _G.vimtex_compile_status_icon = " "  -- compiling
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventCompileSuccess",
  callback = function()
    _G.vimtex_compile_status_icon = " "  -- success
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventCompileFailed",
  callback = function()
    _G.vimtex_compile_status_icon = " "  -- failure
  end,
})


local function vimtex_status()
  return _G.vimtex_compile_status_icon or ""
end

require('lualine').setup {
options = {
    icons_enabled = true,
    theme = carbonfox,
    component_separators = { left = ' ', right = ' '},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {"alpha"},
      winbar = {"alpha"},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    }
  },
  sections = {
    lualine_a = { { 'mode' } },
    lualine_b = { 
       {
       function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        end,
        icon = '', 
       } 
    },
    lualine_c = { },
    lualine_x = { 
        { buffer_modified },
        { filename_no_ext },
    	{ 'filetype' },
    	{ vimtex_status },
    },
    lualine_y = { },
    lualine_z = { { 'location' } },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- Diagnostic display
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  float = true,
})

-- General options
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.textwidth = 90
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.formatoptions = "tcq"
vim.opt.spell = true
vim.opt.spelllang = { "en_gb", "it" }
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.conceallevel = 0
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3
vim.opt.statusline = " "
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.showcmd = true
vim.opt.clipboard = "unnamedplus"

-- Auto-cd to main.tex directory when opening .tex files
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.tex",
  callback = function()
    local root = vim.fn.findfile("main.tex", ".;")
    if root ~= "" then
      vim.cmd("cd " .. vim.fn.fnamemodify(root, ":p:h"))
    end
  end,
})

-- LuaSnip

local luasnip = require("luasnip")
local custom_snippets = require("snippets")
for _, snippet in ipairs(custom_snippets) do
  luasnip.add_snippets("tex", { snippet })
  luasnip.add_snippets(nil, { snippet })
end

-- BLink autocomplete
local blink_cmp = require('blink.cmp')
local luasnip = require('luasnip')

blink_cmp.setup({
  keymap = {
    ['<Down>'] = { "select_next", "fallback" },
    ['<Up>'] = { "select_prev", "fallback" },
    ['<CR>'] = { "accept", "fallback" },
    ['<C-Space>'] = { "show" }
  },

  signature = { enabled = false },

  snippets = {
    expand = function(body)
      luasnip.lsp_expand(body)
    end,
    preset = "luasnip",
  },

  sources = {
    default = { 'spell', 'path', 'snippets', 'buffer', 'lsp' },
    
    providers = {
        snippets = {
            --enabled = function()
                -- Disable LSP source in LaTeX reference contexts to avoid duplicates with VimTeX
                --if vim.bo.filetype == 'tex' then
                --local line = vim.api.nvim_get_current_line()
                --local col = vim.api.nvim_win_get_cursor(0)[2]
                --local before_cursor = line:sub(1, col)
                
                -- Disable in reference contexts only (keep for citations and general editing)
                --if before_cursor:match('\\ref{[^}]*$') or
                    --before_cursor:match('\\[Cc]ref{[^}]*$') or
                    --before_cursor:match('\\eqref{[^}]*$') or
                    --before_cursor:match('\\subfile{[^}]*$') or
                    --before_cursor:match('\\autoref{[^}]*$') then
                    --return false
                --end
                --end
                --return true
            --end,
            enabled = true,
            score_offset = 10
        },
             

      spell = {
        --enabled = function()
                -- Disable LSP source in LaTeX reference contexts to avoid duplicates with VimTeX
                --if vim.bo.filetype == 'tex' then
                --local line = vim.api.nvim_get_current_line()
                --local col = vim.api.nvim_win_get_cursor(0)[2]
                --local before_cursor = line:sub(1, col)
                
                -- Disable in reference contexts only (keep for citations and general editing)
                --if before_cursor:match('\\ref{[^}]*$') or
                    --before_cursor:match('\\[Cc]ref{[^}]*$') or
                    --before_cursor:match('\\eqref{[^}]*$') or
                    --before_cursor:match('\\subfile{[^}]*$') or
                    --before_cursor:match('\\autoref{[^}]*$') then
                    --return false
                --end
                --end
                --return true
            --end,
        enabled = false,
        name = 'Spell',
        module = 'blink-cmp-spell',
        opts = {},
        score_offset = 8
      },
      path = {
          enabled = true,
          name = "Path",
          module = "blink.cmp.sources.path",
          score_offset = 11,
          -- When typing a path, I would get snippets and text in the
          -- suggestions, I want those to show only if there are no path
          -- suggestions
          fallbacks = { "snippets", "buffer" },
          -- min_keyword_length = 2,
        },
      lsp = {
        --enabled = function()
                -- Disable LSP source in LaTeX reference contexts to avoid duplicates with VimTeX
                --if vim.bo.filetype == 'tex' then
                --local line = vim.api.nvim_get_current_line()
                --local col = vim.api.nvim_win_get_cursor(0)[2]
                --local before_cursor = line:sub(1, col)
                
                -- Disable in reference contexts only (keep for citations and general editing)
                --if before_cursor:match('\\subfile{[^}]*$') then
                    --return false
                --end
                --end
                --return true
            --end,
          enabled = true,
          name = "Lsp",
          module = "blink.cmp.sources.lsp",
          score_offset = 10,
        },
      buffer = {
          enabled = false,
          name = "Buffer",
          module = "blink.cmp.sources.buffer",
          score_offset = 4,
        },
    },
  },

  completion = {
    accept = {auto_brackets = { enabled = false }},
    menu = {
      max_height = 3,
      auto_show = true,
      draw = {
        treesitter = { "lsp" },
        columns = { 
          { 'kind_icon' }, 
          { 'label' } 
        },
        components = {
          kind_icon = {
            text = function(ctx) return ' ' .. ctx.kind_icon .. ' ' end,
            highlight = function(ctx) 
              return { { group = ctx.kind_hl, priority = 20 } } 
            end
          },
        },
      },
    },

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 1000,
      treesitter_highlighting = true,
    },
    ghost_text = {
      enabled = false,
    },
  },

  fuzzy = {
    implementation = "rust",
    sorts = {  
      'score',
      'exact'
    }
  },
})

-- Surround Setup
require("nvim-surround").setup({})

-- Telescope Setup
require('telescope').setup{
extensions = {
    bibtex = {
      citation_format = "plain",
      format = "plain",
      backend = "biber",
      include_bib_files_in_preview = true,
    }
  }
}
require('telescope').load_extension('bibtex')
require("telescope").load_extension("file_browser")

-- SNIPE

local ok, snipe = pcall(require, "snipe")
if not ok then
  return
end

local function filename_no_ext(buf)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf.id), ":t")
  local name_no_ext = name:match("(.+)%..+$") or name
  return name_no_ext
end

local function root_folder_name(buf)
  -- :p (full path) -> :h (head/directory) -> :t (tail/folder name)
  local root = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf.id), ":p:h:t")
  return (root ~= "" and root ~= ".") and root or ""
end

local function buffer_modified(buf)
  if vim.api.nvim_buf_is_valid(buf.id) and vim.api.nvim_buf_is_loaded(buf.id) then
    if vim.bo[buf.id].modified then
      return "●"
    end
  end
  return ""
end

local function buffer_filetype(buf)
  if vim.api.nvim_buf_is_valid(buf.id) and vim.api.nvim_buf_is_loaded(buf.id) then
    local ft = vim.bo[buf.id].filetype
    return (ft ~= "" and ft or "noft")
  end
  return "noft"
end

snipe.setup({
  ui = {
    position = "center",
    open_win_override = {
        title = " Buffers ",
        border = "rounded"
    },
    buffer_format = {
      ">",             -- Optional tag marker
      "    ",
      buffer_modified,
      "   ",
      root_folder_name, 
      "/",             -- Separator for visual clarity
      filename_no_ext,
      "    ",
      "icon",          -- Filetype icon
      " ",
      buffer_filetype,
    },
    text_align = "file-first",
  },
  navigate = {
    leader = "\\",
    cancel_snipe = "<esc>",
    leader_map = {
      ["d"] = function (m, i) require("snipe").close_buf(m, i) end,
      ["v"] = function (m, i) require("snipe").open_vsplit(m, i) end,
      ["h"] = function (m, i) require("snipe").open_split(m, i) end,
    },
   },
})

-- -- Snipe setup
-- local ok, snipe = pcall(require, "snipe")
-- if not ok then
--   return
-- end
--
-- local function filename_no_ext(buf)
--   local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf.id), ":t")
--   local name_no_ext = name:match("(.+)%..+$") or name
--   return name_no_ext
-- end
--
-- local function buffer_modified(buf)
--   if vim.api.nvim_buf_is_valid(buf.id) and vim.api.nvim_buf_is_loaded(buf.id) then
--     if vim.bo[buf.id].modified then
--       return "●"
--     end
--   end
--   return ""
-- end
--
-- local function buffer_filetype(buf)
--   if vim.api.nvim_buf_is_valid(buf.id) and vim.api.nvim_buf_is_loaded(buf.id) then
--     local ft = vim.bo[buf.id].filetype
--     return (ft ~= "" and ft or "noft")
--   end
--   return "noft"
-- end
--
-- snipe.setup({
--   ui = {
--     position = "center",
--     open_win_override = {
--         title = " Buffers ",
--     	border = "rounded"
--     },
--     buffer_format = {
-- 	  ">",         -- Optional tag marker
-- 	  "    ",
-- 	  buffer_modified,
-- 	  "   ",
-- 	  filename_no_ext,
-- 	  "   ",
-- 	  "icon",       -- Filetype icon
-- 	  " ",
-- 	  buffer_filetype,
--     },
--     text_align = "file-first",
--   },
--   navigate = {
--     -- Specifies the "leader" key
--     -- This allows you to select a buffer but defer the action.
--     -- NOTE: this does not override your actual leader key!
--     leader = "\\",
--     cancel_snipe = "<esc>",
--
--     -- Leader map defines keys that follow a selection prefixed by the
--     -- leader key. For example (with tag "a"):
--     -- ,ad -> run leader_map["d"](m, i)
--     -- NOTE: the leader_map cannot specify multi character bindings.
--     leader_map = {
--       ["d"] = function (m, i) require("snipe").close_buf(m, i) end,
--       ["v"] = function (m, i) require("snipe").open_vsplit(m, i) end,
--       ["h"] = function (m, i) require("snipe").open_split(m, i) end,
--     },
--    },
-- })


-- Snipe-Spell

require("snipe-spell").setup()

-- Alpha nvim dashboard
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Save the original values of the options
local original_laststatus = vim.o.laststatus
local original_showtabline = vim.o.showtabline

-- 1. On AlphaReady: Hide statusline
vim.api.nvim_create_autocmd("User", {
  pattern = "AlphaReady",
  group = vim.api.nvim_create_augroup("Alpha_UI_Hide", { clear = true }),
  callback = function()
    -- Hide the statusline (0: never, 1: only if split, 2: always)
    vim.opt.laststatus = 0
  end,
})

-- 2. On BufUnload (when leaving the alpha buffer): Restore original values
-- BufUnload fires when the buffer is closed, which happens when you open a file
vim.api.nvim_create_autocmd("BufUnload", {
  -- The Alpha buffer is usually buffer #1 (or 0 depending on the setup)
  -- The check below ensures we only run the restore when leaving the alpha buffer.
  -- You can check the buffer number when alpha is open with `:echo bufnr()`
  buffer = 1, -- Change this number if your alpha buffer is different
  group = vim.api.nvim_create_augroup("Alpha_UI_Restore", { clear = true }),
  callback = function()
    -- Restore the original statusline setting
    vim.opt.laststatus = original_laststatus
    
  end,
})

dashboard.section.header.val = {
  "                                                    █           ",
  "          █                                        █            ",
  "           █    █                                  █            ",
  "        █  █                             █    █   ██  █        ",
  "        ██ █     █            ██        ██   █    ██ █         ",
  "         ███   ██          ██ ██ █     ████ ███   ████         ",
  "          ███  ███████████████████    █████████   ████         ",
  "          ███  ██  ██   ███ ██████   ███ ██ ███  █████         ",
  "          ████ ███ ██   ███  ██ ██   ██  ██ ████ ████          ",
  "          ██ █  █  ████ ██   ██ ███ ███  ██ ██████ ██ █        ",
  "         ███ █████ ██   ███  ██  ██ ██   ██ ██ ███ ███         ",
  "          ██  ███  ██ █████ ███  █████   ██ ██  █  ██          ",
  "          ██   █████████ █████    ████  ███████    ███         ",
  "         ███   ███         █      ███       ███    ███         ",
  "        █████    █████                    ██      █████        ",
  "       ██    █      ████                 █       ██   ██       ",
  "       █      ██                               ██      █       ",
  "       █                                     █         █       ",
  "        █                                             █        ",

}

-- Buttons menu (example shortcuts)
dashboard.section.buttons.val = {
  dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
  dashboard.button("r", "󰥔  Recent Files", ":Telescope oldfiles<CR>"),
  dashboard.button("b", "  Browse Files", ":Telescope file_browser<CR>"),
}

alpha.setup(dashboard.config)

-- Enable auto-commands for indent and tab settings in specific filetypes
vim.cmd [[
  augroup vimrc_autocmds
  autocmd!
  autocmd FileType lua,vim,sh,latex setlocal tabstop=2 shiftwidth=2 expandtab
  augroup END
]]


