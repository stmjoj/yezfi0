*&---------------------------------------------------------------------*
*& Include MYEZFI0100TOP                                       모듈풀              SAPMYEZFI0010
*&
*&---------------------------------------------------------------------*
PROGRAM SAPMYEZFI0010.

*----------------------------------------------------------------------*
* LOCAL CLASSES: Definition
*----------------------------------------------------------------------*
CLASS GCL_ALV_GRID DEFINITION INHERITING FROM CL_GUI_ALV_GRID.

  PUBLIC SECTION.
    METHODS SET_OPTIMIZE_ALL_COLS.
    METHODS SET_CURSOR IMPORTING ROW TYPE I
                                 COL TYPE I.
    METHODS SET_FIXED_COLUMN.
    METHODS SET_ROW_RESIZE.

ENDCLASS.            " GCL_ALV_GRID_DEFINITION

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: YEZFIS0060.
TABLES: YEZFIS0070.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: SAVE_OK     TYPE SY-UCOMM.
DATA: OK_CODE     TYPE SY-UCOMM.

DATA: GV_START    TYPE FLAG.                   " 프로그램 시작 여부
DATA: GS_SUBLOGIN TYPE YEZFIS0040.             " Sublogin Info
DATA: GS_BUKRS    TYPE YEZFIS0020.             " 회사코드 정보

DATA: GV_BSTAT    TYPE BKPF-BSTAT.             " 전표 상태

DATA: GT_OUTTAB   TYPE STANDARD TABLE OF YEZFIS0080.
DATA: GS_OUTTAB   TYPE YEZFIS0080.

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 200 번 화면
CONSTANTS: C_CON_0200     TYPE SCRFNAME   VALUE 'CON_0200'.

DATA: GO_CONTAINER_0200   TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0200        TYPE REF TO GCL_ALV_GRID.

DATA: GT_FCAT_0200        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0200        TYPE LVC_S_FCAT.
DATA: GT_SORT_0200        TYPE LVC_T_SORT.

DATA: GS_LAYOUT_0200      TYPE LVC_S_LAYO.
DATA: GS_VARIANT_0200     TYPE DISVARIANT.
