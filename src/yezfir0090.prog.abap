************************************************************************
* Program ID  : YEZFIR0090
* Title       : [FI] 손익센터 업로드
* Module      : FI
* Type        : Report
* Description : 엑셀 파일을 업로드 받아 손익센터를 대량 생성/변경
************************************************************************

* https://z2soo.github.io/blog/abap/ABAP-%EC%97%91%EC%85%80-%EC%97%85%EB%A1%9C%EB%93%9C-%EB%B0%8F-%EB%8B%A4%EC%9A%B4%EB%A1%9C%EB%93%9C-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%A8/

*----------------------------------------------------------------------*
* INCLUDES
*----------------------------------------------------------------------*
INCLUDE YEZFIR0090_TOP.
INCLUDE YEZFIR0090_C01.
INCLUDE YEZFIR0090_F01.
INCLUDE YEZFIR0090_F02.
INCLUDE YEZFIR0090_O01.
INCLUDE YEZFIR0090_I01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
*       AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM SELSCR_FUNC_KEY_PROC.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SELSCR.            " 선택화면 수정

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM GET_FILE_PATH.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

* 초기화
  PERFORM INIT_PROC.

* 파일 업로드 진행
  PERFORM FILE_UPLOAD.

* 조회를 위한 자료 구성
  PERFORM MAKE_OUTTAB_PROC.

* 화면 출력
  PERFORM DISPLAY_DATA.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
