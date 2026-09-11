return {
  "nvim-mini/mini.pairs",
  event = "VeryLazy",
  opts = {
    modes = { insert = true, command = true, terminal = false },
    -- Removed %' and %$ from the skip list
    skip_next = [=[[%w%%[%_%"%.%`]]=],
    skip_ts = { "string" },
    skip_unbalanced = true,
    markdown = true,

    -- Just define the pair simply here
    mappings = {
      ["$"] = { action = "closeopen", pair = "$$" },
    },
  },
}
