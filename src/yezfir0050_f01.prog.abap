*&---------------------------------------------------------------------*
*&  Include           YEZFIR0050_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       초기화
*----------------------------------------------------------------------*
FORM INITIALIZATION .

* Sublogin 에 대한 사용자 정보를 가져 온다.
  PERFORM CHECK_SUBLOGIN_PROC.

  P_BUKRS  = GS_SUBLOGIN-BUKRS.
  P_BUTXT  = GS_SUBLOGIN-BUTXT.

* 원장기본값 = 주요원장 설정
  PERFORM GET_LEADING_LEADER USING P_RLDNR.

* 원장명 가져 온다
  PERFORM GET_LEDGER_NAME USING P_RLDNR
                                P_LDTXT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SUBLOGIN_PROC
*&---------------------------------------------------------------------*
*       Sublogin 에 대한 사용자 정보를 가져 온다.
*----------------------------------------------------------------------*
FORM CHECK_SUBLOGIN_PROC .

  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CLEAR: LV_RETURN.
  CLEAR: LV_MESSAGE.

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
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_PROC .

*----------------------------------------------------------------------*
* 광역변수 초기화
*----------------------------------------------------------------------*
  CLEAR: YEZFIS0110.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_BUKRS.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GO_CUST_0100.
  CLEAR: GO_GRID_0100.
  .
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
* 지역변수 선언 및 초기화
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
*&      Form  CALL_SCREEN_0100
*&---------------------------------------------------------------------*
*       개별항목 조회화면 호출
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0100 .

  YEZFIS0110-BUKRS     = P_BUKRS.
  YEZFIS0110-BUTXT     = P_BUTXT.
  YEZFIS0110-RLDNR     = P_RLDNR.
  YEZFIS0110-RLDNR_TXT = P_LDTXT.

  CALL SCREEN 0100.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_OUTTAB_PROC
*&---------------------------------------------------------------------*
*       개별항목 자료 선택 및 구성
*----------------------------------------------------------------------*
FORM MAKE_OUTTAB_PROC .

* 총계정원장 SELECT
  PERFORM GET_GENERAL_LEDGER.

* 전표 개별항목 정보 구성
  PERFORM MAKE_ITEM_INFO.

* 개별항목 거래처 정보 설정
  PERFORM SET_PARTNER_INFO .

* 텍스트 정보 구성
  PERFORM GET_TEXT.

* 계정금액 구성
  PERFORM MAKE_AMOUNT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SELSCR_PROC
*&---------------------------------------------------------------------*
*       Select Screen 의 화면상태를 변경한다.
*----------------------------------------------------------------------*
FORM MODIFY_SELSCR_PROC .

*  CHECK ( P_BUKRS IS NOT INITIAL ).

  LOOP AT SCREEN.
    CHECK ( SCREEN-NAME = 'P_BUKRS' ).

    SCREEN-INPUT = 0.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LEADING_LEADER
*&---------------------------------------------------------------------*
*       주요원장 결정
*----------------------------------------------------------------------*
FORM GET_LEADING_LEADER  USING    PV_RLDNR.

  SELECT SINGLE RLDNR
    INTO PV_RLDNR
    FROM T881
   WHERE TAB      = 'FAGLFLEXT'
     AND XLEADING = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LEDGER_NAME
*&---------------------------------------------------------------------*
*       원장 텍스트 가져오기
*----------------------------------------------------------------------*
FORM GET_LEDGER_NAME  USING    PV_RLDNR
                               PV_LDTXT.

  SELECT SINGLE NAME
    INTO PV_LDTXT
    FROM T881T
   WHERE LANGU = SY-LANGU
     AND RLDNR = PV_RLDNR.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_GENERAL_LEDGER
*&---------------------------------------------------------------------*
*       총계정원장 SELECT
*----------------------------------------------------------------------*
FORM GET_GENERAL_LEDGER .

  SELECT A~RBUKRS    AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , B~MONAT     AS MONAT
       , B~BLART     AS BLART
       , B~BLDAT     AS BLDAT
       , B~BUDAT     AS BUDAT
       , B~XBLNR     AS XBLNR
       , A~RLDNR     AS RLDNR
       , B~BKTXT     AS BKTXT
       , B~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~RACCT     AS HKONT
       , A~DRCRK     AS SHKZG
       , A~TSL       AS WRBTR
       , A~HSL       AS DMBTR
       , B~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO CORRESPONDING FIELDS OF TABLE @GT_OUTTAB
    FROM FAGLFLEXA AS A INNER JOIN BKPF AS B ON B~BUKRS = A~RBUKRS
                                            AND B~BELNR = A~BELNR
                                            AND B~GJAHR = A~GJAHR
   WHERE A~RLDNR   =  @P_RLDNR
     AND A~RBUKRS  =  @P_BUKRS
     AND A~RACCT   IN @S_HKONT
     AND A~GJAHR   IN @S_GJAHR
     AND A~BUDAT   IN @S_BUDAT
     AND A~BELNR   IN @S_BELNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND A~RBUSA    IN @S_GSBER
     AND B~BLDAT    IN @S_BLDAT
     AND B~BUDAT    IN @S_BUDAT
     AND B~BLART    IN @S_BLART.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_ITEM_INFO
