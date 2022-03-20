*&---------------------------------------------------------------------*
*&  Include           YEZFIR0060_F01
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
  CLEAR: YEZFIS0130.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_BUKRS.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GT_SKB1[].
  CLEAR: GS_SKB1.

  CLEAR: GT_KEY[].
  CLEAR: GS_KEY.

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

  YEZFIS0130-BUKRS     = P_BUKRS.
  YEZFIS0130-BUTXT     = P_BUTXT.
  YEZFIS0130-DTCNT     = LINES( GT_OUTTAB[] ).

  CALL SCREEN 0100.

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
*&      Form  MAKE_OUTTAB_PROC
*&---------------------------------------------------------------------*
*       개별항목 자료 선택 및 구성
*----------------------------------------------------------------------*
FORM MAKE_OUTTAB_PROC .

* 조회대상 G/L계정 SELECT
  PERFORM MAKE_HKONT_ENTRIES.

  LOOP AT GT_SKB1 INTO GS_SKB1.
    CASE ABAP_TRUE.
*     미결 항목 추출
      WHEN P_OPSEL.
        PERFORM SELECT_OPEN_ITEM.
*     반제 항목 추출
      WHEN P_CLSEL.
        PERFORM SELECT_CLEARED_ITEM.
*     모든 항목 추출
      WHEN P_AISEL.
        PERFORM SELECT_ALL_ITEM.
    ENDCASE.
  ENDLOOP.

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
*&      Form  SELECT_OPEN_ITEM
*&---------------------------------------------------------------------*
*       미결 항목 추출
*----------------------------------------------------------------------*
FORM SELECT_OPEN_ITEM .

  CHECK ( GS_SKB1-XOPVW = ABAP_TRUE ) OR     " 미결항목 또는
        ( GS_SKB1-MITKZ = 'D'       ) OR     " 고객 조정계정 또는
        ( GS_SKB1-MITKZ = 'K'       ).       " 구매처 조정계정

*----------------------------------------------------------------------*
* BSIS
*----------------------------------------------------------------------*
  IF ( P_NORM IS NOT INITIAL ).              " 일반항목
    PERFORM SELECT_OPEN_ITEM_BSIS.
  ENDIF.

*----------------------------------------------------------------------*
* BSAS
*----------------------------------------------------------------------*
  IF ( P_NORM IS NOT INITIAL ).              " 일반항목
    PERFORM SELECT_OPEN_ITEM_BSAS.
  ENDIF.

*----------------------------------------------------------------------*
* VBSEG
*----------------------------------------------------------------------*
  IF ( P_PARK IS NOT INITIAL ).              " 임시항목
    CASE GS_SKB1-MITKZ.
      WHEN 'D'.
        PERFORM SELECT_OPEN_ITEM_VBSEGD.     " 고객 조정계정
      WHEN 'K'.
        PERFORM SELECT_OPEN_ITEM_VBSEGK.     " 구매처 조정계정
      WHEN OTHERS.
        PERFORM SELECT_OPEN_ITEM_VBSEGS.     " 기타
    ENDCASE.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_CLEARED_ITEM
*&---------------------------------------------------------------------*
*       반제 항목 추출
*----------------------------------------------------------------------*
FORM SELECT_CLEARED_ITEM .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , A~MONAT     AS MONAT
       , A~BLART     AS BLART
       , A~BLDAT     AS BLDAT
       , A~BUDAT     AS BUDAT
       , A~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , A~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , A~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_BSAS)
    FROM BSAS AS A INNER JOIN
         BKPF AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND A~AUGDT    IN @S_AUGDT        " 반제일
     AND A~AUGDT    >  @P_STID2        " 주요일자의 미결항목
*----------------------------------------------------------------------*
     AND A~BUDAT    IN @S_BUDAT2
     AND A~BLDAT    IN @S_BLDAT
     AND A~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND A~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_BSAS INTO DATA(LS_BSAS).
    MOVE-CORRESPONDING LS_BSAS TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_GREEN.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ITEM
*&---------------------------------------------------------------------*
*       모든 항목 추출
*----------------------------------------------------------------------*
FORM SELECT_ALL_ITEM .

