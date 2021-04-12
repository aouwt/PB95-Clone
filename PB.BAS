DECLARE SUB WaitS (s!)
DECLARE SUB PrintCentered (y%, t$)
DECLARE FUNCTION ScanProgress% ()
DECLARE SUB PRINTat (x%, y%, s$)
DECLARE SUB GetScreenDimentions (W%, H%)
DECLARE SUB DispColors ()
DECLARE SUB limit ()
'$INCLUDE: 'MOUSE.BI'
ON ERROR RESUME NEXT

WIDTH 80, 50

CONST PBLen = 20, PBHalfLen = 10
CONST interval = 1 / 30
CONST TRUE = -1, FALSE = 0

DIM SHARED ScreenWidth AS INTEGER
DIM SHARED ScreenHeight AS INTEGER
CALL GetScreenDimentions(ScreenWidth, ScreenHeight)
'GOTO CheckProgress
TYPE segtype
  Type AS INTEGER
  x AS INTEGER
  y AS SINGLE
  Speed AS SINGLE
END TYPE

DIM Segs(5) AS segtype, s AS segtype
DIM PBX AS INTEGER, PBY AS INTEGER
                                
FOR i% = LBOUND(Segs) TO UBOUND(Segs)
  'Segs(i%).x = ScreenWidth
  Segs(i%).y = ScreenHeight + 1
