*&---------------------------------------------------------------------*
*&  Include           YEZFIR0040_C01
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
      WHEN 'BUZEI'.
        IF ( E_ROW_ID-ROWTYPE+0(1) = ' ' ).
          CLEAR GS_OUTTAB.
          READ TABLE GT_OUTTAB INDEX E_ROW_ID-INDEX INTO GS_OUTTAB.

          IF ( SY-SUBRC = 0 ).
            GV_BUZEI = GS_OUTTAB-BUZEI.

            CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
              EXPORTING
                NEW_CODE = 'DUMMY'.
          ENDIF.
        ELSE.
*         MESSAGE : 합계 항목은 클릭할 수 없습니다.
          MESSAGE I016(YEZFIM).
        ENDIF.
    ENDCASE.
  ENDMETHOD.                           " handle_hotspot_click

ENDCLASS.
