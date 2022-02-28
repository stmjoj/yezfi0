*----------------------------------------------------------------------*
***INCLUDE LYEZFIF0050F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_PROC .

  CLEAR: GV_BUKRS.
  CLEAR: GV_BELNR.
  CLEAR: GV_GJAHR.

  CLEAR: GS_BKPF.
  CLEAR: GT_BSEG[].
  CLEAR: GS_BSEG.

  CLEAR: GV_RETURN.
  CLEAR: GV_MESSAGE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FI_DOCUMENT_HEADER_READ
*&---------------------------------------------------------------------*
*       전표 헤더 정보 READ
*----------------------------------------------------------------------*
FORM FI_DOCUMENT_HEADER_READ .

*----------------------------------------------------------------------*
* 전표 헤더 READ
*----------------------------------------------------------------------*
* BKPF READ
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF GS_BKPF
    FROM BKPF
   WHERE BUKRS = GV_BUKRS
     AND BELNR = GV_BELNR
     AND GJAHR = GV_GJAHR.

* READ 성공
  IF ( SY-SUBRC = 0 ).
*   전표상태 결정
    IF ( GS_BKPF-BSTAT = 'Z' ).              " 삭제
      GV_RETURN = 'E'.
      " 삭제된 전표번호입니다.
      GV_MESSAGE = TEXT-M01.
      EXIT.
    ELSEIF ( GS_BKPF-BSTAT = 'V' ).          " 임시
      GS_BKPF-STATV = ABAP_TRUE.
      GS_BKPF-STATP = SPACE.
      GS_BKPF-STATR = SPACE.
    ELSE.                                    " 전기
      IF ( GS_BKPF-XREVERSAL IS INITIAL ).   " 역분개 X
        GS_BKPF-STATV = SPACE.
        GS_BKPF-STATP = ABAP_TRUE.
        GS_BKPF-STATR = SPACE.
      ELSE.                                  " 역분개 O
        GS_BKPF-STATV = SPACE.
        GS_BKPF-STATP = SPACE.
        GS_BKPF-STATR = ABAP_TRUE.
      ENDIF.
    ENDIF.
  ELSE.
    GV_RETURN = 'E'.
*   MESSAGE : 전표 & &가(이) 회계연도 &에 없습니다.
    MESSAGE S397(F5A) WITH GV_BELNR GV_BUKRS GV_GJAHR INTO GV_MESSAGE.
    EXIT.
  ENDIF.

* 회사코드 정보 READ
  SELECT SINGLE
         BUTXT
         KTOPL
    INTO (GS_BKPF-BUTXT,
          GS_BKPF-KTOPL)
    FROM T001
   WHERE BUKRS = GV_BUKRS.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PARKING_DOCUMENT_READ
*&---------------------------------------------------------------------*
*       임시전표 정보 구성
*----------------------------------------------------------------------*
FORM PARKING_DOCUMENT_READ .

*----------------------------------------------------------------------*
* 지역변수 선언
*----------------------------------------------------------------------*
  DATA: LT_VBKPF   TYPE STANDARD TABLE OF FVBKPF.
  DATA: LT_VBSEC   TYPE STANDARD TABLE OF FVBSEC.
  DATA: LT_VBSEG   TYPE STANDARD TABLE OF FVBSEG.
  DATA: LT_VBSET   TYPE STANDARD TABLE OF FVBSET.

  DATA: LS_VBSEG   TYPE FVBSEG.
  DATA: LS_MWSKZ   TYPE YEZFIS0090.

  DATA: BEGIN OF LS_KRVAT,
          WMWST   TYPE FVBSEG-WMWST,      " 세액(전표 통화)
          MWSTS   TYPE FVBSEG-MWSTS,      " 세액(현지 통화)
          XNEGP   TYPE FVBSEG-XNEGP,      " 지시자: 마이너스 전기
          SGTXT   TYPE FVBSEG-SGTXT,      " 품목텍스트
          MWSKZ   TYPE FVBSEG-MWSKZ,      " 부가가치세 코드
          BUPLA   TYPE FVBSEG-BUPLA,      " 사업장
          SHKZG   TYPE FVBSEG-SHKZG,      " 차변/대변 지시자
        END OF LS_KRVAT.

  DATA: LV_COUNT   TYPE I.

*----------------------------------------------------------------------*
* 지역변수 초기화
*----------------------------------------------------------------------*
  CLEAR: LT_VBKPF[].
  CLEAR: LT_VBSEC[].
  CLEAR: LT_VBSEG[].
  CLEAR: LT_VBSET[].

  CLEAR: LS_VBSEG.
  CLEAR: LS_MWSKZ.
  CLEAR: LS_KRVAT.

  CLEAR: LV_COUNT.

