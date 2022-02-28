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

    CASE E_COLUMN_ID.
      WHEN 'BELNR'.
        IF ( E_ROW_ID-ROWTYPE+0(1) = ' ' ).
          CLEAR GS_OUTTAB.
          READ TABLE GT_OUTTAB INDEX E_ROW_ID-INDEX INTO GS_OUTTAB.

          IF ( SY-SUBRC = 0 ).
*           전표정보 메모리 세팅
            SET PARAMETER ID 'BUK' FIELD GS_OUTTAB-BUKRS.
            SET PARAMETER ID 'BLN' FIELD GS_OUTTAB-BELNR.
            SET PARAMETER ID 'GJR' FIELD GS_OUTTAB-GJAHR.

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
