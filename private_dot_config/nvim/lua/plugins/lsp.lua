-- return {
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       diagnostics = {
--         -- This overrides the 'virtual_text' block in the default config
--         virtual_text = {
--           prefix = "●",
--           source = false,
--           format = function()
--             return ""
--           end, -- This keeps the icon but hides the message text
--         },
--         -- If you want to try 'virtual_lines' (under the line), set this to true
--         virtual_lines = false,
--         underline = true,
--       },
--     },
--   },
-- }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = {
          prefix = "●",
          source = false,
          format = function()
            return ""
          end,
        },
        virtual_lines = false,
        underline = true,
      },

      servers = {
        texlab = {
          on_attach = function(client)
            client.server_capabilities.inlayHintProvider = false
          end,
        },
      },
    },
  },
}
