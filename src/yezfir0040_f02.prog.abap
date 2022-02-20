*----------------------------------------------------------------------*
***INCLUDE YEZFIR0040_F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER_0211
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0211 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CUST_0211
    EXPORTING
      CONTAINER_NAME              = C_CON_0211
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

  IF ( SY-SUBRC = 0 ).
*   Create an instance of alv control
    CREATE OBJECT GO_GRID_0211
      EXPORTING
        I_PARENT = GO_CUST_0211.
  ELSE.
*   ALV Container 를 생성할 수 없습니다.
    MESSAGE A005(YFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LAYOUT_0211
*&---------------------------------------------------------------------*
*       ALV Layout setting
*----------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0211 .

  GS_LAYOUT_0211-SEL_MODE   = 'A'.
  GS_LAYOUT_0211-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT_0211-CWIDTH_OPT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0211
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0211 .

*  PERFORM FILL_ALV_SORT TABLES  GT_SORT_0211 USING:
*           " SPOS  FIELDNAME  UP   DOWN  SUBTOT
*             '1'   'EMPNO'    'X'  ' '   ' '.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0211
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0211 .

  DATA: LT_FIELDCAT   TYPE STANDARD TABLE OF YEZFIS1010.
  DATA: LS_FIELDCAT   TYPE YEZFIS1010.

  PERFORM SELECT_FIELDCAT_PROC IN PROGRAM YEZFIS0010
                               TABLES LT_FIELDCAT[]
                               USING  SY-REPID
                                      SY-DYNNR
                                      C_CON_0211.

  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
    PERFORM FILL_FIELDCAT IN PROGRAM YEZFIS0010
                          TABLES GT_FCAT_0211 USING:
             " STRUCTURE      START/END   FIELDNAME      VALUE
               GS_FCAT_0211   'S'         'COL_POS'      LS_FIELDCAT-COL_POS,
               GS_FCAT_0211   ' '         'FIELDNAME'    LS_FIELDCAT-FIELDNAME,
               GS_FCAT_0211   ' '         'KEY'          LS_FIELDCAT-KEY_FIELD,
               GS_FCAT_0211   ' '         'REF_TABLE'    LS_FIELDCAT-REF_TABLE,
               GS_FCAT_0211   ' '         'REF_FIELD'    LS_FIELDCAT-REF_FIELD,
               GS_FCAT_0211   ' '         'CFIELDNAME'   LS_FIELDCAT-CFIELDNAME,
               GS_FCAT_0211   ' '         'CHECKBOX'     LS_FIELDCAT-CHECKBOX,
               GS_FCAT_0211   ' '         'HOTSPOT'      LS_FIELDCAT-HOTSPOT,
               GS_FCAT_0211   ' '         'JUST'         LS_FIELDCAT-JUST,
               GS_FCAT_0211   ' '         'DO_SUM'       LS_FIELDCAT-DO_SUM,
               GS_FCAT_0211   ' '         'NO_OUT'       LS_FIELDCAT-NO_OUT,
               GS_FCAT_0211   ' '         'TECH'         LS_FIELDCAT-TECH,
               GS_FCAT_0211   'E'         'REPTEXT'      LS_FIELDCAT-REPTEXT.
  ENDLOOP.

  DATA: LV_INDEX   TYPE SY-TABIX.

  LOOP AT GT_FCAT_0211 INTO GS_FCAT_0211.
    LV_INDEX = SY-TABIX.

    IF ( GS_FCAT_0211-FIELDNAME = 'WRBTR_S' ) OR
       ( GS_FCAT_0211-FIELDNAME = 'WRBTR_H' ) OR
       ( GS_FCAT_0211-FIELDNAME = 'WRBTR_J' ).
      IF ( YEZFIS0070-WAERS = YEZFIS0070-HWAER ).
        GS_FCAT_0211-NO_OUT = ABAP_TRUE.
      ELSE.
        GS_FCAT_0211-NO_OUT = ABAP_FALSE.
      ENDIF.

      MODIFY GT_FCAT_0211 FROM GS_FCAT_0211 INDEX LV_INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_ALV_SORT
*&---------------------------------------------------------------------*
*       ALV 정렬기준 구성
*----------------------------------------------------------------------*
*      <--PT_SORT
*      -->PV_SPOS
*      -->PV_FIELDNAME
*      -->PV_UP
*      -->PV_DOWN
*      -->PV_SUBTOT
*----------------------------------------------------------------------*
FORM FILL_ALV_SORT  TABLES   PT_SORT   STRUCTURE LVC_S_SORT
                    USING    VALUE(PV_SPOS)
                             VALUE(PV_FIELDNAME)
                             VALUE(PV_UP)
                             VALUE(PV_DOWN)
                             VALUE(PV_SUBTOT).

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LS_SORT   TYPE LVC_S_SORT.

  CLEAR: LS_SORT.

*----------------------------------------------------------------------*
* 정렬순서 지정
*----------------------------------------------------------------------*
  LS_SORT-SPOS      = PV_SPOS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP        = PV_UP.
  LS_SORT-DOWN      = PV_DOWN.
  LS_SORT-SUBTOT    = PV_SUBTOT.

  APPEND LS_SORT TO PT_SORT.
  CLEAR: LS_SORT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_ALV_DISPLAY_0211
*&---------------------------------------------------------------------*
*       ALV 를 조회할 수 있도록 한다.
*----------------------------------------------------------------------*
FORM ALV_ALV_DISPLAY_0211 .

  GS_VARIANT_0211-REPORT  = SY-REPID.

  CALL METHOD GO_GRID_0211->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
      IS_LAYOUT          = GS_LAYOUT_0211
      I_SAVE             = 'A'
      IS_VARIANT         = GS_VARIANT_0211
    CHANGING
      IT_OUTTAB          = GT_OUTTAB[]
      IT_FIELDCATALOG    = GT_FCAT_0211[]
      IT_SORT            = GT_SORT_0211[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV_0211
*&---------------------------------------------------------------------*
*       ALV Grid 새로고침
*----------------------------------------------------------------------*
FORM REFRESH_ALV_0211 .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LS_STABLE   TYPE LVC_S_STBL.

  CLEAR: LS_STABLE.

*----------------------------------------------------------------------*
* ALV Grid 새로고침
*----------------------------------------------------------------------*
  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD GO_GRID_0211->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE         " With Stable Rows/Columns
      I_SOFT_REFRESH = ' '.              " Without Sort, Filter, etc

  CALL METHOD GO_GRID_0211->SET_OPTIMIZE_ALL_COLS.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER_0211
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0211 .

  CREATE OBJECT GO_EVENT_RECEIVER.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GO_GRID_0211.

ENDFORM.
