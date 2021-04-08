DECLARE SUB PRINTat (X%, Y%, s$)
DECLARE SUB GetScreenDimentions (W%, H%)
DECLARE SUB DispColors ()
DECLARE SUB Limit ()
'$INCLUDE: 'MOUSE.BI'
ON ERROR RESUME NEXT

WIDTH 80, 50

CONST PBLen = 20, PBHalfLen = 10
CONST interval = 1 / 30
CONST TRUE = -1, false = 0

DIM SHARED ScreenWidth AS INTEGER
DIM SHARED screenheight AS INTEGER
CALL GetScreenDimentions(ScreenWidth, screenheight)

TYPE segtype
  Type AS INTEGER
  X AS INTEGER
  Y AS SINGLE
  Speed AS SINGLE
END TYPE

DIM Segs(5) AS segtype, s AS segtype
DIM PBX AS INTEGER, PBY AS INTEGER
                                
FOR i% = LBOUND(Segs) TO UBOUND(Segs)
  'Segs(i%).x = ScreenWidth
  Segs(i%).Y = screenheight + 1
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
  IF drawframe% THEN t# = TIMER: COLOR , 0: CLS
  IF (TIMER - t#) > interval THEN drawframe% = TRUE ELSE drawframe% = false
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
    Y% = (screenheight - H%) / 2
   
    COLOR 15, 2
    FOR i% = 0 TO H% - 1
      READ l$
      LOCATE Y% + i%, (ScreenWidth - LEN(l$)) / 2
      PRINT l$;
    NEXT

  ELSE
    WIDTH 80, 25
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

  END IF

END



SegAction:
  IF drawframe% THEN s.Y = s.Y + s.Speed
  IF s.Y < 1 THEN RETURN
  IF s.Y >= screenheight GOTO resetSeg
  IF (s.Y - 1 <= PBY) AND (s.Y >= PBY) AND (s.X >= PBX) AND (s.X <= PBX + PBLen) THEN

    IF s.X > PBX + PBVal THEN
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

  COLOR , s.Type
  LOCATE s.Y, s.X
  SELECT CASE s.Type
    CASE 1: PRINT "1";
    CASE 2: PRINT "%";
    CASE 3: PRINT "3";
    CASE 4: PRINT "!";
    CASE 5: PRINT "-";
  END SELECT
RETURN

resetSeg:
  s.Y = -5
  s.X = RND * ScreenWidth
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

SUB Limit ()
  STATIC t#
  WHILE (TIMER - interval <= t#): WEND
  t# = TIMER
END SUB

SUB PRINTat (X%, Y%, s$)
  'IF y% THEN
    DO: i% = i% + 1: LOOP UNTIL i% + X% >= 1
    LOCATE Y%, i% + X%
  'END IF
  FOR i% = i% TO LEN(s$)
    IF POS(0) = ScreenWidth THEN EXIT FOR
    PRINT MID$(s$, i%, 1);
  NEXT
END SUB

