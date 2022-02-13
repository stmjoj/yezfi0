FUNCTION-POOL YEZFIF0030.                     "MESSAGE-ID ..

*----------------------------------------------------------------------*
* LOCAL CLASSES: Definition
*----------------------------------------------------------------------*
CLASS GCL_ALV_GRID_0200 DEFINITION INHERITING FROM CL_GUI_ALV_GRID.

  PUBLIC SECTION.
    METHODS SET_OPTIMIZE_ALL_COLS.
    METHODS SET_CURSOR IMPORTING ROW TYPE I
                                 COL TYPE I.
    METHODS SET_FIXED_COLUMN.
    METHODS SET_ROW_RESIZE.

ENDCLASS.            " GCL_ALV_GRID_0200 DEFINITION

CLASS GCL_EVENT_RECEIVER_0200 DEFINITION.

  PUBLIC SECTION.
    METHODS:
      HANDLE_HOTSPOT_CLICK
          FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
              IMPORTING E_ROW_ID E_COLUMN_ID.

ENDCLASS.            " GCL_EVENT_RECEIVER_0200 DEFINITION

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES: YEZFIS0030.                       " [FI] Structure for Function Y_FI_SUBLOGIN

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_S_ORG,
         BUKRS TYPE YEZFIT0020-BUKRS,       " 회사 코드
         ORGCD TYPE YEZFIT0020-ORGCD,       " 부서코드
         ORGNM TYPE YEZFIT0020-ORGNM,       " 부서명
       END OF TY_S_ORG.

TYPES: TY_T_ORG   TYPE STANDARD TABLE OF TY_S_ORG.

TYPES: BEGIN OF TY_S_EMP,
         BUKRS TYPE YEZFIT0010-BUKRS,     " 회사 코드
         BUTXT TYPE T001-BUTXT,           " 회사 코드 또는 회사 이름
         EMPNO TYPE YEZFIT0010-EMPNO,     " 사원번호
         EMPNM TYPE YEZFIT0010-EMPNM,     " 사원명
         TITLE TYPE YEZFIT0010-TITLE,     " 호칭
         ORGCD TYPE YEZFIT0011-ORGCD,     " 부서코드
         ORGNM TYPE YEZFIT0020-ORGNM,     " 부서명
         AUTYP TYPE YEZFIT0011-AUTYP,     " 권한유형
         ACTIV TYPE YEZFIT0011-ACTIV,     " 활성화 여부
       END OF TY_S_EMP.

TYPES: TY_T_EMP   TYPE STANDARD TABLE OF TY_S_EMP.

TYPES: BEGIN OF TY_S_AUTH,
         CHECK TYPE ICON-ID,              " Radio-Button
         ORGCD TYPE YEZFIT0011-ORGCD,     " 부서코드
         ORGNM TYPE YEZFIT0020-ORGNM,     " 부서명
         AUTYP TYPE YEZFIT0011-AUTYP,     " 권한유형
       END OF TY_S_AUTH.

TYPES: TY_T_AUTH   TYPE STANDARD TABLE OF TY_S_AUTH.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: GV_UNAME          TYPE SY-UNAME.

DATA: GS_SUBLOGIN       TYPE YEZFIS0040.
DATA: GV_RETURN         TYPE BAPI_MTYPE.
DATA: GV_MESSAGE        TYPE BAPI_MSG.

DATA: GT_ORG            TYPE TY_T_ORG.
DATA: GS_ORG            TYPE TY_S_ORG.

DATA: GT_EMP            TYPE TY_T_EMP.
DATA: GS_EMP            TYPE TY_S_EMP.

DATA: GT_AUTH           TYPE TY_T_AUTH.
DATA: GS_AUTH           TYPE TY_S_AUTH.

DATA: GT_VRM_BUKRS      TYPE STANDARD TABLE OF VRM_VALUE.
DATA: GS_VRM_BUKRS      TYPE VRM_VALUE.

DATA: GT_VRM_EMPNO      TYPE STANDARD TABLE OF VRM_VALUE.
DATA: GS_VRM_EMPNO      TYPE VRM_VALUE.

DATA: SAVE_OK           TYPE SY-UCOMM.
DATA: OK_CODE           TYPE SY-UCOMM.

DATA: GV_SINGLE_EMPNO   TYPE FLAG.        " 회사코드 및 사원이 1개 여부

*----------------------------------------------------------------------*
* ALV 관련 변수 선언                                                   *
*----------------------------------------------------------------------*
* 200 번 화면
CONSTANTS: C_CON_0200     TYPE SCRFNAME   VALUE 'CON_0200'.

DATA: GO_CONTAINER_0200   TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
DATA: GO_GRID_0200        TYPE REF TO GCL_ALV_GRID_0200.

DATA: GT_FCAT_0200        TYPE LVC_T_FCAT.
DATA: GS_FCAT_0200        TYPE LVC_S_FCAT.
DATA: GT_SORT_0200        TYPE LVC_T_SORT.

DATA: GS_LAYOUT_0200      TYPE LVC_S_LAYO.
DATA: GS_VARIANT_0200     TYPE DISVARIANT.

DATA: GO_EVENT_RECV_0200  TYPE REF TO GCL_EVENT_RECEIVER_0200.
