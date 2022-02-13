*&---------------------------------------------------------------------*
*&  Include           YEZFIR0010_TOP
*&---------------------------------------------------------------------*
REPORT YEZFIR0010.

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
TABLES: YEZFIS0010.                        " [FI] Structure for Program YFIR0010

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_OUTTAB,
         EMPNO TYPE YEZFIT0010-EMPNO,      " 사원번호
         BNAME TYPE YEZFIT0010-BNAME,      " SAP User ID
         EMPNM TYPE YEZFIT0010-EMPNM,      " 사원명
         ORGCD TYPE YEZFIT0010-ORGCD,      " 부서코드
         ORGNM TYPE YEZFIT0020-ORGNM,      " 부서명
         KOSTL TYPE YEZFIT0020-KOSTL,      " 코스트센터
         EMAIL TYPE YEZFIT0010-EMAIL,      " 이메일 주소
         TITLE TYPE YEZFIT0010-TITLE,      " 호칭
         ACTIV TYPE YEZFIT0010-ACTIV,      " 활성화 여부 ( 'X' :활성화, ' ' : 비활성화 )
         ERDAT TYPE YEZFIT0010-ERDAT,      " 레코드 생성일
         ERZET TYPE YEZFIT0010-ERZET,      " 입력 시간
         ERNAM TYPE YEZFIT0010-ERNAM,      " 오브젝트 생성자 이름
         AEDAT TYPE YEZFIT0010-AEDAT,      " 최종 변경일
         AEZET TYPE YEZFIT0010-AEZET,      " 최종변경시간
         AENAM TYPE YEZFIT0010-AENAM,      " 오브젝트 변경자 이름
       END OF TY_S_OUTTAB.

TYPES: TY_T_OUTTAB   TYPE STANDARD TABLE OF TY_S_OUTTAB.

TYPES: BEGIN OF TY_S_ORGCD,
         ORGCD TYPE YEZFIT0020-ORGCD,      " 부서코드
         ORGNM TYPE YEZFIT0020-ORGNM,      " 부서명
         KOSTL TYPE YEZFIT0020-KOSTL,      " 코스트센터
       END OF TY_S_ORGCD.

TYPES: TY_T_ORGCD   TYPE STANDARD TABLE OF TY_S_ORGCD.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: GT_OUTTAB   TYPE TY_T_OUTTAB.
DATA: GS_OUTTAB   TYPE TY_S_OUTTAB.

DATA: GT_ORGCD    TYPE TY_T_ORGCD.
DATA: GS_ORGCD    TYPE TY_S_ORGCD.

DATA: SAVE_OK     TYPE SY-UCOMM.
DATA: OK_CODE     TYPE SY-UCOMM.

DATA: GS_BUKRS    TYPE YEZFIS0020.
DATA: GV_TITLE    TYPE SY-TITLE.

DATA: GS_SUBLOGIN TYPE YEZFIS0040.

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 100 번 화면
CONSTANTS: C_CON_0100     TYPE SCRFNAME   VALUE 'CON_0100'.

DATA: GO_CONTAINER_0100   TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0100        TYPE REF TO GCL_ALV_GRID.

DATA: GT_FCAT_0100        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0100        TYPE LVC_S_FCAT.
DATA: GT_SORT_0100        TYPE LVC_T_SORT.

DATA: GS_LAYOUT_0100      TYPE LVC_S_LAYO.
DATA: GS_VARIANT_0100     TYPE DISVARIANT.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
* 조회조건
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS:     P_BUKRS   TYPE BUKRS
                          OBLIGATORY
                          MEMORY ID BUK.

SELECTION-SCREEN COMMENT 40(20) P_BUTXT FOR FIELD P_BUKRS.

SELECT-OPTIONS: S_EMPNO   FOR GS_OUTTAB-EMPNO.
SELECT-OPTIONS: S_BNAME   FOR GS_OUTTAB-BNAME.
SELECT-OPTIONS: S_EMPNM   FOR GS_OUTTAB-EMPNM.
SELECT-OPTIONS: S_ORGCD   FOR GS_OUTTAB-ORGCD.
SELECTION-SCREEN END OF BLOCK B1.