*&---------------------------------------------------------------------*
*       전표 개별항목 정보 구성
*----------------------------------------------------------------------*
FORM MAKE_ITEM_INFO .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: BEGIN OF LS_KEY,
          BUKRS TYPE BSEG-BUKRS,
          BELNR TYPE BSEG-BELNR,
          GJAHR TYPE BSEG-GJAHR,
          BUZEI TYPE BSEG-BUZEI,
        END OF LS_KEY.

  DATA: LT_KEY   LIKE STANDARD TABLE OF LS_KEY.

  CLEAR: LT_KEY[].
  CLEAR: LS_KEY.

*----------------------------------------------------------------------*
* For All Entries 를 위한 Itab 구성
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LS_KEY-BUKRS = GS_OUTTAB-BUKRS.
    LS_KEY-BELNR = GS_OUTTAB-BELNR.
    LS_KEY-GJAHR = GS_OUTTAB-GJAHR.
    LS_KEY-BUZEI = GS_OUTTAB-BUZEI.

    APPEND LS_KEY TO LT_KEY.
    CLEAR LS_KEY.
  ENDLOOP.

  SORT LT_KEY[] BY BUKRS BELNR GJAHR BUZEI.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING ALL FIELDS.

*----------------------------------------------------------------------*
* 전표 개별항목 SELECT
*----------------------------------------------------------------------*
  SELECT *
    INTO TABLE @DATA(LT_BSEG)
    FROM BSEG
     FOR ALL ENTRIES IN @LT_KEY
   WHERE BUKRS = @LT_KEY-BUKRS
     AND BELNR = @LT_KEY-BELNR
     AND GJAHR = @LT_KEY-GJAHR
     AND BUZEI = @LT_KEY-BUZEI.

*----------------------------------------------------------------------*
* 전표 개별항목 정보 반영
*----------------------------------------------------------------------*
  SORT LT_BSEG BY BUKRS BELNR GJAHR BUZEI.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    READ TABLE LT_BSEG INTO DATA(LS_BSEG)
                       WITH KEY BUKRS = GS_OUTTAB-BUKRS
                                BELNR = GS_OUTTAB-BELNR
                                GJAHR = GS_OUTTAB-GJAHR
                                BUZEI = GS_OUTTAB-BUZEI.

    IF ( SY-SUBRC = 0 ).
      GS_OUTTAB-SGTXT = LS_BSEG-SGTXT.
      GS_OUTTAB-ZUONR = LS_BSEG-ZUONR.
      GS_OUTTAB-XNEGP = LS_BSEG-XNEGP.
      GS_OUTTAB-KOART = LS_BSEG-KOART.
      GS_OUTTAB-LIFNR = LS_BSEG-LIFNR.
      GS_OUTTAB-KUNNR = LS_BSEG-KUNNR.
      GS_OUTTAB-MWSKZ = LS_BSEG-MWSKZ.
      GS_OUTTAB-BUPLA = LS_BSEG-BUPLA.
      GS_OUTTAB-GSBER = LS_BSEG-GSBER.
      GS_OUTTAB-ZTERM = LS_BSEG-ZTERM.
      GS_OUTTAB-ZFBDT = LS_BSEG-ZFBDT.
      GS_OUTTAB-ZBD1T = LS_BSEG-ZBD1T.
      GS_OUTTAB-ZBD2T = LS_BSEG-ZBD2T.
      GS_OUTTAB-ZBD3T = LS_BSEG-ZBD3T.
      GS_OUTTAB-REBZG = LS_BSEG-REBZG.
      GS_OUTTAB-REBZJ = LS_BSEG-REBZJ.
      GS_OUTTAB-REBZZ = LS_BSEG-REBZZ.
      GS_OUTTAB-ZLSCH = LS_BSEG-ZLSCH.
      GS_OUTTAB-ZLSPR = LS_BSEG-ZLSPR.
