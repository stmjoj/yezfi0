*&---------------------------------------------------------------------*
*&  Include           YEZFIR0060_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR0060.

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
TABLES: YEZFIS0130.         " [FI] Structure for Program YEZFIR0060 Screen 0100

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_SKB1,
         SAKNR   TYPE SKB1-SAKNR,
         MITKZ   TYPE SKB1-MITKZ,
         XOPVW   TYPE SKB1-XOPVW,
       END OF TY_S_SKB1.

TYPES: TY_T_SKB1   TYPE STANDARD TABLE OF TY_S_SKB1.

TYPES: BEGIN OF TY_S_KEY,
         BUKRS   TYPE BSEG-BUKRS,
         BELNR   TYPE BSEG-BELNR,
         GJAHR   TYPE BSEG-GJAHR,
         BUZEI   TYPE BSEG-BUZEI,
       END OF TY_S_KEY.

TYPES: TY_T_KEY   TYPE STANDARD TABLE OF TY_S_KEY.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: SAVE_OK             TYPE SY-UCOMM.
DATA: OK_CODE             TYPE SY-UCOMM.

DATA: GS_SUBLOGIN         TYPE YEZFIS0040.             " Sublogin Info
DATA: GS_BUKRS            TYPE YEZFIS0020.             " ???????????? ??????

DATA: GT_OUTTAB           TYPE STANDARD TABLE OF YEZFIS0120.
DATA: GS_OUTTAB           TYPE YEZFIS0120.

DATA: GT_SKB1             TYPE TY_T_SKB1.
DATA: GS_SKB1             TYPE TY_S_SKB1.

DATA: GT_KEY              TYPE TY_T_KEY.
DATA: GS_KEY              TYPE TY_S_KEY.

DATA: GV_ERROR            TYPE YEZ_ERROR_YN.

*----------------------------------------------------------------------*
* ALV ?????? ?????? ??????                                                   *
*----------------------------------------------------------------------*
* 100 ??? ??????
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


SELECTION-SCREEN BEGIN OF BLOCK B4 WITH FRAME TITLE TEXT-T04.
SELECTION-SCREEN BEGIN OF BLOCK B5 WITH FRAME TITLE TEXT-T05.
PARAMETERS:     P_OPSEL    TYPE XOPSEL_IT RADIOBUTTON GROUP R1.
PARAMETERS:     P_STIDA    TYPE ALLGSTID.

SELECTION-SCREEN SKIP.

PARAMETERS:     P_CLSEL    TYPE XCLSEL_IT RADIOBUTTON GROUP R1.
SELECT-OPTIONS: S_AUGDT    FOR GS_OUTTAB-AUGDT.
PARAMETERS:     P_STID2    TYPE ALLGSTID.

SELECTION-SCREEN SKIP.

PARAMETERS:     P_AISEL    TYPE XAISEL_IT RADIOBUTTON GROUP R1.
SELECT-OPTIONS: S_BUDAT    FOR GS_OUTTAB-BUDAT.
SELECTION-SCREEN END OF BLOCK B5.
SELECTION-SCREEN BEGIN OF BLOCK B6 WITH FRAME TITLE TEXT-T06.
PARAMETERS:     P_NORM     TYPE XNORM_IT AS CHECKBOX DEFAULT ABAP_TRUE.
PARAMETERS:     P_PARK     TYPE XPARK_IT AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK B6.
SELECTION-SCREEN END OF BLOCK B4.


SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-T02.
SELECT-OPTIONS: S_BLART    FOR GS_OUTTAB-BLART.
SELECT-OPTIONS: S_BUDAT2   FOR GS_OUTTAB-BUDAT.
SELECT-OPTIONS: S_BLDAT    FOR GS_OUTTAB-BLDAT.
SELECT-OPTIONS: S_GJAHR    FOR GS_OUTTAB-GJAHR.
SELECT-OPTIONS: S_BELNR    FOR GS_OUTTAB-BELNR.
SELECT-OPTIONS: S_XBLNR    FOR GS_OUTTAB-XBLNR.
SELECT-OPTIONS: S_XREF1H   FOR GS_OUTTAB-XREF2_HD.
SELECT-OPTIONS: S_XREF2H   FOR GS_OUTTAB-XREF1_HD.
SELECTION-SCREEN END OF BLOCK B2.

SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-T03.
SELECT-OPTIONS: S_ZUONR    FOR GS_OUTTAB-ZUONR.
SELECT-OPTIONS: S_GSBER    FOR GS_OUTTAB-GSBER.
SELECTION-SCREEN END OF BLOCK B3.
