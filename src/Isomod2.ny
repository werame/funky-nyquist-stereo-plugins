;nyquist plug-in
;version 4
;type process
;name "IsoMod2..."
;action "Modulating..."
;preview selection
;author "Steve Daulton, We Rame"
;release 0.3.9.8
$copyright (_ "Released under terms of the GNU General Public License version 2")

;; We Rame's stereo version with phase amplitude per channel. A modification of the original:
;info "Isochronic Modulator by Steve Daulton. GPL v.2\nhttp://easyspacepro.com\n\n'Pulse Width' controls the length of each pulse.\n'Fade Time' adjusts the fade in/out speed of the pulses.\nThe modulation frequency (speed) and depth transform\ngradually from the initial settings to the final settings.\n\nPlug-in provided as an audio processing effect.\nThe author does not endorse or claim any relevance\nto the theory or practice of brainwave entrainment."
;; Changelog for the mod
;;   0.1: Initial version with phases added. Always returns a vector, so it doesn't work on split tracks.
;;   0.2: Made it work on split tracks. Requires v4 plug-in support to read pan info from Audacity.
;;   0.3: Refactored to use external sweep.lsp library shared with similar plugins
;;   0.3.8: added sweep type and uses new control-sweep and new gen-based am-sweep from sweep.lsp;

;control pw "Pulse Width [50%=Square]" real "%" 40 0 100
;control ft "Fade Time" real "%" 15 0 100
;control startf "Initial Modulation Frequency" real "Hz" 20 0.1 50
;control endf "Final Modulation Frequency" real "Hz" 1 0.1 50
;control freq-sweep-type "Frequency Sweep Type" choice "Linear,Exponential" 1
;control reverse-at "Reverse Sweep at" int "% (100% = no)" 50 0 100
;control starta "Initial Modulation Depth" int "%" 50 0 100
;control enda "Final Modulation Depth" int "%" 100 0 100
;control phaseL "Initial Phase Left" real "degrees" 0 0 360
;control phaseR "Initial Phase Right" real "degrees" 180 0 360

(setq pw (/ pw 100.0))
(setq ft (/ ft 400.0))
(setq ft (* ft (min pw (- 1 pw)) 2))
; more lovely boilerplate
(setq reverse-at (/ reverse-at 100.0))

; wavetable of the tremolo lfo
(setq *trem-table*
   (abs-env (maketable (pwl ft 1 (- pw ft) 1 (+ pw ft) -1 (- 1 ft) -1 1 0))))

(load "sweep.lsp" :verbose t :print t)

; has potential for more complex shapes, but the dialog box is pretty limiting
; todo: maybe should avoid these 3 boilerplate setqs with a helper func
;   but that creates a packing/unpacking issue that is just as boilerplate
;   unless we move the multichan-expand call insider the helper too
(setq am-freq (control-sweep startf endf freq-sweep-type reverse-at))

;todo: optional sweep type maybe, besides linear
;hmmm: should the reverse point auto-apply to the wet ramp too? Yes for now.
(setq wet (control-sweep (/ starta 100.0) (/ enda 100.0) 0 reverse-at))
(setq dry (auto-dry wet))

; todo: this now allows mc-expanded starta and enda; maybe add sep. ctrls.
(multichan-expand #'am-sweep *track* wet dry am-freq *trem-table*
 (multichan-phase-from-track *track* phaseL phaseR))
