return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- Add the filetypes you previously had in your prettier.setup
      tex = { "prettier" },
      latex = { "prettier" },
      plaintex = { "prettier" },
      -- LazyVim already handles JS/TS/JSON/CSS via its prettier extra
    },
    formatters = {
      prettier = {
        -- This ensures the latex plugin is loaded
        -- prepend_args = { "--plugin", "prettier-plugin-latex" },
      },
    },
  },
}
