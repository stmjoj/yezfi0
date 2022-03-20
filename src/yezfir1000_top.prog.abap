*&---------------------------------------------------------------------*
*&  Include           YEZFIR1000_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR1000.

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
* TYPES
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_EXCLUDE,
         UCOMM   TYPE SY-UCOMM,
       END OF TY_S_EXCLUDE.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: YEZFIS0190.         " [FI] Structure for Program YEZFIR1000 Screen 0100
TABLES: YEZFIS0200.         " [FI] Structure for Program YEZFIR1000 Screen 0100 ALV

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: SAVE_OK             TYPE SY-UCOMM.
DATA: OK_CODE             TYPE SY-UCOMM.

DATA: GS_SUBLOGIN         TYPE YEZFIS0040.                     " Sublogin Info
DATA: GS_BUKRS            TYPE YEZFIS0020.                     " 회사코드 정보

DATA: GT_R_BSTAT          TYPE RANGE OF BKPF-BSTAT.            " 전표상태 RANGE

DATA: GT_PARK             TYPE STANDARD TABLE OF YEZFIS0200.   " 임시전표
DATA: GT_POST             TYPE STANDARD TABLE OF YEZFIS0200.   " 전기전표
DATA: GT_ALL              TYPE STANDARD TABLE OF YEZFIS0200.   " 전체전표

DATA: GT_DDTEXT           TYPE STANDARD TABLE OF DD07T.        " Domain Value Text

DATA: GT_EXCLUDE          TYPE STANDARD TABLE OF TY_S_EXCLUDE. " MENU 명령어 제외

*----------------------------------------------------------------------*
* TABSTRIP 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
CONTROLS: TAB_0100        TYPE TABSTRIP.

DATA: GV_DYNNR            TYPE SY-DYNNR.

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 110 번 화면
CONSTANTS: C_CON_0110     TYPE SCRFNAME   VALUE 'CON_0110'.

DATA: GO_CUST_0110        TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0110        TYPE REF TO GCL_ALV_GRID.

DATA: GT_FCAT_0110        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0110        TYPE LVC_S_FCAT.
DATA: GT_SORT_0110        TYPE LVC_T_SORT.

DATA: GS_LAYO_0110        TYPE LVC_S_LAYO.
DATA: GS_VARI_0110        TYPE DISVARIANT.

DATA: GO_EVNT_0110        TYPE REF TO GCL_EVENT_RECEIVER.

* 120 번 화면
CONSTANTS: C_CON_0120     TYPE SCRFNAME   VALUE 'CON_0120'.

DATA: GO_CUST_0120        TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0120        TYPE REF TO GCL_ALV_GRID.

DATA: GT_FCAT_0120        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0120        TYPE LVC_S_FCAT.
DATA: GT_SORT_0120        TYPE LVC_T_SORT.

DATA: GS_LAYO_0120        TYPE LVC_S_LAYO.
DATA: GS_VARI_0120        TYPE DISVARIANT.

DATA: GO_EVNT_0120        TYPE REF TO GCL_EVENT_RECEIVER.

* 130 번 화면
CONSTANTS: C_CON_0130     TYPE SCRFNAME   VALUE 'CON_0130'.

DATA: GO_CUST_0130        TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0130        TYPE REF TO GCL_ALV_GRID.

DATA: GT_FCAT_0130        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0130        TYPE LVC_S_FCAT.
DATA: GT_SORT_0130        TYPE LVC_T_SORT.

DATA: GS_LAYO_0130        TYPE LVC_S_LAYO.
DATA: GS_VARI_0130        TYPE DISVARIANT.

DATA: GO_EVNT_0130        TYPE REF TO GCL_EVENT_RECEIVER.

*----------------------------------------------------------------------*
* SELECTION-SCREEN                                                     *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
PARAMETERS:     P_BUKRS    TYPE BUKRS
                           OBLIGATORY
                           MEMORY ID BUK.
SELECTION-SCREEN COMMENT 40(20) P_BUTXT FOR FIELD P_BUKRS.

SELECT-OPTIONS: S_BUDAT    FOR YEZFIS0200-BUDAT
                           OBLIGATORY
                           NO-EXTENSION.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(10) TEXT-T03.

SELECTION-SCREEN POSITION 33.
PARAMETERS: P_RBPARK   RADIOBUTTON GROUP R1.
SELECTION-SCREEN COMMENT 35(08) TEXT-T04 FOR FIELD P_RBPARK.

SELECTION-SCREEN POSITION 53.
PARAMETERS: P_RBPOST   RADIOBUTTON GROUP R1.
SELECTION-SCREEN COMMENT 55(08) TEXT-T05 FOR FIELD P_RBPOST.

SELECTION-SCREEN POSITION 73.
PARAMETERS: P_RBALL    RADIOBUTTON GROUP R1.
SELECTION-SCREEN COMMENT 75(04) TEXT-T06 FOR FIELD P_RBALL.

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-T02.
SELECT-OPTIONS: S_BLART    FOR YEZFIS0200-BLART.
SELECT-OPTIONS: S_BLDAT    FOR YEZFIS0200-BLDAT.
SELECT-OPTIONS: S_GJAHR    FOR YEZFIS0200-GJAHR.
SELECT-OPTIONS: S_BELNR    FOR YEZFIS0200-BELNR.
SELECT-OPTIONS: S_XBLNR    FOR YEZFIS0200-XBLNR.
SELECT-OPTIONS: S_XREF1H   FOR YEZFIS0200-XREF1_HD.
SELECT-OPTIONS: S_XREF2H   FOR YEZFIS0200-XREF2_HD.
SELECT-OPTIONS: S_CPUDT    FOR YEZFIS0200-CPUDT.
SELECT-OPTIONS: S_USNAM    FOR YEZFIS0200-USNAM.
SELECTION-SCREEN END OF BLOCK B2.

PARAMETERS: P_REV   AS CHECKBOX.
