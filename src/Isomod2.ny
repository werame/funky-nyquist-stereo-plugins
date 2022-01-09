;nyquist plug-in
;version 4
;type process
;name "IsoMod2..."
;action "Modulating..."
;preview selection
;author "Steve Daulton, We Rame"
;release 0.4.2.1
$copyright (_ "Released under terms of the GNU General Public License version 2")

;; We Rame's stereo version with phase amplitude per channel. A modification of the original:
;info "Isochronic Modulator by Steve Daulton. GPL v.2\nhttp://easyspacepro.com\n\n'Pulse Width' controls the length of each pulse.\n'Fade Time' adjusts the fade in/out speed of the pulses.\nThe modulation frequency (speed) and depth transform\ngradually from the initial settings to the final settings.\n\nPlug-in provided as an audio processing effect.\nThe author does not endorse or claim any relevance\nto the theory or practice of brainwave entrainment."

;; Unfortunately we can't include the common controls boilerplate from another
;;  file because Audacity only parses the top-level plugin file for those.

;control pw "Pulse Width [50%=Square]" real "%" 40 0 100
;control ft "Fade Time" real "%" 15 0 100
;control ini-tf "Initial Modulation Frequency" real "Hz" 20 0.1 50
;control fin-tf "Final Modulation Frequency" real "Hz" 1 0.1 50
;control freq-sweep-type "Frequency Sweep Type" choice "Linear,Exponential" 1
;control reverse-at "Reverse Sweep at" int "% (100% = no)" 50 0 100
;control ini-md "Initial Modulation Depth" int "%" 20 0 100
;control fin-md "Final Modulation Depth" int "%" 60 0 100
;control phaseL "Initial Phase Left" real "degrees" 0 0 360
;control phaseR "Initial Phase Right" real "degrees" 180 0 360

(setq pw (/ pw 100.0))
(setq ft (/ ft 400.0))
(setq ft (* ft (min pw (- 1 pw)) 2))

; wavetable of the tremolo lfo
(setq *tremolo-table*
   (abs-env (maketable (pwl ft 1 (- pw ft) 1 (+ pw ft) -1 (- 1 ft) -1 1 0))))

(load "sweep.lsp" :verbose t :print t)

(sweepy-plugin ini-tf fin-tf freq-sweep-type reverse-at
   ini-md fin-md phaseL phaseR *tremolo-table*)
