*&---------------------------------------------------------------------*
*&  Include           YEZFIR0035_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR0035.

*----------------------------------------------------------------------*
* LOCAL CLASSES: Definition
*----------------------------------------------------------------------*
CLASS GCL_ALV_GRID_0100 DEFINITION INHERITING FROM CL_GUI_ALV_GRID.

  PUBLIC SECTION.
    METHODS SET_OPTIMIZE_ALL_COLS.
    METHODS SET_CURSOR IMPORTING ROW TYPE I
                                 COL TYPE I.
    METHODS SET_FIXED_COLUMN.
    METHODS SET_ROW_RESIZE.

ENDCLASS.            " GCL_ALV_GRID_0100 DEFINITION

CLASS GCL_EVNT_0100 DEFINITION.

  PUBLIC SECTION.
    METHODS
      HANDLE_HOTSPOT_CLICK
                  FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW_ID E_COLUMN_ID.

    METHODS
      HANDLE_ONF4 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
        IMPORTING E_FIELDNAME
                  E_FIELDVALUE
                  ES_ROW_NO
                  ER_EVENT_DATA
                  ET_BAD_CELLS
                  E_DISPLAY.

ENDCLASS.            " GCL_EVNT_0100 DEFINITION

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: YEZFIS0055.                 " 선택화면 기능키 정의

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: SAVE_OK     TYPE SY-UCOMM.
DATA: OK_CODE     TYPE SY-UCOMM.

DATA: GS_BUKRS    TYPE YEZFIS0020.
DATA: GV_TITLE    TYPE SY-TITLE.

DATA: GS_SUBLOGIN TYPE YEZFIS0040.

DATA: GV_TOT_CNT  TYPE I.            " 데이터 건수

* 조회를 위한 ITAB
DATA: GT_OUTTAB   TYPE STANDARD TABLE OF YEZFIS0055.
DATA: GS_OUTTAB   TYPE YEZFIS0055.

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 100 번 화면
CONSTANTS: C_CON_0100     TYPE SCRFNAME   VALUE 'CON_0100'.

DATA: GO_CONT_0100        TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0100        TYPE REF TO GCL_ALV_GRID_0100.

DATA: GT_FCAT_0100        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0100        TYPE LVC_S_FCAT.
DATA: GT_SORT_0100        TYPE LVC_T_SORT.

DATA: GS_LAYO_0100        TYPE LVC_S_LAYO.
DATA: GS_VARI_0100        TYPE DISVARIANT.

DATA: GO_EVNT_0100        TYPE REF TO GCL_EVNT_0100.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

* 조회조건
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS:     P_BUKRS   TYPE BUKRS
                          OBLIGATORY
                          MEMORY ID BUK.

SELECTION-SCREEN COMMENT 40(25) P_BUTXT FOR FIELD P_BUKRS.

SELECT-OPTIONS: S_SAKNR   FOR GS_OUTTAB-SAKNR.
SELECT-OPTIONS: S_TXT50   FOR GS_OUTTAB-TXT50.
SELECT-OPTIONS: S_KTOKS   FOR GS_OUTTAB-KTOKS.
SELECT-OPTIONS: S_MITKZ   FOR GS_OUTTAB-MITKZ.
SELECTION-SCREEN END OF BLOCK B1.