NEXT

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
  IF (TIMER - t#) > interval THEN drawframe% = TRUE ELSE drawframe% = FALSE
  IF drawframe% THEN t# = TIMER: COLOR , 0: CLS
  CALL MousePoll(PBY, PBX, l%, r%)
  PBX = PBX - PBHalfLen

  FOR i% = LBOUND(Segs) TO UBOUND(Segs)
    s = Segs(i%)
    GOSUB SegAction
    Segs(i%) = s
  NEXT

  'COLOR , 11: PRINTat PBX, PBY + 1, SPACE$(PBVal)
  COLOR , 11: PRINTat PBX, PBY, SPACE$(PBVal)
  COLOR , 7: PRINTat PBX + PBVal, PBY, SPACE$(PBLen - PBVal)
  'COLOR , 7: PRINTat PBX + PBVal, PBY + 1, SPACE$(PBLen - PBVal)

  COLOR 15, 0
  p$ = LTRIM$(STR$(INT((PBVal / PBLen) * 100)))
  PRINTat PBX + PBHalfLen - LEN(p$) / 2, PBY, p$
LOOP UNTIL PBVal >= PBLen




GameOver:
  IF PBVal >= PBLen THEN
    RESTORE GameOverData
    READ W%, H%
    y% = (ScreenHeight - H%) / 2
   

    COLOR 15, 2
    FOR i% = 0 TO H%

      IF i% = H% THEN
        COLOR 15, 0
        l$ = LTRIM$(STR$(percentcorrect%)) + "%"
      ELSE
        READ l$
      END IF
      PrintCentered y% + i%, l$

    NEXT

    GOSUB PrintEndRoll
   


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

    LOOP UNTIL CSRLIN = 24

    LOCATE , 1
    PRINT "Press space to run CHECKPROGRESS"
    PRINT "Press any other key to try again"

    FOR i% = 0 TO 1000
      SOUND (999 - i%) / 2, .025
      SOUND 0, .025
      SELECT CASE INKEY$
        CASE ""
        CASE " "
          a% = ScanProgress
        CASE ELSE
      END SELECT
    NEXT

  END IF

END



SegAction:

  IF drawframe% THEN
    s.y = s.y + s.Speed

    IF s.y < 1 THEN RETURN

    COLOR , s.Type
    LOCATE s.y, s.x
    SELECT CASE s.Type
      CASE 1: PRINT "1";
      CASE 2: PRINT "%";
      CASE 3: PRINT "3";
      CASE 4: PRINT "!";
      CASE 5: PRINT "-";
    END SELECT

  END IF

  IF s.y < 1 THEN RETURN
  IF s.y >= ScreenHeight GOTO resetSeg
  IF (INT(s.y) = PBY) AND (s.x >= PBX) AND (s.x <= PBX + PBLen) THEN

    IF s.x > PBX + PBVal THEN
      SELECT CASE s.Type

        CASE 1
          PBVal = PBVal + 1
        CASE 2
          PBVal = PBLen
        CASE 3
          PBVal = PBVal + 3
        CASE 4
          GOTO GameOver
        CASE 5
          PBVal = PBVal - 1

      END SELECT
      GOSUB resetSeg

    ELSEIF s.Type = 4 THEN GOTO GameOver

    ELSE GOSUB resetSeg

    END IF
  END IF
RETURN

resetSeg:
  s.y = -5
  s.x = RND * ScreenWidth
  s.Speed = RND

  SELECT CASE (RND)

    CASE IS >= .5  '50% chance of normal segments
      s.Type = 1

    CASE IS >= .3  '20% chance of subtract segments
      s.Type = 5

    CASE IS >= .2  '10% chance of red segments
      s.Type = 4

    CASE IS >= .05 '15% chance of multi-segments
      s.Type = 3

    CASE ELSE      '5% chance of green
      s.Type = 2

  END SELECT
RETURN


GameOverData:
DATA 10,10
DATA    "±±±"
DATA  "±±±±±±±"
DATA  "±±±±±Û±"
DATA "±±±±±Û±±±"
DATA "±±±±±Û±±±"
DATA "±Û±±Û±±±±"
DATA "±±Û±Û±±±±"
DATA  "±±Û±±±±"
DATA  "±±±±±±±"
DATA    "±±±"



PrintEndRoll:

DIM roll(100) AS STRING
roll(0) = "Time:" + STR$(INT(endtile# - starttime#))
roll(1) = "Caught segments:" + STR$(segmentscaught%)
roll(2) = ""
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

SUB GetScreenDimentions (W%, H%)
  W% = 0
  H% = 0

  LOCATE 1, 1, 1
  DO
    H% = H% + 1
    COLOR SCREEN(H%, 1, 1): PRINT CHR$(SCREEN(H%, 1))
  LOOP UNTIL CSRLIN < H%
  H% = H% - 1

  LOCATE 1, 1, 1
  DO
    W% = W% + 1
    COLOR SCREEN(1, W%, 1): PRINT CHR$(SCREEN(1, W%));
  LOOP UNTIL POS(0) < W%
  W% = W% - 1
END SUB

SUB limit ()
  STATIC t#
  WHILE (TIMER - interval <= t#): WEND
  t# = TIMER
END SUB

SUB PRINTat (x%, y%, s$)
  'IF y% THEN
    DO: i% = i% + 1: LOOP UNTIL i% + x% >= 1
    LOCATE y%, i% + x%
  'END IF
  FOR i% = i% TO LEN(s$)
    IF POS(0) = ScreenWidth THEN EXIT FOR
    PRINT MID$(s$, i%, 1);
  NEXT
END SUB

SUB PrintCentered (y%, t$)
  LOCATE y%, (ScreenWidth - LEN(t$)) / 2
  PRINT t$;
END SUB

FUNCTION ScanProgress% ()

  COLOR 15, 0
  CLS
  PrintCentered ScreenHeight / 3, "ScanProgress"
  COLOR 7, 0
  PrintCentered ScreenHeight / 2, "Rapidly press the space bar to progress"

  x% = (ScreenWidth - PBLen) / 2
  x2% = (ScreenWidth + PBLen) / 2
  mid% = PBLen / 2
  COLOR , 7
  LOCATE ScreenHeight / 1.5, x%
  PRINT SPACE$(PBLen);

  DO
    IF INKEY$ = " " THEN you! = you! + .3
    cpu! = cpu! + .1
    
    LOCATE , x%
    COLOR , 3: PRINT SPACE$(you!);

    LOCATE , x2% - cpu!
    COLOR , 4: PRINT SPACE$(cpu!);

    limit
  LOOP UNTIL (cpu! >= mid%) OR (you! >= mid%)

  COLOR 15, 0
  CLS

  COLOR , 7
  LOCATE ScreenHeight / 2, x%
  PRINT SPACE$(PBLen);

  LOCATE , x%
  COLOR , 3: PRINT SPACE$(you!);

  LOCATE , x2% - cpu!
  COLOR , 4: PRINT SPACE$(cpu!);

  IF cpu! >= mid% THEN
    COLOR 15, 0
    PrintCentered ScreenHeight / 3, "You lose!"

    WaitS 1.5

    COLOR 7, 0
    PrintCentered ScreenHeight / 1.5, "Press any key to continue"

  ELSE
    COLOR 15, 0
    PrintCentered ScreenHeight / 3, "You win!"

    WaitS 1.5

    COLOR 7, 0
    PrintCentered ScreenHeight / 1.5, "Press any key to continue"
  END IF

  SLEEP
END FUNCTION

SUB WaitS (s!)
  t# = TIMER
  WHILE (TIMER - t#) < s!: WEND
END SUB

