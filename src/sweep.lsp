;; author: We Rame
;; heavily refactored and expanded into a library shared by several plugins
;; starting from Steve Daulton's plugins collection
;; release 0.4.3
;; $copyright (_ "Released under terms of the GNU General Public License version 2")

; a basic sweep from one value to another; shape linear or exponential
; starts to look like SuperCollider's Env :D
; has potential for more complex shapes, but the dialog box is limiting
(defun control-sweep (ini-val fin-val &optional (sweep-type 0) (reverse-at 1.0))
   (let ((genf (case sweep-type (0 'pwlv) (1 'pwev)))
         (epts (cond ((> reverse-at 0.99) (list ini-val 1.0 fin-val))
                     ((< reverse-at 0.01) (list fin-val 1.0 ini-val))
                     (t (list ini-val reverse-at fin-val 1.0 ini-val)))))
      (apply genf epts)))
; ^^ interestingly if you run apply in debug mode it's very slow

(defun auto-dry (wet)
   (sum 1 (mult wet -1)))

;; A cyclic amplitude envelope (i.e. unipolar 0..1-valued signal) modulated
;; in its frequency by an arbitrary SOUND (stream) object yielding frequencies
(defun fm-env-gen (freq-gen table phase)
   (mult 0.5 (sum 1.0 (fmlfo freq-gen table phase))))

;; Amplitude modulation sweeper using a wavetable for the envelope sound gen
;; and control ugens ("sound"-class objects) for the wet, dry, and freq ctrls.
(defun am-sweep (mono-snd wet-gen dry-gen mod-freq-gen table phase)
   (mult mono-snd (sum dry-gen (mult wet-gen
       (fm-env-gen mod-freq-gen table phase)))))

;; converts mono track pan slider to phase: -1..1 to phase-left..phase-right
(defun phase-from-signed-pan (signed-pan phase-left phase-right)
   (let ((unsigned-pan (* (+ 1.0 signed-pan) 0.5)))
      (+ phase-left (* (- phase-right phase-left) unsigned-pan))))

;; if stereo track make array of phases for multichan-expand
;; else compute one phase using mono track pan
(defun multichan-phase-from-track (qtrack phase-left phase-right)
   (if (arrayp (eval qtrack))
       (vector (phase-from-signed-pan -1 phase-left phase-right) 
               (phase-from-signed-pan 1 phase-left phase-right))
       ; ^^ ignoring stereo track pan b/c it has different semantics than mono pan
       (phase-from-signed-pan (get qtrack 'pan) phase-left phase-right)))
       ; ^^ props don't get copied, so we need pass in the quoted *track*

;; common boilerplate for IsoMod2 and Vari-tremolo2. Maybe it should be in a
;; separate lib since it's less generic than the above functions, but "meh".

(defmacro div-by-100 (var)
   `(setq ,var (* 0.01 ,var)))

(defmacro div-each-by-100 (&rest var-list)
   `(when ,(consp var-list)
      (div-by-100 ,(first var-list)) 
      (div-each-by-100 ,@(rest var-list))))
;; non-recursive version, but not CL compliant and I'm afraid of mapcar bugs
;(defmacro div-each-by-100 (&rest var-list)
;  (let ((hmmm (lambda (var) (macroexpand-1 `(div-by-100 ,var)))))
;    `(eval (cons 'progn (mapcar ,hmmm ',var-list)))))

(defun sweepy-plugin (ini-af fin-af af-sweep-type reverse-at
                      ini-md fin-md phaseL phaseR wave-table)
   (div-each-by-100 reverse-at ini-md fin-md)
   (let* ((am-freq (control-sweep ini-af fin-af af-sweep-type reverse-at))
         ;Should the reverse point auto-apply to the wet ramp too? Yes for now.
         ;todo: optional wet sweep type maybe, besides linear
         ;todo: mc-expanded wet and dry for sep. ctrls. per chan?
          (wet (control-sweep ini-md fin-md 0 reverse-at))
          (dry (auto-dry wet)))
      (multichan-expand #'am-sweep *track* wet dry am-freq wave-table
         (multichan-phase-from-track '*track* phaseL phaseR))))