*----------------------------------------------------------------------*
* BSIS
*----------------------------------------------------------------------*
  IF ( P_NORM IS NOT INITIAL ).              " 일반항목
    PERFORM SELECT_ALL_ITEM_BSIS.
  ENDIF.

*----------------------------------------------------------------------*
* BSAS
*----------------------------------------------------------------------*
  IF ( P_NORM IS NOT INITIAL ).              " 일반항목
    PERFORM SELECT_ALL_ITEM_BSAS.
  ENDIF.

*----------------------------------------------------------------------*
* VBSEG
*----------------------------------------------------------------------*
  IF ( P_PARK IS NOT INITIAL ).              " 임시항목
    CASE GS_SKB1-MITKZ.
      WHEN 'D'.
        PERFORM SELECT_ALL_ITEM_VBSEGD.     " 고객 조정계정
      WHEN 'K'.
        PERFORM SELECT_ALL_ITEM_VBSEGK.     " 구매처 조정계정
      WHEN OTHERS.
        PERFORM SELECT_ALL_ITEM_VBSEGS.     " 기타
    ENDCASE.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_HKONT_ENTRIES
*&---------------------------------------------------------------------*
*       조회대상 G/L계정 SELECT
*----------------------------------------------------------------------*
FORM MAKE_HKONT_ENTRIES .

  SELECT SAKNR    AS SAKNR
       , MITKZ    AS MITKZ
       , XOPVW    AS XOPVW
    FROM SKB1
   WHERE BUKRS =  @P_BUKRS
     AND SAKNR IN @S_HKONT
    INTO CORRESPONDING FIELDS OF TABLE @GT_SKB1.

  SORT GT_SKB1 BY SAKNR.

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
  DATA: LV_CHECK   TYPE XFELD.

  CLEAR: LV_CHECK.

*----------------------------------------------------------------------*
* For All Entries 를 위한 Itab 구성
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    GS_KEY-BUKRS = GS_OUTTAB-BUKRS.
    GS_KEY-BELNR = GS_OUTTAB-BELNR.
    GS_KEY-GJAHR = GS_OUTTAB-GJAHR.
    GS_KEY-BUZEI = GS_OUTTAB-BUZEI.

    APPEND GS_KEY TO GT_KEY.
    CLEAR GS_KEY.
  ENDLOOP.

  SORT GT_KEY[] BY BUKRS BELNR GJAHR BUZEI.
  DELETE ADJACENT DUPLICATES FROM GT_KEY COMPARING ALL FIELDS.

*----------------------------------------------------------------------*
* 전표 개별항목 정보 반영
*----------------------------------------------------------------------*
* BSEG
  PERFORM MAKE_ITEM_INFO_BSEG.

* VBSEGS
  PERFORM MAKE_ITEM_INFO_VBSEGS.

* VBSEGD
  PERFORM MAKE_ITEM_INFO_VBSEGD.

* VBSEGK
  PERFORM MAKE_ITEM_INFO_VBSEGK.

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

  DATA: GT_KEY   LIKE STANDARD TABLE OF LS_KEY.

  CLEAR: GT_KEY[].
  CLEAR: LS_KEY.

*----------------------------------------------------------------------*
* For All Entries 를 위한 Itab 구성
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LS_KEY-SAKNR = GS_OUTTAB-HKONT.
    APPEND LS_KEY TO GT_KEY.
    CLEAR LS_KEY.
  ENDLOOP.

  SORT GT_KEY[] BY SAKNR.
  DELETE ADJACENT DUPLICATES FROM GT_KEY COMPARING ALL FIELDS.

*----------------------------------------------------------------------*
* G/L계정 명칭 Select
*----------------------------------------------------------------------*
  IF ( GT_KEY[] IS NOT INITIAL ).
    SELECT SAKNR
         , TXT50
      INTO TABLE @DATA(LT_SKAT)
      FROM SKAT
       FOR ALL ENTRIES IN @GT_KEY[]
     WHERE SPRAS = @SY-LANGU
       AND KTOPL = @GS_BUKRS-KTOPL
       AND SAKNR = @GT_KEY-SAKNR.
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

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                       TRANSPORTING HKONT_TXT.
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
      IF ( GS_OUTTAB-XNEGP IS INITIAL ).
        GS_OUTTAB-WRBTR_S = GS_OUTTAB-WRBTR.
        GS_OUTTAB-WRBTR_H = 0.
        GS_OUTTAB-DMBTR_S = GS_OUTTAB-DMBTR.
        GS_OUTTAB-DMBTR_H = 0.
      ELSE.
        GS_OUTTAB-WRBTR_S = 0.
        GS_OUTTAB-WRBTR_H = GS_OUTTAB-WRBTR * ( -1 ).
        GS_OUTTAB-DMBTR_S = 0.
        GS_OUTTAB-DMBTR_H = GS_OUTTAB-DMBTR * ( -1 ).
      ENDIF.
