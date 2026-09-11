return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      theme = "wave", -- The darkest version
      background = { dark = "wave" },
      colors = {
        theme = {
          all = {
            ui = { bg_gutter = "none" },
          },
        },
      },
      overrides = function(colors)
        return {
          ["Normal"] = { bg = "#000000" },
          ["NormalFloat"] = { bg = "#000000" },
          ["FloatBorder"] = { bg = "#000000" },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "kanagawa-wave" },
  },
}
