*&---------------------------------------------------------------------*
*&  Include           YEZFIR1000_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       100번 화면 종료명령어 처리
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND_0100 INPUT.

  IF ( GO_GRID_0110 IS NOT INITIAL ).
    CALL METHOD GO_GRID_0110->FREE.
  ENDIF.

  IF ( GO_GRID_0110 IS NOT INITIAL ).
    CALL METHOD GO_CUST_0110->FREE.
  ENDIF.

  IF ( GO_GRID_0120 IS NOT INITIAL ).
    CALL METHOD GO_GRID_0120->FREE.
  ENDIF.

  IF ( GO_GRID_0120 IS NOT INITIAL ).
    CALL METHOD GO_CUST_0120->FREE.
  ENDIF.

  IF ( GO_GRID_0130 IS NOT INITIAL ).
    CALL METHOD GO_GRID_0130->FREE.
  ENDIF.

  IF ( GO_GRID_0130 IS NOT INITIAL ).
    CALL METHOD GO_CUST_0130->FREE.
  ENDIF.

  CALL METHOD CL_GUI_CFW=>FLUSH.

* 화면 종료
  LEAVE TO SCREEN 0.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       100번 화면 사용자 명령어 처리
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE GV_DYNNR.
    WHEN '0110'.                         " 전체
      PERFORM GET_SELECTED_ROWS_0110.
    WHEN '0120'.                         " 임시
      PERFORM GET_SELECTED_ROWS_0120.
    WHEN '0130'.                         " 전기
      PERFORM GET_SELECTED_ROWS_0130.
  ENDCASE.

  CASE SAVE_OK.
*   탭 클릭 - 전체
    WHEN 'TAB100_1'.
      PERFORM SET_ACTIVE_TAB_0100 USING 'TAB100_1'.
*   탭 클릭 - 임시
    WHEN 'TAB100_2'.
      PERFORM SET_ACTIVE_TAB_0100 USING 'TAB100_2'.
*   탭 클릭 - 전기
    WHEN 'TAB100_3'.
      PERFORM SET_ACTIVE_TAB_0100 USING 'TAB100_3'.
*  그룹전표 생성
    WHEN 'NEWGR'.
      PERFORM CREATE_GROUP_SLIP_NO.
*  그룹전표 삭제
    WHEN 'DELGR'.
      PERFORM DELETE_GROUP_SLIP_NO.
*  전표 삭제
    WHEN '&DEL'.
*  결재 상신
    WHEN '&REQ'.
  ENDCASE.

ENDMODULE.
