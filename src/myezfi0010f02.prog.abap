*----------------------------------------------------------------------*
***INCLUDE MYEZFI0010F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER_0200
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0200 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CONTAINER_0200
    EXPORTING
      CONTAINER_NAME              = C_CON_0200
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

  IF ( SY-SUBRC = 0 ).
*   Create an instance of alv control
    CREATE OBJECT GO_GRID_0200
      EXPORTING
        I_PARENT = GO_CONTAINER_0200.
  ELSE.
*   ALV Container 를 생성할 수 없습니다.
    MESSAGE A005(YFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LAYOUT_0200
*&---------------------------------------------------------------------*
*       ALV Layout setting
*----------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0200 .

  GS_LAYOUT_0200-SEL_MODE   = 'A'.
  GS_LAYOUT_0200-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0200
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0200 .

*  PERFORM FILL_ALV_SORT TABLES  GT_SORT_0200 USING:
*           " SPOS  FIELDNAME  UP   DOWN  SUBTOT
*             '1'   'EMPNO'    'X'  ' '   ' '.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0200
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0200 .

  DATA: LT_FIELDCAT   TYPE STANDARD TABLE OF YEZFIS1010.
  DATA: LS_FIELDCAT   TYPE YEZFIS1010.

  PERFORM SELECT_FIELDCAT_PROC IN PROGRAM YEZFIS0010
                               TABLES LT_FIELDCAT[]
                               USING  SY-REPID
                                      SY-DYNNR
                                      C_CON_0200.

  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
    PERFORM FILL_FIELDCAT IN PROGRAM YEZFIS0010
                          TABLES GT_FCAT_0200 USING:
             " STRUCTURE      START/END   FIELDNAME      VALUE
               GS_FCAT_0200   'S'         'COL_POS'      LS_FIELDCAT-COL_POS,
               GS_FCAT_0200   ' '         'FIELDNAME'    LS_FIELDCAT-FIELDNAME,
               GS_FCAT_0200   ' '         'KEY'          LS_FIELDCAT-KEY_FIELD,
               GS_FCAT_0200   ' '         'REF_TABLE'    LS_FIELDCAT-REF_TABLE,
               GS_FCAT_0200   ' '         'REF_FIELD'    LS_FIELDCAT-REF_FIELD,
               GS_FCAT_0200   ' '         'CFIELDNAME'   LS_FIELDCAT-CFIELDNAME,
               GS_FCAT_0200   ' '         'CHECKBOX'     LS_FIELDCAT-CHECKBOX,
               GS_FCAT_0200   ' '         'HOTSPOT'      LS_FIELDCAT-HOTSPOT,
               GS_FCAT_0200   ' '         'JUST'         LS_FIELDCAT-JUST,
               GS_FCAT_0200   ' '         'DO_SUM'       LS_FIELDCAT-DO_SUM,
               GS_FCAT_0200   ' '         'NO_OUT'       LS_FIELDCAT-NO_OUT,
               GS_FCAT_0200   ' '         'TECH'         LS_FIELDCAT-TECH,
               GS_FCAT_0200   'E'         'REPTEXT'      LS_FIELDCAT-REPTEXT.
  ENDLOOP.

  DATA: LV_INDEX   TYPE SY-TABIX.

  LOOP AT GT_FCAT_0200 INTO GS_FCAT_0200.
    LV_INDEX = SY-TABIX.

    IF ( GS_FCAT_0200-FIELDNAME = 'WRBTR_S' ) OR
       ( GS_FCAT_0200-FIELDNAME = 'WRBTR_H' ) OR
       ( GS_FCAT_0200-FIELDNAME = 'WRBTR_J' ).
      IF ( YEZFIS0070-WAERS = YEZFIS0070-HWAER ).
        GS_FCAT_0200-NO_OUT = ABAP_TRUE.
      ELSE.
        GS_FCAT_0200-NO_OUT = ABAP_FALSE.
      ENDIF.

      MODIFY GT_FCAT_0200 FROM GS_FCAT_0200 INDEX LV_INDEX.
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
*&      Form  ALV_ALV_DISPLAY_0200
*&---------------------------------------------------------------------*
*       ALV 를 조회할 수 있도록 한다.
*----------------------------------------------------------------------*
FORM ALV_ALV_DISPLAY_0200 .

  GS_VARIANT_0200-REPORT  = SY-REPID.

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
      IS_LAYOUT          = GS_LAYOUT_0200
      I_SAVE             = 'A'
      IS_VARIANT         = GS_VARIANT_0200
    CHANGING
      IT_OUTTAB          = GT_OUTTAB[]
      IT_FIELDCATALOG    = GT_FCAT_0200[]
      IT_SORT            = GT_SORT_0200[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV_0200
*&---------------------------------------------------------------------*
*       ALV Grid 새로고침
*----------------------------------------------------------------------*
FORM REFRESH_ALV_0200 .

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

  CALL METHOD GO_GRID_0200->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE         " With Stable Rows/Columns
      I_SOFT_REFRESH = ' '.              " Without Sort, Filter, etc

  CALL METHOD GO_GRID_0200->SET_OPTIMIZE_ALL_COLS.

ENDFORM.
