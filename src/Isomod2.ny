;nyquist plug-in
;version 4
;type process
;name "IsoMod2..."
;action "Modulating..."
;preview selection
;author "Steve Daulton, We Rame"
;release 0.2
$copyright (_ "Released under terms of the GNU General Public License version 2")

;; We Rame's stereo version with phase amplitude per channel. A modification of the original:
;info "Isochronic Modulator by Steve Daulton. GPL v.2\nhttp://easyspacepro.com\n\n'Pulse Width' controls the length of each pulse.\n'Fade Time' adjusts the fade in/out speed of the pulses.\nThe modulation frequency (speed) and depth transform\ngradually from the initial settings to the final settings.\n\nPlug-in provided as an audio processing effect.\nThe author does not endorse or claim any relevance\nto the theory or practice of brainwave entrainment."
;; Changelog for the mod
;;   0.1: Initial version with phases added. Always returns a vector, so it doesn't work on split tracks.
;;   0.2: Made it work on split tracks. Requires v4 plug-in support to read pan info from Audacity.

;control pw "Pulse Width [50%=Square]" real "%" 40 0 100
;control ft "Fade Time" real "%" 15 0 100
;control startf "Initial Modulation Frequency" real "Hz" 7 1 20
;control endf "Final Modulation Frequency" real "Hz" 2 1 20
;control starta "Initial Modulation Depth" int "%" 100 0 100
;control enda "Final Modulation Depth" int "%" 100 0 100
;control phaseL "Initial Phase Left" real "degrees" 0 0 360
;control phaseR "Initial Phase Right" real "degrees" 180 0 360

(setq pw (/ pw 100.0))
(setq  ft (/ ft 400.0))
(setq ft (* ft (min pw (- 1 pw)) 2))

; set tremolo *waveform* 
(setq *waveform*
   (abs-env (list (pwl ft 1 (- pw ft) 1 (+ pw ft) -1 (- 1 ft) -1 1 0)
    (hz-to-step 1.0) t)))

(load "sweep.lsp" :verbose t :print t)

(defun isomod-with-phase (mono-snd phase)
   (let* ((starta (/ starta 100.0))
          (enda (/ enda 100.0))
          (wet (pwlv starta 1 enda))
          (dry (sum 1 (mult wet -1))))
      (mult mono-snd (sum dry (mult wet (sweep startf endf *waveform* phase))))))

;; converts mono track pan slider to phase: -1..1 to phaseL..phaseR
(defun phase-from-signed-pan (signed-pan)
   (let ((unsigned-pan (* (+ 1.0 signed-pan) 0.5)))
      (+ phaseL (* (- phaseR phaseL) unsigned-pan))))

;; if stereo track make array of phases for multichan-expand
;; else compute one phase using mono track pan
(setq multichan-phase
   (if (arrayp *track*)
       (vector (phase-from-signed-pan -1) (phase-from-signed-pan 1))
       ; ^^ ignoring stereo track pan b/c it has different semantics than mono pan
       (phase-from-signed-pan (get '*track* 'pan))))

(multichan-expand #'isomod-with-phase *track* multichan-phase)
