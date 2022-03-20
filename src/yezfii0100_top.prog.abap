*&---------------------------------------------------------------------*
*&  Include           YEZFII0090_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR0090.

*----------------------------------------------------------------------*
* TYPE-POOLS
*----------------------------------------------------------------------*
TYPE-POOLS: ICON.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
* 업로드 데이터 변환
TYPES: BEGIN OF TY_S_UPLOAD,
         KOSTL   TYPE YEZFIS0210-KOSTL,   " 코스트 센터
         DATAB   TYPE YEZFIS0210-DATAB,   " 효력 시작일
         DATBI   TYPE YEZFIS0210-DATBI,   " 효력 종료일
         KTEXT   TYPE YEZFIS0210-KTEXT,   " 일반이름
         LTEXT   TYPE YEZFIS0210-LTEXT,   " 내역
         VERAK   TYPE YEZFIS0210-VERAK,   " 책임자
         KOSAR   TYPE YEZFIS0210-KOSAR,   " 코스트 센터 범주
         KHINR   TYPE YEZFIS0210-KHINR,   " 계층구조 영역
         WAERS   TYPE YEZFIS0210-WAERS,   " 통화
         PRCTR   TYPE YEZFIS0210-PRCTR,   " 손익 센터
      END OF TY_S_UPLOAD.

TYPES: TY_T_UPLOAD   TYPE STANDARD TABLE OF TY_S_UPLOAD.

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

CLASS GCL_ALV_GRID_0200 DEFINITION INHERITING FROM CL_GUI_ALV_GRID.

  PUBLIC SECTION.
    METHODS SET_OPTIMIZE_ALL_COLS.
    METHODS SET_CURSOR IMPORTING ROW TYPE I
                                 COL TYPE I.
    METHODS SET_FIXED_COLUMN.
    METHODS SET_ROW_RESIZE.

ENDCLASS.            " GCL_ALV_GRID_0200 DEFINITION

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS.                 " 선택화면 기능키 정의

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: SAVE_OK     TYPE SY-UCOMM.
DATA: OK_CODE     TYPE SY-UCOMM.

DATA: GS_BUKRS    TYPE YEZFIS0020.
DATA: GV_TITLE    TYPE SY-TITLE.
DATA: GV_BEZEI    TYPE TKA01-BEZEI.

DATA: GS_SUBLOGIN TYPE YEZFIS0040.

DATA: GV_TOT_CNT  TYPE I.            " 전체 건수
DATA: GV_UPD_CNT  TYPE I.            " 대상 건수

* 엑셀 업로드
DATA: GT_EXCEL    TYPE STANDARD TABLE OF ALSMEX_TABLINE.
DATA: GS_EXCEL    TYPE ALSMEX_TABLINE.

* 업로드 데이터 변환
DATA: GT_UPLOAD   TYPE TY_T_UPLOAD.
DATA: GS_UPLOAD   TYPE TY_S_UPLOAD.

* 업로드 결과 조회를 위한 ITAB
DATA: GT_OUTTAB   TYPE STANDARD TABLE OF YEZFIS0210.
DATA: GS_OUTTAB   TYPE YEZFIS0210.

* 처리 결과 조회를 위한 ITAB
DATA: GT_RESULT   TYPE STANDARD TABLE OF YEZFIS0210.
DATA: GS_RESULT   TYPE YEZFIS0210.

* 기존 코스트센터 마스터
DATA: GT_CSKS     TYPE TY_T_UPLOAD.
DATA: GS_CSKS     TYPE TY_S_UPLOAD.

* BDC 처리
DATA: GT_BDCTAB   TYPE STANDARD TABLE OF BDCDATA.
DATA: GS_BDCTAB   TYPE BDCDATA.

DATA: GT_BDCMSG   TYPE STANDARD TABLE OF BDCMSGCOLL.
DATA: GS_BDCMSG   TYPE BDCMSGCOLL.

DATA: GV_MSGTYP   TYPE BDCMSGCOLL-MSGTYP.
DATA: GV_MSGTXT   TYPE NATXT.

DATA: GS_PARAMS   TYPE CTU_PARAMS.
DATA: GV_MODE     TYPE ALLGAZMD.

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

* 200 번 화면
CONSTANTS: C_CON_0200     TYPE SCRFNAME   VALUE 'CON_0200'.

DATA: GO_CONT_0200        TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0200        TYPE REF TO GCL_ALV_GRID_0200.

DATA: GT_FCAT_0200        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0200        TYPE LVC_S_FCAT.
DATA: GT_SORT_0200        TYPE LVC_T_SORT.

DATA: GS_LAYO_0200        TYPE LVC_S_LAYO.
DATA: GS_VARI_0200        TYPE DISVARIANT.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

* 기본정보
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS:     P_BUKRS   TYPE BUKRS
                          OBLIGATORY
                          MEMORY ID BUK.

SELECTION-SCREEN COMMENT 40(25) P_BUTXT FOR FIELD P_BUKRS.

SELECTION-SCREEN END OF BLOCK B1.

* UPLOAD 파일
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-003.
PARAMETERS:     P_FILE    TYPE RLGRAP-FILENAME
*                         DEFAULT 'C:\'
                          DEFAULT 'C:\Users\karij\Desktop\코스트센터 업로드.xlsx'
                          OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B2.
