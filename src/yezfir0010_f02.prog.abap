*----------------------------------------------------------------------*
***INCLUDE YEZFIR0010_F02.
*----------------------------------------------------------------------*
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

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0100
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0100 .

  PERFORM FILL_ALV_SORT TABLES  GT_SORT_0100 USING:
           " SPOS  FIELDNAME  UP   DOWN  SUBTOT
             '1'   'EMPNO'    'X'  ' '   ' '.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0100
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0100 .

  PERFORM FILL_FIELDCAT TABLES GT_FCAT_0100 USING:
           " STRUCTURE      START/END   FIELDNAME      VALUE
             GS_FCAT_0100   'S'         'FIELDNAME'    'EMPNO',
             GS_FCAT_0100   ' '         'KEY'          'X',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'EMPNO',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T02,      " 사원번호

             GS_FCAT_0100   'S'         'FIELDNAME'    'BNAME',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'BNAME',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T03,      " User ID

             GS_FCAT_0100   'S'         'FIELDNAME'    'EMPNM',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'EMPNM',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T04,      " 사원명



             GS_FCAT_0100   'S'         'FIELDNAME'    'ORGCD',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ORGCD',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T15,      " 부서코드

             GS_FCAT_0100   'S'         'FIELDNAME'    'ORGNM',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0020',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ORGNM',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T16,      " 부서명

             GS_FCAT_0100   'S'         'FIELDNAME'    'KOSTL',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0020',
             GS_FCAT_0100   ' '         'REF_FIELD'    'KOSTL',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T05,      " 코스트 센터

             GS_FCAT_0100   'S'         'FIELDNAME'    'EMAIL',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'EMAIL',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T06,      " 이메일 주소

             GS_FCAT_0100   'S'         'FIELDNAME'    'TITLE',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'TITLE',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T07,      " 호칭

             GS_FCAT_0100   'S'         'FIELDNAME'    'ACTIV',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ACTIV',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   ' '         'CHECKBOX'     'X',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T08,      " 발의가능 여부

             GS_FCAT_0100   'S'         'FIELDNAME'    'ERDAT',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ERDAT',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   ' '         'NO_OUT'       'X',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T09,      " 생성일

             GS_FCAT_0100   'S'         'FIELDNAME'    'ERZET',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ERZET',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   ' '         'NO_OUT'       'X',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T10,      " 생성시간

             GS_FCAT_0100   'S'         'FIELDNAME'    'ERNAM',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'ERNAM',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   ' '         'NO_OUT'       'X',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T11,      " 생성자

             GS_FCAT_0100   'S'         'FIELDNAME'    'AEDAT',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'AEDAT',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   ' '         'NO_OUT'       'X',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T12,      " 변경일

             GS_FCAT_0100   'S'         'FIELDNAME'    'AEZET',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'AEZET',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   ' '         'NO_OUT'       'X',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T13,      " 변경시간

             GS_FCAT_0100   'S'         'FIELDNAME'    'AENAM',
             GS_FCAT_0100   ' '         'KEY'          ' ',
             GS_FCAT_0100   ' '         'REF_TABLE'    'YFIT0010',
             GS_FCAT_0100   ' '         'REF_FIELD'    'AENAM',
             GS_FCAT_0100   ' '         'JUST'         'C',
             GS_FCAT_0100   ' '         'NO_OUT'       'X',
             GS_FCAT_0100   'E'         'REPTEXT'      TEXT-T14.      " 변경자

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
