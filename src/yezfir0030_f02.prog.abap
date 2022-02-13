*&---------------------------------------------------------------------*
*&  Include           YEZFIR0030_F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER_0100
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0100 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CONTAINER_0100
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
        I_PARENT = GO_CONTAINER_0100.
  ELSE.
*   ALV Container 를 생성할 수 없습니다.
    MESSAGE A005(YFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LAYOUT_0100
*&---------------------------------------------------------------------*
*       ALV Layout setting
*----------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0100 .

  GS_LAYOUT_0100-SEL_MODE   = 'A'.
  GS_LAYOUT_0100-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_TOOLBAR = ABAP_FALSE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0100
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0100 .

*  PERFORM FILL_ALV_SORT TABLES  GT_SORT_0100 USING:
*           " SPOS  FIELDNAME  UP   DOWN  SUBTOT
*             '1'   'BUKRS'    'X'  ' '   ' ',
*             '2'   'ORGCD'    'X'  ' '   ' '.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0100
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0100 .

  PERFORM FILL_FIELDCAT TABLES GT_FCAT_0100 USING:
           " STRUCTURE      START/END   FIELDNAME      VALUE
*             GS_FCAT_0100   'S'         'FIELDNAME'    'CHECK',
*             GS_FCAT_0100   ' '         'KEY'          ' ',
*             GS_FCAT_0100   ' '         'REF_TABLE'    'ICON',
*             GS_FCAT_0100   ' '         'REF_FIELD'    'ID',
*             GS_FCAT_0100   ' '         'JUST'         'C',
*             GS_FCAT_0100   ' '         'HOTSPOT'      'X',
*             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T01,      " 선택

             GS_FCAT_0100   'S'         'FIELDNAME'    'STATU',
             GS_FCAT_0100   ' '         'KEY'          'X',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'STATU',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T22,      " 상태

             GS_FCAT_0100   'S'         'FIELDNAME'    'PRTYP',
             GS_FCAT_0100   ' '         'KEY'          'X',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'PRTYP',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T21,      " 처리유형

             GS_FCAT_0100   'S'         'FIELDNAME'    'SAKNR',
             GS_FCAT_0100   ' '         'KEY'          'X',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'SAKNR',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T02,      " G/L 계정

             GS_FCAT_0100   'S'         'FIELDNAME'    'TXT20',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'TXT20',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T03,      " 내역

             GS_FCAT_0100   'S'         'FIELDNAME'    'TXT50',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'TXT50',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T04,      " G/L 계정 설명

             GS_FCAT_0100   'S'         'FIELDNAME'    'XBILK',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'XBILK',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T05,      " 대차대조표 계정

             GS_FCAT_0100   'S'         'FIELDNAME'    'GVTYP',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'GVTYP',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T06,      " 손익계산서 계정 유형

             GS_FCAT_0100   'S'         'FIELDNAME'    'KTOKS',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'KTOKS',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T07,      " 계정 그룹

             GS_FCAT_0100   'S'         'FIELDNAME'    'WAERS',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'WAERS',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T08,      " 계정 통화

             GS_FCAT_0100   'S'         'FIELDNAME'    'XSALH',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'XSALH',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T09,      " 잔액(현지 통화)만

             GS_FCAT_0100   'S'         'FIELDNAME'    'MWSKZ',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'MWSKZ',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T10,      " 세금 범주

             GS_FCAT_0100   'S'         'FIELDNAME'    'XMWNO',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'XMWNO',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T11,      " 세금 없이 전기 허용

             GS_FCAT_0100   'S'         'FIELDNAME'    'MITKZ',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'MITKZ',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T12,      " 계정 유형에 대한 조정 계정

             GS_FCAT_0100   'S'         'FIELDNAME'    'ALTKT',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ALTKT',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T13,      " 대체 계정 번호

             GS_FCAT_0100   'S'         'FIELDNAME'    'WMETH',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'WMETH',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T14,      " 외부 시스템에서 관리되는 계정

             GS_FCAT_0100   'S'         'FIELDNAME'    'XOPVW',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'XOPVW',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T15,      " 미결 항목 관리

             GS_FCAT_0100   'S'         'FIELDNAME'    'XKRES',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'XKRES',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T16,      " 개별 항목 조회

             GS_FCAT_0100   'S'         'FIELDNAME'    'ZUAWA',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ZUAWA',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T17,      " 정렬 키

             GS_FCAT_0100   'S'         'FIELDNAME'    'FSTAG',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'FSTAG',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T18,      " 필드상태그룹

             GS_FCAT_0100   'S'         'FIELDNAME'    'XINTB',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'XINTB',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T19,      " 자동 전기만

             GS_FCAT_0100   'S'         'FIELDNAME'    'XMITK',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'XMITK',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T20.      " 조정 계정 입력 가능

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

  GS_VARIANT_0100-REPORT  = SY-REPID.

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
      IS_LAYOUT          = GS_LAYOUT_0100
      I_SAVE             = 'A'
      IS_VARIANT         = GS_VARIANT_0100
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
  GS_LAYOUT_0200-NO_TOOLBAR = ABAP_FALSE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0200
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0200 .

*  PERFORM FILL_ALV_SORT TABLES  GT_SORT_0100 USING:
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
*            GS_FCAT_0200   'S'         'FIELDNAME'    'CHECK',
*            GS_FCAT_0200   ' '         'KEY'          ' ',
*            GS_FCAT_0200   ' '         'REF_TABLE'    'ICON',
*            GS_FCAT_0200   ' '         'REF_FIELD'    'ID',
*            GS_FCAT_0200   ' '         'JUST'         'C',
*            GS_FCAT_0200   ' '         'HOTSPOT'      'X',
*            GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T01,      " 선택

             GS_FCAT_0200   'S'         'FIELDNAME'    'STATU',
             GS_FCAT_0200   ' '         'KEY'          'X',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'STATU',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T22,      " 상태

             GS_FCAT_0200   'S'         'FIELDNAME'    'NATXT',
             GS_FCAT_0200   ' '         'KEY'          'X',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'NATXT',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T23,      " 결과메시지

             GS_FCAT_0100   'S'         'FIELDNAME'    'PRTYP',
             GS_FCAT_0100   ' '         'KEY'          'X',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0100   ' '         'REF_FIELD'    'PRTYP',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T21,      " 처리유형

             GS_FCAT_0200   'S'         'FIELDNAME'    'SAKNR',
             GS_FCAT_0200   ' '         'KEY'          'X',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'SAKNR',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T02,      " G/L 계정

             GS_FCAT_0200   'S'         'FIELDNAME'    'TXT20',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'TXT20',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T03,      " 내역

             GS_FCAT_0200   'S'         'FIELDNAME'    'TXT50',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'TXT50',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T04,      " G/L 계정 설명

             GS_FCAT_0200   'S'         'FIELDNAME'    'XBILK',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'XBILK',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T05,      " 대차대조표 계정

             GS_FCAT_0200   'S'         'FIELDNAME'    'GVTYP',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'GVTYP',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T06,      " 손익계산서 계정 유형

             GS_FCAT_0200   'S'         'FIELDNAME'    'KTOKS',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'KTOKS',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T07,      " 계정 그룹

             GS_FCAT_0200   'S'         'FIELDNAME'    'WAERS',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'WAERS',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T08,      " 계정 통화

             GS_FCAT_0200   'S'         'FIELDNAME'    'XSALH',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'XSALH',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T09,      " 잔액(현지 통화)만

             GS_FCAT_0200   'S'         'FIELDNAME'    'MWSKZ',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'MWSKZ',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T10,      " 세금 범주

             GS_FCAT_0200   'S'         'FIELDNAME'    'XMWNO',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'XMWNO',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T11,      " 세금 없이 전기 허용

             GS_FCAT_0200   'S'         'FIELDNAME'    'MITKZ',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'MITKZ',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T12,      " 계정 유형에 대한 조정 계정

             GS_FCAT_0200   'S'         'FIELDNAME'    'ALTKT',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'ALTKT',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T13,      " 대체 계정 번호

             GS_FCAT_0200   'S'         'FIELDNAME'    'WMETH',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'WMETH',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T14,      " 외부 시스템에서 관리되는 계정

             GS_FCAT_0200   'S'         'FIELDNAME'    'XOPVW',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'XOPVW',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T15,      " 미결 항목 관리

             GS_FCAT_0200   'S'         'FIELDNAME'    'XKRES',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'XKRES',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T16,      " 개별 항목 조회

             GS_FCAT_0200   'S'         'FIELDNAME'    'ZUAWA',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'ZUAWA',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T17,      " 정렬 키

             GS_FCAT_0200   'S'         'FIELDNAME'    'FSTAG',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'FSTAG',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T18,      " 필드상태그룹

             GS_FCAT_0200   'S'         'FIELDNAME'    'XINTB',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'XINTB',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T19,      " 자동 전기만

             GS_FCAT_0200   'S'         'FIELDNAME'    'XMITK',
             GS_FCAT_0200   ' '         'KEY'          ' ',
             GS_FCAT_0200   ' '         'REF_TABLE'    'YFIS0050',
             GS_FCAT_0200   ' '         'REF_FIELD'    'XMITK',
             GS_FCAT_0200   ' '         'JUST'         'C',
             GS_FCAT_0200   'E'         'REPTEXT'      TEXT-T20.      " 조정 계정 입력 가능

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
