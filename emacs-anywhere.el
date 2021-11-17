;;; emacs-anywhere.el --- Use Emacs anywhere! -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Solid
;;
;; Author: Solid <soliditsallgood@mailbox.org>
;; Keywords: convenience
;; Version: 0.1
;; Package-Requires: ((emacs "24.1"))
;; Homepage: https://gitlab.com/slotThe/emacs-anywhere

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This is a spin on the excellent collection of "emacs-anywhere" shell
;; scripts [1], but stripped down to fit my needs (having all of the
;; actual window management done by xmonad), as well as implemented in
;; elisp only.
;;
;; To use, simply bind an instance of emacsclient to execute
;; `emacs-anywhere'.  For example, I have something along the lines of
;;
;;     emacsclient -a '' -c -F '(quote (name . \"emacs-anywhere\"))' -e '(emacs-anywhere)'
;;
;; bound as a scratchpad in my xmonad configuration.
;;
;; [1]: https://github.com/zachcurry/emacs-anywhere

;;; Code:

(require 'xclip)

(declare-function server-buffer-done "server-buffer-done")
(declare-function markdown-mode "markdown-mode")

(define-minor-mode emacs-anywhere-mode
  "A minor mode for using Emacs anywhere!"
  :init-value nil
  :keymap `((,(kbd "C-c C-c") . emacs-anywhere--done )
            (,(kbd "C-c C-k") . emacs-anywhere--abort)
            (,(kbd "C-x C-c") . emacs-anywhere--abort)))

;;;###autoload
(defun emacs-anywhere ()
  "Start an `emacs-anywhere' editing session."
  (find-file (make-temp-file "emacs-anywhere_"))
  (markdown-mode)
  (visual-line-mode)
  (emacs-anywhere-mode))

(defun emacs-anywhere--done (&optional abort)
  "Finish an `emacs-anywhere' editing session.
Optional argument ABORT signals an unsuccessful end; i.e.,
discard the buffer contents instead of saving them to the
clipboard."
  (interactive)
  (when emacs-anywhere-mode
    (delete-trailing-whitespace)
    (let ((str (buffer-string)))
      ;; Clean up, properly.
      (emacs-anywhere-mode -1)
      (delete-file buffer-file-name)
      (server-buffer-done (current-buffer))
      (delete-frame)
      ;; Insert the paste to the currently focused window.  The system's
      ;; window manager is (and should be!) responsible for setting the
      ;; focus back to the original window.
      (unless abort
        ;; A bit overkill, but the easiest way to make this work in the
        ;; terminal and in GUI applications.
        (xclip-set-selection 'clipboard str)
        (xclip-set-selection 'primary   str)
        (call-process
         "xdotool" nil nil nil "key" "--clearmodifiers" "Shift+Insert")))))

(defun emacs-anywhere--abort ()
  "Abort an `emacs-anywhere' editing session."
  (interactive)
  (emacs-anywhere--done 'abort))

(provide 'emacs-anywhere)
;;; emacs-anywhere.el ends here
