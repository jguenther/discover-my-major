;;; discover-my-major.el --- Discover key bindings and their meaning for the current Emacs major mode

;; Copyright (C) 2014, Steckerhalter

;; Author: steckerhalter
;; Package-Requires: ((makey "0.2"))
;; URL: https://github.com/steckerhalter/discover-my-major
;; Keywords: discover help major-mode keys

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Discover key bindings and their meaning for the current Emacs major mode

;;; Code:

(defun dmm/major-mode-actions ()
  (delq nil (mapcar 'dmm/format-binding (dmm/major-mode-bindings))))

(defun dmm/major-mode-bindings (&optional buffer)
  (let ((buffer (or buffer (current-buffer))))
    (cdr (assoc "Major Mode Bindings:" (dmm/descbinds-all-sections (current-buffer))))))

(defun dmm/doc-summary (doc)
  (let* ((docstring (cdr (help-split-fundoc doc nil)))
         (get-summary (lambda (str)
                        (string-match "^\\(.*\\)$" str)
                        (match-string 0 str))))
    (funcall get-summary (if docstring docstring doc))))

(defun dmm/format-binding (item)
  (let* ((key (car item))
         (str (cdr item))
         (sym (intern-soft str))
         (doc (when (and sym (fboundp sym)) (documentation sym))))
    (when doc
      (list key (dmm/doc-summary doc) str))))

(defun dmm/descbinds-all-sections (buffer &optional prefix menus)
  (with-temp-buffer
    (let ((indent-tabs-mode t))
      (describe-buffer-bindings buffer prefix menus))
    (goto-char (point-min))
    (let ((header-p (not (= (char-after) ?\f)))
          sections header section)
      (while (not (eobp))
        (cond
         (header-p
          (setq header (buffer-substring-no-properties
                        (point)
                        (line-end-position)))
          (setq header-p nil)
          (forward-line 3))
         ((= (char-after) ?\f)
          (push (cons header (nreverse section)) sections)
          (setq section nil)
          (setq header-p t))
         ((looking-at "^[ \t]*$")
          ;; ignore
          )
         (t
          (let ((binding-start (save-excursion
                                 (and (re-search-forward "\t+" nil t)
                                      (match-end 0))))
                key binding)
            (when binding-start
              (setq key (buffer-substring-no-properties (point) binding-start)
                    key (replace-regexp-in-string"^[ \t\n]+" "" key)
                    key (replace-regexp-in-string"[ \t\n]+$" "" key))
              (goto-char binding-start)
              (setq binding (buffer-substring-no-properties
                             binding-start
                             (line-end-position)))
              (unless (member binding '("self-insert-command"))
                (push (cons key binding) section))))))
        (forward-line))
      (push (cons header (nreverse section)) sections)
      (nreverse sections))))

(defun dmm/get-makey-func (group-name)
  (intern-soft (concat "makey-key-mode-popup-" (symbol-name group-name))))

;;;###autoload
(defun discover-my-major ()
  (interactive)
  (let* ((group-name major-mode))
    (unless (dmm/get-makey-func group-name)
      (makey-initialize-key-groups
       (list `(,group-name
               (description (format "%s Major mode" ,major-mode))
               (actions ,(cons major-mode (dmm/major-mode-actions)))))))
    (funcall (dmm/get-makey-func group-name))))

(provide 'discover-my-major)

;;; discover-my-major.el ends here
