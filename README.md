# funky-nyquist-stereo-plugins
Funky stereo plugins written in the Nyquist programming language for the Audacity audio editor.

Presently just:

* Isomod2, with left and right amplitude phases.
* Vari-tremolo2, with left and right amplitude phases.
* Vari-tremolo2i, interpolating version between two keyframe shapes.

These share a common `sweep.lsp` library that must also be present in the Audacity plugins directory.

These plugins work on both stereo tracks and "split stereo" pairs of mono tracks that have the 
pan slider set appropriately, which is commonly done via the track menu "Split Stereo Track" command (keyboard shortcut: Shift+M I) .

----

## Changelog for the mod

v0.1. Initial version with phases added. Always returned a vector of sounds, so it didn't work on split tracks.

v0.2.: Made it work on split tracks. Requires v4 Audacity plug-in support to read pan info from Audacity. (I don't know exactly when Audacity stated supporting "v4" plug-ins, but the Audacity 3.x series supports them. Audacity plugin protocol version number isn't matched to Audacity major version numbers.)

v0.3: Refactored to use external `sweep.lsb` library shared with similar plugins.

v0.4: Added sweep type: just exponential besides linear for now. Added reversal point for sweep, so it can ramp and then down, or vice-versa. Refactored `sweep.lsp` library to be internally ugen-based in most parameters, to make such features additions easy. 

v0.4.3 Added (my quickly adapted) interpolating version of Vari-tremolo2. Needs more polish.

----
## Quick visual demo for the latter:

![image](https://user-images.githubusercontent.com/97036286/148672528-c699f31e-3f53-47bb-bb5f-d232afb1c0e6.png)

Using these settings

![image](https://user-images.githubusercontent.com/97036286/148672553-d3a1ee5f-904e-416a-a0ec-43adc1b16827.png)


