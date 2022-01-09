;nyquist plug-in
;version 4
;type process
;name "Variable Tremolo2"
;action "Applying Tremolo..."
;preview selection
;author "Steve Daulton, We Rame"
;release 0.4.2.1
$copyright (_ "Released under terms of the GNU General Public License version 2")

;; We Rame's stereo version with phase amplitude per channel. A modification of the original:
;info "by Steve Daulton. Released under terms of GPL Version 2\nhttp://audacity.easyspacepro.com\n\n'Starting phase' sets where to start tremolo in the waveform cycle.\nThe speed and depth of the tremolo oscilation can be set for the\nstart and the end of the selection.\nThe transition from initial settings to final settings is linear."

;control wave-num "Tremolo Shape" choice "Sine,Triangle,Sawtooth,Inverse sawtooth,Square" 0
;control phaseL "Starting Phase Left" real "degrees" 90 0 360
;control phaseR "Starting Phase Right" real "degrees" 270 0 360
;control ini-tf "Initial Tremolo Frequency" real "Hz" 15 0.1 50
;control fin-tf "Final Tremolo Frequency" real "Hz" 1 0.1 50
;control freq-sweep-type "Frequency Sweep Type" choice "Linear,Exponential" 1
;control reverse-at "Reverse Sweep at" int "% (100% = no)" 50 0 100
;control ini-md "Initial Tremolo Amount" int "%" 60 0 100
;control fin-md "Final Tremolo Amount" int "%" 20 0 100

; wavetable of the tremolo lfo
(setq *tremolo-table* (case wave-num
   (0 *sine-table*)
   (1 *tri-table*) ; triangle
   (t (abs-env (maketable (case wave-num
    (2 (pwl 0 -1 .995  1 1 -1 1)) ; sawtooth
    (3 (pwl 0 1 .995  -1 1 1 1)) ; inverse sawtooth
    (4 (pwl 0 1 .495 1 .5 -1 .995 -1 1 1 1)))))))) ; square

(load "sweep.lsp" :verbose t :print t)

(sweepy-plugin ini-tf fin-tf freq-sweep-type reverse-at
   ini-md fin-md phaseL phaseR *tremolo-table*)
