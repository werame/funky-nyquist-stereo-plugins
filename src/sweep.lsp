;; author "Steve Daulton, We Rame"
;; release 0.1
;; $copyright (_ "Released under terms of the GNU General Public License version 2")

;; Library shared by several plugins

;; Function to generate sweep tone
(defun sweep (sf ef wf ph)
     (mult 0.5 (sum 1.0 (fmlfo (pwlv sf 1.0 ef) wf ph))))
