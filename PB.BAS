DECLARE SUB RandomSeg (S AS ANY)
DECLARE SUB Fill (a() AS INTEGER, v AS INTEGER)
DECLARE SUB PrintPB ()
DECLARE SUB WaitS (S!)
DECLARE SUB PrintCentered (Y%, t$)
DECLARE FUNCTION ScanProgress% ()
DECLARE SUB PrintAt (X%, Y%, S$)
DECLARE SUB GetScreenDimentions (W%, H%)
DECLARE SUB DispColors ()
DECLARE SUB limit ()
'$INCLUDE: 'MOUSE.BI'
ON ERROR RESUME NEXT

WIDTH 80, 50

'#### CONFIGURATION ###################

CONST PBLen = 20     'How wide the progress bar is

CONST FPS = 60       'How many times per second the game state updates. Slower
                     'computers need lower FPS to make it run smoothly.
                     'Best kept at 60 (for modern-ish PCs) or 30 for "retro"
                     'ones, and 10 for that old XT you happened to find in a
                     'warehouse in the middle of nowhere

CONST GameSpeed = 1  'Game speed multiplier.

'######################################

CONST Interval = 1 / FPS
CONST ActualGameSpeed = GameSpeed * (15 / FPS)
CONST PBHalfLen = PBLen / 2
CONST True = -1, False = 0

DIM SHARED ScreenWidth AS INTEGER
DIM SHARED ScreenHeight AS INTEGER
CALL GetScreenDimentions(ScreenWidth, ScreenHeight)
'GOTO CheckProgress
TYPE SegType
  Type   AS INTEGER
  X      AS SINGLE
  Y      AS SINGLE
  Speed  AS SINGLE
  XSpeed AS SINGLE
END TYPE

DIM Segs(5) AS SegType, S AS SegType
DIM PBX AS INTEGER, PBY AS INTEGER
DIM PBVal AS INTEGER
DIM PB(PBLen) AS INTEGER
                                
FOR i% = LBOUND(Segs) TO UBOUND(Segs)
  'Segs(i%).x = ScreenWidth
  Segs(i%).Y = ScreenHeight + 1
NEXT

RANDOMIZE TIMER

DispColors
DO
  SELECT CASE INKEY$
    CASE " "
      END
    CASE ""
    CASE ELSE
      EXIT DO
  END SELECT
LOOP

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

    OrangeSegs% = 0
    FOR i% = 0 TO PBLen 'Check for orange segs
      IF PB(i%) = 6 THEN
        OrangeSegs% = OrangeSegs% + 1
    END IF: NEXT

    IF OrangeSegs% THEN RESTORE Data_CheckMark ELSE RESTORE Data_Perfectionist

    READ W%, H%
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

RetryChr:
      c% = RND * 255

      SELECT CASE c%

        CASE 0 TO 12, 14 TO 32
          GOTO RetryChr

        CASE ELSE
          PRINT CHR$(c%);

      END SELECT

    LOOP UNTIL CSRLIN = ScreenHeight - 3

    PRINT
    LOCATE , 1
    PRINT "Press space to run CHECKPROGRESS"
    PRINT "Press any other key to try again"

    FOR i% = 0 TO 1000
      SOUND (999 - i%) / 2, .025
      SOUND 0, .025
    NEXT

    DO
      SELECT CASE INKEY$
        CASE ""
        CASE " "
          IF ScanProgress%() THEN
          END IF
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
      CASE ELSE
        S.Type = ((S.Type + 1) MOD 9) + 7
        COLOR , S.Type - 7
        PRINT "?";
    END SELECT

  END IF

  IF S.Y < 1 THEN RETURN
  IF S.Y >= ScreenHeight GOTO ResetSeg
  IF (INT(S.Y) = PBY) AND (S.X >= PBX) AND (S.X <= PBX + PBLen) THEN

    IF S.X > PBX + PBVal THEN
      SOUND 440, 1
CheckSeg:
      SELECT CASE S.Type

        CASE 1
          PBVal = PBVal + 1
          PB(PBVal) = 1

        CASE 2
          PBVal = PBLen
          CALL Fill(PB(), 2)

        CASE 3
          PBVal = PBVal + 3
          PB(PBVal - 2) = 1
          PB(PBVal - 1) = 1
          PB(PBVal) = 1
        
        CASE 4
          CALL Fill(PB(), 4)
          PrintPB
          GOTO GameOver

        CASE 5
          PBVal = PBVal - 1

        CASE 6
          PBVal = PBVal + 1
          PB(PBVal) = 6

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

SUB GetScreenDimentions (W%, H%)
  W% = 0
  H% = 0

  LOCATE 1, 1
  DO
    H% = H% + 1
    COLOR SCREEN(H%, 1, 1): PRINT CHR$(SCREEN(H%, 1))
  LOOP UNTIL CSRLIN < H%
  H% = H% - 1

  LOCATE 1, 1
  DO
    W% = W% + 1
    COLOR SCREEN(1, W%, 1): PRINT CHR$(SCREEN(1, W%));
  LOOP UNTIL POS(0) < W%
  W% = W% - 1
END SUB

SUB limit ()
  STATIC t#
  WHILE (TIMER - Interval <= t#): WEND
  t# = TIMER
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
  SHARED PBX AS INTEGER, PBY AS INTEGER
  SHARED PB() AS INTEGER, PBVal AS INTEGER

  p$ = LTRIM$(STR$(INT((PBVal / PBLen) * 100)))
  px% = PBHalfLen - LEN(p$) / 2
  p$ = SPACE$(px%) + p$ + SPACE$(px%)

  IF PBX <= 0 THEN
    i% = ABS(PBX)
    PBX = 1
  ELSE i% = 1
  END IF

  LOCATE PBY, PBX
  FOR i% = i% TO PBVal
    COLOR 15, PB(i%)
    PRINT MID$(p$, i%, 1);
    IF POS(0) >= ScreenWidth THEN EXIT FOR
  NEXT

  COLOR 15, 7
  FOR i% = i% TO PBLen
    IF POS(0) >= ScreenWidth THEN EXIT FOR
    PRINT MID$(p$, i%, 1);
  NEXT
END SUB

SUB RandomSeg (S AS SegType)
  SELECT CASE (RND)

    CASE IS <= .5             '50% chance
      S.Type = 1              'Normal


    CASE IS <= .65            '15% chance
      S.Type = 6              'Orange


    CASE IS <= .7             '5% chance
      S.Type = 7              'Random


    CASE IS <= .75            '5% chance
      S.Type = 4              'Red
      S.Speed = S.Speed * 1.5 '1.5x speed


    CASE IS <= .9             '15% chance
      S.Type = 5              'Pink


    CASE IS <= .999           '9.9% chance
      S.Type = 3              'Multi
      S.Speed = S.Speed * 2   '2x speed


    CASE ELSE                 '1% chance
      S.Type = 2              'Green
      S.Speed = S.Speed * 3 + 1 '3x+1 speed
  END SELECT
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

SUB WaitS (S!)
  t# = TIMER
  WHILE (TIMER - t#) < S!: WEND
END SUB

