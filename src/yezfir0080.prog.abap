************************************************************************
* Program ID  : YEZFIR0080
* Title       : [FI] 고객 개별항목 조회
* Module      : FI
* Type        : Report
* Description : 고개 별 개별항목 조회
************************************************************************

*----------------------------------------------------------------------*
* INCLUDES
*----------------------------------------------------------------------*
INCLUDE YEZFIR0080_TOP.
INCLUDE YEZFIR0080_C01.
INCLUDE YEZFIR0080_F01.
INCLUDE YEZFIR0080_F02.
INCLUDE YEZFIR0080_O01.
INCLUDE YEZFIR0080_I01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN                                                  *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SELSCR_PROC.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

* 초기화면 입력값 점검
  PERFORM CHECK_SELECTION_SCREEN_INPUT.

  CHECK ( GV_ERROR = ABAP_FALSE ).

* 초기화
  PERFORM INIT_PROC.

* 개별항목 자료 선택 및 구성
  PERFORM MAKE_OUTTAB_PROC.

* 전표번호 선택화면 호출
  PERFORM CALL_SCREEN_0100.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
