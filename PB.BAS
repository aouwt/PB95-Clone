DECLARE SUB Prt (S$)
REM $INCLUDE: 'MOUSE.BI'
REM $INCLUDE: 'INIT.BI'
PBX = 1
PBY = 1
StartTime# = TIMER
DO
  IF DrawFrame% THEN
    t# = TIMER
    'DrawFrame% = False
    COLOR , 0
    CLS
  END IF

  CALL MousePoll(MouseY, MouseX, L%, R%)


  IF L% THEN
    COLOR 15: LOCATE MouseY, MouseX: PRINT "€";

    IF MouseLock% = False THEN

      IF (MouseY = PBY) AND (MouseX >= PBX) AND (MouseX <= PBX + PBLen) THEN

        MouseLock% = MouseX - PBX

      ELSE MouseLock% = -1
      END IF

    END IF

  ELSE
    MouseLock% = False
    COLOR 15, 0: LOCATE MouseY, MouseX: PRINT "˛";
  END IF

  IF MouseLock% > 0 THEN
    PBX = MouseX - MouseLock%
    PBY = MouseY
  END IF


  FOR i% = LBOUND(Segs) TO UBOUND(Segs)
    S = Segs(i%)
    GOSUB SegAction
    Segs(i%) = S
  NEXT

  PrintPB

  GOSUB DialogAction

  IF TIMER > D.Time THEN
    D.X = RND * (ScreenWidth - 18)
    D.Y = RND * (ScreenHeight - 9)
    D.Type = RND * 2
    D.Time = TIMER + ((RND + 1) * 15)
  END IF

  IF (TIMER - t#) > Interval THEN DrawFrame% = True ELSE DrawFrame% = False
LOOP UNTIL PBVal >= PBLen

GameOver:
  'SYSTEM
  EndTime# = TIMER
  IF PBVal >= PBLen THEN

    PBX = (ScreenWidth - PBLen) / 2
    PBY = ScreenHeight / 5

    COLOR 0, 7
    LOCATE PBY - 1, PBX - 2: PRINT SPACE$(PBLen + 2);
    LOCATE PBY, PBX - 2:     PRINT SPACE$(PBLen + 2);
    LOCATE PBY + 1, PBX - 2: PRINT SPACE$(PBLen + 2);
    PrintPB

    OrangeSegs% = 0
    FOR i% = 0 TO PBLen 'Check for orange segs
      IF PB(i%) = 6 THEN
        OrangeSegs% = OrangeSegs% + 1
    END IF: NEXT

    IF OrangeSegs% THEN RESTORE Data_CheckMark ELSE RESTORE Data_Perfectionist

    READ w%, H%
    Y% = (ScreenHeight - H%) / 2


    COLOR 15, 2
    FOR i% = 0 TO H%

      IF i% = H% THEN
        COLOR 15, 0
        IF OrangeSegs% THEN
          L$ = LTRIM$(STR$(INT((OrangeSegs% / PBLen) * 100))) + "%"
        ELSE
          L$ = "Perfectionist"
        END IF

      ELSE
        READ L$
      END IF
      PrintCentered Y% + i%, L$

    NEXT
    GOSUB PrintEndRoll
    'FOR i% = 0 TO 100
    '  SOUND 493, .025
    '  SOUND 391, .025
    'NEXT
    SOUND 880, 5
    



  ELSE
    FOR i% = 0 TO 100
      SOUND ((i% AND 2) * 220 + 220), .1
      SOUND ((i% AND 1) * 400 + 64), .1
    NEXT
    'WIDTH 80, 25
    COLOR 7, 1
    CLS

    DO
      PRINT CHR$(RND * 127 + 32);
      IF POS(0) >= R% THEN PRINT : R% = RND * ScreenWidth
    LOOP UNTIL CSRLIN = ScreenHeight - 10
                                         
    PRINT
    LOCATE , 1
    PRINT "Press space to run CHECKPROGRESS"
    PRINT "Press any other key to try again"

    'FOR i% = 1000 TO 37 STEP -1
      SOUND i%, .025
      SOUND 0, .025
    'NEXT

    DO
      SELECT CASE INKEY$
        CASE ""
        CASE " "
          IF ScanProgress%() THEN SYSTEM ELSE SYSTEM 'TODO: Implement lives
        CASE ELSE
          EXIT DO
      END SELECT
    LOOP

  END IF

END



SegAction:

  IF DrawFrame% THEN
    S.Y = S.Y + S.Speed
    S.X = S.X + S.XSpeed

    IF S.XSpeed THEN
      IF (S.Y MOD S.SwTime) = 0 THEN
        S.XSpeed = S.XSpeed * -1
      END IF
    END IF

    IF (S.X <= 1) OR (S.X >= ScreenWidth) GOTO ResetSeg
    IF S.Y < 1 THEN RETURN

    COLOR 15, S.Type
    LOCATE S.Y, S.X
    SELECT CASE S.Type
      CASE 1: PRINT " ";
      CASE 2: PRINT "%";
      CASE 3: PRINT "3";
      CASE 4: PRINT "!";
      CASE 5: PRINT "-";
      CASE 6: PRINT " ";
      CASE 7: PRINT "0";
      CASE 8:
        COLOR , RND * 7
        PRINT "?";
    END SELECT

  END IF

  IF S.Y < 1 THEN RETURN
  IF S.Y >= ScreenHeight GOTO ResetSeg
  IF (INT(S.Y) = PBY) AND (S.X >= PBX) AND (S.X <= (PBX + PBLen)) THEN
    
    DrawFrame% = True

    IF S.X >= (PBX + PBVal) THEN
CheckSeg:
      SELECT CASE S.Type

        CASE 1
          PBVal = PBVal + 1
          PB(PBVal) = 1
          SOUND 220, .5
          SOUND 440, .5

        CASE 2
          PBVal = PBLen
          CALL Fill(PB(), 2)

        CASE 3
          PBVal = PBVal + 3
          PB(PBVal - 2) = 1
          PB(PBVal - 1) = 1
          PB(PBVal) = 1
          SOUND 440, .5
          SOUND 0, .5
          SOUND 440, .5

        CASE 4
          CALL Fill(PB(), 4)
          PrintPB
          WaitS .5
          GOTO GameOver

        CASE 5
          PBVal = PBVal - 1
          SOUND 440, .5
          SOUND 220, .5

        CASE 6
          PBVal = PBVal + 1
          PB(PBVal) = 6
          SOUND 220, .25
          SOUND 440, .75

        CASE 7
          SOUND 110, .1
          SOUND 37, .2

        CASE ELSE
          CALL RandomSeg(S)
          GOTO CheckSeg

      END SELECT
      GOSUB ResetSeg

    ELSEIF S.Type = 4 THEN GOTO GameOver

    ELSE
      SOUND 220, .25
      GOSUB ResetSeg

    END IF
  END IF
RETURN




DialogAction:
  IF D.Type = 0 THEN RETURN

  IF DrawFrame% THEN
    LOCATE D.Y, D.X

    SELECT CASE D.Type
      CASE 1
        COLOR 0, 7:   PRINT "⁄ƒAnnoying Popupƒø"
        LOCATE , D.X: PRINT "≥                ≥"
        LOCATE , D.X: PRINT "≥";
        COLOR 14:      PRINT " ∞€€€∞";
        COLOR 0:             PRINT "          ≥"
        LOCATE , D.X: PRINT "≥ ";
        COLOR 14:       PRINT "€›€ﬁ€";
        COLOR 0:             PRINT "          ≥"
        LOCATE , D.X: PRINT "≥";
        COLOR 14:      PRINT "∞€€€€€∞";
        COLOR 0:              PRINT "         ≥"
        LOCATE , D.X: PRINT "≥ ";
        COLOR 14:       PRINT "€‹ﬂ‹€";
        COLOR 0:             PRINT "    <OK>  ≥"
        LOCATE , D.X: PRINT "≥ ";
        COLOR 14:       PRINT "∞€€€∞";
        COLOR 0:             PRINT "          ≥"
        LOCATE , D.X: PRINT "≥                ≥"
        LOCATE , D.X: PRINT "¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ"
    END SELECT

  END IF

  IF (L% <> 0) AND (MouseLock% = -1) AND (MouseX >= D.X) AND (MouseY >= D.Y) THEN
    X% = MouseX - D.X
    Y% = MouseY - D.Y
  ELSE RETURN
  END IF

  MouseLock% = -2

  SELECT CASE D.Type
    CASE 1
      IF (Y% = 5) AND (X% >= 11) AND (X% <= 14) THEN
        D.Type = 0
      END IF
  END SELECT

RETURN



ResetSeg:
  S.Y = -5
  S.X = RND * ScreenWidth
  S.Speed = RND * ActualGameSpeed + .5 '+5 to keep them moving
  CALL RandomSeg(S)
RETURN



PrintEndRoll:

  PPts% = (PBLen - OrangeSegs%) * 1000
  Time# = (EndTime# - StartTime#)
  
  IF Time# >= 60 THEN Time# = 60
  TPts% = LOG((60 - Time#)) * 2000

  ERY% = (ScreenHeight / 1.4)
  PrintCentered ERY%, "Progress points:" + STR$(PPts%)
  PrintCentered ERY% + 2, "Time bonus:" + STR$(TPts%)
  PrintCentered ERY% + 4, "-----"
  PrintCentered ERY% + 6, "Total points:" + STR$(PPts% + TPts%)

RETURN




Data_CheckMark:
DATA 12,12
DATA     " ∞ "
DATA   " ∞±±±∞ "
DATA  " ±±±±±±± "
DATA  "∞±±±±±€±∞"
DATA " ±±±±±€±±± "
DATA "∞±±±±±€±±±∞"
DATA "∞±€±±€±±±±∞"
DATA " ±±€±€±±±± "
DATA  "∞±±€±±±±∞"
DATA  " ±±±±±±± "
DATA   " ∞±±±∞ "
DATA     " ∞ "

Data_Perfectionist:
DATA 12,12
DATA     " ∞ "
DATA   " ∞±±±∞ "
DATA  " ±±±±±±± "
DATA  "∞±±±±±±±∞"
DATA " ±€±±€±€±± "
DATA "∞±€±€±€±€±∞"
DATA "∞±€±€±€±€±∞"
DATA " ±€±±€±€±± "
DATA  "∞±±±±±±±∞"
DATA  " ±±±±±±± "
DATA   " ∞±±±∞ "
DATA     " ∞ "



Data_DefaultChance:
DATA 100, 1
DATA  .1, 3
DATA   5, 2
DATA  10, 1.5
DATA  15, 1
DATA  25, 1
DATA  20, 1
DATA  20, 1

Data_HardcoreChance:
DATA 100, 3
DATA   0, 1
DATA   5, 5
DATA  50, 1
DATA  20, 1
DATA  70, 1
DATA  30, 1
DATA  25, 1.5

SUB DispColors ()
  CLS
  FOR i% = 0 TO 15

    COLOR 15, 0: PRINT USING "##: "; i%;

    FOR a% = 0 TO 15
     COLOR a%, i%: PRINT USING " ##"; a%;
    NEXT

    PRINT

  NEXT
END SUB

SUB Fill (a() AS INTEGER, v AS INTEGER)
  FOR i% = LBOUND(a) TO UBOUND(a)
    a(i%) = v
  NEXT
END SUB

SUB GetScreenDimentions (w%, H%)
  w% = 0
  H% = 0

  LOCATE 1, 1
  DO
    H% = H% + 1
    PRINT
    'COLOR SCREEN(H%, 1, 1): PRINT CHR$(SCREEN(H%, 1))
  LOOP UNTIL CSRLIN < H%
  H% = H% - 1

  LOCATE 1, 1
  DO
    w% = w% + 1
    PRINT " ";
    'COLOR SCREEN(1, w%, 1): PRINT CHR$(SCREEN(1, w%));
  LOOP UNTIL POS(0) < w%
  w% = w% - 1
END SUB

SUB limit ()
  STATIC t#
  WHILE (TIMER - Interval <= t#): WEND
  t# = TIMER
END SUB

SUB LoadChance ()
  SHARED SegChance() AS SegChanceType

  FOR i% = 1 TO 8
    READ SegChance(i%).C, SegChance(i%).S
    'PRINT SegChance(i%).C, SegChance(i%).S
  NEXT

  CALL SetChance(SegChance())
END SUB

SUB LoadDialogs ()

END SUB

SUB PrintAt (X%, Y%, S$)
  
  DO: i% = i% + 1: LOOP UNTIL i% + X% >= 1
  X% = i% + X%

  LOCATE Y%, X%

  FOR i% = i% TO LEN(S$)
    IF POS(0) = ScreenWidth THEN EXIT FOR

    C$ = MID$(S$, i%, 1)
    IF C$ = CHR$(13) THEN
      IF CSRLIN = ScreenHeight THEN EXIT FOR
      LOCATE CSRLIN + 1, X%

    ELSE PRINT C$;
    END IF
  NEXT
END SUB

SUB PrintCentered (Y%, t$)
  LOCATE Y%, (ScreenWidth - LEN(t$)) / 2
  PRINT t$;
END SUB

SUB PrintPB ()
  SHARED PBX  AS INTEGER, PBY   AS INTEGER
  SHARED PB() AS INTEGER, PBVal AS INTEGER

  X% = PBX - 1 'Don't know why this works...

  p$ = LTRIM$(STR$(INT((PBVal / PBLen) * 100))) + "%"
  px% = PBHalfLen - LEN(p$) / 2
  p$ = SPACE$(px%) + p$ + SPACE$(px% + 1)

  IF PBVal > PBLen THEN PBVal = PBLen

  IF X% <= 0 THEN
    i% = -X%
    X% = 1
  ELSE i% = 1
  END IF

  LOCATE PBY, X%
  FOR i% = i% TO PBVal
    COLOR 15, PB(i%)
    PRINT MID$(p$, i%, 1);
    IF POS(0) >= ScreenWidth THEN EXIT FOR
  NEXT

  COLOR 15, 7
  FOR i% = i% TO PBLen + 1
    IF POS(0) >= ScreenWidth THEN EXIT FOR
    PRINT MID$(p$, i%, 1);
  NEXT
END SUB

SUB Prt (S$)
  DO: i% = i% + 1: LOOP UNTIL i% + POS(0) >= 1

  FOR i% = i% TO LEN(S$)
    IF POS(0) = ScreenWidth THEN EXIT FOR

    PRINT MID$(S$, i%, 1);
  NEXT
END SUB

SUB RandomSeg (S AS SegType)
  SHARED SegChance() AS SegChanceType

  S.X = RND * ScreenWidth
  S.Y = ScreenHeight / -10

  C! = RND

  FOR i% = 1 TO 7
    IF C! <= SegChance(i%).EC THEN

      S.Type = i%
      S.Speed = RND * SegChance(i%).S
      S.XSpeed = Round((RND - .5) * S.Speed, 2)
      S.SwTime = RND * S.Speed * 10
      EXIT SUB

    END IF
  NEXT

  'if it doesnt match those then it must match
  'the last one
  S.Type = 8
  S.Speed = RND * SegChance(8).S
  S.XSpeed = Round((RND - .5) * S.Speed, 2)
  S.SwTime = (RND + 2) * 100
END SUB

FUNCTION Round! (N!, Places%)
  N! = N! * Places%
  N% = N!
  IF (N! - N%) >= .5 THEN Round = (N% + 1) / Places% ELSE Round = N% / Places%
END FUNCTION

FUNCTION ScanProgress% ()

  COLOR 15, 0
  CLS
  PrintCentered ScreenHeight / 3, "ScanProgress"
  COLOR 7, 0
  PrintCentered ScreenHeight / 2, "Rapidly press the space bar to progress"

  X% = (ScreenWidth - PBLen) / 2
  x2% = (ScreenWidth + PBLen) / 2
  mid% = PBLen / 2
  COLOR , 7
  LOCATE ScreenHeight / 1.5, X%
  PRINT SPACE$(PBLen);

  DO
    IF INKEY$ = " " THEN you! = you! + .3
    cpu! = cpu! + .1
    
    LOCATE , X%
    COLOR , 3: PRINT SPACE$(you!);

    LOCATE , x2% - cpu!
    COLOR , 4: PRINT SPACE$(cpu!);

    limit
  LOOP UNTIL (cpu! >= mid%) OR (you! >= mid%)

  COLOR 15, 0
  CLS

  COLOR , 7
  LOCATE ScreenHeight / 2, X%
  PRINT SPACE$(PBLen);

  LOCATE , X%
  COLOR , 3: PRINT SPACE$(you!);

  LOCATE , x2% - cpu!
  COLOR , 4: PRINT SPACE$(cpu!);

  IF cpu! >= mid% THEN
    ScanProgress% = False

    COLOR 15, 0
    PrintCentered ScreenHeight / 3, "You lose!"

    WaitS 1.5

    COLOR 7, 0
    PrintCentered ScreenHeight / 1.5, "Press any key to continue"

  ELSE
    ScanProgress% = True

    COLOR 15, 0
    PrintCentered ScreenHeight / 3, "You win!"

    WaitS 1.5

    COLOR 7, 0
    PrintCentered ScreenHeight / 1.5, "Press any key to continue"
  END IF

  SLEEP
END FUNCTION

SUB SetChance (Chances() AS SegChanceType)
  Mult# = 0
  FOR i% = 1 TO 8
    Mult# = Mult# + Chances(i%).C
    'PRINT Mult#
  NEXT

  'Do the first one to prevent Out Of Range errors
  Chances(1).EC = (Chances(1).C / Mult#)

  FOR i% = 2 TO 8
    Chances(i%).EC = (Chances(i%).C / Mult#) + Chances(i% - 1).EC
    'PRINT Chances(i%).EC
  NEXT
END SUB

SUB WaitS (S!)
  t# = TIMER
  WHILE (TIMER - t#) < S!: WEND
END SUB

