;;; init.el --- Emacs Writing Studio init -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Peter Prevos

;; Author: Peter Prevos <peter@prevos.net>
;; Maintainer: Peter Prevos <peter@prevos.net>

;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; Emacs Writing Studio init file
;; https://lucidmanager.org/tags/emacs
;;
;; This init file is tangled from the Org mode source:
;; documents/ews-book/99-appendix.org
;;
;;; Code:

;; Emacs 29? EWS leverages functionality from the latest Emacs version.

(when (< emacs-major-version 29)
  (error "Emacs Writing Studio requires Emacs version 29 or later"))

;; Custom settings in a separate file and load the custom settings

(setq-default custom-file (expand-file-name "custom.el" user-emacs-directory))

(when (file-exists-p custom-file)
  (load custom-file))

(keymap-global-set "C-c w v" 'customise-variable)

;; Set package archives

(use-package package
  :config
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/"))
  (package-initialize))

;; Package Management

(use-package use-package
  :custom
  (use-package-always-ensure t)
  (package-native-compile t)
  (warning-minimum-level :emergency))

;; Load EWS functions

(load-file (concat (file-name-as-directory user-emacs-directory) "ews.el"))

;; Check for missing external software
;;
;; - soffice (LibreOffice): View and create office documents
;; - zip: Unpack ePub documents
;; - pdftotext (poppler-utils): Convert PDF to text
;; - ddjvu (DjVuLibre): View DjVu files
;; - curl: Reading RSS feeds
;; - convert (ImageMagick) or gm (GraphicsMagick): Convert image files 
;; - latex (TexLive, MacTex or MikTeX): Preview LaTex and export Org to PDF
;; - hunspell: Spellcheck. Also requires a hunspell dictionary
;; - grep: Search inside files
;; - gs (GhostScript) or mutool (MuPDF): View PDF files
;; - mpg321, ogg123 (vorbis-tools), mplayer, mpv, vlc: Media players
;; - git: Version control

(ews-missing-executables
 '("soffice"
   "zip"
   "pdftotext"
   "ddjvu"
   "curl"
   ("convert" "gm")
   "latex"
   "hunspell"
   "grep"
   ("gs" "mutool")
   ("mpg321" "ogg123" "mplayer" "mpv" "vlc")
   "git"))

;;; LOOK AND FEEL

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Short answers only please

(setq use-short-answers t)

;; Spacious padding

(use-package spacious-padding
  :custom
  (line-spacing 3)
  :init
  (spacious-padding-mode 1))

;; Modus Themes

(use-package modus-themes
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts t)
  (modus-themes-to-toggle
   '(modus-operandi-tinted modus-vivendi-tinted))
  :init
  (load-theme 'modus-vivendi-tinted :no-confirm)
  :bind
  (("C-c w t t" . modus-themes-toggle)
   ("C-c w t m" . modus-themes-select)
   ("C-c w t s" . consult-theme)))

;; Mixed-pich mode

(use-package mixed-pitch
  :hook
  (text-mode . mixed-pitch-mode))

;; Window management
;; Split windows sensibly

(setq split-width-threshold 120
      split-height-threshold nil)

;; Keep window sizes balanced

(use-package balanced-windows
  :config
  (balanced-windows-mode))

;; MINIBUFFER COMPLETION

;; Enable vertico

(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-sort-function 'vertico-sort-history-alpha))

;; Persist history over Emacs restarts.

(use-package savehist
  :init
  (savehist-mode))

;; Search for partial matches in any order

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion)))))

;; Enable richer annotations using the Marginalia package

(use-package marginalia
  :init
  (marginalia-mode))

;; Improve keyboard shortcut discoverability