*   대변
    ELSE.
      IF ( GS_OUTTAB-XNEGP IS INITIAL ).
        GS_OUTTAB-WRBTR_S = 0.
        GS_OUTTAB-WRBTR_H = GS_OUTTAB-WRBTR.
        GS_OUTTAB-DMBTR_S = 0.
        GS_OUTTAB-DMBTR_H = GS_OUTTAB-DMBTR.
      ELSE.
        GS_OUTTAB-WRBTR_S = GS_OUTTAB-WRBTR * ( -1 ).
        GS_OUTTAB-WRBTR_H = 0.
        GS_OUTTAB-DMBTR_S = GS_OUTTAB-DMBTR * ( -1 ).
        GS_OUTTAB-DMBTR_H = 0.
      ENDIF.
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

*&---------------------------------------------------------------------*
*&      Form  SELECT_OPEN_ITEM_BSIS
*&---------------------------------------------------------------------*
*       미결 항목 추출 - BSIS
*----------------------------------------------------------------------*
FORM SELECT_OPEN_ITEM_BSIS .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , A~MONAT     AS MONAT
       , A~BLART     AS BLART
       , A~BLDAT     AS BLDAT
       , A~BUDAT     AS BUDAT
       , A~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , A~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , A~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_BSIS)
    FROM BSIS AS A INNER JOIN
         BKPF AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND A~BUDAT    <= @P_STIDA        " 주요일자의 미결항목
*----------------------------------------------------------------------*
     AND A~BUDAT    IN @S_BUDAT2
     AND A~BLDAT    IN @S_BLDAT
     AND A~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND A~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_BSIS INTO DATA(LS_BSIS).
    MOVE-CORRESPONDING LS_BSIS TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_RED.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_OPEN_ITEM_BSAS
*&---------------------------------------------------------------------*
*       미결 항목 추출 - BSAS
*----------------------------------------------------------------------*
FORM SELECT_OPEN_ITEM_BSAS .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , A~MONAT     AS MONAT
       , A~BLART     AS BLART
       , A~BLDAT     AS BLDAT
       , A~BUDAT     AS BUDAT
       , A~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , A~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , A~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_BSAS)
    FROM BSAS AS A INNER JOIN
         BKPF AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND A~BUDAT    <= @P_STIDA        " 주요일자의 미결항목
     AND A~AUGDT    >  @P_STIDA        " 주요일자의 미결항목
*----------------------------------------------------------------------*
     AND A~BUDAT    IN @S_BUDAT2
     AND A~BLDAT    IN @S_BLDAT
     AND A~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND A~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_BSAS INTO DATA(LS_BSAS).
    MOVE-CORRESPONDING LS_BSAS TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_RED.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_OPEN_ITEM_VBSEGS
*&---------------------------------------------------------------------*
*       미결 항목 추출 - VBSEGS
*----------------------------------------------------------------------*
FORM SELECT_OPEN_ITEM_VBSEGS .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , B~MONAT     AS MONAT
       , B~BLART     AS BLART
       , B~BLDAT     AS BLDAT
       , B~BUDAT     AS BUDAT
       , B~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , B~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~SAKNR     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , B~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_VBSEGS)
    FROM VBSEGS AS A INNER JOIN
         BKPF   AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~SAKNR    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND B~BUDAT    <= @P_STIDA        " 주요일자의 미결항목
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT2
     AND B~BLDAT    IN @S_BLDAT
     AND B~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND B~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_VBSEGS INTO DATA(LS_VBSEGS).
    MOVE-CORRESPONDING LS_VBSEGS TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_YELLOW.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_OPEN_ITEM_VBSEGD