*     GS_OUTTAB-FAEDT = LS_BSEG-FAEDT.
      GS_OUTTAB-HBKID = LS_BSEG-HBKID.
      GS_OUTTAB-BVTYP = LS_BSEG-BVTYP.
      GS_OUTTAB-XREF1 = LS_BSEG-XREF1.
      GS_OUTTAB-XREF2 = LS_BSEG-XREF2.
      GS_OUTTAB-XREF3 = LS_BSEG-XREF3.
      GS_OUTTAB-KOSTL = LS_BSEG-KOSTL.
      GS_OUTTAB-FKBER = LS_BSEG-FKBER.
      GS_OUTTAB-PRCTR = LS_BSEG-PRCTR.
      GS_OUTTAB-ANLN1 = LS_BSEG-ANLN1.
      GS_OUTTAB-ANLN2 = LS_BSEG-ANLN2.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_PARTNER_INFO
*&---------------------------------------------------------------------*
*       개별항목 거래처 정보 설정
*----------------------------------------------------------------------*
FORM SET_PARTNER_INFO .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
* 고객 관련 지역변수 선언
  DATA: BEGIN OF LS_CUST,
          KUNNR TYPE KNA1-KUNNR,
        END OF LS_CUST.

  DATA: LT_CUST   LIKE STANDARD TABLE OF LS_CUST.

* 구매처 관련 지역변수 선언
  DATA: BEGIN OF LS_VEND,
          LIFNR TYPE LFA1-LIFNR,
        END OF LS_VEND.

  DATA: LT_VEND   LIKE STANDARD TABLE OF LS_VEND.

* 지역변수 초기화
  CLEAR: LT_CUST[].
  CLEAR: LS_CUST.

  CLEAR: LT_VEND[].
  CLEAR: LS_VEND.

*----------------------------------------------------------------------*
* For all entries 를 위한 거래처 정보 구성
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    CASE GS_OUTTAB-KOART.
*     고객
      WHEN 'D'.
        LS_CUST-KUNNR = GS_OUTTAB-KUNNR.
        APPEND LS_CUST TO LT_CUST.
        CLEAR LS_CUST.
*     구매처
      WHEN 'K'.
        LS_VEND-LIFNR = GS_OUTTAB-LIFNR.
        APPEND LS_VEND TO LT_VEND.
        CLEAR LS_VEND.
    ENDCASE.
  ENDLOOP.

*----------------------------------------------------------------------*
* 구매처 정보 SELECT
*----------------------------------------------------------------------*
  SORT LT_VEND BY LIFNR.
  DELETE ADJACENT DUPLICATES FROM LT_VEND COMPARING ALL FIELDS.

  IF ( LT_VEND[] IS NOT INITIAL ).
    SELECT LIFNR
         , NAME1
      INTO TABLE @DATA(LT_LFA1)
      FROM LFA1
       FOR ALL ENTRIES IN @LT_VEND
     WHERE LIFNR = @LT_VEND-LIFNR.
  ENDIF.

*----------------------------------------------------------------------*
* 고객 정보 SELECT
*----------------------------------------------------------------------*
  SORT LT_CUST BY KUNNR.
  DELETE ADJACENT DUPLICATES FROM LT_CUST COMPARING ALL FIELDS.

  IF ( LT_CUST[] IS NOT INITIAL ).
    SELECT KUNNR
         , NAME1
      INTO TABLE @DATA(LT_KNA1)
      FROM KNA1
       FOR ALL ENTRIES IN @LT_CUST
     WHERE KUNNR = @LT_CUST-KUNNR.
  ENDIF.

*----------------------------------------------------------------------*
* 거래처명 설정
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    CASE GS_OUTTAB-KOART.
*     고객
      WHEN 'D'.
        GS_OUTTAB-PARTNER = GS_OUTTAB-KUNNR.

        READ TABLE LT_KNA1 INTO DATA(LS_KNA1)
                           WITH KEY KUNNR = GS_OUTTAB-KUNNR
                           BINARY SEARCH
                           TRANSPORTING NAME1.

        IF ( SY-SUBRC = 0 ).
          GS_OUTTAB-NAME_ORG1 = LS_KNA1-NAME1.
        ENDIF.
*     구매처
      WHEN 'K'.
        GS_OUTTAB-PARTNER = GS_OUTTAB-LIFNR.

        READ TABLE LT_LFA1 INTO DATA(LS_LFA1)
                           WITH KEY LIFNR = GS_OUTTAB-LIFNR
                           BINARY SEARCH
                           TRANSPORTING NAME1.

        IF ( SY-SUBRC = 0 ).
          GS_OUTTAB-NAME_ORG1 = LS_LFA1-NAME1.
        ENDIF.
    ENDCASE.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                   TRANSPORTING PARTNER
                                NAME_ORG1.
  ENDLOOP.

