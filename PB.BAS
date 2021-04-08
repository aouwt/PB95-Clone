DECLARE SUB PRINTat (x%, Y%, s$)
DECLARE SUB GetScreenDimentions (W%, H%)
DECLARE SUB DispColors ()
DECLARE SUB Limit ()
'$INCLUDE: 'MOUSE.BI'
ON ERROR RESUME NEXT

WIDTH 80, 50

CONST PBLen = 20, PBHalfLen = 10
CONST Interval = 1 / 60

DIM SHARED ScreenWidth AS INTEGER
DIM SHARED ScreenHeight AS INTEGER
CALL GetScreenDimentions(ScreenWidth, ScreenHeight)

TYPE segtype
  type AS INTEGER
  x AS INTEGER
  Y AS SINGLE
  Speed AS SINGLE
END TYPE

DIM Segs(5) AS segtype, s AS segtype
DIM PBX AS INTEGER, PBY AS INTEGER
                                
FOR i% = LBOUND(Segs) TO UBOUND(Segs)
  'Segs(i%).x = ScreenWidth
  Segs(i%).Y = ScreenHeight + 1
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
  CLS
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

  Limit
LOOP UNTIL PBVal = PBLen
GameOver:
END



SegAction:
  s.Y = s.Y + s.Speed
  IF s.Y < 1 THEN RETURN
  IF s.Y >= ScreenHeight GOTO ResetSeg
  IF (s.Y - 1 <= PBY) AND (s.Y >= PBY) AND (s.x >= PBX + PBVal) AND (s.x <= PBX + PBLen) THEN

    SELECT CASE s.type
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

ResetSeg:
    s.Y = -5
    s.x = RND * ScreenWidth
    s.Speed = RND
    
    SELECT CASE (RND)
      CASE IS >= .5  '50% chance of normal segments
        s.type = 1

      CASE IS >= .3  '20% chance of subtract segments
        s.type = 5

      CASE IS >= .2  '10% chance of red segments
        s.type = 4

      CASE IS >= .05 '15% chance of multi-segments
        s.type = 3

      CASE ELSE      '5% chance of green
        s.type = 2
    END SELECT
  END IF

  COLOR , s.type
  LOCATE s.Y, s.x: PRINT " ";
RETURN

SUB DispColors ()
  CLS
  FOR i% = 0 TO 16
    COLOR , i%: PRINT i%,
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
  DO
  LOOP UNTIL (TIMER - Interval > t#)
  t# = TIMER
END SUB

SUB PRINTat (x%, Y%, s$)
  'IF y% THEN
    DO: i% = i% + 1: LOOP UNTIL i% + x% >= 1
    LOCATE Y%, i% + x%
  'END IF
  FOR i% = i% TO LEN(s$)
    IF POS(0) = ScreenWidth THEN EXIT FOR
    PRINT MID$(s$, i%, 1);
  NEXT
END SUB