*&---------------------------------------------------------------------*
*       미결 항목 추출 - VBSEGD
*----------------------------------------------------------------------*
FORM SELECT_OPEN_ITEM_VBSEGD .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , B~MONAT     AS MONAT
       , B~BLART     AS BLART
       , B~BLDAT     AS BLDAT
       , B~BUDAT     AS BUDAT
       , B~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , B~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , B~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_VBSEGD)
    FROM VBSEGD AS A INNER JOIN
         BKPF   AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND B~BUDAT    <= @P_STIDA        " 주요일자의 미결항목
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT2
     AND B~BLDAT    IN @S_BLDAT
     AND B~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND B~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_VBSEGD INTO DATA(LS_VBSEGD).
    MOVE-CORRESPONDING LS_VBSEGD TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_YELLOW.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_OPEN_ITEM_VBSEGK
*&---------------------------------------------------------------------*
*       미결 항목 추출 - VBSEGK
*----------------------------------------------------------------------*
FORM SELECT_OPEN_ITEM_VBSEGK .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , B~MONAT     AS MONAT
       , B~BLART     AS BLART
       , B~BLDAT     AS BLDAT
       , B~BUDAT     AS BUDAT
       , B~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , B~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , B~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_VBSEGK)
    FROM VBSEGD AS A INNER JOIN
         BKPF   AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND B~BUDAT    <= @P_STIDA        " 주요일자의 미결항목
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT2
     AND B~BLDAT    IN @S_BLDAT
     AND B~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND B~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_VBSEGK INTO DATA(LS_VBSEGK).
    MOVE-CORRESPONDING LS_VBSEGK TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_YELLOW.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ITEM_BSIS
*&---------------------------------------------------------------------*
*       모든 항목 추출 - BSIS
*----------------------------------------------------------------------*
FORM SELECT_ALL_ITEM_BSIS .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , A~MONAT     AS MONAT
       , A~BLART     AS BLART
       , A~BLDAT     AS BLDAT
       , A~BUDAT     AS BUDAT
       , A~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , A~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , A~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_BSIS)
    FROM BSIS AS A INNER JOIN
         BKPF AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~ZUONR    IN @S_ZUONR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND A~BUDAT    IN @S_BUDAT        " 전기일
*----------------------------------------------------------------------*
     AND A~BUDAT    IN @S_BUDAT2
     AND A~BLDAT    IN @S_BLDAT
     AND A~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND A~BLART    IN @S_BLART
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_BSIS INTO DATA(LS_BSIS).
    MOVE-CORRESPONDING LS_BSIS TO GS_OUTTAB.

    IF ( GS_SKB1-XOPVW = ABAP_TRUE ) OR
       ( GS_SKB1-MITKZ = 'D' )       OR
       ( GS_SKB1-MITKZ = 'K' ).
      GS_OUTTAB-STATU = ICON_LED_RED.
    ELSE.
      GS_OUTTAB-STATU = ICON_CHECKED.
    ENDIF.

    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ITEM_BSAS
*&---------------------------------------------------------------------*
*       모든 항목 추출 - BSAS
*----------------------------------------------------------------------*
FORM SELECT_ALL_ITEM_BSAS .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , A~MONAT     AS MONAT
       , A~BLART     AS BLART
       , A~BLDAT     AS BLDAT
       , A~BUDAT     AS BUDAT
       , A~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , A~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , A~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_BSAS)
    FROM BSAS AS A INNER JOIN
         BKPF AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~ZUONR    IN @S_ZUONR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND A~BUDAT    IN @S_BUDAT        " 전기일
*----------------------------------------------------------------------*
     AND A~BUDAT    IN @S_BUDAT2
     AND A~BLDAT    IN @S_BLDAT
     AND A~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND A~BLART    IN @S_BLART
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_BSAS INTO DATA(LS_BSAS).
    MOVE-CORRESPONDING LS_BSAS TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_GREEN.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ITEM_VBSEGS
*&---------------------------------------------------------------------*
*       모든 항목 추출 - VBSEGS
*----------------------------------------------------------------------*
FORM SELECT_ALL_ITEM_VBSEGS .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , B~MONAT     AS MONAT
       , B~BLART     AS BLART
       , B~BLDAT     AS BLDAT
       , B~BUDAT     AS BUDAT
       , B~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , B~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~SAKNR     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , B~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_VBSEGS)
    FROM VBSEGS AS A INNER JOIN
         BKPF   AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~SAKNR    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT        " 전기일
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT2
     AND B~BLDAT    IN @S_BLDAT
     AND B~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND B~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_VBSEGS INTO DATA(LS_VBSEGS).
    MOVE-CORRESPONDING LS_VBSEGS TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_YELLOW.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ITEM_VBSEGD