(use-package which-key
  :config
  (which-key-mode)
  :custom
  (which-key-max-description-length 40)
  (which-key-lighter nil)
  (which-key-sort-order 'which-key-description-order))

;; Improved help buffers

(use-package helpful
  :bind
  (("C-h f" . helpful-function)
   ("C-h x" . helpful-command)
   ("C-h k" . helpful-key)
   ("C-h v" . helpful-variable)))

;;; Text mode settings

(use-package text-mode
  :ensure
  nil
  :hook
  (text-mode . visual-line-mode)
  :init
  (delete-selection-mode t)
  :custom
  (sentence-end-double-space nil)
  (scroll-error-top-bottom t)
  (save-interprogram-paste-before-kill t))

;; Check spelling with flyspell and hunspell

(use-package flyspell
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary ews-hunspell-dictionaries)
  (flyspell-mark-duplications-flag nil) ;; Writegood mode does this
  (org-fold-core-style 'overlays) ;; Fix Org mode bug
  :config
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic ews-hunspell-dictionaries)
  :hook
  (text-mode . flyspell-mode)
  :bind
  (("C-c w s s" . ispell)
   ("C-;"       . flyspell-auto-correct-previous-word)))

;;; Ricing Org mode

(use-package org
  :custom
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(450))
  (org-fold-catch-invisible-edits 'error)
  (org-pretty-entities t)
  (org-use-sub-superscripts "{}")
  (org-id-link-to-org-use-id t)
  (org-fold-catch-invisible-edits 'show))

;; Show hidden emphasis markers

(use-package org-appear
  :hook
  (org-mode . org-appear-mode))

;; LaTeX previews

(use-package org-fragtog
  :after org
  :hook
  (org-mode . org-fragtog-mode)
  :custom
  (org-startup-with-latex-preview nil)
  (org-format-latex-options
   (plist-put org-format-latex-options :scale 2)
   (plist-put org-format-latex-options :foreground 'auto)
   (plist-put org-format-latex-options :background 'auto)))

;; Org modern: Most features are disabled for beginning users

(use-package org-modern
  :hook
  (org-mode . org-modern-mode)
  :custom
  (org-modern-table nil)
  (org-modern-keyword nil)
  (org-modern-timestamp nil)
  (org-modern-priority nil)
  (org-modern-checkbox nil)
  (org-modern-tag nil)
  (org-modern-block-name nil)
  (org-modern-keyword nil)
  (org-modern-footnote nil)
  (org-modern-internal-target nil)
  (org-modern-radio-target nil)
  (org-modern-statistics nil)
  (org-modern-progress nil))

;; Consult convenience functions

(use-package consult
  :bind
  (("C-c w h" . consult-org-heading)
   ("C-c w g" . consult-grep)))

;; INSPIRATION

;; Doc-View

(use-package doc-view
  :custom
  (doc-view-resolution 300)
  (large-file-warning-threshold (* 50 (expt 2 20))))

;; Read ePub files

(use-package nov
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

;; Reading LibreOffice files

;; Fixing a bug in Org Mode pre-9.7
;; Org mode clobbers associations with office documents

(use-package ox-odt
  :ensure nil
  :config
  (add-to-list 'auto-mode-alist
               '("\\.\\(?:OD[CFIGPST]\\|od[cfigpst]\\)\\'"
                 . doc-view-mode-maybe)))

;; Managing Bibliographies

(use-package bibtex
  :custom
  (bibtex-user-optional-fields
   '(("keywords" "Keywords to describe the entry" "")
     ("file"     "Relative or absolute path to attachments" "" )))
  (bibtex-align-at-equal-sign t)
  :config
  (ews-bibtex-register)
  :bind
  (("C-c w b r" . ews-bibtex-register)))

;; Biblio package for adding BibTeX records

(use-package biblio
  :bind
  (("C-c w b b" . ews-bibtex-biblio-lookup)))

;; Citar to access bibliographies

(use-package citar
  :defer t
  :custom
  (citar-bibliography ews-bibtex-files)
  :bind
  (("C-c w b o" . citar-open)))

;; Read RSS feeds with Elfeed

(use-package elfeed
  :custom
  (elfeed-db-directory
   (expand-file-name "elfeed" user-emacs-directory))
  (elfeed-show-entry-switch 'display-buffer)
  :bind
  ("C-c w e" . elfeed))

;; Configure Elfeed with org mode

(use-package elfeed-org
  :config
  (elfeed-org)
  :custom
  (rmh-elfeed-org-files
   (list (concat (file-name-as-directory (getenv "HOME")) "elfeed.org"))))

;; Easy insertion of weblinks

(use-package org-web-tools
  :bind
  (("C-c w w" . org-web-tools-insert-link-for-url)))

;; Emacs Multimedia System

(use-package emms
  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (emms-all)
  (emms-default-players)
  (emms-mpris-enable)
  :custom
  (emms-browser-covers #'emms-browser-cache-thumbnail-async)
  :bind
  (("C-c w m b" . emms-browser)
   ("C-c w m e" . emms)
   ("C-c w m p" . emms-play-playlist )
   ("<XF86AudioPrev>" . emms-previous)
   ("<XF86AudioNext>" . emms-next)
   ("<XF86AudioPlay>" . emms-pause)))

(use-package openwith
  :config
  (openwith-mode t)
  :custom
  (openwith-associations nil))

; Fleeting notes

;; (use-package org
;;   :bind
;;   (("C-c c" . org-capture)
;;    ("C-c l" . org-store-link))
;;   :custom
;;   (org-goto-interface 'outline-path-completion)
;;   (org-capture-templates
;;    '(("f" "Fleeting note"
;;       item
;;       (file+headline org-default-notes-file "Notes")
;;       "- %?")
;;      ("p" "Permanent note" plain
;;       (file denote-last-path)
;;       #'denote-org-capture
;;       :no-save t
;;       :immediate-finish nil
;;       :kill-buffer t
;;       :jump-to-captured t)
;;      ("t" "New task" entry
;;       (file+headline org-default-notes-file "Tasks")
;;       "* TODO %i%?"))))


(use-package org
  :bind
  (("C-c c" . org-capture)
   ("C-c l" . org-store-link))
  :custom
  (org-goto-interface 'outline-path-completion)
  (org-capture-templates
   '(
     ("e" "Current file log entry" entry (file+olp+datetree buffer-file-name)
      "* %? \n%u")
     ("F" "Fleeting note"
      entry
      (file+headline "~/Documents/org/gtd.org" "Notes")
      "* %?\nCaptured on %U\n")
     ("p" "Permanent note" plain
      (file denote-last-path)
      #'denote-org-capture
      :no-save t
      :immediate-finish nil
      :kill-buffer t
      :jump-to-captured t)
     ("w" "Review: Weekly Review" entry (file+olp+datetree "~/Documents/org/reviews.org")
      (file "~/Documents/org/tpl-review.txt")
      :after-finalize (lambda () (find-file "~/Documents/org/reviews.org"))
      )
     ("p" "Protocol" entry (file+headline "~/Documents/org/gtd.org" "5_Inbox")
      "* TODO %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
     ("L" "Protocol Link" entry (file+headline "~/Documents/org/gtd.org" "5_Inbox")
      "* TODO %? \n[[%:link][%:description]] \nCaptured On: %U")
     ("t" "todo" entry (file+headline "~/Documents/org/gtd.org" "5_Inbox")
      "* TODO  %?\n \n%a\n")
     )))


;; Denote

(use-package denote
  :defer t
  :custom
  (denote-sort-keywords t)
  :hook
  (dired-mode . denote-dired-mode)
  :custom-face
  (denote-faces-link ((t (:slant italic))))
  :init
  (require 'denote-org-extras)
  :bind
  (("C-c w d b" . denote-find-backlink)
   ("C-c w d d" . denote-date)
   ("C-c w d f" . denote-find-link)
   ("C-c w d h" . denote-org-extras-link-to-heading)
   ("C-c w d i" . denote-link-or-create)
   ("C-c w d k" . denote-rename-file-keywords)
   ("C-c w d l" . denote-insert-link)
   ("C-c w d n" . denote)
   ("C-c w d r" . denote-rename-file)
   ("C-c w d R" . denote-rename-file-using-front-matter)))

;; Consult-Notes for easy access to notes

(use-package consult-notes
  :bind
  (("C-c w f"   . consult-notes)
   ("C-c w d g" . consult-notes-search-in-all-notes))
  :init
  (consult-notes-denote-mode))

;; Citar-Denote to manage literature notes

(use-package citar-denote
  :custom
  (citar-open-always-create-notes t)
  :init
  (citar-denote-mode)
  :bind
  (("C-c w b c" . citar-create-note)
   ("C-c w b n" . citar-denote-open-note)
   ("C-c w b x" . citar-denote-nocite)
   :map org-mode-map
   ("C-c w b k" . citar-denote-add-citekey)
   ("C-c w b K" . citar-denote-remove-citekey)
   ("C-c w b d" . citar-denote-dwim)
   ("C-c w b e" . citar-denote-open-reference-entry)))

;; Explore and manage your Denote collection

(use-package denote-explore
  :bind
  (;; Statistics
   ("C-c w x c" . denote-explore-count-notes)
   ("C-c w x C" . denote-explore-count-keywords)
   ("C-c w x b" . denote-explore-barchart-keywords)
   ("C-c w x e" . denote-explore-barchart-filetypes)
   ;; Random walks
   ("C-c w x r" . denote-explore-random-note)
   ("C-c w x l" . denote-explore-random-link)
   ("C-c w x k" . denote-explore-random-keyword)
   ("C-c w x x" . denote-explore-random-regex)
   ;; Denote Janitor
   ("C-c w x d" . denote-explore-identify-duplicate-notes)
   ("C-c w x z" . denote-explore-zero-keywords)
   ("C-c w x s" . denote-explore-single-keywords)
   ("C-c w x o" . denote-explore-sort-keywords)
   ("C-c w x w" . denote-explore-rename-keyword)
   ;; Visualise denote
   ("C-c w x n" . denote-explore-network)
   ("C-c w x v" . denote-explore-network-regenerate)
   ("C-c w x D" . denote-explore-degree-barchart)))

;; Set some Org mode shortcuts

(use-package org
  :bind
  (:map org-mode-map
        ("C-c w n" . ews-org-insert-notes-drawer)
        ("C-c w p" . ews-org-insert-screenshot)
        ("C-c w c" . ews-org-count-words)))

;; Distraction-free writing

(use-package olivetti
  :demand t
  :bind
  (("C-c w o" . ews-olivetti)))

;; Undo Tree

(use-package undo-tree
  :config
  (global-undo-tree-mode)
  :custom
  (undo-tree-auto-save-history nil)
  :bind
  (("C-c w u" . undo-tree-visualise)))

;; Export citations with Org Mode

(require 'oc-natbib)
(require 'oc-csl)

(setq org-cite-global-bibliography ews-bibtex-files
      org-cite-insert-processor 'citar
      org-cite-follow-processor 'citar
      org-cite-activate-processor 'citar)

;; Lookup words in the online dictionary

(use-package dictionary
  :custom
  (dictionary-server "dict.org")
  :bind
  (("C-c w s d" . dictionary-lookup-definition)))

(use-package powerthesaurus
  :bind
  (("C-c w s p" . powerthesaurus-transient)))

;; Writegood-Mode for weasel words, passive writing and repeated word detection

(use-package writegood-mode
  :bind
  (("C-c w s r" . writegood-reading-ease)
   ("C-c w s l" . writegood-grade-level))
  :hook
  (text-mode . writegood-mode))

;; Titlecasing

(use-package titlecase
  :custom
  (titlecase-style 'apa)
  :bind
  (("C-c w s t" . titlecase-dwim)
   ("C-c w s c" . ews-org-headings-titlecase)))

;; Abbreviations

(add-hook 'text-mode-hook 'abbrev-mode)

;; Lorem Ipsum generator

(use-package lorem-ipsum
  :custom
  (lorem-ipsum-list-bullet "- ") ;; Org mode bullets
  :init
  (setq lorem-ipsum-sentence-separator
        (if sentence-end-double-space "  " " "))
  :bind
  (("C-c w s i" . lorem-ipsum-insert-paragraphs)))

;; ediff

(use-package ediff
  :ensure nil
  :custom
  (ediff-keep-variants nil)
  (ediff-split-window-function 'split-window-horizontally)
  (ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package fountain-mode)

(use-package markdown-mode)

;; Generic Org Export Settings

(use-package org
  :custom
  (org-export-with-drawers nil)
  (org-export-with-todo-keywords nil)
  (org-export-with-broken-links t)
  (org-export-with-toc nil)
  (org-export-with-smart-quotes t)
  (org-export-date-timestamp-format "%e %B %Y"))

;; epub export

(use-package ox-epub
  :demand t
  :init
  (require 'ox-org))

;; LaTeX PDF Export settings

(use-package ox-latex
  :ensure nil
  :demand t
  :custom
  ;; Multiple LaTeX passes for bibliographies
  (org-latex-pdf-process
   '("pdflatex -interaction nonstopmode -output-directory %o %f"
     "bibtex %b"
     "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
     "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
  ;; Clean temporary files after export
  (org-latex-logfiles-extensions
   (quote ("lof" "lot" "tex~" "aux" "idx" "log" "out"
           "toc" "nav" "snm" "vrb" "dvi" "fdb_latexmk"
           "blg" "brf" "fls" "entoc" "ps" "spl" "bbl"
           "tex" "bcf"))))

;; EWS paperback configuration

(with-eval-after-load 'ox-latex
  (add-to-list
   'org-latex-classes
   '("ews"
     "\\documentclass[11pt, twoside]{memoir}
      \\setstocksize{9.25in}{7.5in}
      \\settrimmedsize{\\stockheight}{\\stockwidth}{*}
      \\setlrmarginsandblock{2cm}{1cm}{*} 
      \\setulmarginsandblock{1.5cm}{2.25cm}{*}
      \\checkandfixthelayout
      \\setcounter{tocdepth}{0}
      \\OnehalfSpacing
      \\usepackage{ebgaramond}
      \\usepackage[htt]{hyphenat}
      \\chapterstyle{bianchi}
      \\setsecheadstyle{\\normalfont \\raggedright \\textbf}
      \\setsubsecheadstyle{\\normalfont \\raggedright \\textbf}
      \\setsubsubsecheadstyle{\\normalfont\\centering}
      \\usepackage[font={small, it}]{caption}
      \\pagestyle{myheadings}
      \\usepackage{ccicons}
      \\usepackage[authoryear]{natbib}
      \\bibliographystyle{apalike}
      \\usepackage{svg}"
     ("\\chapter{%s}" . "\\chapter*{%s}")
     ("\\section{%s}" . "\\section*{%s}")
     ("\\subsection{%s}" . "\\subsection*{%s}")
     ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

;;; ADMINISTRATION

;; Bind org agenda command and custom agenda
(use-package org
  :custom
  (org-agenda-custom-commands
   '(
     ("e" "Agenda, next actions and waiting"
      ((agenda "" ((org-agenda-overriding-header "Next three days:")
                   (org-agenda-span 3)
                   (org-agenda-start-on-weekday nil)))
       (todo "NEXT" ((org-agenda-overriding-header "Next Actions:")))
       (todo "WAIT" ((org-agenda-overriding-header "Waiting:")))))

     ("d" "Events" agenda "display deadlines and exclude scheduled" (
								     (org-agenda-span 'week)
								     (org-agenda-time-grid nil)
								     (org-agenda-show-all-dates nil)
								     (org-agenda-entry-types '(:deadline)) ;; this entry excludes :scheduled
								     (org-deadline-warning-days 0) ))

     (  "c" "Completed by week"
	agenda ""
	((org-agenda-span 'week)
	 (org-agenda-start-on-weekday 1)
	 (org-agenda-start-with-log-mode t)
	 (org-agenda-skip-function
          '(org-agenda-skip-entry-if 'nottodo 'done))
	 ))

     ("w" "Events" agenda "display week" (
					;                                                                (org-agenda-span 'week)
					;                                                                (org-agenda-time-grid nil)
                                          (org-agenda-show-all-dates nil)
                                          (tags "week")
                                          (org-deadline-warning-days 0) ))
     ("N" . "Next granular")
     ("Nb" tags-todo "+TODO=\"NEXT\"+boo")
     ("Nc" tags-todo "+TODO=\"NEXT\"+cou")
     ("Nd" tags-todo "+TODO=\"NEXT\"+dev")
     ("Ne" tags-todo "+TODO=\"NEXT\"+emacs")
     ("Ng" tags-todo "+TODO=\"NEXT\"+gra")
     ("Nh" tags-todo "+TODO=\"NEXT\"+human")
     ("Np" tags-todo "+TODO=\"NEXT\"+pap")
     ("NP" tags-todo "+TODO=\"NEXT\"+pro")
     ("Ns" tags-todo "+TODO=\"NEXT\"+ser")
     ("Nt" tags-todo "+TODO=\"NEXT\"+adv")
     
     )
   )
  :bind
  (("C-c a" . org-agenda)))

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
        (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))



;; (use-package org
;;   :custom
;;   (org-agenda-custom-commands
;;    '(("e" "Agenda, next actions and waiting"
;;       ((agenda "" ((org-agenda-overriding-header "Next three days:")
;;                    (org-agenda-span 3)
;;                    (org-agenda-start-on-weekday nil)))
;;        (todo "NEXT" ((org-agenda-overriding-header "Next Actions:")))
;;        (todo "WAIT" ((org-agenda-overriding-header "Waiting:")))))


;;      ))
;;   :bind
;;   (("C-c a" . org-agenda)))

;; FILE MANAGEMENT

(use-package dired
  :ensure
  nil
  :commands
  (dired dired-jump)
  :custom
  (dired-listing-switches
   "-goah --group-directories-first --time-style=long-iso")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  :init
  (put 'dired-find-alternate-file 'disabled nil))

;; Hide hidden files

(use-package dired
  :ensure nil
  :hook (dired-mode . dired-omit-mode)
  :bind (:map dired-mode-map
              ( "."     . dired-omit-mode))
  :custom (dired-omit-files "^\\.[a-zA-Z0-9]+"))

;; Backup files

(setq-default backup-directory-alist
              `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
              version-control t
              delete-old-versions t
              create-lockfiles nil)

;; Recent files

(use-package recentf
  :config
  (recentf-mode t)
  :custom
  (recentf-max-saved-items 50)
  :bind
  (("C-c w r" . recentf-open)))

;; Bookmarks

(use-package bookmark
  :custom
  (bookmark-save-flag 1)
  :bind
  ("C-x r d" . bookmark-delete))

;; Image viewer

(use-package emacs
  :custom
  (image-dired-external-viewer "gimp")
  :bind
  ((:map image-mode-map
         ("k" . image-kill-buffer)
         ("<right>" . image-next-file)
         ("<left>"  . image-previous-file))
   (:map dired-mode-map
         ("C-<return>" . image-dired-dired-display-external))))

(use-package image-dired
  :bind
  (("C-c w I" . image-dired))
  (:map image-dired-thumbnail-mode-map
        ("C-<right>" . image-dired-display-next)
        ("C-<left>"  . image-dired-display-previous)))

;; ADVANCED UNDOCUMENTED EXPORT SETTINGS FOR EWS

;; Use GraphViz for flow diagrams
;; requires GraphViz software
(org-babel-do-load-languages
 'org-babel-load-languages
 '((dot . t))) ; this line activates GraophViz dot


;; SJR Customizations

;;; fixing
;;; insert-directory: Listing directory failed but ‘access-file’ worked
(when (eq system-type 'darwin)
 (setq insert-directory-program "/opt/homebrew/bin/gls"))

;org
(setq org-refile-targets  '((org-agenda-files :maxlevel . 5))
         )
(setq org-log-done 'time)

;; (use-package org-bullets
;;   :ensure t
;;   :config
;;   (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq org-agenda-files
      '("~/Documents/org/tasks/books.org"
        "~/Documents/org/tasks/cogs.org"
        "~/Documents/org/tasks/development.org"
	"~/Documents/org/tasks/emacs.org"
        "~/Documents/org/tasks/family.org"
        "~/Documents/org/tasks/grants.org"
        "~/Documents/org/tasks/manuscripts.org"
        "~/Documents/org/tasks/proposals.org"
        "~/Documents/org/tasks/reviews.org"
        "~/Documents/org/tasks/reyos.org"
        "~/Documents/org/tasks/service.org"
        "~/Documents/org/tasks/talks.org"
        "~/Documents/org/tasks/teaching.org"
        "~/Documents/org/habits.org"
        ))


;hydras
(use-package hydra
  :defer t)
(defhydra hydra-jump-to-project-vertical (:hint nil)
 "
  ^
    ^Projects
    ^─────────-----
    _b_ books
    _c_ cogs
    _d_ development
    _e_ emacs
    _f_ family
    _g_ grants
    _l_ teaching
    _m_ manuscripts
    _o_ reyos
    _p_ proposals
    _r_ reviews
    _s_ service
    _t_ talks

    _q_ quit
    ^────────-----
    "
  ("b" (find-file "/home/serge/Documents/org/tasks/books.org"))
  ("c" (find-file "/home/serge/Documents/org/tasks/cogs.org"))
  ("d" (find-file "/home/serge/Documents/org/tasks/development.org"))
  ("e" (find-file "/home/serge/Documents/org/tasks/emacs.org"))
  ("f" (find-file "/home/serge/Documents/org/tasks/family.org"))
  ("g" (find-file "/home/serge/Documents/org/tasks/grants.org"))
  ("l" (find-file "/home/serge/Documents/org/tasks/teaching.org"))
  ("m" (find-file "/home/serge/Documents/org/tasks/manuscripts.org"))
  ("o" (find-file "/home/serge/Documents/org/tasks/reyos.org"))
  ("p" (find-file "/home/serge/Documents/org/tasks/proposals.org"))
  ("r" (find-file "/home/serge/Documents/org/tasks/reviews.org"))
  ("s" (find-file "/home/serge/Documents/org/tasks/service.org"))
  ("t" (find-file "/home/serge/Documents/org/tasks/talks.org"))

  ("q" nil :color blue)) ; Add :color blue

(global-set-key (kbd "C-c 1") 'hydra-jump-to-project-vertical/body)



; spelling
; Set Hunspell as the spell checker program
(setq ispell-program-name "hunspell")

;; Set the default dictionary to en_US
(setq ispell-dictionary "en_US")

; Set the personal dictionary to use the en_US files in ~/Library/Spelling
(setq ispell-personal-dictionary "~/Library/Spelling/en_US")

; dired listing dot files
; (setq insert-directory-program "/opt/homebrew/bin/gls")  ;; Adjust path if needed
(setq dired-listing-switches "-alh")

; backup
(setq backup-directory-alist
        `(("." . ,(concat user-emacs-directory "backups"))))

;; yasnippet

(require 'yasnippet)
(yas-global-mode 1) ; Enable yasnippet in all buffers
(use-package yasnippet
  :config
  ;; my python-mode snippets will be in ~/.emacs/snippets/python-mode
  (add-to-list 'yas-snippet-dirs (expand-file-name "~/.emacs.d/etc/yasnippet/snippets"))

   :requires yasnippet)
(add-hook 'emacs-startup-hook (lambda () (yas-load-directory "/home/serge/.emacs.d/etc/yasnippet/snippets")))

;; org-download
(require 'org-download)

;; Drag-and-drop to `dired`
(add-hook 'dired-mode-hook 'org-download-enable)


;; dictionary
;https://irreal.org/blog/?p=10824
(setq dictionary-server "dict.org")

;; denote

(setq denote-directory (expand-file-name "~/Documents/notes/"))

;; magit

(use-package magit
    :commands magit-status
    :custom
    (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

  ;; NOTE: Make sure to configure a GitHub token before using this package!
  ;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
  ;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
  (use-package forge
    :after magit)
(remove-hook 'server-switch-hook 'magit-commit-diff)
(remove-hook 'with-editor-filter-visit-hook 'magit-commit-diff)

;; attempting to speed things up https://magit.vc/manual/magit/Performance.html
(setq magit-refresh-status-buffer nil)


(setq auto-revert-buffer-list-filter
      'magit-auto-revert-repository-buffer-p)

;; orderless
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; silence is golden
(setq ring-bell-function 'ignore)


;; projectile
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

;; python
;; https://www.youtube.com/watch?v=SbTzIt6rISg
(use-package python
  :ensure t
  :hook ((python-ts-mode . eglot-ensure)
	 (python-ts-mode . company-mode))
  :mode (("\\.py\\'" . python-ts-mode))
  )

;; (use-package python
;;    :bind (:map python-ts-mode-map
;;                ("<f5>" . recompile)
;;                ("<f6>" . eglot-format)
;; 	       ("<f7>" . py-isort-buffer))
;;    :hook ((python-ts-mode . eglot-ensure)
;;           (python-ts-mode . company-mode))
;;    :mode (("\\.py\\'" . python-ts-mode)))

;; (add-hook 'python-ts-mode-hook
;;           (lambda ()
;;             (add-hook 'before-save-hook
;;                       (lambda ()
;;                         (when (eglot-managed-p)
;;                           (eglot-format-buffer)))
;;                       nil t)
;;             (add-hook 'before-save-hook
;;                       (lambda ()
;;                         (when (derived-mode-p 'python-ts-mode)
;;                           (python-isort-buffer)))
;;                       nil t)))



  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

  (use-package conda
    :ensure t
    :config
    (setq conda-env-home-directory
          (expand-file-name "~/mambaforge")))

  (use-package highlight-indent-guides
    :ensure t
    :hook (python-ts-mode . highlight-indent-guides-mode)
    :config
    (set-face-foreground 'highlight-indent-guides-character-face "white")
    (setq highlight-indent-guides-method 'character))

  (setenv "PATH" (concat (getenv "PATH") ":/home/serge/mambaforge/bin"))
  (add-to-list 'exec-path "/home/serge/mambaforge/bin")

(setq python-shell-interpreter "ipython")

;; company
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))


;; global key bindings
(global-set-key (kbd "M-s M-b") #'consult-buffer)
