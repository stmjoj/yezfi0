*&---------------------------------------------------------------------*
*&  Include           YEZFIR0040_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  INIT_0100  OUTPUT
*&---------------------------------------------------------------------*
*       100번 화면 초기화
*----------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       100번 화면 상태
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS 'M100'.
  SET TITLEBAR '100' WITH TEXT-T01.                " [FI] 전표 조회

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       200번 화면 초기화
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  SET PF-STATUS 'M200'.
  SET TITLEBAR '200' WITH TEXT-T02.                " [FI] 전표 조회

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SET_ALV_GRID_0211  OUTPUT
*&---------------------------------------------------------------------*
*       211번 화면 ALV GRID 구성
*----------------------------------------------------------------------*
MODULE SET_ALV_GRID_0211 OUTPUT.

*----------------------------------------------------------------------*
* Create ALV
*----------------------------------------------------------------------*
  IF ( GO_CUST_0211 IS INITIAL ).
    PERFORM SET_ALV_CONTAINER_0211.
    PERFORM SET_ALV_LAYOUT_0211.
    PERFORM SET_ALV_SORT_0211.
    PERFORM SET_ALV_FIELDCAT_0211.
    PERFORM ALV_ALV_DISPLAY_0211.
    PERFORM SET_EVENT_HANDLER_0211.

*----------------------------------------------------------------------*
* Refresh ALV
*----------------------------------------------------------------------*
  ELSE.
    PERFORM REFRESH_ALV_0211.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0200  OUTPUT
*&---------------------------------------------------------------------*
*       200번 화면 속성 변경
*----------------------------------------------------------------------*
MODULE MODIFY_SCREEN_0200 OUTPUT.

* 현지통화키
  LOOP AT SCREEN.
    CHECK ( SCREEN-NAME = 'YEZFIS0070-HWAER' ).

    IF ( YEZFIS0070-WAERS = YEZFIS0070-HWAER  ).
      SCREEN-INVISIBLE = 1.
    ELSE.
      SCREEN-INVISIBLE = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

* 역분개전표
  LOOP AT SCREEN.
    CHECK ( SCREEN-GROUP1 = 'RV' ).

    IF ( YEZFIS0070-XREVERSAL IS INITIAL ).
      SCREEN-INVISIBLE = 1.
    ELSE.
      SCREEN-INVISIBLE = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_HORIZOTAL_SPLITTER_0210  OUTPUT
*&---------------------------------------------------------------------*
*       210번 화면 HORIZOTAL SPLITTER 초기화
*----------------------------------------------------------------------*
MODULE INIT_HORIZOTAL_SPLITTER_0210 OUTPUT.

  IF ( GO_SPLITTER_HOR IS INITIAL ).
    CREATE OBJECT GO_SPLITTER_HOR
      EXPORTING
        SPLITTER_NAME = 'HOR'.
  ENDIF.

  GO_SPLITTER_HOR->SET_SASH( ).

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0212  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_SCREEN_0212 OUTPUT.

* 고객/구매처 계정 정보 표시
  LOOP AT SCREEN.
    CHECK ( SCREEN-GROUP1 = 'BP' ).

    IF ( YEZFIS0080-KOART = 'D' ) OR
       ( YEZFIS0080-KOART = 'K' ).
      SCREEN-INVISIBLE = 0.
    ELSE.
      SCREEN-INVISIBLE = 1.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

* 현지통화금액 정보 표시
  LOOP AT SCREEN.
    CHECK ( SCREEN-NAME = 'YEZFIS0080-DMBTR' ).

    IF ( YEZFIS0080-WAERS = YEZFIS0080-HWAER  ).
      SCREEN-INVISIBLE = 1.
    ELSE.
      SCREEN-INVISIBLE = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.


ENDMODULE.