*&---------------------------------------------------------------------*
*       모든 항목 추출 - VBSEGD
*----------------------------------------------------------------------*
FORM SELECT_ALL_ITEM_VBSEGD .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , B~MONAT     AS MONAT
       , B~BLART     AS BLART
       , B~BLDAT     AS BLDAT
       , B~BUDAT     AS BUDAT
       , B~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , B~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , B~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_VBSEGD)
    FROM VBSEGD AS A INNER JOIN
         BKPF   AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT        " 전기일
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT2
     AND B~BLDAT    IN @S_BLDAT
     AND B~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND B~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_VBSEGD INTO DATA(LS_VBSEGD).
    MOVE-CORRESPONDING LS_VBSEGD TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_YELLOW.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ITEM_VBSEGK
*&---------------------------------------------------------------------*
*       모든 항목 추출 - VBSEGK
*----------------------------------------------------------------------*
FORM SELECT_ALL_ITEM_VBSEGK .

  SELECT A~BUKRS     AS BUKRS
       , A~BELNR     AS BELNR
       , A~GJAHR     AS GJAHR
       , A~BUZEI     AS BUZEI
       , B~MONAT     AS MONAT
       , B~BLART     AS BLART
       , B~BLDAT     AS BLDAT
       , B~BUDAT     AS BUDAT
       , B~XBLNR     AS XBLNR
       , B~BKTXT     AS BKTXT
       , B~BSTAT     AS BSTAT
       , B~STBLG     AS STBLG
       , B~STJAH     AS STJAH
       , B~XREVERSAL AS XREVERSAL
       , B~XREF1_HD  AS XREF1_HD
       , B~XREF2_HD  AS XREF2_HD
       , A~HKONT     AS HKONT
       , A~SHKZG     AS SHKZG
       , A~WRBTR     AS WRBTR
       , A~DMBTR     AS DMBTR
       , B~WAERS     AS WAERS
       , B~HWAER     AS HWAER
    INTO TABLE @DATA(LT_VBSEGK)
    FROM VBSEGD AS A INNER JOIN
         BKPF   AS B
      ON B~BUKRS    =  A~BUKRS
     AND B~BELNR    =  A~BELNR
     AND B~GJAHR    =  A~GJAHR
   WHERE A~BUKRS    =  @P_BUKRS
     AND A~HKONT    =  @GS_SKB1-SAKNR
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT        " 전기일
*----------------------------------------------------------------------*
     AND B~BUDAT    IN @S_BUDAT2
     AND B~BLDAT    IN @S_BLDAT
     AND B~XBLNR    IN @S_XBLNR
     AND B~XREF1_HD IN @S_XREF1H
     AND B~XREF2_HD IN @S_XREF2H
     AND B~BLART    IN @S_BLART
     AND A~ZUONR    IN @S_ZUONR
     AND A~GSBER    IN @S_GSBER.

  LOOP AT LT_VBSEGK INTO DATA(LS_VBSEGK).
    MOVE-CORRESPONDING LS_VBSEGK TO GS_OUTTAB.
    GS_OUTTAB-STATU = ICON_LED_YELLOW.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_ITEM_INFO_BSEG
