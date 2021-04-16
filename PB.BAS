DECLARE SUB LoadChance ()
REM $INCLUDE: 'MOUSE.BI'
REM $INCLUDE: 'INIT.BI'

DO
  IF (TIMER - t#) > Interval THEN DrawFrame% = True ELSE DrawFrame% = False
  IF DrawFrame% THEN t# = TIMER: COLOR , 0: CLS
  CALL MousePoll(PBY, PBX, l%, r%)
  PBX = PBX - PBHalfLen

  FOR i% = LBOUND(Segs) TO UBOUND(Segs)
    S = Segs(i%)
    GOSUB SegAction
    Segs(i%) = S
  NEXT

  PrintPB
LOOP UNTIL PBVal >= PBLen




GameOver:
  'SYSTEM
  IF PBVal >= PBLen THEN

    PBX = (ScreenWidth - PBLen) / 2
    PBY = ScreenHeight / 5

    COLOR 0, 7
    LOCATE PBY - 1, PBX - 1: PRINT SPACE$(PBLen + 2);
    LOCATE PBY, PBX - 1:     PRINT SPACE$(PBLen + 2);
    LOCATE PBY + 1, PBX - 1: PRINT SPACE$(PBLen + 2);
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
          l$ = LTRIM$(STR$(INT((OrangeSegs% / PBLen) * 100))) + "%"
        ELSE
          l$ = "Perfectionist"
        END IF

      ELSE
        READ l$
      END IF
      PrintCentered Y% + i%, l$

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
      IF POS(0) >= r% THEN PRINT : r% = RND * ScreenWidth
    LOOP UNTIL CSRLIN = ScreenHeight - 10
                                         
    PRINT
    LOCATE , 1
    PRINT "Press space to run CHECKPROGRESS"
    PRINT "Press any other key to try again"

    FOR i% = 1000 TO 37 STEP -1
      SOUND i%, .025
      SOUND 0, .025
    NEXT

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

    IF S.Y < 1 THEN RETURN

    COLOR , S.Type
    LOCATE S.Y, S.X
    SELECT CASE S.Type
      CASE 1: PRINT "1";
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

    IF S.X >= (PBX + PBVal) THEN
CheckSeg:
      SELECT CASE S.Type

        CASE 1
          PBVal = PBVal + 1
          PB(PBVal) = 1
          SOUND 440, 1

        CASE 2
          PBVal = PBLen
          CALL Fill(PB(), 2)

        CASE 3
          PBVal = PBVal + 3
          PB(PBVal - 2) = 1
          PB(PBVal - 1) = 1
          PB(PBVal) = 1
          SOUND 880, .5
          SOUND 0, .5
          SOUND 880, .5
        
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
          SOUND 440, 1

        CASE 7
          SOUND 110, .1

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

ResetSeg:
  S.Y = -5
  S.X = RND * ScreenWidth
  S.Speed = RND * ActualGameSpeed + .5 '+5 to keep them moving
  CALL RandomSeg(S)
RETURN


Data_CheckMark:
DATA 12,12
DATA     " ° "
DATA   " °±±±° "
DATA  " ±±±±±±± "
DATA  "°±±±±±Û±°"
DATA " ±±±±±Û±±± "
DATA "°±±±±±Û±±±°"
DATA "°±Û±±Û±±±±°"
DATA " ±±Û±Û±±±± "
DATA  "°±±Û±±±±°"
DATA  " ±±±±±±± "
DATA   " °±±±° "
DATA     " ° "

Data_Perfectionist:
DATA 12,12
DATA     " ° "
DATA   " °±±±° "
DATA  " ±±±±±±± "
DATA  "°±±±±±±±°"
DATA " ±Û±±Û±Û±± "
DATA "°±Û±Û±Û±Û±°"
DATA "°±Û±Û±Û±Û±°"
DATA " ±Û±±Û±Û±± "
DATA  "°±±±±±±±°"
DATA  " ±±±±±±± "
DATA   " °±±±° "
DATA     " ° "


PrintEndRoll:

  PPts% = (OrangeSegs% / PBLen) * 1000
  Time# = (EndTime# - StartTime#)
  
  IF Time# >= 60 THEN Time# = 60
  TPts% = LOG((60 - Time#)) * 2000

  ERY% = (ScreenHeight / 1.4)
  PrintCentered ERY%, "Progress points:" + STR$(PPts%)
  PrintCentered ERY% + 2, "Time bonus:" + STR$(TPts%)
  PrintCentered ERY% + 4, "-----"
  PrintCentered ERY% + 6, "Total points:" + STR$(PPts% + TPts%)

RETURN


Data_DefaultChance:
DATA 100, 1
DATA   1, 3
DATA   5, 2
DATA  10, 1.5
DATA  15, 1  
DATA  25, 1
DATA  20, 1 
DATA  20, 1 

Data_HardcoreChance:
DATA 100, 3   'Normal
DATA   0, 1   'Green
DATA   5, 5   'Multi
DATA  50, 1   'Red
DATA  20, 1   'Pink
DATA  70, 1   'Orange
DATA  30, 1   'Null
DATA  25, 1.5 'Random

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

SUB PrintAt (X%, Y%, S$)
  'IF y% THEN
    DO: i% = i% + 1: LOOP UNTIL i% + X% >= 1
    LOCATE Y%, i% + X%
  'END IF
  FOR i% = i% TO LEN(S$)
    IF POS(0) = ScreenWidth THEN EXIT FOR
    PRINT MID$(S$, i%, 1);
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

SUB RandomSeg (S AS SegType)
  SHARED SegChance() AS SegChanceType

  S.X = RND * ScreenWidth
  S.Y = ScreenHeight / -10
  S.Speed = RND

  C! = RND

  FOR i% = 1 TO 7
    IF C! <= SegChance(i%).EC THEN

      S.Type = i%
      S.Speed = S.Speed * SegChance(i%).S

      EXIT SUB

    END IF
  NEXT

  'if it doesnt match those then it must match
  'the last one
  S.Type = 8
  S.Speed = S.Speed * SegChance(8).S
END SUB

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

