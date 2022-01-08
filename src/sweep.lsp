;; author "Steve Daulton, We Rame"
;; release 0.3.7.1
;; $copyright (_ "Released under terms of the GNU General Public License version 2")

;; Library shared by several plugins

; todo: think of better names for these functions

;; Function to generate sweep tone
(defun sweep (sf ef wf ph)
     (mult 0.5 (sum 1.0 (fmlfo (pwlv sf 1.0 ef) wf ph))))

; starts to look like SuperCollider's Env :D
(defun control-sweep (ini-val fin-val &optional (sweep-type 0))
   (case sweep-type
      (0 (pwlv ini-val 1.0 fin-val))
      (1 (pwev ini-val 1.0 fin-val))))

(defun auto-dry (wet)
   (sum 1 (mult wet -1)))

;; A cyclic amplitude envelope (i.e. unipolar 0..1-valued signal) modulated
;; in its frequency by an arbitrary SOUND (stream) object yielding frequencies
(defun fmenv (freq-gen table phase)
   (mult 0.5 (sum 1.0 (fmlfo freq-gen table phase))))

; todo: maybe factor out the wet and dry sound objects
; todo: the whole f-sweep thing could also be extracted
(defun am-sweep (mono-snd ini-wet fin-wet ini-modf fin-modf table phase)
   (let* ((wet (pwlv ini-wet 1 fin-wet))
          (dry (sum 1 (mult wet -1))))
      (mult mono-snd (sum dry (mult wet
       (sweep ini-modf fin-modf table phase)))))) ; todo: let-var this

(defun am-sweep-new2 (mono-snd wet-gen dry-gen mod-freq-gen table phase)
   (mult mono-snd (sum dry-gen (mult wet-gen
       (fmenv mod-freq-gen table phase)))))

;; converts mono track pan slider to phase: -1..1 to phase-left..phase-right
; todo: maybe make it return a lambda after binding phase-left phase-right
(defun phase-from-signed-pan (signed-pan phase-left phase-right)
   (let ((unsigned-pan (* (+ 1.0 signed-pan) 0.5)))
      (+ phase-left (* (- phase-right phase-left) unsigned-pan))))

;; if stereo track make array of phases for multichan-expand
;; else compute one phase using mono track pan
(defun multichan-phase-from-track (track phase-left phase-right)
   (if (arrayp track)
       (vector (phase-from-signed-pan -1 phase-left phase-right) 
               (phase-from-signed-pan 1 phase-left phase-right))
       ; ^^ ignoring stereo track pan b/c it has different semantics than mono pan
       (phase-from-signed-pan (get '*track* 'pan) phase-left phase-right)))
