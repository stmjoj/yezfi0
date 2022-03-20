************************************************************************
* Program ID  : YEZFIR9000
* Title       : [FI] Utility - Client 간 자료 복사
* Module      : FI
* Type        : Report
* Description : 선택된 테이블이 자료를 다른 클라이언트로 복사
************************************************************************
REPORT YEZFIR9000.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: GT_FCAT       TYPE LVC_T_FCAT.

DATA: GT_DYNAMIC    TYPE REF TO DATA.
DATA: GS_DYNAMIC    TYPE REF TO DATA.

FIELD-SYMBOLS: <GT_DYNAMIC>   TYPE STANDARD TABLE.
FIELD-SYMBOLS: <GS_DYNAMIC>.
FIELD-SYMBOLS: <GV_MANDT>.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
PARAMETERS: P_SOURCE   TYPE SY-MANDT   OBLIGATORY   DEFAULT '500'.
PARAMETERS: P_TARGET   TYPE SY-MANDT   OBLIGATORY   DEFAULT '700'.
PARAMETERS: P_TABLE    TYPE TABNAME    OBLIGATORY   DEFAULT 'YEZFIT1010'.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM CREATE_DYNAMIC_ITAB.

  PERFORM SELECT_SOURCE.

  PERFORM MODIFY_TARGET.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  CREATE_DYNAMIC_ITAB
*&---------------------------------------------------------------------*
*       선택된 테이블의 구조를 가지는 INTERNAL TABLE 생성
*----------------------------------------------------------------------*
FORM CREATE_DYNAMIC_ITAB .

*----------------------------------------------------------------------*
* FIELD CATALOG 구성
*----------------------------------------------------------------------*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      I_STRUCTURE_NAME       = P_TABLE
      I_CLIENT_NEVER_DISPLAY = ' '
*     I_BYPASSING_BUFFER     =
*     I_INTERNAL_TABNAME     =
    CHANGING
      CT_FIELDCAT            = GT_FCAT[].
*   EXCEPTIONS
*     INCONSISTENT_INTERFACE = 1
*     PROGRAM_ERROR          = 2
*     OTHERS                 = 3

  IF ( SY-SUBRC <> 0 ).
    MESSAGE E341(00).
  ENDIF.

*----------------------------------------------------------------------*
* INTERNAL TABLE 생성
*----------------------------------------------------------------------*
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
*     I_STYLE_TABLE   =
      IT_FIELDCATALOG = GT_FCAT
*     I_LENGTH_IN_BYTE          =
    IMPORTING
      EP_TABLE        = GT_DYNAMIC.
*     E_STYLE_FNAME   =
*   EXCEPTIONS
*     GENERATE_SUBPOOL_DIR_FULL = 1
*     OTHERS          = 2

  BREAK-POINT.

  IF SY-SUBRC <> 0.
    MESSAGE E341(00).
  ENDIF.

*----------------------------------------------------------------------*
* DYNAMIC INTERNAL TABLE ACCESS 를 위한 변수 구성
*----------------------------------------------------------------------*
  ASSIGN GT_DYNAMIC->* TO <GT_DYNAMIC>.
  CREATE DATA GS_DYNAMIC LIKE LINE OF <GT_DYNAMIC>.
  ASSIGN GS_DYNAMIC->* TO <GS_DYNAMIC>.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_SOURCE
*&---------------------------------------------------------------------*
*       SOURCE TABLE SELECT
*----------------------------------------------------------------------*
FORM SELECT_SOURCE .

* TABLE SELECT
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <GT_DYNAMIC>
    FROM (P_TABLE) CLIENT SPECIFIED
   WHERE MANDT = P_SOURCE.

* CLIENT 값 변경
  LOOP AT <GT_DYNAMIC> INTO <GS_DYNAMIC>.
    DATA(LV_INDEX) = SY-TABIX.

    ASSIGN COMPONENT 'MANDT' OF STRUCTURE <GS_DYNAMIC> TO <GV_MANDT>.
    <GV_MANDT> = P_TARGET.

    MODIFY <GT_DYNAMIC> FROM <GS_DYNAMIC>
                        INDEX LV_INDEX.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MODIFY_TARGET
*&---------------------------------------------------------------------*
*       TARGET 테이블 변경
*----------------------------------------------------------------------*
FORM MODIFY_TARGET .

  MODIFY (P_TABLE) CLIENT SPECIFIED FROM TABLE <GT_DYNAMIC>.

ENDFORM.
