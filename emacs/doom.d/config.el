;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Dhruvin Shah"
      user-mail-address "dhruvin3@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Fix font and icon for treemacs
(setq doom-themes-treemacs-enable-variable-pitch nil
      doom-themes-treemacs-theme "doom-colors")

;; org-jira config
(setq jiralib-url "http://jira.burlington.evertz.tv")
(add-hook! 'org-mode-hook #'org-jira-mode)

;; org tab to cycle through
;; (after! evil-org
;;   (remove-hook 'org-tab-first-hook #'+org-cycle-only-current-subtree-h))


;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(map! :leader
      (:prefix-map ("O" . "org")
       (:prefix-map ("j" . "jira")
        (:prefix-map ("i" . "issue")
         :desc "assign-issue"             "a"  #'org-jira-assign-issue
         :desc "browse-issue"             "b"  #'org-jira-browse-issue
         :desc "create-issue"             "c"  #'org-jira-create-issue
         :desc "issues-by-fixversion"     "f"  #'org-jira-get-issues-by-fixversion
         :desc "get-issues"               "g"  #'org-jira-get-issues
         :desc "headonly"                 "h"  #'org-jira-get-issues-headonly
         :desc "copy-current-issue-key"   "k"  #'org-jira-copy-current-issue-key
         :desc "progress-issue-next"      "n"  #'org-jira-progress-issue-next
         :desc "refresh-issue"            "r"  #'org-jira-refresh-issue
         :desc "update-issue"             "u"  #'org-jira-update-issue
         :desc "progress-issue"           "w"  #'org-jira-progress-issue
         :desc "refresh-issues-in-buffer" "R"  #'org-jira-refresh-issues-in-buffer)
        (:prefix-map ("s" . "subtask")
         :desc "create-subtask"          "c"  #'org-jira-create-subtask
         :desc "get-subtask"             "g"  #'org-jira-get-subtasks)
        (:prefix-map ("c" . "comment")
         :desc "add-comment"             "c"  #'org-jira-add-comment
         :desc "update-comment"          "u"  #'org-jira-update-comment)
        :desc "toggle-mode"              "e"  #'org-jira-mode
        :desc "todo-to-jira"             "t"  #'org-jira-todo-to-jira)))

        ;; (kbd "C-c tj") 'org-jira-todo-to-jira
        ;; (kbd "C-c ij") 'org-jira-get-issues-from-custom-jql
        ;; (kbd "C-c wu") 'org-jira-update-worklogs-from-org-clocks
        ;; (kbd "C-c pg") 'org-jira-get-projects
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auth-source-save-behavior nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
