;;; -*- lexical-binding: t; -*-
(let ((minver 26))
  (unless (>= emacs-major-version minver)
    (error "Your Emacs is too old -- this configuration requires v%s or higher" minver)))

(defconst emacs-start-time (current-time))

;; load early-init.el before Emacs 27.0
(unless (featurep 'early-init)
  (message "Early init: Emacs Version < 27.0")
  (load (expand-file-name "early-init.el" user-emacs-directory)))

(setq inhibit-default-init t)           ; Disable the site default settings

(setq inhibit-startup-message t
      inhibit-startup-screen t)

(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-language-environment 'utf-8)
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

;;; package setup
(require 'package)

(setq package-archives
      '(("melpa" . "http://melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")
        ("gnu" . "https://elpa.gnu.org/packages/")))

(setq package-archive-priorities
      '(("melpa" .  3)
        ("org" . 2)
        ("gnu" . 1)))

(require 'tls)

;; From https://github.com/hlissner/doom-emacs/blob/5dacbb7cb1c6ac246a9ccd15e6c4290def67757c/core/core-packages.el#L102
(setq gnutls-verify-error (not (getenv "INSECURE")) ; you shouldn't use this
      tls-checktrust gnutls-verify-error
      tls-program (list "gnutls-cli --x509cafile %t -p %p %h"
                        ;; compatibility fallbacks
                        "gnutls-cli -p %p %h"
                        "openssl s_client -connect %h:%p -no_ssl2 -no_ssl3 -ign_eof"))

;; Initialise the packages, avoiding a re-initialisation.
(unless (bound-and-true-p package--initialized)
  (setq package-enable-at-startup nil)
  (package-initialize))

(setq load-prefer-newer t)              ; Always load newer compiled files
(setq ad-redefinition-action 'accept)   ; Silence advice redefinition warnings

;; Init `delight'
(unless (package-installed-p 'delight)
  (package-refresh-contents)
  (package-install 'delight))

;; Configure `use-package' prior to loading it.
(eval-and-compile
  (setq use-package-always-ensure nil)
  (setq use-package-always-defer nil)
  (setq use-package-always-demand nil)
  (setq use-package-expand-minimally nil)
  (setq use-package-enable-imenu-support t))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(defconst vde/custom-file (locate-user-emacs-file "custom.el")
  "File used to store settings from Customization UI.")

(use-package cus-edit
  :config
  (setq
   custom-file vde/custom-file
   custom-buffer-done-kill nil          ; Kill when existing
   custom-buffer-verbose-help nil       ; Remove redundant help text
   custom-unlispify-tag-names nil       ; Show me the real variable name
   custom-unlispify-menu-entries nil)
  (unless (file-exists-p custom-file)
    (write-region "" nil custom-file))

  (load vde/custom-file 'no-error 'no-message))

(defun vde/el-load-dir (dir)
    "Load el files from the given folder"
    (let ((files (directory-files dir nil "\.el$")))
      (while files
        (load-file (concat dir (pop files))))))

(add-to-list 'load-path (concat user-emacs-directory "lisp/"))
(vde/el-load-dir (concat user-emacs-directory "/config/"))

(defun vde/short-hostname ()
  "Return hostname in short (aka wakasu.local -> wakasu)"
  (string-match "[0-9A-Za-z-]+" system-name)
  (substring system-name (match-beginning 0) (match-end 0)))

(if (file-exists-p (downcase (concat user-emacs-directory "/hosts/" (vde/short-hostname) ".el")))
    (load-file (downcase (concat user-emacs-directory "/hosts/" (vde/short-hostname) ".el"))))

(setenv "PAGER" "cat")
(setenv "TERM" "xterm-256color")
(setenv "NOTMUCH_CONFIG" (expand-file-name ".config/notmuch/notmuchrc" (getenv "HOME")))

(use-package pinentry
  :config
  (setenv "INSIDE_EMACS" (format "%s,comint" emacs-version))
  (pinentry-start))

;; Confirm before quitting Emacs
(setq confirm-kill-emacs #'y-or-n-p)

;; C-up/down onn console
(when (not window-system)
  (define-key function-key-map "\eO1;5A"    [C-up])
  (define-key function-key-map "\eO1;5B"  [C-down])
  (define-key function-key-map "\eO1;5C" [C-right])
  (define-key function-key-map "\eO1;5D"  [C-left])
  )

(let ((elapsed (float-time (time-subtract (current-time)
                                          emacs-start-time))))
  (message "Loading %s...done (%.3fs)" load-file-name elapsed))

(add-hook 'after-init-hook
          `(lambda ()
             (let ((elapsed
                    (float-time
                     (time-subtract (current-time) emacs-start-time))))
               (message "Loading %s...done (%.3fs) [after-init]"
                        ,load-file-name elapsed))) t)

(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-region 'disabled nil)

(put 'magit-diff-edit-hunk-commit 'disabled nil)
;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:
;;; Finalization
;;; init.el ends here
