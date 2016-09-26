;;; ansible-vault.el --- Major mode for editing ansible vault files

;; Copyright (C) 2016 Zachary Elliott
;;
;; Authors: Zachary Elliott <contact@zell.io>
;; Maintainer: Zachary Elliott <contact@zell.io>
;; URL: http://github.com/zellio/ansible-vault-mode
;; Created: 2016-09-25
;; Version: 0.1.0
;; Keywords: org-mode, elisp, project
;; Package-Requires: ((cl-lib "0.4"))

;; This file is not part of GNU Emacs.

;;; Commentary:

;;

;;; License:

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 3 of the License, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.

;; You should have received a copy of the GNU General Public License along
;; with GNU Emacs; see the file COPYING.  If not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
;; USA.

;;; Code:

(require 'cl-lib)

(defconst ansible-vault-version "0.1.0"
  "`ansible-vault' version.")

(defgroup ansible-vault nil
  "`ansible-vault' application group."
  :group 'applications
  :link '(url-link :tag "Website for ansible-vault-mode"
                   "https://github.com/zellio/ansible-vault-mode")
  :prefix "ansible-vault-")

(defcustom ansible-vault-command "ansible-vault"
  "`ansible-vault' shell command."
  :type 'string
  :group 'ansible-vault)

(defcustom ansible-vault-pass-file (expand-file-name ".vault-pass" "~")
  "File containing `ansible-vault' password.

This file is used for encryption and decryption of ansible vault
files.  If it is set to `nil' `ansible-vault-mode' will prompt
you for a password."
  :type 'string
  :group 'ansible-vault)

(defcustom ansible-vault-file-header "$ANSIBLE_VAULT;1.1;AES256"
  ""
  :type 'string
  :group 'ansible-vault)

(defcustom ansible-vault-enable-autosave nil
  ""
  :type 'string
  :group 'ansible-vault)

(defvar ansible-vault--command
  (format "%s --vault-password-file='%s' --output=-"
          ansible-vault-command
          ansible-vault-pass-file)
  "")

(defvar ansible-vault--decrypt-command
  (format "%s decrypt" ansible-vault--command)
  "")

(defvar ansible-vault--encrypt-command
  (format "%s encrypt" ansible-vault--command)
  "")

;;;###autoload
(defun ansible-vault-decrypt-current-buffer ()
  ""
  (shell-command-on-region
   (point-min)
   (point-max)
   ansible-vault--decrypt-command
   (current-buffer)
   t
   (get-buffer-create "*ansible-vault-decrypt-error*")
   t))

;;;###autoload
(defun ansible-vault-encrypt-current-buffer ()
  ""
  (shell-command-on-region
   (point-min)
   (point-max)
   ansible-vault--encrypt-command
   (current-buffer)
   t
   (get-buffer-create "*ansible-vault-encrypt-error*")
   t))

(defvar ansible-vault-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap for `ansible-vault' minor mode.")

;;;###autoload
(define-minor-mode ansible-vault-mode
  "Minor mode for manipulating ansible-vault files"
  :lighter " ansible-vault"
  :keymap ansible-vault-mode-map
  :group 'ansible-vault
  ;; Decrypt the current buffer fist if it needs to be
  (if (string= (buffer-substring-no-properties
                (point-min) (+ 1 (length ansible-vault-file-header)))
               ansible-vault-file-header)
      (ansible-vault-decrypt-current-buffer))
  ;; enable file encryption
  (add-hook
   'before-save-hook
   'ansible-vault-encrypt-current-buffer
   t t)
  ;; enable file decryption
  (add-hook
   'after-save-hook
   'ansible-vault-decrypt-current-buffer
   t t)
  ;; disable autosave
  (auto-save-mode -1))

(provide 'ansible-vault)

;;; ansible-vault.el ends here