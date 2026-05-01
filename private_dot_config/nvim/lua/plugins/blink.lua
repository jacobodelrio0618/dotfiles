return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      -- 1. This tells blink which sources to try
      default = { "lsp", "path", "snippets" },

      -- 2. This explicitly disables the buffer provider logic
      providers = {
        buffer = { enabled = false },
      },
    },
    completion = {
      ghost_text = { enabled = false },
    },
    -- Keep your luasnip setting as is
    snippets = { preset = "luasnip" },
  },
}
