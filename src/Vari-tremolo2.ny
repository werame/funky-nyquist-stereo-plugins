;nyquist plug-in
;version 4
;type process
;name "Variable Tremolo2"
;action "Applying Tremolo..."
;preview selection
;author "Steve Daulton, We Rame"
;release 0.3.3
$copyright (_ "Released under terms of the GNU General Public License version 2")

;; We Rame's stereo version with phase amplitude per channel. A modification of the original:
;info "by Steve Daulton. Released under terms of GPL Version 2\nhttp://audacity.easyspacepro.com\n\n'Starting phase' sets where to start tremolo in the waveform cycle.\nThe speed and depth of the tremolo oscilation can be set for the\nstart and the end of the selection.\nThe transition from initial settings to final settings is linear."
;; Changelog for the mod
;;   0.1: Initial version with phases added. Always returns a vector, so it doesn't work on split tracks.
;;   0.2: Made it work on split tracks. Requires v4 plug-in support to read pan info from Audacity.
;;   0.3: Refactored to use external sweep.lsb library shared with similar plugins

;control wave "Tremolo Shape" choice "sine,triangle,sawtooth,inverse sawtooth,square" 0
;control phaseL "Starting Phase Left" real "degrees" 90 0 360
;control phaseR "Starting Phase Right" real "degrees" 270 0 360
;control startf "Initial Tremolo Frequency" real "Hz" 4 1 20
;control endf "Final Tremolo Frequency" real "Hz" 12 1 20
;control starta "Initial Tremolo Amount" int "%" 20 0 100
;control enda "Final Tremolo Amount" int "%" 60 0 100

; set tremolo *waveform* 
(setq *waveform* (cond
   ((= wave 0) ; sine
   *sine-table*)
   ((= wave 1) ; triangle
   *tri-table*)
   ((= wave 2) ; sawtooth
   (abs-env (list (pwl 0 -1 .995  1 1 -1 1) (hz-to-step 1.0) t)))
   ((= wave 3) ; inverse sawtooth
   (abs-env (list (pwl 0 1 .995  -1 1 1 1) (hz-to-step 1.0) t)))
   (t ; square
   (abs-env (list (pwl 0 1 .495 1 .5 -1 .995 -1 1 1 1) (hz-to-step 1.0) t)))))

(load "sweep.lsp" :verbose t :print t)

(multichan-expand #'am-sweep *track* (/ starta 100.0) (/ enda 100.0)
 startf endf *waveform* (multichan-phase-from-track *track* phaseL phaseR))
