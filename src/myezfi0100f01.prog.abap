*&---------------------------------------------------------------------*
*&  Include           MYEZFI0100F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_SUBLOGIN_PROC
*&---------------------------------------------------------------------*
*       Sublogin 에 대한 사용자 정보를 가져 온다.
*----------------------------------------------------------------------*
FORM CHECK_SUBLOGIN_PROC .

  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CALL FUNCTION 'Y_FI_SUBLOGIN'
*   EXPORTING
*     IV_UNAME    = SY-UNAME
*     IV_SKIP     = ABAP_TRUE
    IMPORTING
      ES_SUBLOGIN = GS_SUBLOGIN
      EV_RETURN   = LV_RETURN
      EV_MESSAGE  = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE E012(YFIM).    " 발의부서를 결정할 수 없습니다.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DOCUMENT_DETAIL
*&---------------------------------------------------------------------*
*       전표 상세내역 조회
*----------------------------------------------------------------------*
FORM DISPLAY_DOCUMENT_DETAIL .

* 전표정보 SELECT
  PERFORM GET_DOCUMENT_DATA.

* 전표정보 메모리 세팅
  SET PARAMETER ID 'BUK' FIELD YEZFIS0060-BUKRS.
  SET PARAMETER ID 'BLN' FIELD YEZFIS0060-BELNR.
  SET PARAMETER ID 'GJR' FIELD YEZFIS0060-GJAHR.

* 200번 화면 호출
  CALL SCREEN 0200.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCUMENT_NO
*&---------------------------------------------------------------------*
*       전표 번호 점검
*----------------------------------------------------------------------*
*      -->PV_BUKRS  회사 코드
*      -->PV_BELNR  전표 번호
*      -->PV_GJAHR  회계연도
*----------------------------------------------------------------------*
FORM CHECK_DOCUMENT_NO  USING    PV_BUKRS
                                 PV_BELNR
                                 PV_GJAHR.

  CLEAR: GV_BSTAT.

  SELECT SINGLE BSTAT
    FROM BKPF
    INTO GV_BSTAT
   WHERE BELNR = PV_BELNR
     AND BUKRS = PV_BUKRS
     AND GJAHR = PV_GJAHR.

  IF ( SY-SUBRC = 0 ).
    IF ( GV_BSTAT = 'Z' ).
      MESSAGE E000(ZCM) WITH TEXT-M02.   " 삭제된 전표번호입니다.
    ENDIF.
  ELSE.
    MESSAGE E000(YFIM) WITH TEXT-M01.    " 올바른 전표번호를 입력하세요.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DOCUMENT_DATA
*&---------------------------------------------------------------------*
*       전표정보 SELECT
*----------------------------------------------------------------------*
FORM GET_DOCUMENT_DATA.

*----------------------------------------------------------------------*
* 전표정보 SELECT - 전표 헤더
*----------------------------------------------------------------------*
  PERFORM GET_DOCUMENT_HEADER_DATA.

*----------------------------------------------------------------------*
* 전표정보 SELECT - 전표 개별항목
*----------------------------------------------------------------------*
  PERFORM GET_DOCUMENT_ITEM_DATA.

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
* 회사코드 정보 결정
*----------------------------------------------------------------------*
  CALL FUNCTION 'Y_FI_GET_BUKRS_INFO'
    EXPORTING
      IV_BUKRS   = YEZFIS0060-BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE
      ES_BUKRS   = GS_BUKRS.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_FOR_NEW_START
*&---------------------------------------------------------------------*
*       프로그램 시작 시 광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_FOR_NEW_START .

  CLEAR: YEZFIS0060.
  CLEAR: YEZFIS0070.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_SUBLOGIN.
  CLEAR: GS_BUKRS.

  CLEAR: GV_BSTAT.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GO_CONTAINER_0200.
  CLEAR: GO_GRID_0200.
  .
  CLEAR: GT_FCAT_0200.
  CLEAR: GS_FCAT_0200.
  CLEAR: GT_SORT_0200.

  CLEAR: GS_LAYOUT_0200.
  CLEAR: GS_VARIANT_0200.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_BELNR_PARAMETER
*&---------------------------------------------------------------------*
*       메모리의 전표번호 반영
*----------------------------------------------------------------------*
FORM SET_BELNR_PARAMETER .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_BUKRS   TYPE BKPF-BUKRS.
  DATA: LV_BELNR   TYPE BKPF-BELNR.
  DATA: LV_GJAHR   TYPE BKPF-GJAHR.

  CLEAR: LV_BUKRS.
  CLEAR: LV_BELNR.
  CLEAR: LV_GJAHR.

  GET PARAMETER ID 'BUK' FIELD LV_BUKRS.
  GET PARAMETER ID 'BLN' FIELD LV_BELNR.
  GET PARAMETER ID 'GJR' FIELD LV_GJAHR.

