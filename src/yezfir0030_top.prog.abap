*&---------------------------------------------------------------------*
*&  Include           YEZFIR0030_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR0030.

*----------------------------------------------------------------------*
* TYPE-POOLS
*----------------------------------------------------------------------*
TYPE-POOLS: ICON.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
* 업로드 데이터 변환
TYPES: BEGIN OF TY_S_UPLOAD,
         SAKNR   TYPE YEZFIS0050-SAKNR,   " G/L 계정
         TXT20   TYPE YEZFIS0050-TXT20,   " 내역
         TXT50   TYPE YEZFIS0050-TXT50,   " G/L 계정 설명
         XBILK   TYPE YEZFIS0050-XBILK,   " 대차대조표 계정
         GVTYP   TYPE YEZFIS0050-GVTYP,   " 손익계산서 계정 유형
         KTOKS   TYPE YEZFIS0050-KTOKS,   " 계정 그룹
         WAERS   TYPE YEZFIS0050-WAERS,   " 계정 통화
         XSALH   TYPE YEZFIS0050-XSALH,   " 잔액(현지 통화)만
         MWSKZ   TYPE YEZFIS0050-MWSKZ,   " 세금 범주
         XMWNO   TYPE YEZFIS0050-XMWNO,   " 세금 없이 전기 허용
         MITKZ   TYPE YEZFIS0050-MITKZ,   " 계정 유형에 대한 조정 계정
         ALTKT   TYPE YEZFIS0050-ALTKT,   " 대체 계정 번호
         WMETH   TYPE YEZFIS0050-WMETH,   " 외부 시스템에서 관리되는 계정
         XOPVW   TYPE YEZFIS0050-XOPVW,   " 미결 항목 관리
         XKRES   TYPE YEZFIS0050-XKRES,   " 개별 항목 조회
         ZUAWA   TYPE YEZFIS0050-ZUAWA,   " 정렬 키
         FSTAG   TYPE YEZFIS0050-FSTAG,   " 필드상태그룹
         XINTB   TYPE YEZFIS0050-XINTB,   " 자동 전기만
         XMITK   TYPE YEZFIS0050-XMITK,   " 조정 계정 입력 가능
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

DATA: GS_SUBLOGIN TYPE YEZFIS0040.

DATA: GV_TOT_CNT  TYPE I.            " 전체 건수
DATA: GV_UPD_CNT  TYPE I.            " 대상 건수

DATA: GV_MODE     TYPE ALLGAZMD.

* 엑셀 업로드
DATA: GT_EXCEL    TYPE STANDARD TABLE OF ALSMEX_TABLINE.
DATA: GS_EXCEL    TYPE ALSMEX_TABLINE.

* 업로드 데이터 변환
DATA: GT_UPLOAD   TYPE TY_T_UPLOAD.
DATA: GS_UPLOAD   TYPE TY_S_UPLOAD.

* 업로드 결과 조회를 위한 ITAB
DATA: GT_OUTTAB   TYPE STANDARD TABLE OF YEZFIS0050.
DATA: GS_OUTTAB   TYPE YEZFIS0050.

* BDC 결과 조회를 위한 ITAB
DATA: GT_RESULT   TYPE STANDARD TABLE OF YEZFIS0050.
DATA: GS_RESULT   TYPE YEZFIS0050.

* G/L 계정 마스터
DATA: GT_SKB1     TYPE TY_T_UPLOAD.
DATA: GS_SKB1     TYPE TY_S_UPLOAD.

* BDC 처리
DATA: GT_BDCTAB   TYPE STANDARD TABLE OF BDCDATA.
DATA: GS_BDCTAB   TYPE BDCDATA.

DATA: GT_BDCMSG   TYPE STANDARD TABLE OF BDCMSGCOLL.
DATA: GS_BDCMSG   TYPE BDCMSGCOLL.

DATA: GV_MSGTYP   TYPE BDCMSGCOLL-MSGTYP.
DATA: GV_MSGTXT   TYPE NATXT.

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 100 번 화면
CONSTANTS: C_CON_0100     TYPE SCRFNAME   VALUE 'CON_0100'.

DATA: GO_CONTAINER_0100   TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0100        TYPE REF TO GCL_ALV_GRID_0100.

DATA: GT_FCAT_0100        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0100        TYPE LVC_S_FCAT.
DATA: GT_SORT_0100        TYPE LVC_T_SORT.

DATA: GS_LAYOUT_0100      TYPE LVC_S_LAYO.
DATA: GS_VARIANT_0100     TYPE DISVARIANT.

* 200 번 화면
CONSTANTS: C_CON_0200     TYPE SCRFNAME   VALUE 'CON_0200'.

DATA: GO_CONTAINER_0200   TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0200        TYPE REF TO GCL_ALV_GRID_0200.

DATA: GT_FCAT_0200        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0200        TYPE LVC_S_FCAT.
DATA: GT_SORT_0200        TYPE LVC_T_SORT.

DATA: GS_LAYOUT_0200      TYPE LVC_S_LAYO.
DATA: GS_VARIANT_0200     TYPE DISVARIANT.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

* 발의자정보
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS:     P_BUKRS   TYPE BUKRS
                          OBLIGATORY
                          MEMORY ID BUK.

SELECTION-SCREEN COMMENT 40(25) P_BUTXT FOR FIELD P_BUKRS.

*PARAMETERS:     P_BEMPNO  TYPE YEZ_BEMPNO
*                          OBLIGATORY
*                          MEMORY ID YEZ_EMPNO.
*
*SELECTION-SCREEN COMMENT 50(30) P_BEMPNM FOR FIELD P_BEMPNO.
*
*PARAMETERS:     P_BORGCD  TYPE YEZ_BORGCD
*                          OBLIGATORY
*                          MEMORY ID YEZ_ORGCD.
*
*SELECTION-SCREEN COMMENT 50(30) P_BORGNM FOR FIELD P_BORGCD.
*
SELECTION-SCREEN END OF BLOCK B1.

* UPLOAD 파일
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-003.
PARAMETERS:     P_FILE    TYPE RLGRAP-FILENAME
*                         DEFAULT 'C:\'
                          DEFAULT 'C:\Users\karij\Desktop\GL계정 업로드 - 복사본.xlsx'
                          OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B2.
