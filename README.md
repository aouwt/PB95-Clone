# pb95-clone
A ProgressBar95 clone written in QuickBasic!

It only runs in `SCREEN 0` and automatically adjusts to your display size, so no fancy graphics card needed.

## Compiling
As far as I know it only runs in VB4DOS, as that's what I use as my IDE. But, it likely would work with QB64 and possibly QB45 with enough effort.

OH and also, you need to load VBDOS.QLB before running it via the command line:

`vbdos /L C:\VB\LIB\VBDOS.QLB`

Additionally, you may need to change the line in PB-CLONE.MAK that says `C:\VB\INC\MOUSE.BAS` to wherever your MOUSE.BAS is on your QB installation.