*&---------------------------------------------------------------------*
*       전표 개별항목 정보 구성 - BSEG
*----------------------------------------------------------------------*
FORM MAKE_ITEM_INFO_BSEG .

  IF ( GT_KEY[] IS NOT INITIAL ).
    SELECT *
      INTO TABLE @DATA(LT_BSEG)
      FROM BSEG
       FOR ALL ENTRIES IN @GT_KEY
     WHERE BUKRS = @GT_KEY-BUKRS
       AND BELNR = @GT_KEY-BELNR
       AND GJAHR = @GT_KEY-GJAHR
       AND BUZEI = @GT_KEY-BUZEI.
  ENDIF.

  CHECK ( LT_BSEG[] IS NOT INITIAL ).

  SORT LT_BSEG   BY BUKRS BELNR GJAHR BUZEI.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    READ TABLE LT_BSEG INTO DATA(LS_BSEG)
                       WITH KEY BUKRS = GS_OUTTAB-BUKRS
                                BELNR = GS_OUTTAB-BELNR
                                GJAHR = GS_OUTTAB-GJAHR
                                BUZEI = GS_OUTTAB-BUZEI
                       BINARY SEARCH.

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
*&      Form  MAKE_ITEM_INFO_VBSEGS
*&---------------------------------------------------------------------*
*       전표 개별항목 정보 구성 - VBSEGS
*----------------------------------------------------------------------*
FORM MAKE_ITEM_INFO_VBSEGS.

  IF ( GT_KEY[] IS NOT INITIAL ).
    SELECT *
      INTO TABLE @DATA(LT_VBSEGS)
      FROM VBSEGS
       FOR ALL ENTRIES IN @GT_KEY
     WHERE BUKRS = @GT_KEY-BUKRS
       AND BELNR = @GT_KEY-BELNR
       AND GJAHR = @GT_KEY-GJAHR
       AND BUZEI = @GT_KEY-BUZEI.
  ENDIF.

  CHECK ( LT_VBSEGS[] IS NOT INITIAL ).

  SORT LT_VBSEGS BY BUKRS BELNR GJAHR BUZEI.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    READ TABLE LT_VBSEGS INTO DATA(LS_VBSEGS)
                         WITH KEY BUKRS = GS_OUTTAB-BUKRS
                                  BELNR = GS_OUTTAB-BELNR
                                  GJAHR = GS_OUTTAB-GJAHR
                                  BUZEI = GS_OUTTAB-BUZEI.

    IF ( SY-SUBRC = 0 ).
      GS_OUTTAB-SGTXT = LS_VBSEGS-SGTXT.
      GS_OUTTAB-ZUONR = LS_VBSEGS-ZUONR.
      GS_OUTTAB-XNEGP = LS_VBSEGS-XNEGP.
      GS_OUTTAB-KOART = LS_VBSEGS-KOART.
*     GS_OUTTAB-LIFNR = LS_VBSEGS-LIFNR.
*     GS_OUTTAB-KUNNR = LS_VBSEGS-KUNNR.
      GS_OUTTAB-MWSKZ = LS_VBSEGS-MWSKZ.
      GS_OUTTAB-BUPLA = LS_VBSEGS-BUPLA.
      GS_OUTTAB-GSBER = LS_VBSEGS-GSBER.
*     GS_OUTTAB-ZTERM = LS_VBSEGS-ZTERM.
      GS_OUTTAB-ZFBDT = LS_VBSEGS-ZFBDT.
*     GS_OUTTAB-ZBD1T = LS_VBSEGS-ZBD1T.
*     GS_OUTTAB-ZBD2T = LS_VBSEGS-ZBD2T.
*     GS_OUTTAB-ZBD3T = LS_VBSEGS-ZBD3T.
*     GS_OUTTAB-REBZG = LS_VBSEGS-REBZG.
*     GS_OUTTAB-REBZJ = LS_VBSEGS-REBZJ.
*     GS_OUTTAB-REBZZ = LS_VBSEGS-REBZZ.
*     GS_OUTTAB-ZLSCH = LS_VBSEGS-ZLSCH.
*     GS_OUTTAB-ZLSPR = LS_VBSEGS-ZLSPR.
*     GS_OUTTAB-FAEDT = LS_VBSEGS-FAEDT.
*     GS_OUTTAB-HBKID = LS_VBSEGS-HBKID.
*     GS_OUTTAB-BVTYP = LS_VBSEGS-BVTYP.
      GS_OUTTAB-XREF1 = LS_VBSEGS-XREF1.
      GS_OUTTAB-XREF2 = LS_VBSEGS-XREF2.
      GS_OUTTAB-XREF3 = LS_VBSEGS-XREF3.
      GS_OUTTAB-KOSTL = LS_VBSEGS-KOSTL.
      GS_OUTTAB-FKBER = LS_VBSEGS-FKBER.
      GS_OUTTAB-PRCTR = LS_VBSEGS-PRCTR.
      GS_OUTTAB-ANLN1 = LS_VBSEGS-ANLN1.
      GS_OUTTAB-ANLN2 = LS_VBSEGS-ANLN2.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_ITEM_INFO_VBSEGD
