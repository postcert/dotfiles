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

(after! ws-butler
  (setq ws-butler-trim-predicate
      (lambda (beg end)
        (let* ((current-line (line-number-at-pos))
               (beg-line (line-number-at-pos beg))
               (end-line (line-number-at-pos end))
               ;; Assuming the use of evil-mode for insert mode detection. Adjust if using a different system.
               (in-insert-mode (and (bound-and-true-p evil-mode)
                                    (eq 'insert evil-state))))
          ;; Return true (allow trimming) unless in insert mode and the current line is within the region.
          (not (and in-insert-mode
                    (>= current-line beg-line)
                    (<= current-line end-line))))))
)

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

;; to enable reset_check_boxes
(add-to-list 'org-modules 'org-checklist)

;; Persist clocks and history
(after! org-clock
  (setq org-clock-persist t)
  (org-clock-persistence-insinuate))

;; Org-habit
(use-package! org-habit
  :after org
  :config
  (setq
        org-habit-following-days 1
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

(defvar my/org-moods-with-descriptions
  '(("None" . "No specific mood or prefer not to say.")
    ("Happy" . "Feeling or showing pleasure or contentment.")
    ("Joyful" . "Experiencing, causing, or showing joy; happy.")
    ("Grateful" . "Feeling or showing an appreciation for something done or received.")
    ("Optimistic" . "Hopeful and confident about the future.")
    ("Excited" . "Very enthusiastic and eager.")
    ("Energized" . "Give vitality and enthusiasm to.")
    ("Refreshed" . "Give new strength or energy to; reinvigorate.")
    ("Content" . "In a state of peaceful happiness.")
    ("Calm" . "Not showing or feeling nervousness, anger, or other strong emotions.")
    ("Relaxed" . "Free from tension and anxiety; at ease.")
    ("Peaceful" . "Free from disturbance; tranquil.")
    ("Tranquil" . "Free from disturbance; calm.")
    ("Hopeful" . "Feeling or inspiring optimism about a future event.")
    ("Interested" . "Showing curiosity or concern about something or someone; having a feeling of interest.")
    ("Curious" . "Eager to know or learn something.")
    ("Amused" . "Find something funny or entertaining.")
    ("Mischievous" . "Causing or showing a fondness for causing trouble in a playful way.")
    ("Reflective" . "Relating to or characterized by deep thought; thoughtful.")
    ("Sleepy" . "Needing or ready for sleep.")
    ("Tired" . "Drained of strength and energy; fatigued often to the point of exhaustion.")
    ("Exhausted" . "Drained of one's physical or mental resources; very tired.")
    ("Frustrated" . "Feeling or expressing distress and annoyance resulting from an inability to change or achieve something.")
    ("Worried" . "Anxious or troubled about actual or potential problems.")
    ("Anxious" . "Experiencing worry, unease, or nervousness.")
    ("Confused" . "Unable to think clearly; bewildered.")
    ("Irritated" . "Showing or feeling slight anger; annoyed.")
    ("Angry" . "Feeling or showing strong annoyance, displeasure, or hostility.")
    ("Lonely" . "Sad because one has no friends or company.")
    ("Disappointed" . "Sad or displeased because someone or something has failed to fulfill one's hopes or expectations.")
    ("Gloomy" . "Dark or poorly lit, especially so as to appear depressing or frightening.")
    ("Sad" . "Feeling or showing sorrow; unhappy.")
    ("Rejected" . "Dismissed as inadequate, inappropriate, or not to one's taste."))
  "Association list of moods and their descriptions for marginalia annotations.")

(defun my/marginalia-annotate-mood (cand)
  (when-let ((desc (cdr (assoc cand my/org-moods-with-descriptions))))
    (concat (propertize " " 'display '(space :align-to 20))
            (propertize desc 'face 'marginalia-documentation))))

(after! marginalia
  ;; Example of adding a prompt category mapping
  (add-to-list 'marginalia-prompt-categories '("Select mood: " . mood))
  (add-to-list 'marginalia-annotator-registry
               '(mood my/marginalia-annotate-mood marginalia-annotate-variable builtin none)))

(defun my/org-set-mood-property ()
  "Set a predefined 'MOOD' property under the current Org mode heading."
  (interactive)
  (if (eq major-mode 'org-mode)
      (let* ((moods (mapcar #'car my/org-moods-with-descriptions))
             (selected-mood (completing-read "Select mood: " moods nil nil)))
        (org-entry-put nil "MOOD" selected-mood))
    (message "You are not in an Org mode buffer.")))

(defun my/org-journal-mood-then-insert-mode ()
  "Switch to insert mode after creating a journal entry and setting mood."
  (my/org-set-mood-property) ;; Set the mood first.
  (evil-insert 1)) ;; Then switch to insert mode.

(after! org-journal
  (add-hook 'org-journal-after-entry-create-hook 'my/org-journal-mood-then-insert-mode))

(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq
   ;; org-agenda-skip-scehduled-if-done t
   ;; org-agenda-skip-deadline-if-done t
   org-agenda-include-deadlines t
   org-agenda-block-separator nil
   org-agenda-compact-blocks t
   org-agenda-start-day nil
   org-agenda-show-future-repeats nil
   org-agenda-time-grid '((daily today require-timed remove-match)
                        (600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000)
                        " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"))
   (setq org-super-agenda-groups '(
                        (:name "Today"
                         :time-grid t
                         :scheduled today)
                        (:name "Life"
                         :tag "life")
                        (:name "Chores"
                         :todo "Today"
                         :tag "chore")
                        (:name "Due today"
                         :deadline today)
                        (:name "Important"
                         :priority "A")
                        (:name "Overdue"
                         :deadline past)
                        (:name "Due soon"
                         :deadline future)
                        (:name "Habits"
                         :tag "habit")
                             ))
  :config
  (org-super-agenda-mode))

(after! (org-super-agenda evil-org-agenda)
   (setq org-super-agenda-header-map evil-org-agenda-mode-map)) ;; https://github.com/alphapapa/org-super-agenda/issues/50

(defun my/org-tab-conditional ()
  (interactive)
  (if (yas-active-snippets)
      (yas-next-field-or-maybe-expand)
    (org-cycle)))

(map! :after evil-org
      :map evil-org-mode-map
      :i "<tab>" #'my/org-tab-conditional)
;; (with-eval-after-load 'org
;;   (define-key evil-org-mode-map (kbd "<tab>") #'my/org-tab-conditional))

(after! org-roam
  (setq org-roam-directory (concat my/dropbox "org_roam")))

(after! org
  (require 'ace-window) ;; Ensure ace-window is loaded

  (defun my/open-link-or-footnote-in-selected-window ()
  "Open the Org link or footnote at point in a window selected with ace-window or split if only one window."
  (interactive)
  (let ((element (org-element-context))
        (link))
    ;; Determine if the element is a link or a footnote and get its path or link
    (cond ((eq (org-element-type element) 'link)
           (setq link (org-element-property :raw-link element)))
          ((eq (org-element-type element) 'footnote-reference)
           (let ((def (org-footnote-get-definition (org-element-property :label element))))
             (setq link (concat "file:" (buffer-file-name))
                   ;; Optionally, adjust this part to handle the footnote text or definition as needed
                   ))))

    ;; If only one window is visible, split it before selecting
    (when (eq (length (window-list)) 1)
      (split-window-right) ;; Or `split-window-below` to split horizontally
      (other-window 1))

    ;; Now select the window using ace-window, which will include the newly split window if applicable
    (when link
      (aw-select "Select window for opening link"
                 (lambda (window)
                   (when (window-live-p window)
                     (select-window window)
                     (if (string-prefix-p "file:" link)
                         (find-file (substring link 5))
                       (org-open-link-from-string link))))))))

  (defun my/org-at-footnote-p ()
  "Check if the point is at an Org footnote."
  (interactive)
  (let ((el (org-element-context)))
    (or (eq (org-element-type el) 'footnote-reference)
        (eq (org-element-type el) 'footnote-definition))))

  (defun my/org-shift-return-open-ace-window ()
  "Perform context-specific actions on Shift+Return in org-mode.
- In tables, execute `org-table-copy-down`.
- On links or footnotes, open them in a selected window."
  (interactive)
  (cond ((org-at-table-p)
         (call-interactively 'org-table-copy-down))
        ((or (org-in-regexp org-bracket-link-regexp 1)
             (org-in-regexp org-link-plain-re 1)
             (my/org-at-footnote-p))
         (my/open-link-or-footnote-in-selected-window))
        (t (message "Shift+Enter does not apply here."))))
)

(map! :after org
      (:map org-mode-map
        :desc "Open link or footnote in the a different window"
            "S-<return>" 'my/org-shift-return-open-ace-window))

;; No confirm on exit
(setq confirm-kill-emacs nil)
