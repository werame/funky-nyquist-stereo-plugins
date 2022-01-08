;nyquist plug-in
;version 4
;type process
;name "Variable Tremolo2"
;action "Applying Tremolo..."
;preview selection
;author "Steve Daulton, We Rame"
;release 0.3.9
$copyright (_ "Released under terms of the GNU General Public License version 2")

;; We Rame's stereo version with phase amplitude per channel. A modification of the original:
;info "by Steve Daulton. Released under terms of GPL Version 2\nhttp://audacity.easyspacepro.com\n\n'Starting phase' sets where to start tremolo in the waveform cycle.\nThe speed and depth of the tremolo oscilation can be set for the\nstart and the end of the selection.\nThe transition from initial settings to final settings is linear."
;; Changelog for the mod
;;   0.1: Initial version with phases added. Always returns a vector, so it doesn't work on split tracks.
;;   0.2: Made it work on split tracks. Requires v4 plug-in support to read pan info from Audacity.
;;   0.3: Refactored to use external sweep.lsb library shared with similar plugins
;;   0.3.8: added sweep type and uses new control-sweep and new gen-based am-sweep from sweep.lsp;

;control wavenum "Tremolo Shape" choice "Sine,Triangle,Sawtooth,Inverse sawtooth,Square" 0
;control phaseL "Starting Phase Left" real "degrees" 90 0 360
;control phaseR "Starting Phase Right" real "degrees" 270 0 360
;control startf "Initial Tremolo Frequency" real "Hz" 2 0.1 50
;control endf "Final Tremolo Frequency" real "Hz" 12 0.1 50
;control freq-sweep-type "Frequency Sweep Type" choice "Linear,Exponential" 0
;control starta "Initial Tremolo Amount" int "%" 20 0 100
;control enda "Final Tremolo Amount" int "%" 60 0 100

; wavetable of the tremolo lfo
(setq *trem-table* (case wavenum
   (0 *sine-table*)
   (1 *tri-table*) ; triangle
   (t (abs-env (maketable (case wavenum
    (2 (pwl 0 -1 .995  1 1 -1 1)) ; sawtooth
    (3 (pwl 0 1 .995  -1 1 1 1)) ; inverse sawtooth
    (4 (pwl 0 1 .495 1 .5 -1 .995 -1 1 1 1)))))))) ; square

(load "sweep.lsp" :verbose t :print t)

(setq am-freq (control-sweep startf endf freq-sweep-type))

;todo: optional sweep type maybe, besides linear
(setq wet (control-sweep (/ starta 100.0) (/ enda 100.0)))
(setq dry (auto-dry wet))

(multichan-expand #'am-sweep *track* wet dry am-freq *trem-table*
 (multichan-phase-from-track *track* phaseL phaseR))
