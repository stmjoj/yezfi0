*&---------------------------------------------------------------------*
*&  Include           YEZFIR0035_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       레포트 Initialization 이벤트 처리
*----------------------------------------------------------------------*
FORM INITIALIZATION .

* Sublogin 에 대한 사용자 정보를 가져 온다.
  PERFORM CHECK_SUBLOGIN_PROC.

  P_BUKRS  = GS_SUBLOGIN-BUKRS.
  P_BUTXT  = GS_SUBLOGIN-BUTXT.

  PERFORM GET_COMPANY_INFO.           " 회사코드 정보 설정

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SUBLOGIN_PROC
*&---------------------------------------------------------------------*
*       Sublogin 에 대한 사용자 정보를 가져 온다.
*----------------------------------------------------------------------*
FORM CHECK_SUBLOGIN_PROC .

  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CALL FUNCTION 'Y_EZFI_SUBLOGIN'
*   EXPORTING
*     IV_UNAME    = SY-UNAME
*     IV_SKIP     = ABAP_TRUE
    IMPORTING
      ES_SUBLOGIN = GS_SUBLOGIN
      EV_RETURN   = LV_RETURN
      EV_MESSAGE  = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE E012(YEZFIM).    " 발의부서를 결정할 수 없습니다.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SELSCR
*&---------------------------------------------------------------------*
*       SLECTION-SCREEN 수정
*----------------------------------------------------------------------*
FORM MODIFY_SELSCR .

  LOOP AT SCREEN.
    IF ( SCREEN-NAME = 'P_BUKRS' ).
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_PROC .

*----------------------------------------------------------------------*
* 광역변수 초기화
*----------------------------------------------------------------------*
  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_BUKRS.
  CLEAR: GV_TITLE.

  CLEAR: GV_TOT_CNT.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  GV_TITLE = SY-TITLE.

*----------------------------------------------------------------------*
* ALV 변수 초기화
*----------------------------------------------------------------------*
* 100번 화면
  CLEAR: GO_CONT_0100.
  CLEAR: GO_GRID_0100.

  CLEAR: GT_FCAT_0100.
  CLEAR: GS_FCAT_0100.
  CLEAR: GT_SORT_0100.

  CLEAR: GS_LAYO_0100.
  CLEAR: GS_VARI_0100.

*----------------------------------------------------------------------*
* 초기값 설정
*----------------------------------------------------------------------*
  PERFORM GET_COMPANY_INFO.           " 회사코드 정보 설정

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_COMPANY_INFO
*&---------------------------------------------------------------------*
*       회사코드 정보 설정
*----------------------------------------------------------------------*
FORM GET_COMPANY_INFO .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CLEAR: LV_RETURN.
  CLEAR: LV_MESSAGE.

*----------------------------------------------------------------------*
* 회사코드 정보 가져오기
*----------------------------------------------------------------------*
  CALL FUNCTION 'Y_EZFI_GET_BUKRS_INFO'
    EXPORTING
      IV_BUKRS   = P_BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE
      ES_BUKRS   = GS_BUKRS.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YEZFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_OUTTAB_PROC
*&---------------------------------------------------------------------*
*       조회를 위한 자료 구성
*----------------------------------------------------------------------*
FORM MAKE_OUTTAB_PROC .

  SELECT A~SAKNR   AS SAKNR
       , C~TXT20   AS TXT20
       , C~TXT50   AS TXT50
       , A~XBILK   AS XBILK
       , A~GVTYP   AS GVTYP
       , A~KTOKS   AS KTOKS
       , B~WAERS   AS WAERS
       , B~XSALH   AS XSALH
       , B~MWSKZ   AS MWSKZ
       , B~XMWNO   AS XMWNO
       , B~MITKZ   AS MITKZ
       , B~ALTKT   AS ALTKT
       , B~WMETH   AS WMETH
       , B~XOPVW   AS XOPVW
       , B~XKRES   AS XKRES
       , B~ZUAWA   AS ZUAWA
       , B~FSTAG   AS FSTAG
       , B~XINTB   AS XINTB
       , B~XMITK   AS XMITK
    INTO CORRESPONDING FIELDS OF TABLE @GT_OUTTAB
    FROM SKA1 AS A INNER JOIN      SKB1 AS B ON B~BUKRS = @P_BUKRS
                                            AND B~SAKNR = A~SAKNR
                   LEFT OUTER JOIN SKAT AS C ON C~SPRAS = @SY-LANGU
                                            AND C~KTOPL = A~KTOPL
                                            AND C~SAKNR = A~SAKNR
   WHERE A~KTOPL =  @GS_BUKRS-KTOPL
     AND A~SAKNR IN @S_SAKNR
     AND A~KTOKS IN @S_KTOKS
     AND B~MITKZ IN @S_MITKZ
     AND C~TXT50 IN @S_TXT50.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       화면 출력
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF ( GT_OUTTAB[] IS NOT INITIAL ).
    GV_TOT_CNT = LINES( GT_OUTTAB[] ).

    CALL SCREEN 0100.
  ELSE.
