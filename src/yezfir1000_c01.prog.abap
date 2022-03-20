*&---------------------------------------------------------------------*
*&  Include           YEZFIR1000_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           YEZFIR0050_C01
*&---------------------------------------------------------------------*
CLASS GCL_ALV_GRID IMPLEMENTATION.

  METHOD SET_OPTIMIZE_ALL_COLS.
    CALL METHOD ME->OPTIMIZE_ALL_COLS
      EXPORTING
        INCLUDE_HEADER = 1.
  ENDMETHOD.                    " SET_OPTIMIZE_ALL_COLS

  METHOD SET_CURSOR.
    CALL METHOD ME->SET_CURRENT_CELL_BASE
      EXPORTING
        ROW = ROW
        COL = COL.
  ENDMETHOD.                    " SET_CURSOR

  METHOD SET_FIXED_COLUMN.
    CALL METHOD ME->SET_FIXED_COLS
      EXPORTING
        COLS = 11.
  ENDMETHOD.                    " SET_FIXED_COLUMN

  METHOD SET_ROW_RESIZE.
    CALL METHOD ME->SET_RESIZE_ROWS
      EXPORTING
        ENABLE = 1.
  ENDMETHOD.                    " SET_ROW_RESIZE

ENDCLASS.                    " GCL_ALV_GRID IMPLEMENTATION

CLASS GCL_EVENT_RECEIVER IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.
    DATA: LT_TABLE   TYPE STANDARD TABLE OF YEZFIS0200.

    CLEAR: LT_TABLE[].

    CASE GV_DYNNR.
      WHEN '0110'.                  " 전체
        LT_TABLE[] = GT_ALL[].
      WHEN '0120'.                  " 임시
        LT_TABLE[] = GT_PARK[].
      WHEN '0130'.                  " 전기
        LT_TABLE[] = GT_POST[].
    ENDCASE.

    CASE E_COLUMN_ID.
      WHEN 'BELNR'.
        IF ( E_ROW_ID-ROWTYPE+0(1) = ' ' ).
          READ TABLE LT_TABLE INTO DATA(LS_WA) INDEX E_ROW_ID-INDEX.

          IF ( SY-SUBRC = 0 ).
*           전표정보 메모리 세팅
            SET PARAMETER ID 'BUK' FIELD LS_WA-BUKRS.
            SET PARAMETER ID 'BLN' FIELD LS_WA-BELNR.
            SET PARAMETER ID 'GJR' FIELD LS_WA-GJAHR.

*           타프로그램 호출
            SET PARAMETER ID 'YEZ_CALLD' FIELD ABAP_TRUE.

            CALL TRANSACTION 'YEZFIR0040' AND SKIP FIRST SCREEN.
          ENDIF.
        ELSE.
*         MESSAGE : 합계 항목은 클릭할 수 없습니다.
          MESSAGE I016(YEZFIM).
        ENDIF.
    ENDCASE.
  ENDMETHOD.                           " handle_hotspot_click

ENDCLASS.