*----------------------------------------------------------------------*
* 메모리의 전표정보 가져오기
*----------------------------------------------------------------------*
* 메모리와 Sublogin 의 회사코드 동일 - 메모리 전표정보 세팅
  IF ( LV_BUKRS = YEZFIS0060-BUKRS ).
    YEZFIS0060-BELNR = LV_BELNR.
    YEZFIS0060-GJAHR = LV_GJAHR.
* 메모리와 Sublogin 의 회사코드 상이 - 초기화
  ELSE.
    CLEAR: YEZFIS0060-BELNR.
    CLEAR: YEZFIS0060-GJAHR.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DOCUMENT_HEADER_DATA
*&---------------------------------------------------------------------*
*       전표정보 SELECT - 전표 헤더
*----------------------------------------------------------------------*
FORM GET_DOCUMENT_HEADER_DATA .

* 전표번호
  YEZFIS0070-BUKRS = YEZFIS0060-BUKRS.
  YEZFIS0070-BELNR = YEZFIS0060-BELNR.
  YEZFIS0070-GJAHR = YEZFIS0060-GJAHR.
  YEZFIS0070-BUTXT = YEZFIS0060-BUTXT.

* 전표상태
  IF ( GV_BSTAT = 'V' ).          " 임시
    YEZFIS0070-STATV = 'X'.
    YEZFIS0070-STATP = SPACE.
  ELSE.                           " 전기
    YEZFIS0070-STATV = SPACE.
    YEZFIS0070-STATP = 'X'.
  ENDIF.

* 전표헤더 추가 정보
  SELECT SINGLE
         BLART
         BLDAT
         BUDAT
         XBLNR
         WAERS
         HWAER
         LDGRP
         BKTXT
    INTO (YEZFIS0070-BLART,
          YEZFIS0070-BLDAT,
          YEZFIS0070-BUDAT,
          YEZFIS0070-XBLNR,
          YEZFIS0070-WAERS,
          YEZFIS0070-HWAER,
          YEZFIS0070-LDGRP,
          YEZFIS0070-BKTXT)
    FROM BKPF
   WHERE BUKRS = YEZFIS0070-BUKRS
     AND BELNR = YEZFIS0070-BELNR
     AND GJAHR = YEZFIS0070-GJAHR.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DOCUMENT_ITEM_DATA
*&---------------------------------------------------------------------*
*       전표정보 SELECT - 전표 개별항목
*----------------------------------------------------------------------*
FORM GET_DOCUMENT_ITEM_DATA .

*----------------------------------------------------------------------*
* BSEG SELECT
*----------------------------------------------------------------------*
  PERFORM SELECT_BSEG.

*----------------------------------------------------------------------*
* 개별항목 G/L계정명 설정
*----------------------------------------------------------------------*
  PERFORM SET_GL_ACCOUNT_NAME.

*----------------------------------------------------------------------*
* 개별항목 금액정보 설정
*----------------------------------------------------------------------*
  PERFORM SET_LINE_ITEM_AMT_INFO.

*----------------------------------------------------------------------*
* 개별항목 거래처 정보 설정
*----------------------------------------------------------------------*
  PERFORM SET_PARTNER_INFO.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_FOR_NEW_ENTRY
*&---------------------------------------------------------------------*
*       새로운 전표 조회 시 광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_FOR_NEW_ENTRY .

  CLEAR: YEZFIS0070.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GV_BSTAT.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GO_CONTAINER_0200.
  CLEAR: GO_GRID_0200.
  .
  CLEAR: GT_FCAT_0200.
  CLEAR: GS_FCAT_0200.
  CLEAR: GT_SORT_0200.

  CLEAR: GS_LAYOUT_0200.
  CLEAR: GS_VARIANT_0200.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_BSEG
*&---------------------------------------------------------------------*
*       BSEG SELECT
*----------------------------------------------------------------------*
FORM SELECT_BSEG .

  SELECT BUZEI
         HKONT
         SHKZG
         WRBTR   AS WRBTR_J
         DMBTR   AS DMBTR_J
         SGTXT
         ZUONR
         XNEGP
         KOART
         LIFNR
         KUNNR
         MWSKZ
         BUPLA
    INTO CORRESPONDING FIELDS OF TABLE GT_OUTTAB
    FROM BSEG
   WHERE BUKRS = YEZFIS0060-BUKRS
     AND BELNR = YEZFIS0060-BELNR
     AND GJAHR = YEZFIS0060-GJAHR.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_GL_ACCOUNT_NAME