*&---------------------------------------------------------------------*
*       전표 개별항목 정보 구성 - VBSEGD
*----------------------------------------------------------------------*
FORM MAKE_ITEM_INFO_VBSEGD.

  IF ( GT_KEY[] IS NOT INITIAL ).
    SELECT *
      INTO TABLE @DATA(LT_VBSEGD)
      FROM VBSEGD
       FOR ALL ENTRIES IN @GT_KEY
     WHERE BUKRS = @GT_KEY-BUKRS
       AND BELNR = @GT_KEY-BELNR
       AND GJAHR = @GT_KEY-GJAHR
       AND BUZEI = @GT_KEY-BUZEI.
  ENDIF.

  CHECK ( LT_VBSEGD[] IS NOT INITIAL ).

  SORT LT_VBSEGD BY BUKRS BELNR GJAHR BUZEI.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    READ TABLE LT_VBSEGD INTO DATA(LS_VBSEGD)
                         WITH KEY BUKRS = GS_OUTTAB-BUKRS
                                  BELNR = GS_OUTTAB-BELNR
                                  GJAHR = GS_OUTTAB-GJAHR
                                  BUZEI = GS_OUTTAB-BUZEI.

    IF ( SY-SUBRC = 0 ).
      GS_OUTTAB-SGTXT = LS_VBSEGD-SGTXT.
      GS_OUTTAB-ZUONR = LS_VBSEGD-ZUONR.
      GS_OUTTAB-XNEGP = LS_VBSEGD-XNEGP.
      GS_OUTTAB-KOART = 'D'.
*     GS_OUTTAB-LIFNR = LS_VBSEGD-LIFNR.
      GS_OUTTAB-KUNNR = LS_VBSEGD-KUNNR.
      GS_OUTTAB-MWSKZ = LS_VBSEGD-MWSKZ.
      GS_OUTTAB-BUPLA = LS_VBSEGD-BUPLA.
      GS_OUTTAB-GSBER = LS_VBSEGD-GSBER.
      GS_OUTTAB-ZTERM = LS_VBSEGD-ZTERM.
      GS_OUTTAB-ZFBDT = LS_VBSEGD-ZFBDT.
      GS_OUTTAB-ZBD1T = LS_VBSEGD-ZBD1T.
      GS_OUTTAB-ZBD2T = LS_VBSEGD-ZBD2T.
      GS_OUTTAB-ZBD3T = LS_VBSEGD-ZBD3T.
      GS_OUTTAB-REBZG = LS_VBSEGD-REBZG.
      GS_OUTTAB-REBZJ = LS_VBSEGD-REBZJ.
      GS_OUTTAB-REBZZ = LS_VBSEGD-REBZZ.
      GS_OUTTAB-ZLSCH = LS_VBSEGD-ZLSCH.
      GS_OUTTAB-ZLSPR = LS_VBSEGD-ZLSPR.
*     GS_OUTTAB-FAEDT = LS_VBSEGD-FAEDT.
      GS_OUTTAB-HBKID = LS_VBSEGD-HBKID.
      GS_OUTTAB-BVTYP = LS_VBSEGD-BVTYP.
      GS_OUTTAB-XREF1 = LS_VBSEGD-XREF1.
      GS_OUTTAB-XREF2 = LS_VBSEGD-XREF2.
      GS_OUTTAB-XREF3 = LS_VBSEGD-XREF3.
*     GS_OUTTAB-KOSTL = LS_VBSEGD-KOSTL.
      GS_OUTTAB-FKBER = LS_VBSEGD-FKBER.
