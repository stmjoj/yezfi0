*&---------------------------------------------------------------------*
*&  Include           YEZFIR0050_F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER_0100
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0100 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CUST_0100
    EXPORTING
      CONTAINER_NAME              = C_CON_0100
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

  IF ( SY-SUBRC = 0 ).
*   Create an instance of alv control
    CREATE OBJECT GO_GRID_0100
      EXPORTING
        I_PARENT = GO_CUST_0100.
  ELSE.
*   ALV Container 를 생성할 수 없습니다.
    MESSAGE A005(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LAYOUT_0100
*&---------------------------------------------------------------------*
*       ALV Layout setting
*----------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0100 .

  GS_LAYO_0100-SEL_MODE   = 'A'.
  GS_LAYO_0100-ZEBRA      = ABAP_TRUE.
  GS_LAYO_0100-CWIDTH_OPT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0100
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0100 .

  DATA: LT_SORT   TYPE STANDARD TABLE OF YEZFIS1020.
  DATA: LS_SORT   TYPE YEZFIS1020.

  PERFORM SELECT_SORT_ORDER_PROC IN PROGRAM YEZFIS0010
                                 TABLES LT_SORT[]
                                 USING  SY-REPID
                                        SY-DYNNR
                                        C_CON_0100.

  LOOP AT LT_SORT INTO LS_SORT.
    CHECK ( LS_SORT-SPOS IS NOT INITIAL ).

    PERFORM FILL_ALV_SORT TABLES  GT_SORT_0100 USING:
             LS_SORT-SPOS              " SPOS
             LS_SORT-FIELDNAME         " FIELDNAME
             LS_SORT-UP                " UP
             LS_SORT-DOWN              " DOWN
             LS_SORT-SUBTOT.            " SUBTOT
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0100
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0100 .

  DATA: LT_FIELDCAT   TYPE STANDARD TABLE OF YEZFIS1010.
  DATA: LS_FIELDCAT   TYPE YEZFIS1010.

  PERFORM SELECT_FIELDCAT_PROC IN PROGRAM YEZFIS0010
                               TABLES LT_FIELDCAT[]
                               USING  SY-REPID
                                      SY-DYNNR
                                      C_CON_0100.

  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
    PERFORM FILL_FIELDCAT IN PROGRAM YEZFIS0010
                          TABLES GT_FCAT_0100 USING:
             " STRUCTURE      START/END   FIELDNAME      VALUE
               GS_FCAT_0100   'S'         'COL_POS'      LS_FIELDCAT-COL_POS,
               GS_FCAT_0100   ' '         'FIELDNAME'    LS_FIELDCAT-FIELDNAME,
               GS_FCAT_0100   ' '         'KEY'          LS_FIELDCAT-KEY_FIELD,
               GS_FCAT_0100   ' '         'REF_TABLE'    LS_FIELDCAT-REF_TABLE,
               GS_FCAT_0100   ' '         'REF_FIELD'    LS_FIELDCAT-REF_FIELD,
               GS_FCAT_0100   ' '         'CFIELDNAME'   LS_FIELDCAT-CFIELDNAME,
               GS_FCAT_0100   ' '         'CHECKBOX'     LS_FIELDCAT-CHECKBOX,
               GS_FCAT_0100   ' '         'HOTSPOT'      LS_FIELDCAT-HOTSPOT,
               GS_FCAT_0100   ' '         'JUST'         LS_FIELDCAT-JUST,
               GS_FCAT_0100   ' '         'DO_SUM'       LS_FIELDCAT-DO_SUM,
               GS_FCAT_0100   ' '         'NO_OUT'       LS_FIELDCAT-NO_OUT,
               GS_FCAT_0100   ' '         'TECH'         LS_FIELDCAT-TECH,
               GS_FCAT_0100   'E'         'REPTEXT'      LS_FIELDCAT-REPTEXT.
  ENDLOOP.

*  DATA: LV_INDEX   TYPE SY-TABIX.
*
*  LOOP AT GT_FCAT_0100 INTO GS_FCAT_0100.
*    LV_INDEX = SY-TABIX.
*
*    IF ( GS_FCAT_0100-FIELDNAME = 'WRBTR_S' ) OR
*       ( GS_FCAT_0100-FIELDNAME = 'WRBTR_H' ) OR
*       ( GS_FCAT_0100-FIELDNAME = 'WRBTR_J' ).
*      IF ( YEZFIS0070-WAERS = YEZFIS0070-HWAER ).
*        GS_FCAT_0100-NO_OUT = ABAP_TRUE.
*      ELSE.
*        GS_FCAT_0100-NO_OUT = ABAP_FALSE.
*      ENDIF.
*
*      MODIFY GT_FCAT_0100 FROM GS_FCAT_0100 INDEX LV_INDEX.
*    ENDIF.
*  ENDLOOP.

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
*&      Form  ALV_ALV_DISPLAY_0100
*&---------------------------------------------------------------------*
*       ALV 를 조회할 수 있도록 한다.
*----------------------------------------------------------------------*
FORM ALV_ALV_DISPLAY_0100 .

  GS_VARI_0100-REPORT  = SY-REPID.

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
      IS_LAYOUT          = GS_LAYO_0100
      I_SAVE             = 'A'
      IS_VARIANT         = GS_VARI_0100
    CHANGING
      IT_OUTTAB          = GT_OUTTAB[]
      IT_FIELDCATALOG    = GT_FCAT_0100[]
      IT_SORT            = GT_SORT_0100[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV_0100
*&---------------------------------------------------------------------*
*       ALV Grid 새로고침
*----------------------------------------------------------------------*
FORM REFRESH_ALV_0100 .

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

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE         " With Stable Rows/Columns
      I_SOFT_REFRESH = ' '.              " Without Sort, Filter, etc

  CALL METHOD GO_GRID_0100->SET_OPTIMIZE_ALL_COLS.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0100 .

  CREATE OBJECT GO_EVENT_RECEIVER.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GO_GRID_0100.

ENDFORM.