*&---------------------------------------------------------------------*
*       개별항목 G/L계정명 결정
*----------------------------------------------------------------------*
FORM SET_GL_ACCOUNT_NAME .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
* 지역변수 선언
  DATA: LV_INDEX   TYPE SY-TABIX.

  DATA: BEGIN OF LS_SAKNR,
          SAKNR TYPE SKAT-SAKNR,
        END OF LS_SAKNR.

  DATA: LT_SAKNR   LIKE STANDARD TABLE OF LS_SAKNR.

  DATA: BEGIN OF LS_SKAT,
          SAKNR TYPE SKAT-SAKNR,
          TXT50 TYPE SKAT-TXT50,
        END OF LS_SKAT.

  DATA: LT_SKAT   LIKE STANDARD TABLE OF LS_SKAT.

* 지역변수 초기화
  CLEAR: LV_INDEX.

  CLEAR: LT_SAKNR[].
  CLEAR: LS_SAKNR.

  CLEAR: LT_SKAT[].
  CLEAR: LS_SKAT.

*----------------------------------------------------------------------*
* For all entries 를 위한 G/L 계정 목록 구성
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LS_SAKNR-SAKNR = GS_OUTTAB-HKONT.
    APPEND LS_SAKNR TO LT_SAKNR.
    CLEAR LS_SAKNR.
  ENDLOOP.

  SORT LT_SAKNR BY SAKNR.
  DELETE ADJACENT DUPLICATES FROM LT_SAKNR.

*----------------------------------------------------------------------*
* G/L계정명 SELECT
*----------------------------------------------------------------------*
  IF ( LT_SAKNR[] IS NOT INITIAL ).
    SELECT SAKNR
           TXT50
      INTO CORRESPONDING FIELDS OF TABLE LT_SKAT
      FROM SKAT
       FOR ALL ENTRIES IN LT_SAKNR
     WHERE SPRAS = SY-LANGU
       AND KTOPL = GS_BUKRS-KTOPL
    AND SAKNR = LT_SAKNR-SAKNR.
  ENDIF.

*----------------------------------------------------------------------*
* G/L계정명 반영
*----------------------------------------------------------------------*
  SORT LT_SKAT BY SAKNR.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_INDEX = SY-TABIX.

    CLEAR LS_SKAT.
    READ TABLE LT_SKAT INTO LS_SKAT
                       WITH KEY SAKNR = GS_OUTTAB-HKONT
                       BINARY SEARCH
                       TRANSPORTING TXT50.

    IF ( SY-SUBRC = 0 ).
      GS_OUTTAB-HKONT_TXT = LS_SKAT-TXT50.
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                       TRANSPORTING HKONT_TXT.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LINE_ITEM_AMT_INFO
*&---------------------------------------------------------------------*
*       개별항목 금액정보 설정
*----------------------------------------------------------------------*
FORM SET_LINE_ITEM_AMT_INFO .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
* 지역변수 선언
  DATA: LV_INDEX   TYPE SY-TABIX.

* 지역변수 초기화
  CLEAR: LV_INDEX.

*----------------------------------------------------------------------*
* 차/대변 금액정보 결정
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_INDEX = SY-TABIX.

*   통화키
    GS_OUTTAB-WAERS = YEZFIS0070-WAERS.
    GS_OUTTAB-HWAER = YEZFIS0070-HWAER.

*   차변
    IF ( GS_OUTTAB-SHKZG = 'S' ).
      IF ( GS_OUTTAB-XNEGP IS INITIAL ).                " 정상 전기 - 차변의 +
        GS_OUTTAB-WRBTR_S = GS_OUTTAB-WRBTR_J.
        GS_OUTTAB-WRBTR_H = 0.
        GS_OUTTAB-DMBTR_S = GS_OUTTAB-DMBTR_J.
        GS_OUTTAB-DMBTR_H = 0.
      ELSE.                                             " 마이너스 전기 - 대변의 -
        GS_OUTTAB-WRBTR_S = 0.
        GS_OUTTAB-WRBTR_H = GS_OUTTAB-WRBTR_J * ( -1 ).
        GS_OUTTAB-DMBTR_S = 0.
        GS_OUTTAB-DMBTR_H = GS_OUTTAB-DMBTR_J * ( -1 ).
      ENDIF.