*----------------------------------------------------------------------*
* 임시전표 READ
*----------------------------------------------------------------------*
  CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
    EXPORTING
      BELNR                   = GS_BKPF-BELNR
      BUKRS                   = GS_BKPF-BUKRS
      GJAHR                   = GS_BKPF-GJAHR
    TABLES
      T_VBKPF                 = LT_VBKPF[]
      T_VBSEC                 = LT_VBSEC[]
      T_VBSEG                 = LT_VBSEG[]
      T_VBSET                 = LT_VBSET[]
*     T_VACSPLT               =
*     T_VSPLTWT               =
    EXCEPTIONS
      DOCUMENT_LINE_NOT_FOUND = 1
      DOCUMENT_NOT_FOUND      = 2
      INPUT_INCOMPLETE        = 3
      OTHERS                  = 4.

*----------------------------------------------------------------------*
* 임시전표 개별항목 구성
*----------------------------------------------------------------------*
  IF ( SY-SUBRC = 0 ).
    LOOP AT LT_VBSEG INTO LS_VBSEG.
      MOVE-CORRESPONDING LS_VBSEG TO GS_BSEG.
      APPEND GS_BSEG TO GT_BSEG.
      CLEAR GS_BSEG.

*     세액 존재여부 확인
      IF ( LS_VBSEG-WMWST IS NOT INITIAL ).
*       세액이 입력된 고객 또는 구매처 개별항목 정보를 Move
        LS_KRVAT-WMWST = LS_VBSEG-WRBTR.      " 세액(전표 통화)
        LS_KRVAT-MWSTS = LS_VBSEG-DMBTR.      " 세액(현지 통화)
        LS_KRVAT-XNEGP = LS_VBSEG-XNEGP.      " 지시자: 마이너스 전기
        LS_KRVAT-SGTXT = LS_VBSEG-SGTXT.      " 품목텍스트
        LS_KRVAT-MWSKZ = LS_VBSEG-MWSKZ.      " 부가가치세 코드
        LS_KRVAT-BUPLA = LS_VBSEG-BUPLA.      " 사업장

        IF ( LS_VBSEG-SHKZG = 'S' ).
          LS_KRVAT-SHKZG = 'H'.                   " 차변/대변 지시자
        ELSE.
          LS_KRVAT-SHKZG = 'S'.                   " 차변/대변 지시자
        ENDIF.
      ENDIF.
    ENDLOOP.

    LV_COUNT = LINES( GT_BSEG[] ).
  ENDIF.

*----------------------------------------------------------------------*
* 임시전표 세금 개별항목 추가
*----------------------------------------------------------------------*
* 세액 > 0
  CHECK ( LS_KRVAT-MWSKZ IS NOT INITIAL ).

* 세금코드 정보 READ
  CALL FUNCTION 'Y_EZFI_TAX_SHOW_MWSKZ'
    EXPORTING
      I_BUKRS         = GS_BKPF-BUKRS
      I_MWSKZ         = LS_KRVAT-MWSKZ
      I_SHOW_INACTIVE = ' '
    IMPORTING
      ES_MWSKZ        = LS_MWSKZ.

* 매입세액 불공제
  IF ( LS_MWSKZ-KTOSL = 'NVV' ).
    LOOP AT LT_VBSEG INTO LS_VBSEG.
*     세금코드가 동일한 일반G/L계정 또는 고정자산 계정 대상
      CHECK ( LS_VBSEG-MWSKZ = LS_KRVAT-MWSKZ )
        AND ( ( LS_VBSEG-KOART = 'S' ) OR ( LS_VBSEG-KOART = 'A' ) ).


    ENDLOOP.
* 매입세액 공제
  ELSEIF ( LS_MWSKZ-KTOSL = 'VST' ).
    GS_BSEG-BUKRS = GS_BKPF-BUKRS.         " 회사 코드
    GS_BSEG-BELNR = GS_BKPF-BELNR.         " 회계 전표 번호
    GS_BSEG-GJAHR = GS_BKPF-GJAHR.         " 회계연도
    GS_BSEG-BUZEI = LV_COUNT + 1.          " 회계 전표의 개별 항목 번호
    GS_BSEG-BUZID = 'T'.                   " 개별 항목 ID
    GS_BSEG-HKONT = LS_MWSKZ-HKONT.        " 총계정원장계정

    GS_BSEG-WRBTR = LS_KRVAT-WMWST.        " 금액(전표 통화)
    GS_BSEG-DMBTR = LS_KRVAT-MWSTS.        " 금액(현지 통화)
    GS_BSEG-XNEGP = LS_KRVAT-XNEGP.        " 지시자: 마이너스 전기
    GS_BSEG-SGTXT = LS_KRVAT-SGTXT.        " 품목텍스트
    GS_BSEG-KOART = 'S'.                   " 계정 유형
    GS_BSEG-MWSKZ = LS_KRVAT-MWSKZ.        " 부가가치세 코드
    GS_BSEG-BUPLA = LS_KRVAT-BUPLA.        " 사업장
    GS_BSEG-SHKZG = LS_KRVAT-SHKZG.        " 차변/대변 지시자

    APPEND GS_BSEG TO GT_BSEG.
    CLEAR GS_BSEG.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  POSTING_DOCUMENT_ITEM_READ
