************************************************************************
* Program ID  : YEZFIR0035
* Title       : [FI] G/L계정 조회
* Module      : FI
* Type        : Report
* Description : 회사코드 별 G/L계정 조회
************************************************************************

*----------------------------------------------------------------------*
* INCLUDES
*----------------------------------------------------------------------*
INCLUDE YEZFIR0035_TOP.
INCLUDE YEZFIR0035_C01.
INCLUDE YEZFIR0035_F01.
INCLUDE YEZFIR0035_F02.
INCLUDE YEZFIR0035_O01.
INCLUDE YEZFIR0035_I01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
* 선택화면 수정
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SELSCR.

* 계정그룹에 대한 F4 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KTOKS-LOW.
  PERFORM F4_HELP_KTOKS USING 'S_KTOKS-LOW'
                              S_KTOKS-LOW.

* 계정그룹에 대한 F4 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KTOKS-HIGH.
  PERFORM F4_HELP_KTOKS USING 'S_KTOKS-HIGH'
                              S_KTOKS-HIGH.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

* 초기화
  PERFORM INIT_PROC.

* 조회를 위한 자료 구성
  PERFORM MAKE_OUTTAB_PROC.

* 화면 출력
  PERFORM DISPLAY_DATA.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
