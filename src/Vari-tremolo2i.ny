;nyquist plug-in
;version 4
;type process
;name "VT2 interpolating"
;action "Applying Tremolo..."
;author "We Rame, Steve Daulton"
;release 0.4.3
$copyright (_ "Released under terms of the GNU General Public License version 2")

;; We Rame's stereo & interpolating version. A modification of the original:
;; info "by Steve Daulton. Released under terms of GPL Version 2\nhttp://audacity.easyspacepro.com\n\n'Starting phase' sets where to start tremolo in the waveform cycle.\nThe speed and depth of the tremolo oscilation can be set for the\nstart and the end of the selection.\nThe transition from initial settings to final settings is linear."

;;; todo: more suggestive name to better indicate alignment
;control wave1 "Tremolo Shape 1" choice "sine,sine peak mid,triangle,sawtooth,inverse sawtooth,square,square peak mid" 0
;control maxa1 "Shape 1 Peak Scale" real "%" 100 20 100
;control wave2 "Tremolo Shape 2" choice "sine,sine peak mid,triangle,sawtooth,inverse sawtooth,square,square peak mid" 5
;control maxa2 "Shape 2 Peak Scale" real "%" 100 20 100

;control isteps "Interpol. Steps" int "(per halfcycle)" 2 1 20
;control csteps "Constant Steps" int "(per halfcycle)" 0 0 20

;;;control phaseL "Starting Phase Left" real "degrees" 0 0 360
;control phaseR "Starting Phase Right" real "degrees" 180 0 360
;control phRmul "Phase Right Extra" real "X 360 deg." 0 0 40

;control ini-tf "Initial Tremolo Frequency" real "Hz" 15 0.1 50
;control fin-tf "Final Tremolo Frequency" real "Hz" 1 0.1 50
;;;control freq-sweep-type "Frequency Sweep Type" choice "Linear,Exponential" 1
;;;control reverse-at "Reverse Sweep at" int "% (100% = no)" 50 0 100
;control ini-md "Initial Tremolo Amount" int "%" 60 0 100
;control fin-md "Final Tremolo Amount" int "%" 20 0 100

(setq maxa1 (/ maxa1 100.0))
(setq maxa2 (/ maxa2 100.0))

; Creates (the two) tremolo keyframe waveforms as sound objects
(defun wave-snd (wavenum phase)
  (abs-env (case wavenum
    (0 (hzosc 1 *sine-table* phase))
    (1 (hzosc 1 *sine-table* (- phase 90)))
    (2 (hzosc 1 *tri-table* phase))
    ; sawtooth
    (3 (hzosc 1 (maketable (pwlv -1 0.995 1 1 -1)) phase))
    ; inverse sawtooth
    (4 (hzosc 1 (maketable (pwlv -1 0.005 1 1 -1)) phase))
    ; square
    (5 (hzosc 1 (maketable (pwlv -1 0.005 1 0.5 1 0.505 -1 1 -1)) phase))
    (6 (hzosc 1 (maketable (pwlv -1 0.005 1 0.5 1 0.505 -1 1 -1)) (- phase 90))))))

(setq steps (* 2 (+ isteps csteps)))
(setq ctime (/ (float csteps) steps))

; And turns them into a wavetable using interpolation. 
; IIRC not using the maketable helper because that only supports step=1,
; although (todo) it seems to call snd-extent so maybe we can make it work.
; todo: maybe add feature to shift sounds to zero, because mult<1 raises them
(setq *tremolo-table* (abs-env (list 
    (siosc (hz-to-step steps) (const 0)
           (list          (mult maxa1 (wave-snd wave1 0)) ; todo: let
            ctime         (mult maxa1 (wave-snd wave1 0))
            0.5           (mult maxa2 (wave-snd wave2 0))
            (+ 0.5 ctime) (mult maxa2 (wave-snd wave2 0))
            1             (mult maxa1 (wave-snd wave1 0))))
    (hz-to-step steps) t)))

(psetq freq-sweep-type 1 reverse-at 50.0) ; those damn percentages!
(setq phaseL 0) ; too many paras in the box adds a scroll
(setq phaseR (+ phaseR (* 360 phRmul)))

(load "sweep.lsp" :verbose t :print t)

(sweepy-plugin ini-tf fin-tf freq-sweep-type reverse-at
   ini-md fin-md phaseL phaseR *tremolo-table*)
