*&---------------------------------------------------------------------*
*&  Include           YEZFIR0035_F02
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
             LS_SORT-SUBTOT.           " SUBTOT
  ENDLOOP.

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
*&      Form  SET_EVENT_HANDLER_0100
*&---------------------------------------------------------------------*
*       이벤트 등록
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0100 .

  CREATE OBJECT GO_EVNT_0100.
  SET HANDLER GO_EVNT_0100->HANDLE_HOTSPOT_CLICK FOR GO_GRID_0100.
  SET HANDLER GO_EVNT_0100->HANDLE_ONF4          FOR GO_GRID_0100.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_F4_0100
*&---------------------------------------------------------------------*
*       ALV F4 HELP
*----------------------------------------------------------------------*
FORM SET_ALV_F4_0100 .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LT_F4   TYPE LVC_T_F4.
  DATA: LS_F4   TYPE LVC_S_F4.

  CLEAR: LT_F4[].
  CLEAR: LS_F4.

*----------------------------------------------------------------------*
* 계정그룹 필드 추가
*----------------------------------------------------------------------*
  LS_F4-FIELDNAME  = 'GVTYP'.
  LS_F4-REGISTER   = ABAP_TRUE.
  LS_F4-GETBEFORE  = ABAP_TRUE.
  LS_F4-CHNGEAFTER = ABAP_FALSE.

  INSERT LS_F4 INTO TABLE LT_F4.
  CLEAR: LS_F4.

  LS_F4-FIELDNAME  = 'KTOKS'.
  LS_F4-REGISTER   = ABAP_TRUE.
  LS_F4-GETBEFORE  = ABAP_TRUE.
  LS_F4-CHNGEAFTER = ABAP_FALSE.

  INSERT LS_F4 INTO TABLE LT_F4.
  CLEAR: LS_F4.

  LS_F4-FIELDNAME  = 'MWSKZ'.
  LS_F4-REGISTER   = ABAP_TRUE.
  LS_F4-GETBEFORE  = ABAP_TRUE.
  LS_F4-CHNGEAFTER = ABAP_FALSE.

  INSERT LS_F4 INTO TABLE LT_F4.
  CLEAR: LS_F4.

  LS_F4-FIELDNAME  = 'FSTAG'.
  LS_F4-REGISTER   = ABAP_TRUE.
  LS_F4-GETBEFORE  = ABAP_TRUE.
  LS_F4-CHNGEAFTER = ABAP_FALSE.

  INSERT LS_F4 INTO TABLE LT_F4.
  CLEAR: LS_F4.

*----------------------------------------------------------------------*
* F4 HELP 필드 등록
*----------------------------------------------------------------------*
  CALL METHOD GO_GRID_0100->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EVENT_HELP_ON_F4
*&---------------------------------------------------------------------*
*       ALV HELP EVENT 처리
*----------------------------------------------------------------------*
FORM EVENT_HELP_ON_F4  USING    PV_FIELDNAME      TYPE LVC_FNAME
                                PV_FIELDVALUE     TYPE LVC_VALUE
                                PS_ROW_NO         TYPE LVC_S_ROID
                                PO_EVENT_DATA     TYPE REF TO	CL_ALV_EVENT_DATA
                                PT_BAD_CELLS      TYPE LVC_T_MODI
                                PV_DISPLAY        TYPE CHAR01.

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_GVTYP   TYPE YEZFIS0055-GVTYP.
  DATA: LV_KTOKS   TYPE YEZFIS0055-KTOKS.
  DATA: LV_MWSKZ   TYPE YEZFIS0055-MWSKZ.
  DATA: LV_FSTAG   TYPE YEZFIS0055-FSTAG.

  CLEAR: LV_GVTYP.
  CLEAR: LV_KTOKS.
  CLEAR: LV_MWSKZ.
  CLEAR: LV_FSTAG.

*----------------------------------------------------------------------*
* 필드 별 F4 HELP 처리
*----------------------------------------------------------------------*
  PO_EVENT_DATA->M_EVENT_HANDLED = ABAP_TRUE.   " Standard F4 사용하지 않음

  CASE PV_FIELDNAME.
*   손익계산서 계정유형
    WHEN 'GVTYP'.
      PERFORM F4_HELP_GVTYP USING PV_FIELDNAME
                                  LV_GVTYP.
*   계정그룹
    WHEN 'KTOKS'.
      PERFORM F4_HELP_KTOKS USING PV_FIELDNAME
                                  LV_KTOKS.
*   세금범주
    WHEN 'MWSKZ'.
      PERFORM F4_HELP_MWSKZ USING PV_FIELDNAME
                                  LV_MWSKZ.
*   필드상태그룹
    WHEN 'FSTAG'.
      PERFORM F4_HELP_FSTAG USING PV_FIELDNAME
                                  LV_FSTAG.
  ENDCASE.

ENDFORM.
