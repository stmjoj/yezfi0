*----------------------------------------------------------------------*
***INCLUDE LYFIF0030F02.
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
    MESSAGE A005(YEZFIM).
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
  GS_LAYOUT_0200-NO_TOOLBAR = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0200
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0200 .

*  PERFORM FILL_ALV_SORT TABLES  GT_SORT_0200 USING:
*           " SPOS  FIELDNAME  UP   DOWN  SUBTOT
*             '1'   'BUKRS'    'X'  ' '   ' ',
*             '2'   'ORGCD'    'X'  ' '   ' '.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0200
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0200 .

  PERFORM FILL_FIELDCAT TABLES GT_FCAT_0200 USING:
           " STRUCTURE      START/END   FIELDNAME      VALUE
             GS_FCAT_0200   'S'         'FIELDNAME'    'CHECK',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'ICON',
             GS_FCAT_0200   ' '         'REF_FIELD'    'ID',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   ' '         'HOTSPOT'      'X',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T01,      " 선택

             GS_FCAT_0200   'S'         'FIELDNAME'    'ORGCD',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIT0011',
             GS_FCAT_0200   ' '         'REF_FIELD'    'ORGCD',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T02,      " 부서코드

             GS_FCAT_0200   'S'         'FIELDNAME'    'ORGNM',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIT0020',
             GS_FCAT_0200   ' '         'REF_FIELD'    'ORGNM',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T03,      " 부서명

             GS_FCAT_0200   'S'         'FIELDNAME'    'AUTYP',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIT0011',
             GS_FCAT_0200   ' '         'REF_FIELD'    'AUTYP',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T04.      " 권한유형

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
      IT_OUTTAB          = GT_AUTH[]
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

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER_0200
*&---------------------------------------------------------------------*
*       ALV Event 등록
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0200 .

  CREATE OBJECT GO_EVENT_RECV_0200.

  SET HANDLER GO_EVENT_RECV_0200->HANDLE_HOTSPOT_CLICK FOR GO_GRID_0200.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT_CLICK_0200
*&---------------------------------------------------------------------*
*       200번 화면 HOTSPOT CLICK EVENT 처리
*----------------------------------------------------------------------*
*      -->PS_ROW_ID
*      -->PS_COLUMN_ID
*----------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK_0200  USING    PS_ROW_ID      TYPE LVC_S_ROW
                                         PS_COLUMN_ID   TYPE LVC_S_COL.

  CHECK ( PS_COLUMN_ID-FIELDNAME = 'CHECK' ).

  LOOP AT GT_AUTH INTO GS_AUTH.
    DATA(LV_INDEX) = SY-TABIX.

    IF ( PS_ROW_ID-INDEX = LV_INDEX ).
      GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON.
    ELSE.
      GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON_EMPTY.
    ENDIF.

    MODIFY GT_AUTH FROM GS_AUTH INDEX LV_INDEX
                   TRANSPORTING CHECK.
  ENDLOOP.

  PERFORM REFRESH_ALV_0200.

ENDFORM.
