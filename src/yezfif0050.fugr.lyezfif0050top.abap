FUNCTION-POOL YEZFIF0050.                   "MESSAGE-ID ..

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: GV_BUKRS     TYPE BKPF-BUKRS.
DATA: GV_BELNR     TYPE BKPF-BELNR.
DATA: GV_GJAHR     TYPE BKPF-GJAHR.

DATA: GS_BKPF      TYPE YEZFISBKPF.
DATA: GT_BSEG      TYPE STANDARD TABLE OF YEZFISBSEG.
DATA: GS_BSEG      TYPE YEZFISBSEG.

DATA: GV_RETURN    TYPE BAPI_MTYPE.
DATA: GV_MESSAGE   TYPE	BAPI_MSG.
