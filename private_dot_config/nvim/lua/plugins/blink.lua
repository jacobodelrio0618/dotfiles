return {
  "saghen/blink.cmp",
  opts = {
    -- Insert-mode completion
    keymap = {
      preset = "none",
      ["<Tab>"] = {},
      ["<S-Tab>"] = {},
    },

    -- Command-line completion
    cmdline = {
      keymap = {
        preset = "none",

        ["<C-J>"] = {},
        ["<C-K>"] = {},
      },

      completion = {
        ghost_text = { enabled = false },
        menu = {
          auto_show = true,
        },

        list = {
          selection = {
            preselect = true,
          },
        },
      },
    },

    sources = {
      default = { "lsp", "path", "snippets" },
      providers = {
        buffer = { enabled = false },
      },
    },

    completion = {
      ghost_text = { enabled = false },
    },

    snippets = {
      preset = "luasnip",
    },
  },
}