*&---------------------------------------------------------------------*
*       전기전표 개별항목 정보 구성
*----------------------------------------------------------------------*
FORM POSTING_DOCUMENT_ITEM_READ .

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_BSEG
    FROM BSEG
   WHERE BUKRS = GS_BKPF-BUKRS
     AND BELNR = GS_BKPF-BELNR
     AND GJAHR = GS_BKPF-GJAHR.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LEDGER_DOCUMENT_ITEM_READ
*&---------------------------------------------------------------------*
*       원장전표 개별항목 정보 구성
*----------------------------------------------------------------------*
FORM LEDGER_DOCUMENT_ITEM_READ .

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_BSEG
    FROM BSEG_ADD
   WHERE BUKRS = GS_BKPF-BUKRS
     AND BELNR = GS_BKPF-BELNR
     AND GJAHR = GS_BKPF-GJAHR.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_DOCUMENT_INFO
*&---------------------------------------------------------------------*
*       전표 정보 구성
*----------------------------------------------------------------------*
FORM FILL_DOCUMENT_INFO .

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
  LOOP AT GT_BSEG INTO GS_BSEG.
    LS_SAKNR-SAKNR = GS_BSEG-HKONT.
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
       AND KTOPL = GS_BKPF-KTOPL
       AND SAKNR = LT_SAKNR-SAKNR.
  ENDIF.

*----------------------------------------------------------------------*
* G/L계정명 반영
*----------------------------------------------------------------------*
  SORT LT_SKAT BY SAKNR.

  LOOP AT GT_BSEG INTO GS_BSEG.
    LV_INDEX = SY-TABIX.

    CLEAR LS_SKAT.
    READ TABLE LT_SKAT INTO LS_SKAT
                       WITH KEY SAKNR = GS_BSEG-HKONT
                       BINARY SEARCH
                       TRANSPORTING TXT50.

    IF ( SY-SUBRC = 0 ).
      GS_BSEG-HKONT_TXT = LS_SKAT-TXT50.
      MODIFY GT_BSEG FROM GS_BSEG INDEX LV_INDEX
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
  LOOP AT GT_BSEG INTO GS_BSEG.
    LV_INDEX = SY-TABIX.

*   통화키
    GS_BSEG-WAERS = GS_BKPF-WAERS.
    GS_BSEG-HWAER = GS_BKPF-HWAER.

*   차변
    IF ( GS_BSEG-SHKZG = 'S' ).
      IF ( GS_BSEG-XNEGP IS INITIAL ).                " 정상 전기 - 차변의 +
        GS_BSEG-DEBIT   = ABAP_TRUE.
        GS_BSEG-CREDIT  = ABAP_FALSE.
        GS_BSEG-WRBTR_S = GS_BSEG-WRBTR.
        GS_BSEG-WRBTR_H = 0.
        GS_BSEG-DMBTR_S = GS_BSEG-DMBTR.
        GS_BSEG-DMBTR_H = 0.
      ELSE.                                           " 마이너스 전기 - 대변의 -
        GS_BSEG-DEBIT   = ABAP_FALSE.
        GS_BSEG-CREDIT  = ABAP_TRUE.
        GS_BSEG-WRBTR   = GS_BSEG-WRBTR * ( -1 ).
        GS_BSEG-DMBTR   = GS_BSEG-DMBTR * ( -1 ).
        GS_BSEG-WRBTR_S = 0.
        GS_BSEG-WRBTR_H = GS_BSEG-WRBTR.
        GS_BSEG-DMBTR_S = 0.
        GS_BSEG-DMBTR_H = GS_BSEG-DMBTR.
      ENDIF.
*   대변
    ELSE.
      IF ( GS_BSEG-XNEGP IS INITIAL ).                " 정상 전기 - 대변의 +
        GS_BSEG-DEBIT   = ABAP_FALSE.
        GS_BSEG-CREDIT  = ABAP_TRUE.
        GS_BSEG-WRBTR_S = 0.
        GS_BSEG-WRBTR_H = GS_BSEG-WRBTR.
        GS_BSEG-DMBTR_S = 0.
        GS_BSEG-DMBTR_H = GS_BSEG-DMBTR.
      ELSE.                                           " 마이너스 전기 - 차변의 -
        GS_BSEG-DEBIT   = ABAP_TRUE.
        GS_BSEG-CREDIT  = ABAP_FALSE.
        GS_BSEG-WRBTR   = GS_BSEG-WRBTR * ( -1 ).
        GS_BSEG-DMBTR   = GS_BSEG-DMBTR * ( -1 ).
        GS_BSEG-WRBTR_S = GS_BSEG-WRBTR.
        GS_BSEG-WRBTR_H = 0.
        GS_BSEG-DMBTR_S = GS_BSEG-DMBTR.
        GS_BSEG-DMBTR_H = 0.
      ENDIF.
    ENDIF.

