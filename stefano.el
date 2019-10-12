(setq user-full-name "Stefano Picchiotti"
      user-mail-address "stefano.picchiotti@gmail.com")

(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(setq load-prefer-newer t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(use-package async
  :init
  (autoload 'dired-async-mode "dired-async.el" nil t)
  (dired-async-mode 1)
  (async-bytecomp-package-mode 1)
  (autoload 'dired-async-mode "dired-async.el" nil t)
  (async-bytecomp-package-mode 1)
  (dired-async-mode 1)
  (require 'smtpmail-async)
  (setq send-mail-function 'async-smtpmail-send-it))

(use-package paradox
  :config
  (setq paradox-execute-asynchronously t))

(defun is-mac-p
    ()
  (eq system-type 'darwin))

(defun is-linux-p
    ()
  (eq system-type 'gnu/linux))

(defun is-windows-p
    ()
  (or
   (eq system-type 'ms-dos)
   (eq system-type 'windows-nt)
   (eq system-type 'cygwin)))

(defun is-bsd-p
    ()
  (eq system-type 'gnu/kfreebsd))

(defun internet-up-p (&optional host)
  (= 0 (call-process "ping" nil nil nil "-c" "1" "-W" "1"
                     (if host host "www.google.com"))))

(use-package spacemacs-theme
  :load-path "themes"
  :defer t
  :init
  (load-theme 'spacemacs-light t))

(set-default-font "Source Code Pro" nil t)
(set-face-attribute 'default nil :height 100)

(global-prettify-symbols-mode +1)

(setq x-stretch-cursor t)

(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(setq inhibit-startup-message t
      initial-scratch-message ""
      inhibit-startup-echo-area-message t)

(setq-default mode-line-format
              '("%e" ; print error message about full memory.
                mode-line-front-space
                ;; mode-line-mule-info
                ;; mode-line-client
                ;; mode-line-modified
                ;; mode-line-remote
                ;; mode-line-frame-identification
                mode-line-buffer-identification
                "   "
                ;; mode-line-position
                ;; (vc-mode vc-mode)
                ;; "  "
                ;; mode-line-modes
                "   "
                ;; mode-line-misc-info
                ;; battery-mode-line-string
                mode-line-end-spaces))

(setq display-time-format "%a, %b %e %R"
      battery-mode-line-format "%p%%"  ; Default: "[%b%p%%]"
      global-mode-string   (remove 'display-time-string global-mode-string)
      mode-line-end-spaces (list (propertize " "
                                             'display '(space :align-to (- right 17)))
                                 'display-time-string))
(display-time-mode 1)
(display-time-update)

(setq tls-checktrust t
      gnutls-verify-error t)

(setenv "GPG_AGENT_INFO" nil)

(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat user-emacs-directory "backups")))))

(fset 'yes-or-no-p 'y-or-n-p)

(setq confirm-nonexistent-file-or-buffer nil)

(defun create-non-existent-directory ()
  "Check whether a given file's parent directories exist; if they do not, offer to create them."
  (let ((parent-directory (file-name-directory buffer-file-name)))
    (when (and (not (file-exists-p parent-directory))
               (y-or-n-p (format "Directory `%s' does not exist! Create it?" parent-directory)))
      (make-directory parent-directory t))))

(add-to-list 'find-file-not-found-functions #'create-non-existent-directory)

(setq kmacro-ring-max 30)

(setq ediff-window-setup-function 'ediff-setup-windows-plain
      ediff-split-window-function 'split-window-horizontally)

(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'set-goal-column 'disabled nil)

(defadvice upcase-word (before upcase-word-advice activate)
  (unless (looking-back "\\b" nil)
    (backward-word)))

(defadvice downcase-word (before downcase-word-advice activate)
  (unless (looking-back "\\b" nil)
    (backward-word)))

(defadvice capitalize-word (before capitalize-word-advice activate)
  (unless (looking-back "\\b" nil)
    (backward-word)))

(unbind-key "C-x C-l")

(defadvice pop-to-mark-command (around ensure-new-position activate)
  (let ((p (point)))
    (dotimes (i 10)
      (when (= p (point)) ad-do-it))))

(setq set-mark-command-repeat-pop t)

(prefer-coding-system 'utf-8)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)

(setq ring-bell-function 'ignore)

(bind-key "M-/" #'hippie-expand)

(bind-keys ("RET" . newline-and-indent)
           ("C-j" . newline-and-indent))

(setq next-line-add-newlines t)

(defun super-next-line ()
  (interactive)
  (ignore-errors (next-line 5)))

(defun super-previous-line ()
  (interactive)
  (ignore-errors (previous-line 5)))

(defun super-backward-char ()
  (interactive)
  (ignore-errors (backward-char 5)))

(defun super-forward-char ()
  (interactive)
  (ignore-errors (forward-char 5)))

(bind-keys ("C-S-n" . super-next-line)
           ("C-S-p" . super-previous-line)
           ("C-S-b" . super-backward-char)
           ("C-S-f" . super-forward-char))

(bind-keys ("M-1" . delete-other-windows)
           ("M-O" . mode-line-other-buffer))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(bind-key "C-<backspace>" (lambda ()
                            (interactive)
                            (kill-line 0)
                            (indent-according-to-mode)))

(defadvice forward-sentence (around real-forward)
  "Consider a sentence to have one space at the end."
  (let ((sentence-end-double-space nil))
    ad-do-it))

(defadvice backward-sentence (around real-backward)
  "Consider a sentence to have one space at the end."
  (let ((sentence-end-double-space nil))
    ad-do-it))

(defadvice kill-sentence (around real-kill)
  "Consider a sentence to have one space at the end."
  (let ((sentence-end-double-space nil))
    ad-do-it))

(ad-activate 'forward-sentence)
(ad-activate 'backward-sentence)
(ad-activate 'kill-sentence)

(bind-keys ("M-A" . backward-paragraph)
           ("M-E" . forward-paragraph)
           ("M-K" . kill-paragraph))

(bind-key "C-x SPC" 'cycle-spacing)

(defun narrow-or-widen-dwim (p)
  "If the buffer is narrowed, it widens. Otherwise, it narrows
intelligently.  Intelligently means: region, org-src-block,
org-subtree, or defun, whichever applies first.  Narrowing to
org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is already
narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((and (boundp 'org-src-mode) org-src-mode (not p))
         (org-edit-src-exit))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((derived-mode-p 'org-mode)
         (cond ((ignore-errors (org-edit-src-code))
                (delete-other-windows))
               ((org-at-block-p)
                (org-narrow-to-block))
               (t (org-narrow-to-subtree))))
        ((derived-mode-p 'prog-mode) (narrow-to-defun))
        (t (error "Please select a region to narrow to"))))

(eval-after-load 'org-src
  '(bind-key "C-x C-s" 'org-edit-src-exit org-src-mode-map))

(use-package hideshow
  :hook ((prog-mode . hs-minor-mode)))

(defun toggle-fold ()
  (interactive)
  (save-excursion
    (end-of-line)
    (hs-toggle-hiding)))

(defun read-write-toggle ()
  "Toggles read-only in any relevant mode: ag-mode, Dired, or
just any file at all."
  (interactive)
  (if (equal major-mode 'ag-mode)
      ;; wgrep-ag can support ag-mode
      (wgrep-change-to-wgrep-mode)
    ;; dired-toggle-read-only has its own conditional:
    ;; if the mode is Dired, it will make the directory writable
    ;; if it is not, it will just toggle read only, as desired
    (dired-toggle-read-only)))

(bind-keys :prefix-map toggle-map
           :prefix "C-x t"
           ("d" . toggle-debug-on-error)
           ("f" . toggle-fold)
           ("l" . linum-mode)
           ("n" . narrow-or-widen-dwim)
           ("o" . org-mode)
           ("r" . read-write-toggle)
           ("t" . text-mode)
           ("w" . whitespace-mode))

(defun scratch ()
    (interactive)
    (switch-to-buffer-other-window (get-buffer-create "*scratch*")))

(defun make-org-scratch ()
  (interactive)
  (find-file "~/org/scratch.org"))

(bind-keys :prefix-map launcher-map
           :prefix "C-x l"
           ("A" . ansi-term) ;; save "a" for open-agenda
           ("c" . calc)
           ("C" . calendar)
           ("d" . ediff-buffers)
           ("e" . eshell)
           ("E" . eww)
           ("h" . man)
           ("l" . paradox-list-packages)
           ("u" . paradox-upgrade-packages)
           ("p l" . paradox-list-packages)
           ("p u" . paradox-upgrade-packages)
           ("P" . proced)
           ("s" . scratch)
           ("S" . make-org-scratch))

(when (is-linux-p)
  (bind-keys :map launcher-map
             ("." . counsel-linux-app)))

(when (is-mac-p)
  (use-package counsel-osx-app
    :bind (:map launcher-map
                ("." . counsel-osx-app))))

(use-package counsel-osx-app)

(bind-keys :prefix-map macro-map
           :prefix "C-c m"
           ("a" . kmacro-add-counter)
           ("b" . kmacro-bind-to-key)
           ("e" . kmacro-edit-macro)
           ("i" . kmacro-insert-counter)
           ("I" . insert-kbd-macro)
           ("K" . kmacro-end-or-call-macro-repeat)
           ("n" . kmacro-cycle-ring-next)
           ("N" . kmacro-name-last-macro)
           ("p" . kmacro-cycle-ring-previous)
           ("r" . apply-macro-to-region-lines)
           ("c" . kmacro-set-counter)
           ("s" . kmacro-start-macro)
           ("t" . kmacro-end-or-call-macro))

(when (is-mac-p)
  (setq mac-command-modifier 'meta
        mac-option-modifier 'super
        mac-control-modifier 'control
        ns-function-modifier 'hyper))

(when (is-mac-p)
  (set-face-attribute 'default nil :height 165))

(use-package eshell
  :bind (("<f1>" . eshell))
  :hook ((eshell-mode . with-editor-export-editor)
         (eshell-mode . setup-company-eshell-autosuggest))
  :init
  (setq eshell-banner-message "")

  (defun new-eshell ()
    (interactive)
    (eshell 'true))

  (use-package esh-autosuggest
    :hook (eshell-mode . esh-autosuggest-mode)))

(use-package shell
  :bind (:map shell-mode-map
              ("<s-up>" . comint-previous-input)
              ("<s-down>" . comint-next-input))
  :init
  (dirtrack-mode)
  (setq explicit-shell-file-name (cond ((is-linux-p) "/bin/bash")
                                       ((is-mac-p) "/usr/bin/bash")))
  (when (is-mac-p)
    (use-package exec-path-from-shell
      :init
      (exec-path-from-shell-initialize))))

(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

(use-package dired
  :ensure f
  :bind (("<f2>" . dired)
         ("C-x C-d" . dired)
         :map dired-mode-map
         ("C-x o" . ace-window)
         ("<return>" . dired-find-alternate-file)
         ("'" . wdired-change-to-wdired-mode)
         ("s-/" . dired-filter-mode))
  :config
  (bind-key "^" (lambda () (interactive) (find-alternate-file "..")) dired-mode-map)
  (put 'dired-find-alternate-file 'disabled nil)
  ;; (add-hook 'dired-mode-hook #'dired-omit-mode)
  (setq dired-dwim-target t
        dired-recursive-deletes 'always
        dired-recursive-copies 'always
        dired-isearch-filenames t
        dired-listing-switches "-alh"
        ;; dired-omit-files-p t
        ;; dired-omit-files "\\|^.DS_STORE$\\|^.projectile$"
        )
  (use-package dired+
    :load-path "~/repos/emacs-src/lisp-lib"
    :init
    (setq diredp-hide-details-initially-flag t)) ;; also automatically calls dired-x, enabling dired-jump, C-x C-j
  (use-package dired-details
    :disabled t
    :init
    (dired-details-install))
  (use-package dired-filter)
  (use-package dired-subtree
    :init
    (unbind-key "M-O" dired-mode-map) ;; to support mode-line-other-buffer in Dired
    (bind-keys :map dired-mode-map
               :prefix "C-,"
               :prefix-map dired-subtree-map
               :prefix-docstring "Dired subtree map."
               ("C-i" . dired-subtree-insert)
               ("i" . dired-subtree-insert)
               ("C-/" . dired-subtree-apply-filter)
               (";" . dired-subtree-remove)
               ("C-k" . dired-subtree-remove)
               ("C-n" . dired-subtree-next-sibling)
               ("C-p" . dired-subtree-previous-sibling)
               ("C-u" . dired-subtree-up)
               ("C-d" . dired-subtree-down)
               ("C-a" . dired-subtree-beginning)
               ("C-e" . dired-subtree-end)
               ("m" . dired-subtree-mark-subtree)
               ("u" . dired-subtree-unmark-subtree)
               ("C-o C-f" . dired-subtree-only-this-file)
               ("C-o C-d" . dired-subtree-only-this-directory)))
  (use-package dired-quick-sort
    :init
    (dired-quick-sort-setup))
  (use-package dired-collapse
    :hook dired-mode))

(use-package deadgrep
  :bind (("C-c d" . deadgrep)
         ("C-c D" . counsel-rg)
         (:map deadgrep-mode-map
               ("q" . kill-this-buffer))))

(use-package hydra
  :config
  (setq hydra-lv nil))

(defhydra hydra-zoom ()
  "zoom"
  ("+" text-scale-increase "in")
  ("=" text-scale-increase "in")
  ("-" text-scale-decrease "out")
  ("_" text-scale-decrease "out")
  ("0" (text-scale-adjust 0) "reset")
  ("q" nil "quit" :color blue))

(bind-keys ("C-x C-0" . hydra-zoom/body)
           ("C-x C-=" . hydra-zoom/body)
           ("C-x C--" . hydra-zoom/body)
           ("C-x C-+" . hydra-zoom/body))

(defun vsplit-last-buffer ()
  (interactive)
  (split-window-vertically)
  (other-window 1 nil)
  (switch-to-next-buffer))

(defun hsplit-last-buffer ()
  (interactive)
  (split-window-horizontally)
  (other-window 1 nil)
  (switch-to-next-buffer))

(bind-key "C-x 2" 'vsplit-last-buffer)
(bind-key "C-x 3" 'hsplit-last-buffer)

(use-package zoom
  :init
  (setq zoom-mode t
        zoom-size '(0.618 . 0.618)))

(use-package counsel
    :bind (("C-x C-f" . counsel-find-file)
           ("C-x C-m" . counsel-M-x)
           ("C-x C-f" . counsel-find-file)
           ("C-h f" . counsel-describe-function)
           ("C-h v" . counsel-describe-variable)
           ("M-i" . counsel-imenu)
           ("M-I" . counsel-imenu)
           ("C-c i" . counsel-unicode-char)
           :map read-expression-map
           ("C-r" . counsel-expression-history)))

(use-package recentf
  :bind ("C-x C-r" . counsel-recentf)
  :init
  (recentf-mode t)
  (setq recentf-max-saved-items 100))

(use-package swiper
  :bind (("C-s" . swiper)
         ("C-r" . swiper)
         ("C-c C-r" . ivy-resume)
         :map ivy-minibuffer-map
         ("C-SPC" . ivy-restrict-to-matches))
  :init
  (ivy-mode 1)
  :config
  (setq ivy-count-format "(%d/%d) "
        ivy-display-style 'fancy
        ivy-height 4
        ivy-use-virtual-buffers t
        ivy-initial-inputs-alist () ;; http://irreal.org/blog/?p=6512
        enable-recursive-minibuffers t))

(use-package all-the-icons)

(use-package ivy-rich
  :after ivy
  :config
  ;; All the icon support to ivy-rich
  (defun ivy-rich-switch-buffer-icon (candidate)
    (with-current-buffer
        (get-buffer candidate)
      (all-the-icons-icon-for-mode major-mode)))

  (setq ivy-rich--display-transformers-list
        '(ivy-switch-buffer
          (:columns
           ((ivy-rich-switch-buffer-icon (:width 2))
            (ivy-rich-candidate (:width 30))
            (ivy-rich-switch-buffer-size (:width 7))
            (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
            (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))
            (ivy-rich-switch-buffer-project (:width 15 :face success))
            (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))
           :predicate
           (lambda (cand) (get-buffer cand)))))

  ;; Add custom icons for various modes that can break ivy-rich
  (add-to-list 'all-the-icons-mode-icon-alist '(dashboard-mode all-the-icons-fileicon "elisp" :height 1.0 :v-adjust -0.2 :face all-the-icons-dsilver))
  (add-to-list 'all-the-icons-mode-icon-alist '(ess-mode all-the-icons-fileicon "R" :face all-the-icons-lblue))

  (ivy-rich-mode 1))

(setq ido-enable-flex-matching t
      ido-everywhere t
      ido-use-faces t ;; disable ido faces to see flx highlights.
      ido-create-new-buffer 'always
      ;; suppress  "reference to free variable problems"
      ido-cur-item nil
      ido-context-switch-command nil
      ido-cur-list nil
      ido-default-item nil)

(use-package ido-vertical-mode
  :init
  (ido-vertical-mode)
  (setq ido-vertical-define-keys 'C-n-and-C-p-only))

(use-package flx-ido
  :init
  (setq flx-ido-threshold 1000)
  (flx-ido-mode 1))

(use-package smex
  :bind (("C-x M-m" . smex-major-mode-commands)
         ("M-x" . smex-major-mode-commands)
         ("C-c C-c M-x" . execute-extended-command))
  :init
  (smex-initialize))

(use-package company
  :bind (("C-." . company-complete)
         :map company-active-map
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous)
         ("C-d" . company-show-doc-buffer)
         ("<tab>" . company-complete))
  :init
  (global-company-mode 1)
  :config
  (setq company-show-numbers t
        company-tooltip-align-annotations t)

  (let ((map company-active-map))
    (mapc
     (lambda (x)
       (define-key map (format "%d" x) 'ora-company-number))
     (number-sequence 0 9))
    (define-key map " " (lambda ()
                          (interactive)
                          (company-abort)
                          (self-insert-command 1)))
    (define-key map (kbd "<return>") nil))

  (defun ora-company-number ()
    "Forward to `company-complete-number'.

Unless the number is potentially part of the candidate.
In that case, insert the number."
    (interactive)
    (let* ((k (this-command-keys))
           (re (concat "^" company-prefix k)))
      (if (cl-find-if (lambda (s) (string-match re s))
                      company-candidates)
          (self-insert-command 1)
        (company-complete-number (string-to-number k))))))

(use-package avy
  :bind ("M-SPC" . avy-goto-char)
  :config
  (setq avy-background t
        avy-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s)))

(use-package ace-window
  :bind (("C-x o" . ace-window)
         ("M-2" . ace-window))
  :init
  (setq aw-background nil
        aw-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s)))

(autoload 'zap-up-to-char "misc"
  "Kill up to, but not including ARGth occurrence of CHAR.")
(bind-key "M-Z" 'zap-up-to-char)

(use-package avy-zap)

(use-package ace-link
    :init
    (ace-link-setup-default))

(bind-keys :prefix-map avy-map
           :prefix "C-c j"
           ("c" . avy-goto-char)
           ("l" . avy-goto-line)
           ("w" . avy-goto-word-or-subword-1)
           ("W" . ace-window)
           ("z" . avy-zap-to-char)
           ("Z" . avy-zap-up-to-char))

(use-package expand-region
  :bind (("C-@" . er/expand-region)
         ("C-=" . er/expand-region)
         ("M-3" . er/expand-region)))

(pending-delete-mode t)

(use-package browse-kill-ring
  :bind ("C-x C-y" . browse-kill-ring)
  :config
  (setq browse-kill-ring-quit-action 'kill-and-delete-window))

(setq save-interprogram-paste-before-kill t)

(use-package easy-kill
  :bind ("M-w" . easy-kill))

(use-package hungry-delete
  :init
  (global-hungry-delete-mode))

(defun auto-save-command ()
  (let* ((basic (and buffer-file-name
                     (buffer-modified-p (current-buffer))
                     (file-writable-p buffer-file-name)
                     (not org-src-mode)))
         (proj (and (projectile-project-p)
                    basic)))
    (if proj
        (projectile-save-project-buffers)
      (when basic
        (save-buffer)))))

(defmacro advise-commands (advice-name commands class &rest body)
  "Apply advice named ADVICE-NAME to multiple COMMANDS.
The body of the advice is in BODY."
  `(progn
     ,@(mapcar (lambda (command)
                 `(defadvice ,command (,class ,(intern (concat (symbol-name command) "-" advice-name)) activate)
                    ,@body))
               commands)))

(advise-commands "auto-save"
                 (ido-switch-buffer ace-window magit-status windmove-up windmove-down windmove-left windmove-right mode-line-other-buffer)
                 before
                 (auto-save-command))

(add-hook 'mouse-leave-buffer-hook 'auto-save-command)
(add-hook 'focus-out-hook 'auto-save-command)

(bind-key "C-x C-s" 'save-buffer)

(defvar backup-dir (expand-file-name "~/.emacs.d/emacs_backup/"))
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq backup-directory-alist (list (cons ".*" backup-dir))
      auto-save-list-file-prefix autosave-dir
      auto-save-file-name-transforms `((".*" ,autosave-dir t))
      tramp-backup-directory-alist backup-directory-alist
      tramp-auto-save-directory autosave-dir)

(global-auto-revert-mode t)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(setq-default save-place t)
(setq save-place-file (expand-file-name ".places" user-emacs-directory))

(save-place-mode 1)

(use-package re-builder
  :bind (("C-c R" . re-builder))
  :config
  (setq reb-re-syntax 'string))

(use-package visual-regexp
    :bind (("M-5" . vr/replace)
           ("M-%" . vr/query-replace)))

(use-package highlight-symbol
  :bind (("M-p" . highlight-symbol-prev)
         ("M-n" . highlight-symbol-next)
         ("M-'" . highlight-symbol-query-replace))
  :init
  (defun highlight-symbol-first ()
    "Jump to the first location of symbol at point."
    (interactive)
    (push-mark)
    (eval
     `(progn
        (goto-char (point-min))
        (search-forward-regexp
         (rx symbol-start ,(thing-at-point 'symbol) symbol-end)
         nil t)
        (beginning-of-thing 'symbol))))

  (defun highlight-symbol-last ()
    "Jump to the last location of symbol at point."
    (interactive)
    (push-mark)
    (eval
     `(progn
        (goto-char (point-max))
        (search-backward-regexp
         (rx symbol-start ,(thing-at-point 'symbol) symbol-end)
         nil t))))

  (bind-keys ("M-P" . highlight-symbol-first)
             ("M-N" . highlight-symbol-last)))

(use-package iedit
  :bind ("C-;" . iedit-mode))

(use-package edit-list)

(use-package which-key
  :init
  (which-key-mode))

(use-package help-fns+
  :load-path "~/repos/emacs-src/lisp-lib"
  :bind ("C-h M-k" . describe-keymap)) ; For autoloading.

(use-package discover-my-major
  :bind ("C-h C-m" . discover-my-major))

(use-package interaction-log)

(interaction-log-mode +1)

(defun open-interaction-log ()
  (interactive)
  (display-buffer ilog-buffer-name))

(bind-key "C-h C-l" 'open-interaction-log)

(use-package goto-chg
  :bind (("C-c ," . goto-last-change)
         ("C-c ." . goto-last-change-reverse)))

(use-package selected
  :commands selected-minor-mode
  :init
  (setq selected-org-mode-map (make-sparse-keymap))
  (selected-global-mode 1)
  :bind (:map selected-keymap
              ("e" . er/expand-region)
              ("i" . indent-region)
              ("l" . downcase-region)
              ("m" . apply-macro-to-region-lines)
              ("q" . selected-off)
              ("r" . reverse-region)
              ("s" . sort-lines)
              ("u" . upcase-region)
              ("w" . count-words-region)
              ("y" . yank)
              :map selected-org-mode-map
              ("t" . org-table-convert-region)))

(use-package beginend
  :init
  (beginend-global-mode))

(use-package goto-addr
  :hook ((compilation-mode . goto-address-mode)
         (prog-mode . goto-address-prog-mode)
         (eshell-mode . goto-address-mode)
         (shell-mode . goto-address-mode))
  :bind (:map goto-address-highlight-keymap
              ("C-c C-o" . goto-address-at-point))
  :commands (goto-address-prog-mode
             goto-address-mode))

(use-package emojify
  :init (global-emojify-mode))

(setq browse-url-browser-function (cond ((is-mac-p) 'browse-url-default-macosx-browser)
                                        ((is-linux-p) 'browse-url-default-browser)))

(bind-key "C-c B" 'browse-url-at-point)

(use-package eww-lnum
  :after eww
  :bind (:map eww-mode-map
              ("f" . eww-lnum-follow)
              ("F" . eww-lnum-universal)))

(use-package clojure-mode
  :mode (("\\.boot$"  . clojure-mode)
         ("\\.clj$"   . clojure-mode)
         ("\\.cljs$"  . clojurescript-mode)
         ("\\.edn$"   . clojure-mode))
  :config
  (use-package align-cljlet
    :bind (:map clojure-mode-map
                ("C-! a a" . align-cljlet)
                :map clojurescript-mode-map
                ("C-! a a" . align-cljlet)
                :map clojurec-mode-map
                ("C-! a a" . align-cljlet))))

(use-package clj-refactor
  :disabled
  :init
  (defun my-clj-refactor-mode-hook ()
    (clj-refactor-mode 1)
    (yas-minor-mode 1))
  (add-hook 'clojure-mode-hook #'my-clj-refactor-mode-hook)
  (setq cljr-clojure-test-declaration "[clojure.test :refer :all]"
        cljr-cljs-clojure-test-declaration "[cljs.test :refer-macros [deftest is use-fixtures]]")
  :config
  (cljr-add-keybindings-with-prefix "<menu>")

  (add-to-list 'cljr-magic-require-namespaces
               '("s"  . "clojure.spec.alpha"))

  (add-to-list 'cljr-magic-require-namespaces
               '("S"  . "com.rpl.specter"))

  (advice-add 'cljr-add-require-to-ns :after
              (lambda (&rest _)
                (yas-next-field)
                (yas-next-field))))

(use-package cider
  :bind (:map cider-repl-mode-map
              ("M-r" . cider-refresh)
              ("M-R" . cider-use-repl-tools))
  :config
  (setq nrepl-hide-special-buffers t
        nrepl-popup-stacktraces-in-repl t
        nrepl-history-file "~/.emacs.d/nrepl-history"
        cider-mode-line " CIDER"
        cider-repl-display-in-current-window t
        cider-auto-select-error-buffer nil
        cider-repl-pop-to-buffer-on-connect nil
        cider-show-error-buffer nil
        cider-repl-use-pretty-printing t
        cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")

  (defun cider-use-repl-tools ()
    (interactive)
    (cider-interactive-eval
     "(use 'clojure.repl)"))

  (fset 'cider-eval-last-sexp-and-comment
        "\C-u\C-x\C-e\C-a\260 ;; \C-e")

  (bind-key "C-j" 'cider-eval-last-sexp-and-comment clojure-mode-map)

  ;; this snippet comes from schmir https://github.com/schmir/.emacs.d/blob/master/lisp/setup-clojure.el
  (defadvice cider-load-buffer (after switch-namespace activate compile)
    "switch to namespace"
    (cider-repl-set-ns (cider-current-ns))
    (cider-switch-to-repl-buffer))

  ;; fix cond indenting
  (put 'cond 'clojure-backtracking-indent '(2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4 2 4)))

(use-package elisp-slime-nav
  :init
  (dolist (hook '(emacs-lisp-mode-hook ielm-mode-hook))
    (add-hook hook 'elisp-slime-nav-mode)))

(autoload 'turn-on-eldoc-mode "eldoc" nil t)
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'eldoc-mode)
(add-hook 'ielm-mode-hook 'eldoc-mode)
(add-hook 'cider-mode-hook 'eldoc-mode)

;  (bind-key "C-c C-l" 'html-href-anchor html-mode-map)

(use-package proof-general )

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-c g" . magit-status)
         :map magit-status-mode-map
         ("TAB" . magit-section-toggle)
         ("<C-tab>" . magit-section-cycle)
         :map magit-branch-section-map
         ("RET" . magit-checkout))
  :config
  (add-hook 'after-save-hook 'magit-after-save-refresh-status)
  (setq magit-use-overlays nil
        magit-section-visibility-indicator nil
        magit-completing-read-function 'ivy-completing-read
        magit-push-always-verify nil
        magit-repository-directories '("~/src/"))
  (use-package git-timemachine
    :bind (("C-x v t" . git-timemachine)))
  (use-package git-link
    :bind (("C-x v L" . git-link))
    :init
    (setq git-link-open-in-browser t))
  (use-package pcmpl-git)
  (defun visit-pull-request-url ()
    "Visit the current branch's PR on Github."
    (interactive)
    (browse-url
     (format "https://github.com/%s/pull/new/%s"
             (replace-regexp-in-string
              "\\`.+github\\.com:\\(.+\\)\\.git\\'" "\\1"
              (magit-get "remote"
                         (magit-get-remote)
                         "url"))
             (cdr (magit-get-remote-branch)))))

  (bind-key "v" 'visit-pull-request-url magit-mode-map)

  ;; Do Not Show Recent Commits in status window
  ;; https://github.com/magit/magit/issues/3230#issuecomment-339900039
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-unpushed-to-upstream
                          'magit-insert-unpushed-to-upstream-or-recent
                          'replace))

(use-package git-auto-commit-mode
  :delight)

(use-package projectile
  :bind ("C-c p" . projectile-switch-project)
  :init
  (projectile-global-mode)
  (use-package ibuffer-projectile
    :bind (("C-x C-b" . ibuffer)
           :map ibuffer-mode-map
           ("c" . clean-buffer-list)
           ("n" . ibuffer-forward-filter-group)
           ("p" . ibuffer-backward-filter-group))
    :init
    (add-hook 'ibuffer-hook
              (lambda ()
                (ibuffer-projectile-set-filter-groups)
                (unless (eq ibuffer-sorting-mode 'alphabetic)
                  (ibuffer-do-sort-by-alphabetic)))))
  :config
  (setq projectile-enable-caching t
        projectile-create-missing-test-files t
        projectile-completion-system 'ivy
        projectile-use-git-grep t
        projectile-switch-project-action #'projectile-commander
        ;; I'm redefining a lot of bindings, so unset pre-defined methods
        ;; and define everyting here.
        projectile-commander-methods nil)


  (def-projectile-commander-method ?? "Commander help buffer."
    (ignore-errors (kill-buffer projectile-commander-help-buffer))
    (with-current-buffer (get-buffer-create projectile-commander-help-buffer)
      (insert "Projectile Commander Methods:\n\n")
      (dolist (met projectile-commander-methods)
        (insert (format "%c:\t%s\n" (car met) (cadr met))))
      (goto-char (point-min))
      (help-mode)
      (display-buffer (current-buffer) t))
    (projectile-commander))
  (def-projectile-commander-method ?a
    "Run ag on project."
    (counsel-projectile-ag))
  (def-projectile-commander-method ?b
    "Open an IBuffer window showing all buffers in the current project."
    (counsel-projectile-switch-to-buffer))
  (def-projectile-commander-method ?B
    "Display a project buffer in other window."
    (projectile-display-buffer))
  (def-projectile-commander-method ?c
    "Run `compile' in the project."
    (projectile-compile-project nil))
  (def-projectile-commander-method ?d
    "Open project root in dired."
    (projectile-dired))
  (def-projectile-commander-method ?D
    "Find a project directory in other window."
    (projectile-find-dir-other-window))
  (def-projectile-commander-method ?e
    "Open an eshell buffer for the project."
    ;; This requires a snapshot version of Projectile.
    (projectile-run-eshell))
  (def-projectile-commander-method ?f
    "Find a project directory in other window."
    (projectile-find-file))
  (def-projectile-commander-method ?F
    "Find project file in other window."
    (projectile-find-file-other-window))
  (def-projectile-commander-method ?g
    "Open project root in vc-dir or magit."
    (projectile-vc))
  (def-projectile-commander-method ?G
    "Run grep on project."
    (projectile-grep))
  (def-projectile-commander-method ?i
    "Open an IBuffer window showing all buffers in the current project."
    (projectile-ibuffer))
  (def-projectile-commander-method ?j
    "Jack in to CLJ or CLJS depending on context."
    (let* ((opts (projectile-current-project-files))
           (file (ido-completing-read
                  "Find file: "
                  opts
                  nil nil nil nil
                  (car (cl-member-if
                        (lambda (f)
                          (string-match "core\\.clj\\'" f))
                        opts)))))
      (find-file (expand-file-name
                  file (projectile-project-root)))
      (run-hooks 'projectile-find-file-hook)
      (if (derived-mode-p 'clojurescript-mode)
          (cider-jack-in-clojurescript)
        (cider-jack-in))))
  (def-projectile-commander-method ?r
    "Find recently visited file in project."
    (projectile-recentf))
  (def-projectile-commander-method ?s
    "Switch project."
    (counsel-projectile-switch-project))
  (def-projectile-commander-method ?t
    "Find test file in project."
    (projectile-find-test-file))
  (def-projectile-commander-method ?\C-?
    "Go back to project selection."
    (projectile-switch-project)))

(use-package flycheck
  :init
  (use-package flycheck-clojure)
  (global-flycheck-mode)
  (setq flycheck-indication-mode 'right-fringe))

(use-package restclient)

(add-hook 'before-save-hook 'whitespace-cleanup)

(use-package smartparens
  :bind
  (("C-M-f" . sp-forward-sexp)
   ("C-M-b" . sp-backward-sexp)
   ("C-M-d" . sp-down-sexp)
   ("C-M-a" . sp-backward-down-sexp)
   ("C-S-a" . sp-beginning-of-sexp)
   ("C-S-d" . sp-end-of-sexp)
   ("C-M-e" . sp-up-sexp)
   ("C-M-u" . sp-backward-up-sexp)
   ("C-M-t" . sp-transpose-sexp)
   ("C-M-n" . sp-next-sexp)
   ("C-M-p" . sp-previous-sexp)
   ("C-M-k" . sp-kill-sexp)
   ("C-M-w" . sp-copy-sexp)
   ("M-<delete>" . sp-unwrap-sexp)
   ("M-S-<backspace>" . sp-backward-unwrap-sexp)
   ("C-<right>" . sp-forward-slurp-sexp)
   ("C-<left>" . sp-forward-barf-sexp)
   ("C-M-<left>" . sp-backward-slurp-sexp)
   ("C-M-<right>" . sp-backward-barf-sexp)
   ("M-D" . sp-splice-sexp)
   ("C-M-<delete>" . sp-splice-sexp-killing-forward)
   ("C-M-<backspace>" . sp-splice-sexp-killing-backward)
   ("C-M-S-<backspace>" . sp-splice-sexp-killing-around)
   ("C-]" . sp-select-next-thing-exchange)
   ("C-<left_bracket>" . sp-select-previous-thing)
   ("C-M-]" . sp-select-next-thing)
   ("M-F" . sp-forward-symbol)
   ("M-B" . sp-backward-symbol)
   ("H-t" . sp-prefix-tag-object)
   ("H-p" . sp-prefix-pair-object)
   ("H-s c" . sp-convolute-sexp)
   ("H-s a" . sp-absorb-sexp)
   ("H-s e" . sp-emit-sexp)
   ("H-s p" . sp-add-to-previous-sexp)
   ("H-s n" . sp-add-to-next-sexp)
   ("H-s j" . sp-join-sexp)
   ("H-s s" . sp-split-sexp)
   ("M-9" . sp-backward-sexp)
   ("M-0" . sp-forward-sexp))
  :init
  (smartparens-global-mode t)
  (show-smartparens-global-mode t)
  (use-package smartparens-config
    :ensure f)
  (bind-key "s" 'smartparens-mode toggle-map)
  (when (is-mac-p)
    (bind-keys ("<s-right>" . sp-forward-slurp-sexp)
               ("<s-left>" . sp-forward-barf-sexp)))
  (sp-with-modes '(markdown-mode gfm-mode)
    (sp-local-pair "*" "*"))
  (sp-with-modes '(org-mode)
    (sp-local-pair "=" "=")
    (sp-local-pair "*" "*")
    (sp-local-pair "/" "/")
    (sp-local-pair "_" "_")
    (sp-local-pair "+" "+")
    (sp-local-pair "<" ">")
    (sp-local-pair "[" "]"))
  (use-package rainbow-delimiters
    :hook (prog-mode . rainbow-delimiters-mode)))

(use-package linum-relative
  :init
  (setq linum-format 'linum-relative)
  :config
  (setq linum-relative-current-symbol ""))

(use-package comment-dwim-2
  :bind
  (("M-;" . comment-dwim-2)
   ("C-M-;" . comment-or-uncomment-sexp))
  :init
  (defun uncomment-sexp (&optional n)
    "Uncomment a sexp around point."
    (interactive "P")
    (let* ((initial-point (point-marker))
           (inhibit-field-text-motion t)
           (p)
           (end (save-excursion
                  (when (elt (syntax-ppss) 4)
                    (re-search-backward comment-start-skip
                                        (line-beginning-position)
                                        t))
                  (setq p (point-marker))
                  (comment-forward (point-max))
                  (point-marker)))
           (beg (save-excursion
                  (forward-line 0)
                  (while (and (not (bobp))
                              (= end (save-excursion
                                       (comment-forward (point-max))
                                       (point))))
                    (forward-line -1))
                  (goto-char (line-end-position))
                  (re-search-backward comment-start-skip
                                      (line-beginning-position)
                                      t)
                  (ignore-errors
                    (while (looking-at-p comment-start-skip)
                      (forward-char -1)))
                  (point-marker))))
      (unless (= beg end)
        (uncomment-region beg end)
        (goto-char p)
        ;; Indentify the "top-level" sexp inside the comment.
        (while (and (ignore-errors (backward-up-list) t)
                    (>= (point) beg))
          (skip-chars-backward (rx (syntax expression-prefix)))
          (setq p (point-marker)))
        ;; Re-comment everything before it.
        (ignore-errors
          (comment-region beg p))
        ;; And everything after it.
        (goto-char p)
        (forward-sexp (or n 1))
        (skip-chars-forward "\r\n[:blank:]")
        (if (< (point) end)
            (ignore-errors
              (comment-region (point) end))
          ;; If this is a closing delimiter, pull it up.
          (goto-char end)
          (skip-chars-forward "\r\n[:blank:]")
          (when (eq 5 (car (syntax-after (point))))
            (delete-indentation))))
      ;; Without a prefix, it's more useful to leave point where
      ;; it was.
      (unless n
        (goto-char initial-point))))

  (defun comment-sexp--raw ()
    "Comment the sexp at point or ahead of point."
    (pcase (or (bounds-of-thing-at-point 'sexp)
               (save-excursion
                 (skip-chars-forward "\r\n[:blank:]")
                 (bounds-of-thing-at-point 'sexp)))
      (`(,l . ,r)
       (goto-char r)
       (skip-chars-forward "\r\n[:blank:]")
       (save-excursion
         (comment-region l r))
       (skip-chars-forward "\r\n[:blank:]"))))

  (defun comment-or-uncomment-sexp (&optional n)
    "Comment the sexp at point and move past it.
If already inside (or before) a comment, uncomment instead.
With a prefix argument N, (un)comment that many sexps."
    (interactive "P")
    (if (or (elt (syntax-ppss) 4)
            (< (save-excursion
                 (skip-chars-forward "\r\n[:blank:]")
                 (point))
               (save-excursion
                 (comment-forward 1)
                 (point))))
        (uncomment-sexp n)
      (dotimes (_ (or n 1))
        (comment-sexp--raw)))))

(use-package aggressive-indent
  :init
  (global-aggressive-indent-mode 1)
  (add-to-list 'aggressive-indent-excluded-modes 'html-mode)
  (unbind-key "C-c C-q" aggressive-indent-mode-map))

(use-package org
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("C-c b" . org-iswitchb)
         ("C-c M-k" . org-cut-subtree)
         ("<down>" . org-insert-todo-heading)
         :map org-mode-map
         ("C-c >" . org-time-stamp-inactive))
  :custom-face
  (variable-pitch ((t (:family "ETBembo"))))
  (org-document-title ((t (:foreground "#171717" :weight bold :height 1.5))))
  (org-done ((t (:background "#E8E8E8" :foreground "#0E0E0E" :strike-through t :weight bold))))
  (org-headline-done ((t (:foreground "#171717" :strike-through t))))
  (org-level-1 ((t (:foreground "#090909" :weight bold :height 1.3))))
  (org-level-2 ((t (:foreground "#090909" :weight normal :height 1.2))))
  (org-level-3 ((t (:foreground "#090909" :weight normal :height 1.1))))
  (org-image-actual-width '(600))
  :init
  (setq default-major-mode 'org-mode
        org-directory "~/org/"
        org-log-done t
        org-startup-indented t
        org-startup-truncated nil
        org-startup-with-inline-images t
        org-completion-use-ido t
        org-default-notes-file (concat org-directory "notes.org")
        org-image-actual-width '(300)
        org-goto-max-level 10
        org-imenu-depth 5
        org-goto-interface 'outline-path-completion
        org-outline-path-complete-in-steps nil
        org-src-fontify-natively t
        org-lowest-priority ?C
        org-default-priority ?B
        org-expiry-inactive-timestamps t
        org-show-notification-handler 'message
        org-special-ctrl-a/e t
        org-special-ctrl-k t
        org-yank-adjusted-subtrees t
        org-file-apps
        '((auto-mode . emacs)
          ("\\.mm\\'" . default)
          ("\\.x?html?\\'" . "firefox %s")
          ("\\.pdf\\'" . "open %s"))
        org-todo-keywords
        '((sequence "TODO(t)" "STARTED(s)" "WAITING(w)" "SOMEDAY(.)" "MAYBE(m)" "|" "DONE(x!)" "CANCELLED(c)"))
        ;; Theming
        org-ellipsis "  " ;; folding symbol
        org-pretty-entities t
        org-hide-emphasis-markers t ;; show actually italicized text instead of /italicized text/
        org-agenda-block-separator ""
        org-fontify-whole-heading-line t
        org-fontify-done-headline t
        org-fontify-quote-and-verse-blocks t)

  (add-to-list 'org-global-properties
               '("Effort_ALL". "0:05 0:15 0:30 1:00 2:00 3:00 4:00"))

  (add-hook 'org-mode-hook
            '(lambda ()
               (setq line-spacing 0.2) ;; Add more line padding for readability
               (variable-pitch-mode 1) ;; All fonts with variable pitch.
               (mapc
                (lambda (face) ;; Other fonts with fixed-pitch.
                  (set-face-attribute face nil :inherit 'fixed-pitch))
                (list 'org-code
                      'org-link
                      'org-block
                      'org-table
                      'org-verbatim
                      'org-block-begin-line
                      'org-block-end-line
                      'org-meta-line
                      'org-document-info-keyword))))

  (custom-theme-set-faces
   'spacemacs-light
   `(org-block-begin-line ((t (:background "#fbf8ef"))))
   `(org-block-end-line ((t (:background "#fbf8ef"))))))

(require 'org-install)
(setq org-modules '(org-habit org-info org-tempo))
(org-load-modules-maybe t)

(setq org-habit-graph-column 105)

(defun org-make-habit ()
  (interactive)
  (org-set-property "STYLE" "habit"))

(use-package org-gcal
  :bind (:map org-agenda-mode-map
              ;; "r" is bound to org-agenda-redo
              ("g" . org-gcal-fetch))
  :init
  (add-hook 'emacs-startup-hook #'org-gcal-fetch)

  (defun fetch-calendar ()
    (when (internet-up-p) (org-gcal-fetch))))

(use-package org-cliplink
  :bind ("C-x p i" . org-cliplink))

(use-package org-bullets
  :init
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(defun yant/org-entry-has-subentries ()
  "Any entry with subheadings."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (save-excursion
      (org-back-to-heading)
      (forward-line 1)
      (when (< (point) subtree-end)
        (re-search-forward "^\*+ " subtree-end t)))))

(defun yant/org-entry-sort-by-property nil
  "Apply property sort on current entry. The sorting is done using property with the name from value of :SORT: property.
      For example, :SORT: DEADLINE will apply org-sort-entries by DEADLINE property on current entry."
  (let ((property (org-entry-get (point) "SORT" 'INHERIT)))
    (when (and (not (seq-empty-p property))
               (yant/org-entry-has-subentries))
      (funcall #'org-sort-entries nil ?r nil nil property))))

(defun yant/org-buffer-sort-by-property (&optional MATCH)
  "Sort all subtrees in buffer by the property, which is the value of their :SORT: property.
        Only subtrees, matching MATCH are selected"
  (org-map-entries #'yant/org-entry-sort-by-property MATCH 'file))

(add-hook 'org-mode-hook #'yant/org-buffer-sort-by-property)

(use-package helm-org-rifle
  :bind ("C-c o" . helm-org-rifle))

(use-package yasnippet)

(use-package yankpad
  :init
  (setq yankpad-file "~/org/templates/yankpad.org")
  (bind-keys :prefix-map yank-map
             :prefix "C-c y"
             ("c" . yankpad-set-category)
             ("e" . yankpad-edit)
             ("i" . yankpad-insert)
             ("m" . yankpad-map)
             ("r" . yankpad-reload)
             ("x" . yankpad-expand)))

(setq org-agenda-inhibit-startup nil
      org-agenda-show-future-repeats nil
      org-agenda-start-on-weekday nil
      org-agenda-skip-deadline-if-done t
      org-agenda-skip-scheduled-if-done t)

(unbind-key "C-c [")
(unbind-key "C-c ]")

(use-package org-super-agenda
  :init
  (org-super-agenda-mode)

  (defun my-org-super-agenda ()
    (interactive)
    (let ((org-super-agenda-groups
           '((:name "Schedule"
                    :time-grid t)
             (:name "MAPLE" ;; monastery work
                    :tag "maple")
             ;; After the last group, the agenda will display items that didn't
             ;; match any of these groups, with the default order position of 99
             ;; To prevent this, add this code:
             ;; (:discard (:anything t))
             )))
      (org-agenda nil "a")))

  (defun my-org-super-agenda-today ()
    (interactive)
    (progn
      (my-org-super-agenda)
      (org-agenda-day-view)))

  (defun my-personal-agenda ()
    (interactive)
    (let ((org-super-agenda-groups
           '(;; After the last group, the agenda will display items that didn't
             ;; match any of these groups, with the default order position of 99
             ;; To prevent this, add this code:
             (:discard (:tag ("maple"))))))
      (org-agenda nil "a")
      (org-agenda-day-view)))

  (defun my-monastery-agenda ()
    (interactive)
    (let ((org-super-agenda-groups
           '((:name "MAPLE" ;; monastery work
                    :tag "maple")
             ;; After the last group, the agenda will display items that didn't
             ;; match any of these groups, with the default order position of 99
             ;; To prevent this, add this code:
             (:discard (:anything t)))))
      (org-agenda nil "a")
      (org-agenda-day-view)))

  (bind-keys ("C-c `" . my-org-super-agenda-today)
             ("C-c 1" . my-personal-agenda)
             ("C-c 2" . my-monastery-agenda)
             ("C-c 0" . my-org-super-agenda))

  :config
  ;; Enable folding
  (use-package origami
    :bind (:map org-super-agenda-header-map
                ("TAB" . origami-toggle-node))
    :hook ((org-agenda-mode . origami-mode))))

(setq org-agenda-files (quote ("~/org/todo.org"
                               "~/org/agendas.org"
                               "~/org/inbox.org"
                               "~/org/waiting.org"
                               "~/org/calendar/gcal.org"
                               "~/org/calendar/maple.org"
                               "~/org/somedaymaybe.org")))

(defun open-agenda ()
  "Opens the org-agenda."
  (interactive)
  (let ((agenda "*Org Agenda*"))
    (if (equal (get-buffer agenda) nil)
        (org-agenda-list)
      (unless (equal (buffer-name (current-buffer)) agenda)
        (switch-to-buffer agenda))
      (org-agenda-redo t)
      (beginning-of-buffer))))

(bind-key "<f5>" 'open-agenda)
(bind-key "a" 'open-agenda launcher-map)

(add-hook 'org-agenda-finalize-hook (lambda () (delete-other-windows)))

(defun org-buffer-todo ()
  (interactive)
  "Creates a todo-list for the current buffer. Equivalent to the sequence: org-agenda, < (restrict to current buffer), t (todo-list)."
  (progn
    (org-agenda-set-restriction-lock 'file)
    (org-todo-list)))

(defun org-buffer-agenda ()
  (interactive)
  "Creates an agenda for the current buffer. Equivalent to the sequence: org-agenda, < (restrict to current buffer), a (agenda-list)."
  (progn
    (org-agenda-set-restriction-lock 'file)
    (org-agenda-list)))

(defun org-buffer-day-agenda ()
  (interactive)
  "Creates an agenda for the current buffer. Equivalent to the sequence: org-agenda, < (restrict to current buffer), a (agenda-list), d (org-agenda-day-view)."
  (progn
    (org-agenda-set-restriction-lock 'file)
    (org-agenda-list)
    (org-agenda-day-view))) ;; Maybe I should try writing a Emacs Lisp macro for this kind of thing!

(bind-key "y" 'org-agenda-todo-yesterday org-agenda-mode-map)

(add-to-list 'org-agenda-custom-commands
             '("L" "Timeline"
               ((agenda
                 ""
                 ((org-agenda-span 7)
                  (org-agenda-prefix-format '((agenda . " %1c %?-12t% s"))))))))

(add-to-list 'org-agenda-custom-commands
             '("u" "Unscheduled TODOs"
               ((todo ""
                      ((org-agenda-overriding-header "\nUnscheduled TODO")
                       (org-agenda-skip-function '(org-agenda-skip-entry-if 'timestamp 'todo '("DONE" "CANCELLED" "MAYBE" "WAITING" "SOMEDAY"))))))) t)

(defun my-org-agenda-recent-open-loops ()
  (interactive)
  (let ((org-agenda-start-with-log-mode t)
        (org-agenda-use-time-grid nil)
        (org-agenda-files '("~/org/calendar/gcal.org" "~/org/calendar/maple.org")))
    (fetch-calendar)
    (org-agenda-list nil (org-read-date nil nil "-2d") 4)
    (beginend-org-agenda-mode-goto-beginning)))

(defun my-org-agenda-longer-open-loops ()
  (interactive)
  (let ((org-agenda-start-with-log-mode t)
        (org-agenda-use-time-grid nil)
        (org-agenda-files '("~/org/calendar/gcal.org" "~/org/calendar/maple.org")))
    (fetch-calendar)
    (org-agenda-list 'file (org-read-date nil nil "-14d") 28)
    (beginend-org-agenda-mode-goto-beginning)))

(add-to-list 'org-agenda-custom-commands
             '("w" "WAITING" todo "WAITING" ((org-agenda-overriding-header "Delegated and/or Waiting"))) t)

(defun org-agenda-set-tags-auto-advance ()
  (interactive)
  (while t
    (call-interactively #'org-agenda-set-tags)
    (org-agenda-next-line)))

(bind-key "`" 'org-agenda-set-tags-auto-advance org-agenda-mode-map)

(setq org-capture-templates
      '(("t" "Task" entry (file "~/org/inbox.org")
         "* TODO %?\n")
        ("p" "Project" entry (file+headline "~/org/todo.org" "Projects")
         (file "~/org/templates/newprojecttemplate.org"))
        ("s" "Someday" entry (file+headline "~/org/somedaymaybe.org" "Someday / Maybe")
         "* SOMEDAY %?\n")
        ("m" "Maybe" entry (file+headline "~/org/somedaymaybe.org" "Someday / Maybe")
         "* MAYBE %?\n")
        ("l" "Log" entry (file+olp+datetree "~/org/log.org" "Log")
         (file "~/org/templates/logtemplate.org"))))

(setq org-log-done 'time
      org-clock-idle-time nil
      org-clock-continuously nil
      org-clock-persist t
      org-clock-in-switch-to-state "STARTED"
      org-clock-in-resume nil
      org-clock-report-include-clocking-task t
      org-clock-out-remove-zero-time-clocks t
      ;; Too many clock entries clutter up a heading
      org-log-into-drawer t
      org-clock-into-drawer 1)

(defun bh/remove-empty-drawer-on-clock-out ()
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    (org-remove-empty-drawer-at (point))))

(add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)

(defhydra hydra-org-clock (:color blue :hint nil)
  "
Clock   In/out^     ^Edit^   ^Summary     (_?_)
-----------------------------------------
        _i_n         _e_dit   _g_oto entry
        _c_ontinue   _q_uit   _d_isplay
        _o_ut        ^ ^      _r_eport
      "
  ("i" org-clock-in)
  ("o" org-clock-out)
  ("c" org-clock-in-last)
  ("e" org-clock-modify-effort-estimate)
  ("q" org-clock-cancel)
  ("g" org-clock-goto)
  ("d" org-clock-display)
  ("r" org-clock-report)
  ("?" (org-info "Clocking commands")))

(defhydra hydra-org-agenda-clock (:color blue :hint nil)
  "
Clock   In/out^
-----------------------------------------
        _i_n
        _g_oto entry
        _o_ut
        _q_uit
      "
  ("i" org-agenda-clock-in)
  ("o" org-agenda-clock-out)
  ("q" org-agenda-clock-cancel)
  ("g" org-agenda-clock-goto))

(bind-keys ("C-c w" . hydra-org-clock/body)
           :map org-agenda-mode-map
           ("C-c w" . hydra-org-agenda-clock/body))

(use-package org-download)

(setq org-export-with-toc nil
      org-export-with-section-numbers nil)

(use-package ox-twbs)

(use-package org-preview-html
  :commands org-preview-html/preview
  :after org)

(use-package htmlize
  :after org)
(use-package ox-clip
  :after org
  :config
  (defun ox-clip-dwim ()
    "If the region is active, call ox-clip as normal. Otherwise, call ox-clip on whole buffer (or visible / narrowed section, if applicable)."
    (interactive)
    (if (region-active-p)
        (ox-clip-formatted-copy (region-beginning) (region-end))
      ;; if buffer is narrowed, this will work on visible; if not, it will capture whole buffer
      (ox-clip-formatted-copy (point-min) (point-max))))
  (bind-keys ("C-c x" . ox-clip-dwim)
             :map selected-org-mode-map
             ("x" . ox-clip-dwim)))

(setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id
      org-clone-delete-id t)

(defun org-teleport (&optional arg)
  "Teleport the current heading to after a headline selected with avy.
  With a prefix ARG move the headline to before the selected
  headline. With a numeric prefix, set the headline level. If ARG
  is positive, move after, and if negative, move before."
  (interactive "P")
  ;; Kill current headline
  (org-mark-subtree)
  (kill-region (region-beginning) (region-end))
  ;; Jump to a visible headline
  (avy-with avy-goto-line (avy--generic-jump "^\\*+" nil avy-style))
  (cond
   ;; Move before  and change headline level
   ((and (numberp arg) (> 0 arg))
    (save-excursion
      (yank))
    ;; arg is what we want, second is what we have
    ;; if n is positive, we need to demote (increase level)
    (let ((n (- (abs arg) (car (org-heading-components)))))
      (cl-loop for i from 1 to (abs n)
               do
               (if (> 0 n)
                   (org-promote-subtree)
                 (org-demote-subtree)))))
   ;; Move after and change level
   ((and (numberp arg) (< 0 arg))
    (org-mark-subtree)
    (goto-char (region-end))
    (when (eobp) (insert "\n"))
    (save-excursion
      (yank))
    ;; n is what we want and second is what we have
    ;; if n is positive, we need to demote
    (let ((n (- (abs arg) (car (org-heading-components)))))
      (cl-loop for i from 1 to (abs n)
               do
               (if (> 0 n) (org-promote-subtree)
                 (org-demote-subtree)))))

   ;; move to before selection
   ((equal arg '(4))
    (save-excursion
      (yank)))
   ;; move to after selection
   (t
    (org-mark-subtree)
    (goto-char (region-end))
    (when (eobp) (insert "\n"))
    (save-excursion
      (yank))))
  (outline-hide-leaves))

(add-to-list 'org-speed-commands-user
             (cons "q" (lambda ()
                         (avy-with avy-goto-line
                           (avy--generic-jump "^\\*+" nil avy-style)))))

(add-to-list 'org-speed-commands-user (cons "T" 'org-teleport))

(bind-key "T" 'org-teleport selected-org-mode-map)

(setq org-refile-targets '((("~/org/todo.org" "~/org/somedaymaybe.org") :maxlevel . 3))
      ;; org-refile-use-cache t
      org-refile-use-outline-path t)

(defun bh/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))

(setq org-refile-target-verify-function 'bh/verify-refile-target)

(setq org-use-speed-commands t
      org-speed-commands-user
      '(("N" org-narrow-to-subtree)
        ("$" org-archive-subtree)
        ("A" org-archive-subtree)
        ("W" widen)
        ("d" org-down-element)
        ("k" org-cut-subtree)
        ("m" org-mark-subtree)
        ("s" org-sort)
        ("x" smex-major-mode-commands)
        ("X" org-todo-done)
        ("R" org-done-and-archive)
        ("y" org-todo-yesterday)))

(defun org-go-speed ()
  "Goes to the beginning of an element's header, so that you can execute speed commands."
  (interactive)
  (when (equal major-mode 'org-mode)
    (if (org-at-heading-p)
        (beginning-of-line)
      (outline-previous-heading))))

(bind-key "C-c s" 'org-go-speed)

;;  (add-to-list 'org-structure-template-alist '("g" "# -*- mode:org; epa-file-encrypt-to: (\"stefanol.picchiotti@gmail.com\") -*-"))
;;  (add-to-list 'org-structure-template-alist '("l" "#+BEGIN_SRC emacs-lisp\n?\n#+END_SRC" "<src lang=\"emacs-lisp\">\n?\n</src>"))

(setq org-tag-alist '(
                      ;; Depth
                      ("@immersive" . ?i) ;; "Deep"
                      ("@process" . ?p) ;; "Shallow"
                      ;; Context
                      ("@work" . ?w)
                      ("@home" . ?h)
                      ("@errand" . ?e)
                      ;; Time
                      ("15min" . ?<)
                      ("30min" . ?=)
                      ("1h" . ?>)
                      ;; Energy
                      ("Challenge" . ?1)
                      ("Average" . ?2)
                      ("Easy" . ?3)
                      ))

(org-babel-do-load-languages 'org-babel-load-languages
                             '((shell . t)))

(setq sentence-end-double-space nil)

(defun open-todo-file ()
  (interactive)
  (find-file "~/org/todo.org"))

(bind-key "C-c t" 'open-todo-file)

(add-hook 'org-mode-hook
              (lambda ()
                (push '("TODO"  . ?▲) prettify-symbols-alist)
                (push '("DONE"  . ?✓) prettify-symbols-alist)
                (push '("CANCELLED"  . ?✘) prettify-symbols-alist)
                (push '("QUESTION"  . ??) prettify-symbols-alist)))

(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

(defun the-the ()
  "Search forward for for a duplicated word."
  (interactive)
  (message "Searching for for duplicated words ...")
  (push-mark)
  ;; This regexp is not perfect
  ;; but is fairly good over all:
  (if (re-search-forward
       "\\b\\([^@ \n\t]+\\)[ \n\t]+\\1\\b" nil 'move)
      (message "Found duplicated word.")
    (message "End of buffer")))

;; Bind 'the-the' to  C-c \
(bind-key "C-c \\" 'the-the)

(defun org-pass-link-to-system (link)
  (if (string-match "^[a-zA-Z0-9]+:" link)
      (browse-url link)
    nil))

(add-hook 'org-open-link-functions 'org-pass-link-to-system)

(defun open-evernote-osx ()
  (interactive)
  (when (is-mac-p) (shell-command "open -a evernote.app")))

(defun my-insert-space ()
  (interactive)
  (progn
    (call-interactively 'avy-goto-char)
    (insert-char ?\s)))

(bind-key "M-`" 'my-insert-space)

(use-package markdown-mode)

(use-package calc
  :config
  (setq calc-display-trail ()))

(use-package shift-number
  :bind (("M-+" . shift-number-up)
         ("M-_" . shift-number-down)))

(use-package flyspell
  :bind (("C-`" . ispell-word)
         ("C-~" . ispell-buffer))
  :init
  (dolist (hook '(text-mode-hook org-mode-hook))
    (add-hook hook (lambda () (flyspell-mode 1))))
  :config
  (setq ispell-program-name "aspell"
        ispell-list-command "--list"))

(use-package pandoc-mode
  :init
  (add-hook 'pandoc-mode-hook 'pandoc-load-default-settings)
  :config
  (when (is-mac-p)
    (add-to-list 'exec-path "/usr/local/texlive/2016basic/bin/universal-darwin")))

(use-package csv-mode
  :mode ("\\.csv$" . csv-mode))

(defun copy-whole-buffer ()
  (interactive)
  (copy-region-as-kill (point-min) (point-max)))

(use-package nov
  :bind (:map nov-mode-map
              ("c" . copy-whole-buffer))
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

(defun go-to-projects ()
  (interactive)
  (find-file "~/org/todo.org")
  (widen)
  (beginning-of-buffer)
  (re-search-forward "* Projects")
  (beginning-of-line))

(defun project-overview ()
  (interactive)
  (go-to-projects)
  (org-narrow-to-subtree)
  (org-sort-entries t ?p)
  (org-columns))

(defun project-deadline-overview ()
  (interactive)
  (go-to-projects)
  (org-narrow-to-subtree)
  (org-sort-entries t ?d)
  (org-columns))

(defun my-org-agenda-list-stuck-projects ()
  (interactive)
  (go-to-projects)
  (org-agenda nil "#" 'subtree))

(defun go-to-areas ()
    (interactive)
    (find-file "~/org/todo.org")
    (widen)
    (beginning-of-buffer)
    (re-search-forward "* Areas")
    (beginning-of-line))

(defun areas-overview ()
    (interactive)
    (go-to-areas)
    (org-narrow-to-subtree)
    (org-columns))

(defun my-new-daily-review ()
  (interactive)
  (let ((org-capture-templates '(("d" "Review: Daily Review" entry (file+olp+datetree "/tmp/reviews.org")
                                  (file "~/org/templates/dailyreviewtemplate.org")))))
    (progn
      (org-capture nil "d")
      (org-capture-finalize t)
      (org-speed-move-safe 'outline-up-heading)
      (org-narrow-to-subtree)
      (fetch-calendar)
      (org-clock-in))))

(defun my-new-weekly-review ()
  (interactive)
  (let ((org-capture-templates '(("w" "Review: Weekly Review" entry (file+olp+datetree "/tmp/reviews.org")
                                  (file "~/org/templates/weeklyreviewtemplate.org")))))
    (progn
      (org-capture nil "w")
      (org-capture-finalize t)
      (org-speed-move-safe 'outline-up-heading)
      (org-narrow-to-subtree)
      (fetch-calendar)
      (org-clock-in))))

(defun my-new-monthly-review ()
  (interactive)
  (let ((org-capture-templates '(("m" "Review: Monthly Review" entry (file+olp+datetree "/tmp/reviews.org")
                                  (file "~/org/templates/monthlyreviewtemplate.org")))))
    (progn
      (org-capture nil "m")
      (org-capture-finalize t)
      (org-speed-move-safe 'outline-up-heading)
      (org-narrow-to-subtree)
      (fetch-calendar)
      (org-clock-in))))

(bind-keys :prefix-map review-map
           :prefix "C-c r"
           ("d" . my-new-daily-review)
           ("w" . my-new-weekly-review)
           ("m" . my-new-monthly-review))

(f-touch "/tmp/reviews.org")

(use-package org-randomnote
  :bind (:map launcher-map
              ("R" . org-randomnote))
  :init
  (setq org-randomnote-candidates '("~/org/todo.org"))
  (defun randomnote-osx ()
    (interactive)
    (when (is-mac-p) (shell-command "open -a randomnote.app")))
  (bind-key "r" 'randomnote-osx 'launcher-map))

(use-package wrap-region
  :init
  (wrap-region-global-mode)
  :config
  (wrap-region-add-wrapper "@@html:<mark>@@" "@@html:</mark>@@" "~" 'org-mode))

(defun find-init-file ()
  "Edit my init file in another window."
  (interactive)
  (let ((mwf-init-file "~/src/.emacs.d/michael.org"))
    (find-file mwf-init-file)))

(bind-key "C-c I" 'find-init-file)

(defun reload-init-file ()
  "Reload my init file."
  (interactive)
  (load-file user-init-file))

(bind-key "C-c M-l" 'reload-init-file)

(defun kill-this-buffer ()
  (interactive)
  (kill-buffer (current-buffer)))

(bind-key "C-x C-k" 'kill-this-buffer)

(bind-keys :map dired-mode-map
           ("q" . kill-this-buffer))

(bind-keys :map package-menu-mode-map
           ("q" . kill-this-buffer))

(defun kill-other-buffers ()
   "Kill all other buffers."
   (interactive)
   (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

(defun switch-to-minibuffer ()
  "Switch to minibuffer window."
  (interactive)
  (if (active-minibuffer-window)
      (select-window (active-minibuffer-window))
    (error "Minibuffer is not active")))

(bind-key "M-m" 'switch-to-minibuffer)

(defun find-file-as-root ()
  "Like `ido-find-file, but automatically edit the file with
root-privileges (using tramp/sudo), if the file is not writable by
user."
  (interactive)
  (let ((file (ido-read-file-name "Edit as root: ")))
    (unless (file-writable-p file)
      (setq file (concat "/sudo:root@localhost:" file)))
    (find-file file)))

(bind-key "C-x F" 'find-file-as-root)

(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn
                 (barf-if-buffer-read-only)
                 (list t)))
  (let ((fill-column (point-max)))
    (fill-paragraph nil region)))

(bind-key "M-Q" 'unfill-paragraph)

(defun move-line-up ()
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun move-line-down ()
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(bind-keys ("M-<up>" . move-line-up)
           ("M-<down>" . move-line-down))

(defun flush-empty-lines ()
  (interactive)
  (flush-lines "^$"))

(defun add-newlines-between-paragraphs ()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (< (point) (point-max))
      (move-end-of-line nil)
      (newline)
      (next-line))))

(defun clean-instapaper-evernote-notes ()
  "Cleans notes exported from Instapaper into Evernote. Copies processed buffer to clipboard."
  (interactive)
  (beginning-of-buffer)
  (replace-regexp "^\“" "")
  (beginning-of-buffer)
  (replace-regexp "\”$" "")
  (beginning-of-buffer)
  (add-newlines-between-paragraphs)
  (copy-whole-buffer))

(defun clean-liner-evernote-notes ()
  "Cleans notes exported from Liner into Evernote. Copies processed buffer to clipboard."
  (interactive)
  (beginning-of-buffer)
  (replace-regexp "Source \:" "Source:")
  (beginning-of-buffer)
  (replace-regexp "^- " "")
  (copy-whole-buffer))
