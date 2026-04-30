return {
  "L3MON4D3/LuaSnip",
  opts = {
    history = true,
    delete_check_events = "TextChanged",
    enable_autosnippets = true,
  },
  config = function(_, opts)
    require("luasnip").setup(opts)
    require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/lua/snippets" } })
  end,
}
