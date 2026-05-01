return {
  "snacks.nvim",
  opts = {
    indent = {
      enabled = true,
      blank = true,
    },
    scope = {
      enabled = true, -- Keeps the "active" highlight you want
      -- This is the specific fix: it tells the scope NOT to bridge
      -- across lines that are completely empty.
      treesitter = { enabled = false },
    },
  },
}
