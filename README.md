# funky-nyquist-stereo-plugins
Funky stereo plugins written in the Nyquist programming language for the Audacity audio editor.

Presently just:

* Isomod2, with left and right amplitude phases.
* Vari-tremolo2, with left and right amplitude phases.

These share a common `sweep.lsp` library that must also be present in the Audacity plugins directory.

These plugins work on both stereo tracks and "split stereo" pairs of mono tracks that have the 
pan slider set appropriately, which is commonly done via the (Shift+M I) track menu "Split Stereo Track" command.
