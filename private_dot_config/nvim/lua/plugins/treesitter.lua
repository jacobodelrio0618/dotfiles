return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure the highlight table exists
      opts.highlight = opts.highlight or {}

      -- Disable treesitter highlighting for LaTeX/Tex
      if type(opts.highlight.disable) == "table" then
        vim.list_extend(opts.highlight.disable, { "latex", "tex" })
      else
        opts.highlight.disable = { "latex", "tex" }
      end
    end,
  },
}
