*&---------------------------------------------------------------------*
*&  Include           YEZFIR0035_C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* LOCAL CLASSES: Implementation
*----------------------------------------------------------------------*
CLASS GCL_ALV_GRID_0100 IMPLEMENTATION.

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

ENDCLASS.                    " GCL_ALV_GRID_0100 IMPLEMENTATION

CLASS GCL_EVNT_0100 IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.

    CASE E_COLUMN_ID.
      WHEN 'SAKNR'.
        IF ( E_ROW_ID-ROWTYPE+0(1) = ' ' ).
          CLEAR GS_OUTTAB.
          READ TABLE GT_OUTTAB INDEX E_ROW_ID-INDEX INTO GS_OUTTAB.

          IF ( SY-SUBRC = 0 ).
*           전표정보 메모리 세팅
            SET PARAMETER ID 'SAK' FIELD GS_OUTTAB-SAKNR.
            SET PARAMETER ID 'BUK' FIELD P_BUKRS.

            CALL TRANSACTION 'FS00' AND SKIP FIRST SCREEN.
          ENDIF.
        ELSE.
*         MESSAGE : 합계 항목은 클릭할 수 없습니다.
          MESSAGE I016(YEZFIM).
        ENDIF.
    ENDCASE.
  ENDMETHOD.                           " handle_hotspot_click

  METHOD HANDLE_ONF4.

    PERFORM EVENT_HELP_ON_F4 USING E_FIELDNAME
                                   E_FIELDVALUE
                                   ES_ROW_NO
                                   ER_EVENT_DATA
                                   ET_BAD_CELLS
                                   E_DISPLAY.

  ENDMETHOD.                           " handle_hotspot_click

ENDCLASS.
