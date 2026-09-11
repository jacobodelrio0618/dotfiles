return {
  "nvim-mini/mini.surround",
  opts = {
    -- Custom surroundings for LaTeX commands
    custom_surroundings = {
      -- (e) emphasized: \emph{text}
      ["e"] = { output = { left = "\\emph{", right = "}" } },
      -- (i) italic: \textit{text}
      ["i"] = { output = { left = "\\textit{", right = "}" } },
      -- (q) blockquote: \begin{quote} text \end{quote}
      ["q"] = { output = { left = "\\bsq{", right = "}" } },
      -- ($) standard math: $text$
      ["$"] = { output = { left = "$", right = "$" } },
      -- (m) LaTeX inline math: \(text\)
      ["m"] = { output = { left = "\\(", right = "\\)" } },

      -- Fix for parentheses: Force '(' to be tight (no spaces)
      ["("] = { output = { left = "(", right = ")" } },
    },
  },
}
