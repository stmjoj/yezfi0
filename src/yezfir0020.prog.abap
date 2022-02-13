************************************************************************
* Program ID  : YEZFIR0020
* Title       : [FI] 발의부서 변경
* Module      : FI
* Type        : Report
* Description : 발의자 및 발의부서를 변경할 수 있다.
************************************************************************

REPORT YEZFIR0020.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: GS_SUBLOGIN   TYPE YEZFIS0040.
DATA: GV_RETURN     TYPE BAPI_MTYPE.
DATA: GV_MESSAGE    TYPE BAPI_MSG.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CALL FUNCTION 'Y_EZFI_SUBLOGIN'
    EXPORTING
*     IV_UNAME          = SY-UNAME
      IV_SKIP           = ABAP_FALSE
    IMPORTING
      ES_SUBLOGIN       = GS_SUBLOGIN
      EV_RETURN         = GV_RETURN
      EV_MESSAGE        = GV_MESSAGE.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
