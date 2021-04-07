DECLARE SUB PRINTat (x%, Y%, S$)
DECLARE SUB GetScreenDimentions (W%, H%)
DECLARE SUB DispColors ()
DECLARE SUB Limit ()
'$INCLUDE: 'MOUSE.BI'
ON ERROR RESUME NEXT

WIDTH 80, 50

CONST PBLen = 20, PBHalfLen = 10

DIM SHARED ScreenWidth AS INTEGER
DIM SHARED ScreenHeight AS INTEGER
CALL GetScreenDimentions(ScreenWidth, ScreenHeight)

TYPE segtype
  Color AS INTEGER
  x AS INTEGER
  Y AS SINGLE
  Speed AS SINGLE
END TYPE

DIM Segs(5) AS segtype, S AS segtype
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
    S = Segs(i%)
    GOSUB SegAction
    Segs(i%) = S
  NEXT

  COLOR , 11: PRINTat PBX, PBY, SPACE$(PBVal)
  COLOR , 7: PRINTat PBX + PBVal, PBY, SPACE$(PBLen - PBVal)

  COLOR 15, 0
  p$ = LTRIM$(STR$(INT((PBVal / PBLen) * 100)))
  PRINTat PBX + PBHalfLen - LEN(p$) / 2, PBY, p$

  Limit
LOOP UNTIL PBVal = PBLen
END



SegAction:
  S.Y = S.Y + S.Speed
  IF S.Y >= ScreenHeight GOTO ResetSeg
  IF (S.Y - 1 <= PBY) AND (S.Y >= PBY) AND (S.x >= PBX + PBVal) AND (S.x <= PBX + PBLen) THEN
    PBVal = PBVal + 1

ResetSeg:
    S.Y = 0
    S.x = RND * ScreenWidth
    S.Speed = RND
  END IF

  COLOR , 1
  LOCATE S.Y, S.x: PRINT " ";
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
  CONST Interval = 1 / 30
  STATIC t#
  DO
  LOOP UNTIL (TIMER - Interval > t#)
  t# = TIMER
END SUB

SUB PRINTat (x%, Y%, S$)
  'IF y% THEN
    DO: i% = i% + 1: LOOP UNTIL i% + x% >= 1
    LOCATE Y%, i% + x%
  'END IF
  FOR i% = i% TO LEN(S$)
    IF POS(0) = ScreenWidth THEN EXIT FOR
    PRINT MID$(S$, i%, 1);
  NEXT
END SUB

