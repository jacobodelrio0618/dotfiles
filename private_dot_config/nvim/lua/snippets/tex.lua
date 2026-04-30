local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep
local in_math = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

return {

  s("\\1", { t("{"), i(1), t("}"), i(0) }),
  s("\\2", { t("["), i(1), t("]"), i(0) }),
  s("\\3", { t("("), i(1), t(")"), i(0) }),
  s("\\m", { t("$"), i(1), t("$"), i(0) }),
  s("\\i", { t("\\textit{"), i(1), t("}"), i(0) }),
  s("\\e", { t("\\emph{"), i(1), t("}"), i(0) }),
  s("\\q", { t("\\bsq{"), i(1), t("}"), i(0) }),

  -- Environments
  s("\\qe", {
    t({ "%", "" }), -- 1) Comment sign and 2) New line
    t("\\begin{bsqenv}"), -- Start of environment
    t({ "", "  " }), -- New line and 2 spaces of indentation
    i(1), -- 3) First tabstop (content)
    t({ "", "\\end{bsqenv}" }), -- New line and end of environment
    i(2), -- 3) Tabstop right beside the closing bracket
    t(" % "), -- 4) Space and comment sign
    t({ "", "" }), -- 5) New line
    i(0), -- Final position to keep typing
  }),

  s("\\bq", {
    t({ "\\begin{bqenv}", "" }), -- 1) Comment signs + 2) New line & start
    t("[{{\\autocite["), -- Start of autocite
    i(2), -- Tabstop 2: Page/Postnote
    t("]{"), -- Separator
    i(1), -- Tabstop 1: Citation Key
    t("}}}]%"), -- Closing brackets + Comment
    t({ "", "  " }), -- New line + 4 spaces indent (or 2, as preferred)
    i(3), -- Tabstop 3: Content
    t({ "", "\\end{bqenv}" }), -- End of environment
    i(0), -- Tabstop 0: Beside closing bracket
    t(" %"), -- Comment sign
  }),

  s("\\tq", {
    t({ "%", "\\begin{textqenv}", "  " }), -- 1) Comment + Start + 2 spaces indent
    i(1), -- Tabstop 1: Environment content
    t({ "", "\\end{textqenv}" }), -- End of environment
    i(2), -- Tabstop 2: Right beside the bracket
    t(" %"), -- Space and comment sign
    t({ "", "%", "" }), -- 5) New line with comment + Final new line
    i(0), -- Tabstop 0: Where you keep typing
  }),
  -- BibLaTeX and quotes

  s("\\b1", {
    t({ "", "%", "\\blockquote[{\\autocite[" }),
    i(2),
    t("]{"),
    i(1),
    t("}}]%"),
    t({ "", "{" }),
    i(3),
    t({ "}.", "%", "" }),
    i(0),
  }),

  s("\\ac", {
    t({ " %", "\\autocite[" }),
    i(2),
    t("]{"),
    i(1),
    t("}"),
    i(3),
    t({ "%", "" }),
    i(0),
  }),

  s("\\cfr", {
    t({ " %", "\\autocite[" }),
    i(1),
    t("]["),
    i(3),
    t("]{"),
    i(2),
    t("}"),
    i(4),
    t({ "%", "" }),
    i(0),
  }),

  s("\\ip", {
    t("\\InitPerson"),
    i(3),
    t("{"),
    i(1),
    t("}{"),
    i(2),
    t("}"),
    i(0),
  }),

  s("\\p", {
    t("\\Person{"),
    i(1),
    t("}"),
    i(0),
  }),

  s("latin", {
    t("\\textlatin{\\textit{"),
    i(1),
    t("}}"),
    i(0),
  }),

  s("greek", {
    t("\\textgreek{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Subfile Snippet

  s("subfile", {
    t({
      "\\documentclass[../main.tex]{subfiles}%",
      "\\ifSubfilesClassLoaded{\\addbibresource{../bibliography.bib}}{}",
      "",
      "\\begin{document}",
      "",
      "",
    }),
    i(0),
    t({
      "",
      "",
      "\\end{document}",
    }),
  }),

  -- Beamer Snippets
  s("\\f", {
    t({ "", "\\begin{frame}" }),
    i(1), -- Title position
    t({ "", "\t" }),
    i(2), -- Content position
    t({ "", "\\end{frame}", "" }),
    i(0), -- Final exit point after the frame
  }),

  s("\\fb", {
    t("\\begin{block}"),
    i(1), -- First position: Block Title
    t({ "", "\t" }),
    i(2), -- Second (and final) position: Block Content
    t({ "", "\\end{block}" }),
  }),

  -- Logic - Fitch Proof
  s("fitch", {
    t({ "", "\\begin{align*}", "$\\begin{nd}" }),
    t({ "", "    " }),
    i(0),
    t({ "", "\\end{nd}$", "\\end{align*}" }),
  }),

  s("h", {
    t("\\hypo{"),
    i(1, "Label"),
    t("}{"),
    i(2, "Formula"),
    t("}"),
    i(0),
  }),

  s("j", {
    t("\\have{"),
    i(1, "Label"),
    t("}{"),
    i(2, "Formula"),
    t("}"),
    i(0),
  }),

  s("s", {
    t({ "\\open", "   " }),
    i(0),
    t({ "", "\\close" }),
  }),

  -- Ebproof synthetic
  s("sproof", {
    t({
      "\\begin{prooftree}",
      "    ",
    }),
    i(0),
    t({
      "",
      "\\end{prooftree}",
    }),
  }),

  s("sh", {
    t("\\hypo{"),
    i(1, "Formula"),
    t({ "}%", "" }),
    i(0),
  }),

  s("sj", {
    t("\\infer"),
    i(1, "From"),
    t("[$"),
    i(2, "Rule"),
    t("$]{"),
    i(3, "Formula"),
    t({ "}%", "" }),
    i(0),
  }),

  -- Ebproof analytic
  s("aproof", {
    t({
      "\\begin{prooftree}[proof style = downwards]%",
      "    ",
    }),
    i(0),
    t({
      "",
      "\\end{prooftree}",
    }),
  }),

  s("aj", {
    i(0),
    t({ "", "\\hypo{\\begin{gathered} " }),
    i(1, "Formula"),
    t({ " \\\\", "    " }),
    i(2, "Status"),
    t({ "", "\\end{gathered}}%" }),
  }),

  s("ah", {
    i(0),
    t({ "", "\\infer" }),
    i(1, "Branching"),
    t("[$"),
    i(2, "Rule"),
    t("$]{"),
    i(3, "Formula"),
    t("}%"),
  }),

  -- Forest trees
  s("tree", {
    t({ "\\begin{center}", "    \\begin{forest}", "    for tree={l sep=-2pt, l=-2pt, no edge}", "    %" }),
    t({ "    [" }),
    t("$ "),
    i(1, "Formula"),
    t({ " $%" }),
    t({ "    [\\langle " }),
    i(2, "Rule"),
    t({ " \\rangle $" }),
    i(0),
    t({ "]", "    %", "    \\end{forest}", "\\end{center}" }),
  }),

  s("sbranch", {
    t({ "", "    %" }),
    t({ "    [" }),
    t("$ "),
    i(1, "Formula"),
    t({ " $%" }),
    t({ "    [\\langle " }),
    i(2, "Rule"),
    t({ " \\rangle $" }),
    i(0),
    t({ "]" }),
  }),

  s("obranch", {
    t({ "", "%" }),
    t({ "[" }),
    t("$ "),
    i(1, "Formula"),
    t({ " $%" }),
    t({ "[\\langle " }),
    i(2, "Rule"),
    t({ " \\rangle $" }),
    i(0),
    t({ "]" }),
  }),

  s("fbranch", {
    t({ "%" }),
    t({ "[" }),
    t("$ "),
    i(1, "Formula"),
    t({ "]" }),
  }),

  -- Math notations
  s("\\mf", {
    t("\\mathfra\\{"),
    i(1),
    t("}"),
    i(0),
  }),

  s("\\mc", {
    t("\\mathcal{"),
    i(1),
    t("}"),
    i(0),
  }),

  s("\\ms", {
    t("\\mathsf{"),
    i(1),
    t("}"),
    i(0),
  }),

  s("\\s1", {
    t("^{"),
    i(1),
    t("}"),
    i(0),
  }),

  s("\\s2", {
    t("_{"),
    i(1),
    t("}"),
    i(0),
  }),

  s("\\s3", {
    t("^{"),
    i(1),
    t("}_{"),
    i(2),
    t("}"),
    i(0),
  }),

  s("str", {
    t("[\\stac\\rel{"),
    i(1, "x"),
    t("}{_{"),
    i(2, "t"),
    t("}}]"),
    i(0),
  }),

  s("\\tc", {
    t("~|~ "),
  }),

  -- Gree\\ letters and symbols
  s({ trig = "phi", desc = "φ" }, { t("\\phi") }),
  s({ trig = "Phi", desc = "Φ" }, { t("\\Phi") }),
  s({ trig = "varphi", desc = "ϕ" }, { t("\\varphi") }),
  s({ trig = "psi", desc = "ψ" }, { t("\\psi") }),
  s({ trig = "Psi", desc = "Ψ" }, { t("\\Psi") }),
  s({ trig = "chi", desc = "χ" }, { t("\\chi") }),
  s({ trig = "Chi", desc = "Χ" }, { t("\\Chi") }),
  s({ trig = "omega", desc = "ω" }, { t("\\omega") }),
  s({ trig = "Omega", desc = "Ω" }, { t("\\Omega") }),
  s({ trig = "alpha", desc = "α" }, { t("\\alpha") }),
  s({ trig = "Alpha", desc = "Α" }, { t("\\Alpha") }),
  s({ trig = "beta", desc = "β" }, { t("\\beta") }),
  s({ trig = "Beta", desc = "Β" }, { t("\\Beta") }),
  s({ trig = "gamma", desc = "γ" }, { t("\\gamma") }),
  s({ trig = "Gamma", desc = "Γ" }, { t("\\Gamma") }),
  s({ trig = "delta", desc = "δ" }, { t("\\delta") }),
  s({ trig = "Delta", desc = "Δ" }, { t("\\Delta") }),
  s({ trig = "epsilon", desc = "ε" }, { t("\\epsilon") }),
  s({ trig = "Epsilon", desc = "Ε" }, { t("\\Epsilon") }),
  s({ trig = "varepsilon", desc = "ϵ" }, { t("\\varepsilon") }),
  s({ trig = "theta", desc = "θ" }, { t("\\theta") }),
  s({ trig = "Theta", desc = "Θ" }, { t("\\Theta") }),
  s({ trig = "vartheta", desc = "ϑ" }, { t("\\vartheta") }),
  s({ trig = "lambda", desc = "λ" }, { t("\\lambda") }),
  s({ trig = "Lambda", desc = "Λ" }, { t("\\Lambda") }),
  s({ trig = "mu", desc = "μ" }, { t("\\mu") }),
  s({ trig = "Mu", desc = "Μ" }, { t("\\Mu") }),

  s({ trig = "xi", desc = "ξ" }, { t("\\xi") }),
  s({ trig = "Xi", desc = "Ξ" }, { t("\\Xi") }),

  s({ trig = "sigma", desc = "σ" }, { t("\\sigma") }),
  s({ trig = "Sigma", desc = "Σ" }, { t("\\Sigma") }),
  s({ trig = "tau", desc = "τ" }, { t("\\tau") }),
  s({ trig = "Tau", desc = "Τ" }, { t("\\Tau") }),
  s({ trig = "upsilon", desc = "υ" }, { t("\\upsilon") }),
  s({ trig = "Upsilon", desc = "Υ" }, { t("\\Upsilon") }),

  -- Logic symbols
  s({ trig = "land", desc = "∧" }, { t("\\land") }),
  s({ trig = "lor", desc = "∨" }, { t("\\lor") }),
  s({ trig = "lnot", desc = "¬" }, { t("\\lnot") }),
  s({ trig = "to", desc = "→" }, { t("\\to") }),
  s({ trig = "leftrightarrow", desc = "↔" }, { t("\\leftrightarrow") }),
  s({ trig = "equiv", desc = "≡" }, { t("\\equiv") }),
  s({ trig = "models", desc = "⊨" }, { t("\\models") }),
  s({ trig = "dash", desc = "⊧" }, { t("\\vDash") }),
  s({ trig = "sdash", desc = "⊢" }, { t("\\vdash") }),
  s({ trig = "seq", desc = "⇒" }, { t("\\Rightarrow") }),
  s({ trig = "therefore", desc = "∴" }, { t("\\therefore") }),
  s({ trig = "because", desc = "∵" }, { t("\\because") }),

  -- Quantifiers
  s({ trig = "fa", desc = "∀" }, { t("\\fall") }),
  s({ trig = "ex", desc = "∃" }, { t("\\fexists") }),
}, {
  -- AUTOSNIPPETS TABLE
  -- Trigger: ^
  s(
    { trig = "^", wordTrig = false, snippetType = "autosnippet" },
    { t("^{"), i(1), t("}"), i(0) },
    { condition = in_math }
  ),

  -- Trigger: _
  s(
    { trig = "_", wordTrig = false, snippetType = "autosnippet" },
    { t("_{"), i(1), t("}"), i(0) },
    { condition = in_math }
  ),

  -- Trigger: __ (Double underscore for the combined Super/Sub script)
  s(
    { trig = "?", wordTrig = false, snippetType = "autosnippet" },
    { t("^{"), i(1), t("}_{"), i(2), t("}"), i(0) },
    { condition = in_math }
  ),
}
