# Progressbar95 clone
A Progressbar95 clone written in QuickBasic!

It only runs in `SCREEN 0` and automatically adjusts to your display size, so no fancy graphics card needed.

## Compiling
As far as I know it only runs in VB4DOS, as that's what I use as my IDE. But, it likely would work with QB64 and possibly QB45 with enough effort.

OH and also, you need to load VBDOS.QLB (which is bundled) before running it via the command line:

`vbdos /L VBDOS.QLB`

### For older computers
If the display is flickery, you may need to change some options to make the game run faster.

- First thing you could do is optimize your emulator or look for options to adjust the CPU speed (if using one.)
- Another thing you could do is try to compile it. Go to the `Run` menu and select `Make EXE File...`
- Displaying dialogs eats up alot of processing power. To disable them, comment out this block:
```vba
IF TIMER > D.Time THEN
  D.X = (RND * (ScreenWidth - DialogWidth) + 1)
  D.Y = (RND * (ScreenHeight - DialogHeight) + 1)
  D.Type = RND * 3
  D.Time = TIMER + ((RND + 1) * 10)
  D.Var = 0
END IF
```
- Alternatively, adjust the `FPS` value in `CONFIG.BI`. Ususally a value of 30 does the trick, but for *really* old computers you may need to use 15.
