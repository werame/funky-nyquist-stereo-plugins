;; author: We Rame, heavily refactored in a library 
;; starting from Steve Daulton's plugins collection
;; release 0.3.8
;; $copyright (_ "Released under terms of the GNU General Public License version 2")

;; Library shared by several plugins

; todo: think of better names for these functions

; a basic sweep from one value to another; shape linear or exponential
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

;; Amplitude modulation sweeper using a wavetable for the envelope sound gen
;; and control ugens ("sound"-class objects) for the wet, dry, and freq ctrls.
(defun am-sweep (mono-snd wet-gen dry-gen mod-freq-gen table phase)
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
