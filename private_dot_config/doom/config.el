;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; =========================
;; Basic Settings
;; =========================

;; The Theme
(setq doom-theme 'doom-gruvbox)

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

;; force true black background
(custom-set-faces!
  '(default :background "#000000")
  '(hl-line :background "#0a0a0a"))

;; Line Trimming
(setq doom-modeline-buffer-file-name-style 'truncate-with-project)

;; The Font
;; Doom uses specific variables for fonts to ensure they scale correctly
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 14))

;; Aesthetic Tweaks for Single Screen
(setq display-line-numbers-type t) ; Or 'relative if you prefer
(remove-hook 'doom-first-buffer-hook #'global-hl-line-mode) ; Optional: removes the grey line highlight for a "pure" black look

;; Line Numbers
(setq display-line-numbers-type 'relative)

;; Line Breaks
(setq-default fill-column 80)

;; This enables auto-fill-mode (hard breaks) in all text-related buffers
(add-hook 'text-mode-hook #'turn-on-auto-fill)

;; If you also want it for code comments or specific programming modes:
(add-hook 'prog-mode-hook #'turn-on-auto-fill)

;; Math Preview! 1.0 is the default; try 0.8 or 0.7 for a more compact look.
(setq preview-scale-function 0.8)

;; Spell Check (Requires Dependency)
(after! ispell
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "it_IT"))

;; Flyspell Disabled by Default. No Lines Below Words.
(add-hook 'LaTeX-mode-hook
          (lambda ()
            (flyspell-mode -1)))

;; Completion
 (after! corfu
  (setq corfu-auto t
        corfu-auto-delay 0.25
        corfu-auto-prefix 2)
  (map! :i "C-c f" #'cape-file))

;; Optimization
(blink-cursor-mode 0)
(setq-default bidi-display-reordering nil)

;; =========================
;; LaTeX & Zathura SyncTeX
;; =========================

(after! latex
  (setq TeX-source-correlate-mode t
        TeX-source-correlate-method 'synctex
        TeX-source-correlate-start-server t
        TeX-command-default "LatexMk"
        TeX-electric-sub-and-superscript t
        TeX-fold-mode nil
        )

  (add-to-list 'TeX-view-program-list
               '("Zathura"
                 ("zathura %o"
                  (mode-io-correlate " --synctex-forward %n:0:\"%b\""))
                 "zathura"))

  (setq TeX-view-program-selection '((output-pdf "Zathura"))))

;; Math-modify from "'" to "\", better for Italian.
(after! cdlatex
  ;; Update the variables for internal logic
  (setq cdlatex-math-modify-prefix ?\\)

  ;; Manually map the backslash to the math triggers
  (map! :map cdlatex-mode-map
        :i "\\" #'cdlatex-math-modify
        :i "'"  nil)
  (define-key cdlatex-mode-map "'" nil))

;; Smart <tab> key
(defun my-latex-tab-handler ()
  "Smart Tab: expand → yas field → cdlatex → completion → indent."
  (interactive)
  (cond

   ;; Try expanding a snippet
   ((and (bound-and-true-p yas-minor-mode)
         (yas-expand)))

   ;; If inside an active yasnippet field → jump to next field
   ((and (bound-and-true-p yas-minor-mode)
         (yas--snippets-at-point))
    (yas-next-field))

   ;; Cdlatex handling
   ((bound-and-true-p cdlatex-mode)
    (cdlatex-tab))

   ;; Fallback
   (t
    (indent-for-tab-command))))

(map! :map cdlatex-mode-map
    :i "<tab>" #'my-latex-tab-handler)
(map! :i "<backtab>" #'indent-for-tab-command)

;; =========================
;; Citar Bibliography
;; =========================

(after! citar
  ;; The upward search logic
  (defun my/set-citar-bib-upwards ()
    "Search upwards for bibliography.bib and set it locally."
    (let ((bib-path (locate-dominating-file default-directory "bibliography.bib")))
      (if bib-path
          (setq-local citar-bibliography (list (expand-file-name "bibliography.bib" bib-path)))
        (message "Citar: bibliography.bib not found in parent folders"))))

  ;; The hook to apply the bib path
  (add-hook 'TeX-mode-hook
            (lambda ()
              (my/set-citar-bib-upwards))))

;; =========================
;; Snippets (Only Custom)
;; =========================

(after! yasnippet
  (setq yas-snippet-dirs
        (list (expand-file-name "~/.config/doom/snippets")))
  (yas-reload-all)
  (yas-minor-mode -1)
  (yas-minor-mode +1)
  )

;; =========================
;; Prettier Formatting
;; =========================

(use-package! prettier-js
  :hook ((latex-mode . prettier-js-mode)
         (LaTeX-mode . prettier-js-mode))
  :config
  (setq prettier-js-command "prettier")

  (let ((plugin-file (expand-file-name "~/.npm-global/lib/node_modules/prettier-plugin-latex/dist/prettier-plugin-latex.js")))
    (setq prettier-js-args (list "--plugin" plugin-file)))

  ;; Define a "Quiet" version of the command
  (defun my/prettier-latex-format ()
    "Format the current buffer and show a clean message."
    (interactive)
    (message "Prettier: Formatting...")
    (prettier-js)
    (message "Prettier: Applied!"))

  ;; Bind F9 to our new quiet function
  (map! "<f9>" #'my/prettier-latex-format))
