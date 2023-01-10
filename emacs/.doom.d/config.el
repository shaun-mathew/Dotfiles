;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

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
(setq org-directory "~/Org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


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

(setq deft-directory "~/Org"
      def-extensions '("org","txt","md")
      deft-recursive t)

(defun cm/deft-parse-title (file contents)
"Parse the given FILE and CONTENTS and determine the title. If `deft-use-filename-as-title' is nil, the title is taken to be the first non-empty line of the FILE.  Else the base name of the FILE is used as title." (let ((begin (string-match "^#\\+[tT][iI][tT][lL][eE]: .*$" contents))) (if begin (string-trim (substring contents begin (match-end 0)) "#\\+[tT][iI][tT][lL][eE]: *" "[\n\t ]+")
(deft-base-filename file))))

(advice-add 'deft-parse-title :override #'cm/deft-parse-title)

(setq deft-strip-summary-regexp
(concat "\\("
        "[\n\t]" ;; blank
        "\\|^#\\+[[:alpha:]_]+:.*$" ;; org-mode metadata
        "\\|^:PROPERTIES:\n\\(.+\n\\)+:END:\n"
        "\\)"))


(setq org-directory "~/Org")
;;(setq org-roam-directory "~/Org")
;(org-roam-db-autosync-mode)

(after! org
(require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-startup-with-latex-preview t)
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-skip-scheduled-if-deadline-is-shown 'repeated-after-deadline)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))
  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Org/Agenda.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Org/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Org/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("n", "Notes/Ideas")
      ("nn" "Note" entry
           (file+olp+datetree "~/Org/FlashNotes.org", "Notes")
           "* %<%I:%M %p> - :notes:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("ni" "Idea" entry
           (file+olp+datetree "~/Org/FlashNotes.org", "Ideas")
           "* %<%I:%M %p> - :ideas:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ;; ("w" "Workflows")
      ;; ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
      ;;      "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/Org/Metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)
        ;(1 - No issue 2 - Solved, but slowly 3 - Figured out solution, but not code 4 - Kind of figured out solution, but not code 5 - No Idea)
      ("ml" "LeetCode" table-line (file+headline "~/Org/Metrics.org" "LeetCode")
       "| %U | %^{Problem Number} | %^{Trouble \(1 - No issue 2 - Solved, but slowly 3 - Figured out solution, but not code 4 - Kind of figured out solution, but not code 5 - No Idea\)} | %^{Notes} |" :kill-buffer t)
      ("md" "Water" table-line (file+headline "~/Org/Metrics.org" "Water")
       "| %U | %^{Number of Cups} | " :kill-buffer t)
      ("ms" "Supplements" table-line (file+headline "~/Org/Metrics.org" "Supplements")
       "| %U | %^{Supplement Name} |  %^{Dosage} | %^{Notes} |" :kill-buffer t)
      ("mm" "Stress" table-line (file+headline "~/Org/Metrics.org" "Stress")
       "| %U | %^{Notes} |" :kill-buffer t)

      ("mp" "Russian Pullups" table-line (file+headline "~/Org/Metrics.org" "Russian Pullups")
       "| %U | %^{Routine} | %^{Notes} |" :kill-buffer t)
      )
    )


      ;; ("mr" "Russian Pullups" table-line (file+headline "~/Org/Metrics.org" "Russian Pullups")
      ;;  "| %U | %^{Current Routine} | %^{Notes} |" :kill-buffer t))
  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Agenda.org" :maxlevel . 1)))

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?I)))
  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-agenda-files
	'("~/Org/Agenda.org"
	  "~/Org/Habits.org"
	  ))
  )

(use-package! org-fragtog
:after org
:hook (org-mode . org-fragtog-mode) ; this auto-enables it when you enter an org-buffer, remove if you do not want this
:config
;; whatever you want
)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((typescript . t)
))
