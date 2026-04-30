return {
  "lervag/vimtex",
  lazy = false, -- VimTeX recommends not lazy-loading
  init = function()
    -- VimTeX configuration goes here
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_quickfix_open_on_warning = 0
  end,
}
