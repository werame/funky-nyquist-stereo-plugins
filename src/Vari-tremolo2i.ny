;nyquist plug-in
;version 3
;type process
;categories "http://lv2plug.in/ns/lv2core#ModulatorPlugin"
;name "Variable Tremolo2i"
;action "Applying Tremolo..."
;info "by Steve Daulton & werame5913. Released under terms of GPL Version 2\nhttp://audacity.easyspacepro.com\n\n'Starting phase' sets where to start tremolo in the waveform cycle.\nThe speed and depth of the tremolo oscilation can be set for the\nstart and the end of the selection.\nThe transition from initial settings to final settings is linear."

;control wave1 "Tremolo Shape 1" choice "sine,sine peak mid,triangle,sawtooth,inverse sawtooth,square,square peak mid" 0
;control maxa1 "Shape 1 Peak Scale" real "%" 100 20 100
;control wave2 "Tremolo Shape 2" choice "sine,sine peak mid,triangle,sawtooth,inverse sawtooth,square,square peak mid" 5
;control maxa2 "Shape 2 Peak Scale" real "%" 100 20 100

;control isteps "Interpol. Steps" int "(per halfcycle)" 2 1 20
;control csteps "Constant Steps" int "(per halfcycle)" 0 0 20

;;;control phaseL "Starting Phase Left" real "degrees" 0 0 360
;control phaseR "Starting Phase Right" real "degrees" 180 0 360
;control phRmul "Phase Right Extra" real "X 360 deg." 0 0 40

;control startf "Initial Tremolo Frequency" real "Hz" 12 1 20
;control endf "Final Tremolo Frequency" real "Hz" 4 1 20
;control starta "Initial Tremolo Amount" int "%" 40 0 100
;control enda "Final Tremolo Amount" int "%" 40 0 100

(setq maxa1 (/ maxa1 100.0))
(setq maxa2 (/ maxa2 100.0))

; set tremolo waveform 

(defun wave-snd (wavenum phase)
  (abs-env
	(case wavenum
		(0 (hzosc 1 *sine-table* phase))
		(1 (hzosc 1 *sine-table* (- phase 90)))
		(2 (hzosc 1 *tri-table* phase))
		; sawtooth
		(3 (hzosc 1 (maketable (pwlv -1 0.995 1 1 -1)) phase))
		; inverse sawtooth
		(4 (hzosc 1 (maketable (pwlv -1 0.005 1 1 -1)) phase))
		; square
		(5 (hzosc 1 (maketable (pwlv -1 0.005 1 0.5 1 0.505 -1 1 -1)) phase))
		(6 (hzosc 1 (maketable (pwlv -1 0.005 1 0.5 1 0.505 -1 1 -1)) (- phase 90))) )))


(setq steps (* 2 (+ isteps csteps)))
(setq ctime (/ (float csteps) steps))

; set tremolo *waveform* 
(setq *waveform* 
;   (abs-env (list (siosc (hz-to-step steps) (const 0) (list
;		(mult maxa1 (wave-snd wave1 0)) 0.5 (mult maxa2 (wave-snd wave2 0)) 1 (mult maxa1 (wave-snd wave1 0)))) (hz-to-step steps) t)))
	(abs-env (list (siosc (hz-to-step steps) (const 0) (list	
		(mult maxa1 (wave-snd wave1 0)) ctime (mult maxa1 (wave-snd wave1 0)) 0.5 (mult maxa2 (wave-snd wave2 0))
		(+ 0.5 ctime) (mult maxa2 (wave-snd wave2 0)) 1 (mult maxa1 (wave-snd wave1 0)))) (hz-to-step steps) t)))

;; Function to generate sweep tone
(defun sweep (sf ef wf ph)
    (mult 0.5 (sum 1.0 (fmlfo (pwev sf 0.5 ef 1.0 sf) wf ph))))

(setq phaseL 0) ; too many paras in the box adds a scroll

(let* ((starta (/ starta 100.0))
	(enda (/ enda 100.0))
	(wet (pwlv starta 0.5 enda 1 starta))
	(dry (sum 1 (mult wet -1))))
	(mult s (vector 
		(sum dry (mult wet (sweep startf endf *waveform* phaseL)))
		(sum dry (mult wet (sweep startf endf *waveform* (+ phaseR (* 360 phRmul))))))))
