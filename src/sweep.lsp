;; author "Steve Daulton, We Rame"
;; release 0.1
;; $copyright (_ "Released under terms of the GNU General Public License version 2")

;; Library shared by several plugins

; todo: think of better names for thse functions

;; Function to generate sweep tone
(defun sweep (sf ef wf ph)
     (mult 0.5 (sum 1.0 (fmlfo (pwlv sf 1.0 ef) wf ph))))

; todo: maybe factor out the wet and dry sound objects
; todo: the whole f-sweep thing could also be extracted
(defun am-sweep (mono-snd ini-wet fin-wet ini-modf fin-modf table phase)
   (let* ((wet (pwlv ini-wet 1 fin-wet))
          (dry (sum 1 (mult wet -1))))
      (mult mono-snd (sum dry (mult wet
       (sweep ini-modf fin-modf table phase)))))) ; todo: let-var this
