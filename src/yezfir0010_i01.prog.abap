*&---------------------------------------------------------------------*
*&  Include           YEZFIR0010_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       100번 화면 종료명령어 처리
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND_0100 INPUT.

* ALV GRID 초기화
  IF ( GO_GRID_0100 IS NOT INITIAL ).
    CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY.
    CALL METHOD GO_GRID_0100->FREE.
    CLEAR: GO_GRID_0100.
  ENDIF.

* CONTAINER 초기화
  IF ( GO_CONTAINER_0100 IS NOT INITIAL ).
    CALL METHOD GO_CONTAINER_0100->FREE.
    CLEAR GO_CONTAINER_0100.
  ENDIF.

* 화면 종료
   LEAVE TO SCREEN 0.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*      100번 화면 사용자 명령어 처리
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'SAVE'.
  ENDCASE.

ENDMODULE.
