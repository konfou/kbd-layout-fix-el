;;; kbd-layout-fix.el --- Auto-correct text entered with the wrong keyboard layout  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Konstantinos Foutzopoulos

;; Author: Konstantinos Foutzopoulos <mail@konfou.xyz>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Adapted from https://github.com/dspinellis/kbd-layout-fix
;; Set a key binding to function in config file.
;; Take care to bind function such as be available for both layouts.
;; For example in order to use the wrapper function for Greek/Latin layouts:
;;
;;   (global-set-key (kbd "C-x C-g") 'greek-latin-fix)
;;   (global-set-key (kbd "C-χ C-γ") 'greek-latin-fix)

;;; Code:

;; Probably not good algorithm as it runs over supplied string multiple times.
;; Is string-zip required or can iterate over two loops silmutaneously?
;; Optimally should read over text in a single loop?
;; Check whether a dead exists, if it doesn't replace using the single key map.
;; If it does, read text character and perform corresponding replacement.
;; Idiomatically rather loop use a functional implementation, e.g. map?

(require 'cl-lib)

(defun layout-maps (layout-a layout-b)
  "Return LAYOUT-A and LAYOUT-B mappings."
  (pcase (concat layout-a "-" layout-b)
    ("us-gr"
     '(("single-key-maps" .
        (("abcdefghijklmnopqrstuvwxyz" . "αβψδεφγηιξκλμνοπ;ρστθωςχυζ")
         ("ABCDEFGHIJKLMNOPQRSTUVWXYZ" . "ΑΒΨΔΕΦΓΗΙΞΚΛΜΝΟΠ;ΡΣΤΘΩΣΧΥΖ")))
       ("dead-key-maps" .
        ((";" . (("aehioyv" . "άέήίόύώ")
                 ("AEHIOYV" . "ΆΈΉΊΌΎΏ")))
         (":" . (("iy" . "ϊϋ")
                 ("IY" . "ΪΫ")))))))))

(defun string-zip (string-a string-b)
  "Aggregate STRING-A and STRING-B to list of corresponding characters."
  (mapcar* #'cons (split-string string-a "" t) (split-string string-b "" t)))

(defun single-key-replace (string source target)
  "Replace each character in STRING from SOURCE to its TARGET corresponding."
  (cl-loop for x in (string-zip source target) do
           (setq string
                 (replace-regexp-in-string (car x) (cdr x) string)))
  string)

(defun dead-key-replace (string dead source target)
  "Replace each DEAD key character in STRING from SOURCE to its TARGET corresponding."
  (cl-loop for x in (string-zip source target) do
           (setq string
                 (replace-regexp-in-string (concat dead (car x)) (cdr x) string)))
  string)

(defun kbd-layout-fix (string layout-a layout-b)
  "Auto-correct STRING between LAYOUT-A and LAYOUT-B."
  (if (use-region-p)
    (setq string (buffer-substring-no-properties (region-beginning) (region-end))))
  (let* ((maps (layout-maps layout-a layout-b))
         ;; Take the mappings for the two layouts.
         (single-key-maps (cdr (assoc "single-key-maps" maps)))
         (dead-key-maps (cdr (assoc "dead-key-maps" maps)))
         ;; Take every character when in LAYOUT-A.
         (chars-a (mapcar* #'car (append single-key-maps dead-key-maps)))
         ;; Construct regex checking for LAYOUT-A.
         (regex-a (concat "^[" (mapconcat 'identity chars-a "") " ]+$")))
    ;; Assuming that diacritics only exist in one layout.
    (if (string-match-p regex-a string)
        ;; Convert from LAYOUT-A to LAYOUT-B.
        (progn
          (cl-loop for dead-map in dead-key-maps do
                   (let ((key (car dead-map)))
                     (cl-loop for map in (cdr dead-map) do
                              (setq string (dead-key-replace string key (car map) (cdr map))))))
          (cl-loop for map in single-key-maps do
                   (setq string
                         (single-key-replace string (car map) (cdr map)))))
      ;; Convert from LAYOUT-B to LAYOUT-A.
      (cl-loop for map in single-key-maps do
               (setq string
                     (single-key-replace string (cdr map) (car map))))))
  (if (use-region-p)
      (save-excursion
        (delete-region (region-beginning) (region-end))
        (goto-char (region-beginning))
        (insert string))
    string))

(defun greek-latin-fix (&optional string)
  "Auto-correct STRING between Greek and Latin layouts."
  (interactive)
  (if (use-region-p)
      (kbd-layout-fix nil "us" "gr")
    (kbd-layout-fix string "us" "gr")))

(provide 'kbd-layout-fix)
;;; kbd-layout-fix.el ends here
