return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    -- [Your existing init code for statusline loading...]
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end

    -- VIMTEX STATUS LOGIC
    _G.vimtex_compile_status_icon = " " -- Default idle icon

    local group = vim.api.nvim_create_augroup("VimtexStatus", { clear = true })

    vim.api.nvim_create_autocmd("User", {
      pattern = { "VimtexEventCompileStarted", "VimtexEventCompiling" },
      group = group,
      callback = function()
        _G.vimtex_compile_status_icon = " "
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "VimtexEventCompileSuccess",
      group = group,
      callback = function()
        _G.vimtex_compile_status_icon = " "
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "VimtexEventCompileFailed",
      group = group,
      callback = function()
        _G.vimtex_compile_status_icon = " "
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "VimtexEventCompileStopped",
      group = group,
      callback = function()
        _G.vimtex_compile_status_icon = " "
      end,
    })
  end,

  opts = function()
    local icons = LazyVim.config.icons
    vim.o.laststatus = vim.g.lualine_laststatus

    return {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return str:sub(1, 1)
            end,
          },
        },
        lualine_b = {},
        lualine_c = {
          LazyVim.lualine.root_dir(),
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { LazyVim.lualine.pretty_path() },
        },
        lualine_x = {
          -- ADDED VIMTEX STATUS HERE
          {
            function()
              return _G.vimtex_compile_status_icon
            end,
            color = { fg = "#888888" },
          },

          Snacks.profiler.status(),
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = function()
              return { fg = Snacks.util.color("Statement") }
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {},
      },
    }
  end,
}