*   MESSAGE : 데이터가 존재하지 않습니다.
    MESSAGE I013(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_HELP_KTOKS
*&---------------------------------------------------------------------*
*       계정그룹에 대한 F4 HELP
*----------------------------------------------------------------------*
FORM F4_HELP_KTOKS  USING    PV_FIELDNAME      TYPE LVC_FNAME
                             PV_KTOKS.

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETFIELD   TYPE DFIES-FIELDNAME.
  DATA: LV_DYNPROFLD  TYPE HELP_INFO-DYNPROFLD.

  DATA: LT_RETURN     TYPE STANDARD TABLE OF DDSHRETVAL.
  DATA: LS_RETURN     TYPE DDSHRETVAL.

  CLEAR: LV_RETFIELD.
  CLEAR: LV_DYNPROFLD.

  CLEAR: LT_RETURN[].
  CLEAR: LS_RETURN.

  CLEAR: PV_KTOKS.

  LV_DYNPROFLD = PV_FIELDNAME.

*----------------------------------------------------------------------*
* 계정그룹 값 구성
*----------------------------------------------------------------------*
  SELECT KTOKS
       , TXT30
    INTO TABLE @DATA(LT_KTOKS)
    FROM T077Z
   WHERE SPRAS = @SY-LANGU
     AND KTOPL = @GS_BUKRS-KTOPL.

*----------------------------------------------------------------------*
* F4 HELP 호출
*----------------------------------------------------------------------*
  LV_RETFIELD = 'KTOKS'.    " Name of return field in FIELD_TAB

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      RETFIELD        = LV_RETFIELD
*     PVALKEY         = ' '
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = LV_DYNPROFLD
*     STEPL           = 0
      WINDOW_TITLE    = TEXT-T01
*     VALUE           = ' '
      VALUE_ORG       = 'S'
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*   IMPORTING
*     USER_RESET      =
    TABLES
      VALUE_TAB       = LT_KTOKS[]
*     FIELD_TAB       =
      RETURN_TAB      = LT_RETURN[]
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


*----------------------------------------------------------------------*
* 선택값 RETURN
*----------------------------------------------------------------------*
  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF ( LS_RETURN IS NOT INITIAL ).
    PV_KTOKS = LS_RETURN-FIELDVAL.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_HELP_FSTAG
*&---------------------------------------------------------------------*
*       필드상태그룹에 대한 F4 HELP
*----------------------------------------------------------------------*
FORM F4_HELP_FSTAG  USING    PV_FIELDNAME      TYPE LVC_FNAME
                             PV_FSTAG.

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETFIELD   TYPE DFIES-FIELDNAME.
  DATA: LV_DYNPROFLD  TYPE HELP_INFO-DYNPROFLD.

  DATA: LT_RETURN     TYPE STANDARD TABLE OF DDSHRETVAL.
  DATA: LS_RETURN     TYPE DDSHRETVAL.

  CLEAR: LV_RETFIELD.
  CLEAR: LV_DYNPROFLD.

  CLEAR: LT_RETURN[].
  CLEAR: LS_RETURN.

  CLEAR: PV_FSTAG.

*----------------------------------------------------------------------*
* 계정그룹 값 구성
*----------------------------------------------------------------------*
  SELECT FSTAG
       , FSTTX
    INTO TABLE @DATA(LT_FSTAG)
    FROM T004G
   WHERE SPRAS = @SY-LANGU
     AND BUKRS = @GS_BUKRS-BUKRS.

*----------------------------------------------------------------------*
* F4 HELP 호출
*----------------------------------------------------------------------*
  LV_RETFIELD = 'FSTAG'.    " Name of return field in FIELD_TAB

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      RETFIELD        = LV_RETFIELD
*     PVALKEY         = ' '
*     DYNPPROG        = SY-REPID
*     DYNPNR          = SY-DYNNR
*     DYNPROFIELD     = LV_DYNPROFLD
*     STEPL           = 0
      WINDOW_TITLE    = TEXT-T02
*     VALUE           = ' '
      VALUE_ORG       = 'S'
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*   IMPORTING
*     USER_RESET      =
    TABLES
      VALUE_TAB       = LT_FSTAG[]
*     FIELD_TAB       =
      RETURN_TAB      = LT_RETURN[]
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


*----------------------------------------------------------------------*
* 선택값 RETURN
*----------------------------------------------------------------------*
  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF ( LS_RETURN IS NOT INITIAL ).
    PV_FSTAG = LS_RETURN-FIELDVAL.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_HELP_GVTYP
*&---------------------------------------------------------------------*
*       손익계산서 계정유형에 대한 F4 HELP
*----------------------------------------------------------------------*
FORM F4_HELP_GVTYP  USING    PV_FIELDNAME      TYPE LVC_FNAME
                             PV_GVTYP.

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETFIELD   TYPE DFIES-FIELDNAME.
  DATA: LV_DYNPROFLD  TYPE HELP_INFO-DYNPROFLD.

  DATA: LT_RETURN     TYPE STANDARD TABLE OF DDSHRETVAL.
  DATA: LS_RETURN     TYPE DDSHRETVAL.

  CLEAR: LV_RETFIELD.
  CLEAR: LV_DYNPROFLD.

  CLEAR: LT_RETURN[].
  CLEAR: LS_RETURN.

  CLEAR: PV_GVTYP.

*----------------------------------------------------------------------*
* 계정그룹 값 구성
*----------------------------------------------------------------------*
  SELECT A~KOMOK   AS KOMOK
       , A~KONTS   AS KONTS
       , B~TXT50   AS TXT50
    FROM T030 AS A LEFT OUTER JOIN
         SKAT AS B
      ON B~SPRAS = @SY-LANGU
     AND B~KTOPL = A~KTOPL
     AND B~SAKNR = A~KONTS
   WHERE A~KTOPL = @GS_BUKRS-KTOPL
     AND A~KTOSL = 'BIL'
    INTO TABLE @DATA(LT_GVTYP).

*----------------------------------------------------------------------*
* F4 HELP 호출
*----------------------------------------------------------------------*
  LV_RETFIELD = 'GVTYP'.    " Name of return field in FIELD_TAB

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      RETFIELD        = LV_RETFIELD
*     PVALKEY         = ' '
*     DYNPPROG        = SY-REPID
*     DYNPNR          = SY-DYNNR
*     DYNPROFIELD     = LV_DYNPROFLD
*     STEPL           = 0
      WINDOW_TITLE    = TEXT-T03
*     VALUE           = ' '
      VALUE_ORG       = 'S'
*     MULTIPLE_CHOICE = ' '
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*   IMPORTING
*     USER_RESET      =
    TABLES
      VALUE_TAB       = LT_GVTYP[]
*     FIELD_TAB       =
      RETURN_TAB      = LT_RETURN[]
*     DYNPFLD_MAPPING =
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


*----------------------------------------------------------------------*
* 선택값 RETURN
*----------------------------------------------------------------------*
  READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.

  IF ( LS_RETURN IS NOT INITIAL ).
    PV_GVTYP = LS_RETURN-FIELDVAL.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_HELP_MWSKZ
*&---------------------------------------------------------------------*
*       세금범주에 대한 F4 HELP
*----------------------------------------------------------------------*
FORM F4_HELP_MWSKZ  USING    PV_FIELDNAME      TYPE LVC_FNAME
                             PV_MWSKZ.

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETFIELD   TYPE DFIES-FIELDNAME.
  DATA: LV_DYNPROFLD  TYPE HELP_INFO-DYNPROFLD.

  DATA: LT_RETURN     TYPE STANDARD TABLE OF DDSHRETVAL.
  DATA: LS_RETURN     TYPE DDSHRETVAL.

  CLEAR: LV_RETFIELD.
  CLEAR: LV_DYNPROFLD.

  CLEAR: LT_RETURN[].
  CLEAR: LS_RETURN.

*----------------------------------------------------------------------*
* F4 HELP 호출
*----------------------------------------------------------------------*
  CALL FUNCTION 'F_VALUES_T007A'
    EXPORTING
      I_KALSM   = GS_BUKRS-KALSM
      I_MWSKZ   = PV_MWSKZ
    IMPORTING
      E_MWSKZ   = PV_MWSKZ
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

ENDFORM.
