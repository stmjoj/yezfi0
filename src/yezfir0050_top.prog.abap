*&---------------------------------------------------------------------*
*&  Include           YEZFIR0050_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR0050.

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
TABLES: YEZFIS0110.         " [FI] Structure for Program YEZFIR0050 Screen 0100

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: SAVE_OK             TYPE SY-UCOMM.
DATA: OK_CODE             TYPE SY-UCOMM.

DATA: GS_SUBLOGIN         TYPE YEZFIS0040.             " Sublogin Info
DATA: GS_BUKRS            TYPE YEZFIS0020.             " 회사코드 정보

DATA: GT_OUTTAB           TYPE STANDARD TABLE OF YEZFIS0100.
DATA: GS_OUTTAB           TYPE YEZFIS0100.

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 100 번 화면
CONSTANTS: C_CON_0100     TYPE SCRFNAME   VALUE 'CON_0100'.

DATA: GO_CUST_0100        TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0100        TYPE REF TO GCL_ALV_GRID.

DATA: GT_FCAT_0100        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0100        TYPE LVC_S_FCAT.
DATA: GT_SORT_0100        TYPE LVC_T_SORT.

DATA: GS_LAYO_0100        TYPE LVC_S_LAYO.
DATA: GS_VARI_0100        TYPE DISVARIANT.

DATA: GO_EVENT_RECEIVER   TYPE REF TO GCL_EVENT_RECEIVER.

*----------------------------------------------------------------------*
* SELECTION-SCREEN                                                     *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
SELECT-OPTIONS: S_HKONT    FOR GS_OUTTAB-HKONT
                           MATCHCODE OBJECT SAKO
                           OBLIGATORY
                           MEMORY ID SAK.
PARAMETERS:     P_BUKRS    TYPE BUKRS
                           OBLIGATORY
                           MEMORY ID BUK.
SELECTION-SCREEN COMMENT 40(20) P_BUTXT FOR FIELD P_BUKRS.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-T02.
SELECT-OPTIONS: S_BLART    FOR GS_OUTTAB-BLART.
SELECT-OPTIONS: S_BUDAT    FOR GS_OUTTAB-BUDAT
                           OBLIGATORY.
SELECT-OPTIONS: S_BLDAT    FOR GS_OUTTAB-BLDAT.
SELECT-OPTIONS: S_GJAHR    FOR GS_OUTTAB-GJAHR.
SELECT-OPTIONS: S_BELNR    FOR GS_OUTTAB-BELNR.
SELECT-OPTIONS: S_XBLNR    FOR GS_OUTTAB-XBLNR.
SELECT-OPTIONS: S_XREF1H   FOR GS_OUTTAB-XREF2_HD.
SELECT-OPTIONS: S_XREF2H   FOR GS_OUTTAB-XREF1_HD.

PARAMETERS:     P_RLDNR    TYPE FAGLFLEXT-RLDNR
                           OBLIGATORY
                           MATCHCODE OBJECT FAGL_RLDNR_WITH_DEPENDENT.
SELECTION-SCREEN COMMENT 40(20) P_LDTXT FOR FIELD P_RLDNR.
SELECTION-SCREEN END OF BLOCK B2.

SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-T03.
*SELECT-OPTIONS: S_ZUONR    FOR GS_OUTTAB-ZUONR.
SELECT-OPTIONS: S_GSBER    FOR GS_OUTTAB-GSBER.
SELECTION-SCREEN END OF BLOCK B3.
