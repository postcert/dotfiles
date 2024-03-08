;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
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

(setq user-full-name "postcert"
      user-email-address "postcert@gmail.com")

(setq projectile-project-search-path '("~/projects/"))
(setq my/org-directory "~/Dropbox/personal/org/")
(setq my/dropbox "~/Dropbox/personal/")

;; theme
(use-package! doom-themes
  :config
  (load-theme 'catppuccin t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(setq catppuccin-flavor 'frappe) ;; or 'latte, 'macchiato, or 'mocha
(catppuccin-reload)

(setq
 doom-font (font-spec :family "Hack Nerd Font Mono" :size 14)
 doom-variable-pitch-font (font-spec :family "Hack Nerd Font"))

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

(use-package window-stool
  :config
  (add-hook 'prog-mode-hook #'window-stool-mode))

;; Flashes cursor on buffer/window/etc change
;; (beacon-mode 1)

;; line numbers
(setq display-line-numbers-type t)

(custom-set-faces
 '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight bold :family "variable-pitch"))))
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.7))))
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.6))))
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.5))))
 '(markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.4))))
 '(markdown-header-face-5 ((t (:inherit markdown-header-face :height 1.3))))
 '(markdown-header-face-6 ((t (:inherit markdown-header-face :height 1.2)))))

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(setq auto-save-visited-mode t)
(auto-save-visited-mode +1)

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(setq org-directory my/org-directory)
(after! org
  (setq org-agenda-files (directory-files-recursively my/org-directory "\\.org$")
        ;; No *'s around bold or /'s for italics
        org-hide-emphasis-markers t
        ;; show sub and superscript
        org-pretty-entities t
        org-log-done 'time
        org-log-into-drawer t))
(add-hook! org-mode :append #'org-appear-mode)

;; Persist clocks and history
(after! org-clock
  (setq org-clock-persist t)
  (org-clock-persistence-insinuate))

;; Org-habit
(use-package! org-habit
  :after org
  :config
  (setq
        org-habit-following-days 5
        org-habit-preceding-days 35
        org-habit-show-habits t
        org-habit-show-habits-only-for-today t))

;; Org-media-note
(use-package! org-media-note
  :hook (org-mode .  org-media-note-mode)
  ;; :bind (
         ;; (:map org-mode ("m-v" . org-media-note-hydra/body)))  ;; Main entrance
  :config
  (setq org-media-note-screenshot-image-dir "~/Notes/imgs/")  ;; Folder to save screenshot
)
(map! :after org-media-note
      :localleader
      (:map org-mode-map
        :desc "org-media-note"
            "w" #'org-media-note-hydra/body))
;; (define-advice mpv-get-property (:around (oldfn &rest arg) ignore-errors) "Do not warn me \\='get_property property unavailable.\\='." (ignore-errors (apply oldfn arg)))

(setq org-journal-dir (concat my/org-directory "journal/")
      org-journal-file-type 'monthly
      org-journal-file-header
      "#+title: %B, %Y\n#+category: journal\n\n"
      ;; org-journal-time-format "%I %p"
      org-journal-date-format "%A %d"
      org-journal-file-format "%m-%y.org")

(after! org-roam
  (setq org-roam-directory (concat my/org-directory "org_roam")))

;; No confirm on exit
(setq confirm-kill-emacs nil)
