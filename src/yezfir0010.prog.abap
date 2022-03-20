************************************************************************
* Program ID  : YEZFIR0010
* Title       : [FI] 발의자 리스트
* Module      : FI
* Type        : Report
* Description : 발의자 사원목록을 조회할 수 있다.
************************************************************************

*----------------------------------------------------------------------*
* INCLUDES
*----------------------------------------------------------------------*
INCLUDE YEZFIR0010_TOP.
INCLUDE YEZFIR0010_C01.
INCLUDE YEZFIR0010_F01.
INCLUDE YEZFIR0010_F02.
INCLUDE YEZFIR0010_O01.
INCLUDE YEZFIR0010_I01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SELSCR.            " 선택화면 수정

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM CHECK_BUKRS_AUTH.         " 회사코드 권한 점검

  PERFORM INIT_PROC.                " 광역변수 초기화

  PERFORM MAKE_OUTTAB.              " 출력자료 구성

  PERFORM DISPLAY_OUTTAB.           " 자료 출력

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