*   대변금액인 경우 잔액 '-' 표시
    GS_BSEG-WRBTR_J = GS_BSEG-WRBTR_S - GS_BSEG-WRBTR_H.
    GS_BSEG-DMBTR_J = GS_BSEG-DMBTR_S - GS_BSEG-DMBTR_H.

    MODIFY GT_BSEG FROM GS_BSEG INDEX LV_INDEX
                   TRANSPORTING WAERS
                                HWAER
                                DEBIT
                                CREDIT
                                WRBTR_S
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
  LOOP AT GT_BSEG INTO GS_BSEG.
    CASE GS_BSEG-KOART.
*     고객
      WHEN 'D'.
        LS_CUST-KUNNR = GS_BSEG-KUNNR.
        APPEND LS_CUST TO LT_CUST.
        CLEAR LS_CUST.
*     구매처
      WHEN 'K'.
        LS_VEND-LIFNR = GS_BSEG-LIFNR.
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
  LOOP AT GT_BSEG INTO GS_BSEG.
    LV_INDEX = SY-TABIX.

    CASE GS_BSEG-KOART.
*     고객
      WHEN 'D'.
        GS_BSEG-PARTNER = GS_BSEG-KUNNR.

        CLEAR LS_KNA1.
        READ TABLE LT_KNA1 INTO LS_KNA1
                           WITH KEY KUNNR = GS_BSEG-KUNNR
                           BINARY SEARCH
                           TRANSPORTING NAME1.

        IF ( SY-SUBRC = 0 ).
          GS_BSEG-NAME_ORG1 = LS_KNA1-NAME1.
        ENDIF.
*     구매처
      WHEN 'K'.
        GS_BSEG-PARTNER = GS_BSEG-LIFNR.

        CLEAR LS_LFA1.
        READ TABLE LT_LFA1 INTO LS_LFA1
                           WITH KEY LIFNR = GS_BSEG-LIFNR
                           BINARY SEARCH
                           TRANSPORTING NAME1.

        IF ( SY-SUBRC = 0 ).
          GS_BSEG-NAME_ORG1 = LS_LFA1-NAME1.
        ENDIF.
    ENDCASE.

    MODIFY GT_BSEG FROM GS_BSEG INDEX LV_INDEX
                   TRANSPORTING PARTNER
                                NAME_ORG1.
  ENDLOOP.

*----------------------------------------------------------------------*
* 순만기일 결정
*----------------------------------------------------------------------*
  LOOP AT GT_BSEG INTO GS_BSEG.
    LV_INDEX = SY-TABIX.

    CHECK ( GS_BSEG-KOART = 'D' ) OR
          ( GS_BSEG-KOART = 'K' ).

    CALL FUNCTION 'NET_DUE_DATE_GET'
      EXPORTING
        I_ZFBDT = GS_BSEG-ZFBDT
        I_ZBD1T = GS_BSEG-ZBD1T
        I_ZBD2T = GS_BSEG-ZBD2T
        I_ZBD3T = GS_BSEG-ZBD3T
        I_SHKZG = GS_BSEG-SHKZG
        I_REBZG = GS_BSEG-REBZG
        I_KOART = GS_BSEG-KOART
      IMPORTING
        E_FAEDT = GS_BSEG-FAEDT.

    MODIFY GT_BSEG FROM GS_BSEG INDEX LV_INDEX
                   TRANSPORTING FAEDT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_REQUIRED_FIELD
*&---------------------------------------------------------------------*
*       필수필드 점검
*----------------------------------------------------------------------*
FORM CHECK_REQUIRED_FIELD .

* 회사코드 점검
  IF ( GV_BUKRS IS INITIAL ).
    GV_RETURN  = 'E'.
    GV_MESSAGE = TEXT-M02.         " 회사코드를 입력하십시오.
    EXIT.
  ENDIF.

* 전표번호 점검
  IF ( GV_BELNR IS INITIAL ).
    GV_RETURN = 'E'.
*   MESSAGE : 전표 번호를 입력하십시오.
    MESSAGE S279(F5) INTO GV_MESSAGE.
    EXIT.
  ENDIF.

* 회계연도 점검
  IF ( GV_GJAHR IS INITIAL ).
    GV_RETURN  = 'E'.
    GV_MESSAGE = TEXT-M03.         " 회계연도를 입력하십시오.
    EXIT.
  ENDIF.

ENDFORM.