*     GS_OUTTAB-PRCTR = LS_VBSEGD-PRCTR.
*     GS_OUTTAB-ANLN1 = LS_VBSEGD-ANLN1.
*     GS_OUTTAB-ANLN2 = LS_VBSEGD-ANLN2.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_ITEM_INFO_VBSEGK
*&---------------------------------------------------------------------*
*       전표 개별항목 정보 구성 - VBSEGK
*----------------------------------------------------------------------*
FORM MAKE_ITEM_INFO_VBSEGK.

  IF ( GT_KEY[] IS NOT INITIAL ).
    SELECT *
      INTO TABLE @DATA(LT_VBSEGK)
      FROM VBSEGK
       FOR ALL ENTRIES IN @GT_KEY
     WHERE BUKRS = @GT_KEY-BUKRS
       AND BELNR = @GT_KEY-BELNR
       AND GJAHR = @GT_KEY-GJAHR
       AND BUZEI = @GT_KEY-BUZEI.
  ENDIF.

  CHECK ( LT_VBSEGK[] IS NOT INITIAL ).

  SORT LT_VBSEGK BY BUKRS BELNR GJAHR BUZEI.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    READ TABLE LT_VBSEGK INTO DATA(LS_VBSEGK)
                         WITH KEY BUKRS = GS_OUTTAB-BUKRS
                                  BELNR = GS_OUTTAB-BELNR
                                  GJAHR = GS_OUTTAB-GJAHR
                                  BUZEI = GS_OUTTAB-BUZEI.

    IF ( SY-SUBRC = 0 ).
      GS_OUTTAB-SGTXT = LS_VBSEGK-SGTXT.
      GS_OUTTAB-ZUONR = LS_VBSEGK-ZUONR.
      GS_OUTTAB-XNEGP = LS_VBSEGK-XNEGP.
      GS_OUTTAB-KOART = 'K'.
      GS_OUTTAB-LIFNR = LS_VBSEGK-LIFNR.
*     GS_OUTTAB-KUNNR = LS_VBSEGK-KUNNR.
      GS_OUTTAB-MWSKZ = LS_VBSEGK-MWSKZ.
      GS_OUTTAB-BUPLA = LS_VBSEGK-BUPLA.
      GS_OUTTAB-GSBER = LS_VBSEGK-GSBER.
      GS_OUTTAB-ZTERM = LS_VBSEGK-ZTERM.
      GS_OUTTAB-ZFBDT = LS_VBSEGK-ZFBDT.
      GS_OUTTAB-ZBD1T = LS_VBSEGK-ZBD1T.
      GS_OUTTAB-ZBD2T = LS_VBSEGK-ZBD2T.
      GS_OUTTAB-ZBD3T = LS_VBSEGK-ZBD3T.
      GS_OUTTAB-REBZG = LS_VBSEGK-REBZG.
      GS_OUTTAB-REBZJ = LS_VBSEGK-REBZJ.
      GS_OUTTAB-REBZZ = LS_VBSEGK-REBZZ.
      GS_OUTTAB-ZLSCH = LS_VBSEGK-ZLSCH.
      GS_OUTTAB-ZLSPR = LS_VBSEGK-ZLSPR.
*     GS_OUTTAB-FAEDT = LS_VBSEGK-FAEDT.
      GS_OUTTAB-HBKID = LS_VBSEGK-HBKID.
      GS_OUTTAB-BVTYP = LS_VBSEGK-BVTYP.
      GS_OUTTAB-XREF1 = LS_VBSEGK-XREF1.
      GS_OUTTAB-XREF2 = LS_VBSEGK-XREF2.
      GS_OUTTAB-XREF3 = LS_VBSEGK-XREF3.
*     GS_OUTTAB-KOSTL = LS_VBSEGK-KOSTL.
      GS_OUTTAB-FKBER = LS_VBSEGK-FKBER.
*     GS_OUTTAB-PRCTR = LS_VBSEGK-PRCTR.
*     GS_OUTTAB-ANLN1 = LS_VBSEGK-ANLN1.
*     GS_OUTTAB-ANLN2 = LS_VBSEGK-ANLN2.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTION_SCREEN_INPUT
*&---------------------------------------------------------------------*
*       초기화면 입력값 점검
*----------------------------------------------------------------------*
FORM CHECK_SELECTION_SCREEN_INPUT .

  CLEAR: GV_ERROR.

  IF ( P_OPSEL IS NOT INITIAL ).
    IF ( P_STIDA IS INITIAL ).
      P_STIDA = SY-DATUM.
    ENDIF.
  ENDIF.

  IF ( P_NORM IS INITIAL ) AND
     ( P_PARK IS INITIAL ).
    MESSAGE S020(MSITEM).
    GV_ERROR = ABAP_TRUE.
  ENDIF.

ENDFORM.