*   대변
    ELSE.
      IF ( GS_OUTTAB-XNEGP IS INITIAL ).               " 정상 전기 - 대변의 +
        GS_OUTTAB-WRBTR_S = 0.
        GS_OUTTAB-WRBTR_H = GS_OUTTAB-WRBTR_J.
        GS_OUTTAB-DMBTR_S = 0.
        GS_OUTTAB-DMBTR_H = GS_OUTTAB-DMBTR_J.
      ELSE.                                            " 마이너스 전기 - 차변의 -
        GS_OUTTAB-WRBTR_S = GS_OUTTAB-WRBTR_J * ( -1 ).
        GS_OUTTAB-WRBTR_H = 0.
        GS_OUTTAB-DMBTR_S = GS_OUTTAB-DMBTR_J * ( -1 ).
        GS_OUTTAB-DMBTR_H = 0.
      ENDIF.

*     대변금액인 경우 잔액 '-' 표시
      GS_OUTTAB-WRBTR_J = GS_OUTTAB-WRBTR_J * ( -1 ).
      GS_OUTTAB-DMBTR_J = GS_OUTTAB-DMBTR_J * ( -1 ).
    ENDIF.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                     TRANSPORTING WRBTR_S
                                  WRBTR_H
                                  WRBTR_J
                                  DMBTR_S
                                  DMBTR_H
                                  DMBTR_J.
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
* 지역변수 선언
  DATA: LV_INDEX   TYPE SY-TABIX.

* 고객 관련 지역변수 선언
  DATA: BEGIN OF LS_CUST,
          KUNNR TYPE KNA1-KUNNR,
        END OF LS_CUST.

  DATA: LT_CUST   LIKE STANDARD TABLE OF LS_CUST.

  DATA: BEGIN OF LS_KNA1,
          KUNNR TYPE KNA1-KUNNR,
          NAME1 TYPE KNA1-NAME1,
        END OF LS_KNA1.

  DATA: LT_KNA1   LIKE STANDARD TABLE OF LS_KNA1.

* 구매처 관련 지역변수 선언
  DATA: BEGIN OF LS_VEND,
          LIFNR TYPE LFA1-LIFNR,
        END OF LS_VEND.

  DATA: LT_VEND   LIKE STANDARD TABLE OF LS_VEND.

  DATA: BEGIN OF LS_LFA1,
          LIFNR TYPE LFA1-LIFNR,
          NAME1 TYPE LFA1-NAME1,
        END OF LS_LFA1.

  DATA: LT_LFA1   LIKE STANDARD TABLE OF LS_LFA1.

* 지역변수 초기화
  CLEAR: LV_INDEX.

  CLEAR: LT_CUST[].
  CLEAR: LS_CUST.

  CLEAR: LT_KNA1[].
  CLEAR: LS_KNA1.

  CLEAR: LT_VEND[].
  CLEAR: LS_VEND.

  CLEAR: LT_LFA1[].
  CLEAR: LS_LFA1.

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
           NAME1
      INTO CORRESPONDING FIELDS OF TABLE LT_LFA1
      FROM LFA1
       FOR ALL ENTRIES IN LT_VEND
     WHERE LIFNR = LT_VEND-LIFNR.
  ENDIF.

*----------------------------------------------------------------------*
* 고객 정보 SELECT
*----------------------------------------------------------------------*
  SORT LT_CUST BY KUNNR.
  DELETE ADJACENT DUPLICATES FROM LT_CUST COMPARING ALL FIELDS.

  IF ( LT_CUST[] IS NOT INITIAL ).
    SELECT KUNNR
           NAME1
      INTO CORRESPONDING FIELDS OF TABLE LT_KNA1
      FROM KNA1
       FOR ALL ENTRIES IN LT_CUST
     WHERE KUNNR = LT_CUST-KUNNR.
  ENDIF.

*----------------------------------------------------------------------*
* 거래처명 설정
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_INDEX = SY-TABIX.

    CASE GS_OUTTAB-KOART.
*     고객
      WHEN 'D'.
        GS_OUTTAB-PARTNER = GS_OUTTAB-KUNNR.

        CLEAR LS_KNA1.
        READ TABLE LT_KNA1 INTO LS_KNA1
                           WITH KEY KUNNR = GS_OUTTAB-KUNNR
                           BINARY SEARCH
                           TRANSPORTING NAME1.

        IF ( SY-SUBRC = 0 ).
          GS_OUTTAB-NAME_ORG1 = LS_KNA1-NAME1.
        ENDIF.
*     구매처
      WHEN 'K'.
        GS_OUTTAB-PARTNER = GS_OUTTAB-LIFNR.

        CLEAR LS_LFA1.
        READ TABLE LT_LFA1 INTO LS_LFA1
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

ENDFORM.
