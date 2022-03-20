*&---------------------------------------------------------------------*
*&  Include           YEZFIR0090_F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER_0100
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0100 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CONT_0100
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
        I_PARENT = GO_CONT_0100.
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
  GS_LAYO_0100-NO_TOOLBAR = ABAP_FALSE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0100
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0100 .

*  PERFORM SET_SORTORDER_PROC IN PROGRAM YEZFIS0010
*                        TABLES GT_SORT_0100[]
*                        USING  SY-REPID
*                               SY-DYNNR
*                               C_CON_0100.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0100
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0100 .

  PERFORM SET_FIELDCAT_PROC IN PROGRAM YEZFIS0010
                       TABLES GT_FCAT_0100[]
                       USING  SY-REPID
                              SY-DYNNR
                              C_CON_0100.

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
*&      Form  FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       FIELD CATALOG 구성
*----------------------------------------------------------------------*
*      <--PT_FCAT
*      -->PV_GUBUN
*      -->PV_FNAME
*      -->PV_VALUE
*----------------------------------------------------------------------*
FORM FILL_FIELDCAT  TABLES   PT_FCAT   STRUCTURE LVC_S_FCAT
                    USING    PS_FCAT   TYPE LVC_S_FCAT
                             VALUE(PV_GUBUN)
                             VALUE(PV_FNAME)
                             VALUE(PV_VALUE).

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_FNAME(40)   TYPE C.

  FIELD-SYMBOLS: <FS>   TYPE ANY.

  CLEAR: LV_FNAME.

*----------------------------------------------------------------------*
* FIELD CATALOG 구성
*----------------------------------------------------------------------*
  IF ( PV_GUBUN = 'S' ).
    CLEAR: PS_FCAT.
  ENDIF.

  CONCATENATE 'PS_FCAT-' PV_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS>.
  <FS> = PV_VALUE.

  IF ( PV_FNAME = 'REPTEXT' ).
    PS_FCAT-SCRTEXT_L  = PV_VALUE.
    PS_FCAT-SCRTEXT_M  = PV_VALUE.
    PS_FCAT-SCRTEXT_S  = PV_VALUE.
    PS_FCAT-COLDDICTXT = 'L'.
  ENDIF.

  IF ( PV_GUBUN = 'E' ).
    APPEND PS_FCAT TO PT_FCAT.
  ENDIF.

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
*&      Form  SET_ALV_CONTAINER_0200
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0200 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CONT_0200
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
        I_PARENT = GO_CONT_0200.
  ELSE.
*   ALV Container 를 생성할 수 없습니다.
    MESSAGE A005(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LAYOUT_0200
*&---------------------------------------------------------------------*
*       ALV Layout setting
*----------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0200 .

  GS_LAYO_0200-SEL_MODE   = 'A'.
  GS_LAYO_0200-ZEBRA      = ABAP_TRUE.
  GS_LAYO_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYO_0200-NO_TOOLBAR = ABAP_FALSE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0200
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0200 .

*  PERFORM SET_SORTORDER_PROC IN PROGRAM YEZFIS0010
*                        TABLES GT_SORT_0200[]
*                        USING  SY-REPID
*                               SY-DYNNR
*                               C_CON_0200.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0200
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0200 .

  PERFORM SET_FIELDCAT_PROC IN PROGRAM YEZFIS0010
                       TABLES GT_FCAT_0200[]
                       USING  SY-REPID
                              SY-DYNNR
                              C_CON_0200.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_ALV_DISPLAY_0200
*&---------------------------------------------------------------------*
*       ALV 를 조회할 수 있도록 한다.
*----------------------------------------------------------------------*
FORM ALV_ALV_DISPLAY_0200 .

  GS_VARI_0200-REPORT  = SY-REPID.

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
      IS_LAYOUT          = GS_LAYO_0200
      I_SAVE             = 'A'
      IS_VARIANT         = GS_VARI_0200
    CHANGING
      IT_OUTTAB          = GT_RESULT[]
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
