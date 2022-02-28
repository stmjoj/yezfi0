*&---------------------------------------------------------------------*
*&  Include           YEZFIR0040_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR0040.

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

ENDCLASS.            " GCL_ALV_GRID DEFINITION

CLASS GCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    METHODS
      HANDLE_HOTSPOT_CLICK
                  FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW_ID E_COLUMN_ID.

ENDCLASS.            " GCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: YEZFIS0060.       " [FI] Structure for Program SAPMYFI0010 Screen 0100
TABLES: YEZFIS0070.       " [FI] Structure for Program SAPMYFI0010 Screen 0200
TABLES: YEZFIS0080.       " [FI] Structure for Program SAPMYFI0010 Screen 0211 ALV

TABLES: T001.             " 회사 코드

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: SAVE_OK             TYPE SY-UCOMM.
DATA: OK_CODE             TYPE SY-UCOMM.

DATA: GS_SUBLOGIN         TYPE YEZFIS0040.             " Sublogin Info
DATA: GS_BUKRS            TYPE YEZFIS0020.             " 회사코드 정보
DATA: GV_BSTAT            TYPE BKPF-BSTAT.             " 전표 상태
DATA: GV_BUZEI            TYPE BUZEI.                  " 회계 전표의 개별 항목 번호
DATA: GV_CALLD            TYPE ABAP_BOOL.              " 타프로그램 호출 여부

DATA: GT_OUTTAB           TYPE STANDARD TABLE OF YEZFIS0080.
DATA: GS_OUTTAB           TYPE YEZFIS0080.

DATA: GO_SPLITTER_HOR     TYPE REF TO CL_DYNPRO_SPLITTER.

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 211 번 화면
CONSTANTS: C_CON_0211     TYPE SCRFNAME   VALUE 'CON_0211'.

DATA: GO_CUST_0211        TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0211        TYPE REF TO GCL_ALV_GRID.

DATA: GT_FCAT_0211        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0211        TYPE LVC_S_FCAT.
DATA: GT_SORT_0211        TYPE LVC_T_SORT.

DATA: GS_LAYOUT_0211      TYPE LVC_S_LAYO.
DATA: GS_VARIANT_0211     TYPE DISVARIANT.

DATA: GO_EVENT_RECEIVER   TYPE REF TO GCL_EVENT_RECEIVER.
