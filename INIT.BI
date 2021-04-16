DECLARE SUB RandomSeg (S AS ANY)
DECLARE SUB Fill (a() AS INTEGER, v AS INTEGER)
DECLARE SUB PrintPB ()
DECLARE SUB WaitS (S!)
DECLARE SUB PrintCentered (Y%, t$)
DECLARE FUNCTION ScanProgress% ()
DECLARE SUB PrintAt (X%, Y%, S$)
DECLARE SUB GetScreenDimentions (w%, H%)
DECLARE SUB DispColors ()
DECLARE SUB limit ()
DECLARE SUB SetChance (Chances() AS ANY)


TYPE SegType
  Type   AS INTEGER
  X      AS SINGLE
  Y      AS SINGLE
  Speed  AS SINGLE
  XSpeed AS SINGLE
END TYPE

TYPE SegChanceType
  C  AS SINGLE 'Chance in comparison to others
  EC AS SINGLE 'Effective chance (0-1)
  S  AS SINGLE 'Speed multiplier
END TYPE

REM $INCLUDE: 'CONFIG.BI'

CONST Interval = 1 / FPS
CONST ActualGameSpeed = GameSpeed * (15 / FPS)
CONST PBHalfLen = PBLen / 2
CONST True = -1, False = 0

DIM Segs(5)      AS SegType
DIM S            AS SegType
DIM SegChance(8) AS SegChanceType

DIM PBX       AS INTEGER
DIM PBY       AS INTEGER
DIM PBVal     AS INTEGER
DIM PB(PBLen) AS INTEGER

DIM SHARED ScreenWidth AS INTEGER
DIM SHARED ScreenHeight AS INTEGER
CALL GetScreenDimentions(ScreenWidth, ScreenHeight)

ON ERROR RESUME NEXT

FOR i% = LBOUND(Segs) TO UBOUND(Segs)
  Segs(i%).Y = ScreenHeight + 1 'Trigger all segs to reset
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

RESTORE Data_DefaultChance
LoadChance

