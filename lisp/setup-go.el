;;; setup-go.el --- setup go mode(s)
;;; Commentary:
;;; Code:
;;; -*- lexical-binding: t; -*-

(use-package go-mode
  :mode "\\.go$"
  :interpreter "go"
  :bind (:map go-mode-map
	      ("C-," . 'hydra-go/body))
  :init
  (defhydra hydra-go (:hint nil :color teal)
    "
         ^Command^      ^Imports^       ^Doc^
         ^-------^      ^-------^       ^---^
      _r_: run      _ig_: goto       _d_: doc at point
    [_g_]: guru     _ia_: add
    ^  ^            _ir_: remove
    "
    ("g" 'hydra-go-guru/body :color blue)
    ("r" go-run-main)
    ("d" godoc-at-point)
    ("ig" go-goto-imports )
    ("ia" go-import-add)
    ("ir" go-remove-unused-imports)
    ("q" nil "quit" :color blue))
  :config
  (use-package company-go
    :config
    (setq company-go-show-annotation t)
    (push 'company-go company-backends))
  (setq gofmt-command "goimports")
  (if (not (executable-find "goimports"))
      (warn "go-mode: couldn't find goimports; no code formatting/fixed imports on save")
    (add-hook 'before-save-hook 'gofmt-before-save))
  (if (not (string-match "go" compile-command))   ; set compile command default
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet")))

(use-package go-guru
  :commands (go-guru-describe go-guru-freevars go-guru-implements go-guru-peers
             go-guru-referrers go-guru-definition go-guru-pointsto
             go-guru-callstack go-guru-whicherrs go-guru-callers go-guru-callees
             go-guru-expand-region)
  :config
  (unless (executable-find "guru")
    (warn "go-mode: couldn't find guru, refactoring commands won't work"))
  (add-hook 'go-mode-hook #'go-guru-hl-identifier-mode)
  (defhydra hydra-go-guru (:color pink :columns 2 :hint nil)
    "
^NAME^             ^TYPE^            ^CALL^           ^ALIAS^
_._: definition    _d_: describe     _lr_: callers     _p_: pointsto
_r_: referrers     _i_: implement    _le_: callees     _c_: peers
_f_: freevars      ^ ^               _s_: callstack    _e_: whicherrs"
    ("." go-guru-definition)
    ("r" go-guru-referrers)
    ("f" go-guru-freevars)
    ("d" go-guru-describe)
    ("i" go-guru-implements)
    ("lr" go-guru-callers)
    ("le" go-guru-callees)
    ("s" go-guru-callstack)
    ("p" go-guru-pointsto)
    ("c" go-guru-peers)
    ("e" go-guru-whicherrs)
    ("S" go-guru-set-scope "scope" :color blue)))

(use-package go-eldoc
  :defer 2
  :config
  (add-hook 'go-mode-hook 'go-eldoc-setup))

(use-package gotest
  :defer 2
  :after go-mode
  :bind (:map go-mode-map
              ("C-c t m" . go-test-current-file)
              ("C-c t ." . go-test-current-test)
              ("C-c t c" . go-test-current-coverage)
              ("C-c t b" . go-test-current-benchmark)))

(use-package flycheck-golangci-lint
  :hook (go-mode . flycheck-golangci-lint-setup)
  :config (setq flycheck-golangci-lint-tests t))

(use-package godoctor
  :defer 2
  :after go-mode)

;; (use-package lsp-go
;;   :defer 2
;;   :after lsp-mode
;;   :hook ((go-mode . lsp-go-enable)))

(provide 'setup-go)

;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:
