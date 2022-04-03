;;; early-init.el --- Early Init File -*- lexical-binding: t -*-
;; Initialise installed packages

;; Always load newest byte code
(setq load-prefer-newer t)

;; Do not resize the frame at this early stage.
(setq frame-inhibit-implied-resize t)

;; Disable GUI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)           ; Disable tooltips
(blink-cursor-mode -1)      ; Disable cursor blinking
(setq inhibit-splash-screen t)
(setq use-dialog-box t)                 ; only for mouse events
(setq use-file-dialog nil)

(setq inhibit-startup-echo-area-message user-login-name) ; read the docstring
(setq inhibit-startup-screen t)
(setq inhibit-startup-buffer-menu t)
(setq inhibit-startup-message t)

(setq native-comp-async-report-warnings-errors 'silent) ; emacs28 with native compilation

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)