*----------------------------------------------------------------------*
* 순만기일 결정
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_INDEX = SY-TABIX.

    CHECK ( GS_OUTTAB-KOART = 'D' ) OR
          ( GS_OUTTAB-KOART = 'K' ).

    CALL FUNCTION 'NET_DUE_DATE_GET'
      EXPORTING
        I_ZFBDT = GS_OUTTAB-ZFBDT
        I_ZBD1T = GS_OUTTAB-ZBD1T
        I_ZBD2T = GS_OUTTAB-ZBD2T
        I_ZBD3T = GS_OUTTAB-ZBD3T
        I_SHKZG = GS_OUTTAB-SHKZG
        I_REBZG = GS_OUTTAB-REBZG
        I_KOART = GS_OUTTAB-KOART
      IMPORTING
        E_FAEDT = GS_OUTTAB-FAEDT.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                   TRANSPORTING FAEDT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_TEXT
*&---------------------------------------------------------------------*
*       텍스트 정보 구성
*----------------------------------------------------------------------*
FORM GET_TEXT .

  PERFORM GET_TEXT_SKAT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_TEXT_SKAT
*&---------------------------------------------------------------------*
*       텍스트 정보 구성 - G/L 계정
*----------------------------------------------------------------------*
FORM GET_TEXT_SKAT .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: BEGIN OF LS_KEY,
          SAKNR TYPE SKA1-SAKNR,
        END OF LS_KEY.

  DATA: LT_KEY   LIKE STANDARD TABLE OF LS_KEY.

  DATA: LV_HKONT   TYPE HKONT.

  CLEAR: LT_KEY[].
  CLEAR: LS_KEY.

  CLEAR: LV_HKONT.

*----------------------------------------------------------------------*
* For All Entries 를 위한 Itab 구성
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LS_KEY-SAKNR = GS_OUTTAB-HKONT.
    APPEND LS_KEY TO LT_KEY.
    CLEAR LS_KEY.
  ENDLOOP.

  SORT LT_KEY[] BY SAKNR.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING ALL FIELDS.

*----------------------------------------------------------------------*
* G/L계정 명칭 Select
*----------------------------------------------------------------------*
  IF ( LT_KEY[] IS NOT INITIAL ).
    SELECT SAKNR
         , TXT50
      INTO TABLE @DATA(LT_SKAT)
      FROM SKAT
       FOR ALL ENTRIES IN @LT_KEY[]
     WHERE SPRAS = @SY-LANGU
       AND KTOPL = @GS_BUKRS-KTOPL
       AND SAKNR = @LT_KEY-SAKNR.
  ENDIF.

*----------------------------------------------------------------------*
* G/L계정명 반영
*----------------------------------------------------------------------*
  SORT LT_SKAT BY SAKNR.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    READ TABLE LT_SKAT INTO DATA(LS_SKAT)
                       WITH KEY SAKNR = GS_OUTTAB-HKONT
                       TRANSPORTING TXT50.

    IF ( SY-SUBRC = 0 ).
      GS_OUTTAB-HKONT_TXT = LS_SKAT-TXT50.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GS_OUTTAB-HKONT
        IMPORTING
          OUTPUT = LV_HKONT.

      CONCATENATE LV_HKONT
                  '/'
                  GS_OUTTAB-HKONT_TXT
             INTO GS_OUTTAB-HKONT_KEY
        SEPARATED BY SPACE.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                       TRANSPORTING HKONT_TXT
                                    HKONT_KEY.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_AMOUNT
*&---------------------------------------------------------------------*
*       계정금액 구성
*----------------------------------------------------------------------*
FORM MAKE_AMOUNT .

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

*   차변
    IF ( GS_OUTTAB-SHKZG = 'S' ).
      GS_OUTTAB-WRBTR_S = GS_OUTTAB-WRBTR.
      GS_OUTTAB-WRBTR_H = 0.
      GS_OUTTAB-DMBTR_S = GS_OUTTAB-DMBTR.
      GS_OUTTAB-DMBTR_H = 0.
*   대변
    ELSE.
      GS_OUTTAB-WRBTR   = GS_OUTTAB-WRBTR * ( -1 ).
      GS_OUTTAB-DMBTR   = GS_OUTTAB-DMBTR * ( -1 ).

      GS_OUTTAB-WRBTR_S = 0.
      GS_OUTTAB-WRBTR_H = GS_OUTTAB-WRBTR.
      GS_OUTTAB-DMBTR_S = 0.
      GS_OUTTAB-DMBTR_H = GS_OUTTAB-DMBTR.
    ENDIF.

*   대변금액인 경우 잔액 '-' 표시
    GS_OUTTAB-WRBTR_J = GS_OUTTAB-WRBTR_S - GS_OUTTAB-WRBTR_H.
    GS_OUTTAB-DMBTR_J = GS_OUTTAB-DMBTR_S - GS_OUTTAB-DMBTR_H.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                     TRANSPORTING WRBTR_S
                                  WRBTR_H
                                  WRBTR_J
                                  DMBTR_S
                                  DMBTR_H
                                  DMBTR_J
                                  WRBTR
                                  DMBTR.
  ENDLOOP.

ENDFORM.
