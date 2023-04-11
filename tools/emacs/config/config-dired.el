;;; config-dired.el --  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Configuration of Dired
;;; Code:

(use-package dired
  :unless noninteractive
  :commands (dired find-name-dired)
  :bind (("C-c RET" . vde/open-in-external-app)
         ("C-c f g" . vde/dired-get-size)
         ("M-s d" . vde/dired-fd-dirs)
         ("M-s z" . vde/dired-fd-files-and-dirs)
         ("C-c f f"    . find-name-dired)
         (:map dired-mode-map
               ("M-p"         . vde/dired-up)
               ("^"           . vde/dired-up)
               ("<backspace>" . vde/dired-up)
               ("M-n"         . vde/dired-down)
               ("RET"         . find-file-reuse-dir-buffer)
               ("!"           . vde/sudired)
               ("<prior>"     . beginend-dired-mode-goto-beginning)
               ("<next>"      . beginend-dired-mode-goto-end)))
  :config
  (setq-default dired-auto-revert-buffer t
                dired-recursive-copies 'always
                dired-recursive-deletes 'always
                dired-isearch-filenames 'dwim
                delete-by-moving-to-trash t
                dired-listing-switches "-lFaGh1v --group-directories-first"
                dired-ls-F-marks-symlinks t
                dired-dwim-target t)
  (when (string= system-type "darwin")
    (setq dired-use-ls-dired t
          insert-directory-program "/usr/local/bin/gls"))

  ;; Enable dired-find-alternate-file
  (put 'dired-find-alternate-file 'disabled nil)

  ;; Handle long file names
  (add-hook 'dired-mode-hook #'toggle-truncate-lines)

  (defun vde/dired-up ()
    "Go to previous directory."
    (interactive)
    (find-alternate-file ".."))

  (defun vde/dired-down ()
    "Enter directory."
    (interactive)
    (dired-find-alternate-file))

  (defun vde/open-in-external-app ()
    "Open the file(s) at point with an external application."
    (interactive)
    (let* ((file-list
            (dired-get-marked-files)))
      (mapc
       (lambda (file-path)
         (let ((process-connection-type nil))
           (start-process "" nil "xdg-open" file-path))) file-list)))

  (defun find-file-reuse-dir-buffer ()
    "Like `dired-find-file', but reuse Dired buffers."
    (interactive)
    (set-buffer-modified-p nil)
    (let ((file (dired-get-file-for-visit)))
      (if (file-directory-p file)
          (find-alternate-file file)
        (find-file file))))

  (defun vde/sudired ()
    "Open directory with sudo in Dired."
    (interactive)
    (require 'tramp)
    (let ((dir (expand-file-name default-directory)))
      (if (string-match "^/sudo:" dir)
          (user-error "Already in sudo")
        (dired (concat "/sudo::" dir)))))

  (defun vde/dired-get-size ()
    "Quick and easy way to get file size in Dired."
    (interactive)
    (let ((files (dired-get-marked-files)))
      (with-temp-buffer
        (apply 'call-process "du" nil t nil "-sch" files)
        (message
         "Size of all marked files: %s"
         (progn
           (re-search-backward "\\(^[0-9.,]+[A-Za-z]+\\).*total$")
           (match-string 1))))))
  (defmacro vde/dired-fd (name doc prompt &rest flags)
    "Make commands for selecting 'fd' results with completion.
NAME is how the function should be named.  DOC is the function's
documentation string.  PROMPT describes the scope of the query.
FLAGS are the command-line arguments passed to the 'fd'
executable, each of which is a string."
    `(defun ,name (&optional arg)
       ,doc
       (interactive "P")
       (let* ((vc (vc-root-dir))
              (dir (expand-file-name (if vc vc default-directory)))
              (regexp (read-regexp
                       (format "%s matching REGEXP in %s: " ,prompt
                               (propertize dir 'face 'bold))))
              (names (process-lines "fd" ,@flags regexp dir))
              (buf "*FD Dired*"))
         (if names
             (if arg
                 (dired (cons (generate-new-buffer-name buf) names))
               (icomplete-vertical-do ()
                 (find-file
                  (completing-read (format "Items matching %s (%s): "
                                           (propertize regexp 'face 'success)
                                           (length names))
                                   names nil t)))))
         (user-error (format "No matches for « %s » in %s" regexp dir)))))

  (vde/dired-fd
   vde/dired-fd-dirs
   "Search for directories in VC root or PWD.
With \\[universal-argument] put the results in a `dired' buffer.
This relies on the external 'fd' executable."
   "Subdirectories"
   "-i" "-H" "-a" "-t" "d" "-c" "never")

  (vde/dired-fd
   vde/dired-fd-files-and-dirs
   "Search for files and directories in VC root or PWD.
With \\[universal-argument] put the results in a `dired' buffer.
This relies on the external 'fd' executable."
   "Files and dirs"
   "-i" "-H" "-a" "-t" "d" "-t" "f" "-c" "never")
  )

(use-package find-dired
  :after dired
  :commands (find-name-dired)
  :config
  (setq-default find-ls-option ;; applies to `find-name-dired'
                '("-ls" . "-AFhlv --group-directories-first")
                find-name-arg "-iname"))

(use-package dired-x
  :after dired
  :bind ("C-x C-j" . dired-jump)
  :commands (dired-jump dired-omit-mode)
  :config
  (setq-default dired-omit-files (concat dired-omit-files "\\|^\\.+$\\|^\\..+$")
                dired-omit-verbose nil
                dired-clean-confirm-killing-deleted-buffers nil))

(use-package dired-aux
  :unless noninteractive
  :after dired
  :config
  (setq-default
   ;; Ask for creation of missing directories when copying/moving
   dired-create-destination-dirs 'ask
   ;; Search only file names when point is on a file name
   dired-isearch-filenames'dwim))

(use-package dired-collapse
  :unless noninteractive
  :commands (dired-collapse-mode)
  :hook (dired-mode . dired-collapse-mode))

(use-package async)
(use-package dired-async
  :unless noninteractive
  :after (dired async)
  :commands (dired-async-mode)
  :hook (dired-mode . dired-async-mode))

(use-package dired-narrow
  :unless noninteractive
  :after dired
  :commands (dired-narrow)
  :bind (:map dired-mode-map
              ("M-s n" . dired-narrow))
  :config
  (setq-default dired-narrow-exit-when-one-left t
                dired-narrow-enable-blinking t
                dired-narrow-blink-time 0.3))

(use-package wdired
  :unless noninteractive
  :after dired
  :commands (wdired-mode
             wdired-change-to-wdired-mode)
  :config
  (setq-default wdired-allow-to-change-permissions t
                wdired-create-parent-directories t))

(use-package dired-rsync
  :unless noninteractive
  :after dired
  :commands (dired-rsync)
  :bind (:map dired-mode-map
              ("r" . dired-rsync)))

(use-package dired-subtree
  :unless noninteractive
  :after dired
  :config
  (setq dired-subtree-use-backgrounds nil)
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)
              ("<C-tab>" . dired-subtree-cycle)
              ("<S-iso-lefttab>" . dired-subtree-remove)))

(use-package diredfl
  :unless noninteractive
  :commands (diredfl-mode)
  :config
  (setq diredfl-ignore-compressed-flag nil)
  :hook (dired-mode . diredfl-mode))

(use-package trashed
  :unless noninteractive
  :commands (trashed)
  :config
  (setq trashed-action-confirmer 'y-or-n-p)
  (setq trashed-use-header-line t)
  (setq trashed-sort-key '("Date deleted" . t))
  (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

(provide 'config-dired)
;; config-dired.el ends here
