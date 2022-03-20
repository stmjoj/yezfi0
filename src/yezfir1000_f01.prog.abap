*&---------------------------------------------------------------------*
*&  Include           YEZFIR1000_F01
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
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_PROC .

*----------------------------------------------------------------------*
* 광역변수 초기화
*----------------------------------------------------------------------*
  CLEAR: YEZFIS0190.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_BUKRS.

  CLEAR: GT_R_BSTAT[].

  CLEAR: GT_PARK[].
  CLEAR: GT_POST[].
  CLEAR: GT_ALL[].

  CLEAR: GT_DDTEXT[].

  CLEAR: GT_EXCLUDE[].

* TAB STRIP
  CLEAR: TAB_0100.
  CLEAR: GV_DYNNR.

* 110 번 화면 ALV 변수
  CLEAR: GO_CUST_0110.
  CLEAR: GO_GRID_0110.
  .
  CLEAR: GT_FCAT_0110.
  CLEAR: GS_FCAT_0110.
  CLEAR: GT_SORT_0110.

  CLEAR: GS_LAYO_0110.
  CLEAR: GS_VARI_0110.

  CLEAR: GO_EVNT_0110.

* 120 번 화면 ALV 변수
  CLEAR: GO_CUST_0120.
  CLEAR: GO_GRID_0120.
  .
  CLEAR: GT_FCAT_0120.
  CLEAR: GS_FCAT_0120.
  CLEAR: GT_SORT_0120.

  CLEAR: GS_LAYO_0120.
  CLEAR: GS_VARI_0120.

  CLEAR: GO_EVNT_0120.

* 130 번 화면 ALV 변수
  CLEAR: GO_CUST_0130.
  CLEAR: GO_GRID_0130.
  .
  CLEAR: GT_FCAT_0130.
  CLEAR: GS_FCAT_0130.
  CLEAR: GT_SORT_0130.

  CLEAR: GS_LAYO_0130.
  CLEAR: GS_VARI_0130.

  CLEAR: GO_EVNT_0130.

*----------------------------------------------------------------------*
* 초기값 설정
*----------------------------------------------------------------------*
  PERFORM GET_COMPANY_INFO.           " 회사코드 정보 설정

*----------------------------------------------------------------------*
* Domain Value 텍스트 구성
*----------------------------------------------------------------------*
  PERFORM GET_DOMAIN_VALUE_TEXT TABLES GT_DDTEXT
                                USING 'YEZ_XSTAT'.

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

*----------------------------------------------------------------------*
* 화면 헤더 구성
*----------------------------------------------------------------------*
  YEZFIS0190-BUKRS      = P_BUKRS.
  YEZFIS0190-BUTXT      = P_BUTXT.
  YEZFIS0190-BUDAT_FROM = S_BUDAT-LOW.
  YEZFIS0190-BUDAT_TO   = S_BUDAT-HIGH.

*----------------------------------------------------------------------*
* Default 탭 선택
*----------------------------------------------------------------------*
  CASE ABAP_TRUE.
    WHEN P_RBPARK.
      PERFORM SET_ACTIVE_TAB_0100 USING 'TAB100_2'.
    WHEN P_RBPOST.
      PERFORM SET_ACTIVE_TAB_0100 USING 'TAB100_3'.
    WHEN P_RBALL.
      PERFORM SET_ACTIVE_TAB_0100 USING 'TAB100_1'.
  ENDCASE.

*----------------------------------------------------------------------*
* 화면 호출
*----------------------------------------------------------------------*
  CALL SCREEN 0100.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_OUTTAB_PROC
*&---------------------------------------------------------------------*
*       자료 선택 및 구성
*----------------------------------------------------------------------*
FORM MAKE_OUTTAB_PROC .

*----------------------------------------------------------------------*
* 임시전표 SELECT
*----------------------------------------------------------------------*
  PERFORM SELECT_PARK_DOC.

*----------------------------------------------------------------------*
* 전기전표 SELECT
*----------------------------------------------------------------------*
  PERFORM SELECT_POST_DOC.

*----------------------------------------------------------------------*
* 전체전표 구성
*----------------------------------------------------------------------*
  LOOP AT GT_PARK INTO DATA(LS_PARK).
    APPEND LS_PARK TO GT_ALL.
    CLEAR LS_PARK.
  ENDLOOP.

  LOOP AT GT_POST INTO DATA(LS_POST).
    APPEND LS_POST TO GT_ALL.
    CLEAR LS_POST.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_PARK_DOC
*&---------------------------------------------------------------------*
*       임시전표 추출
*----------------------------------------------------------------------*
FORM SELECT_PARK_DOC .

* 임시전표 상태 RANGE 구성
  CLEAR: GT_R_BSTAT[].

  PERFORM MAKE_RANGE_BSTAT USING 'V'.       " 임시전표

* 전표 헤더 테이블 SELECT
  PERFORM SELECT_DOCUMENT_HEADER TABLES GT_PARK.

* 결재진행상태 텍스트 결정
  PERFORM GET_XSTAT_TEXT TABLES GT_PARK.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_POST_DOC
*&---------------------------------------------------------------------*
*       전기전표 추출
*----------------------------------------------------------------------*
FORM SELECT_POST_DOC .

* 임시전표 상태 RANGE 구성
  CLEAR: GT_R_BSTAT[].

  PERFORM MAKE_RANGE_BSTAT USING: ' ',       " 정규전표
                                  'A',       " 반제 전표
                                  'B',       " 반제취소
                                  'L'.       " 주요 원장 이외의 전기

* 전표 헤더 테이블 SELECT
  PERFORM SELECT_DOCUMENT_HEADER TABLES GT_POST.

* 결재진행상태 텍스트 결정
  PERFORM GET_XSTAT_TEXT TABLES GT_POST.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ACTIVE_TAB_0100
*&---------------------------------------------------------------------*
*       100번 화면 TAB 선택
*----------------------------------------------------------------------*
FORM SET_ACTIVE_TAB_0100 USING PV_ACTIVETAB.

  TAB_0100-ACTIVETAB = PV_ACTIVETAB.

  CASE PV_ACTIVETAB.
    WHEN 'TAB100_1'.
      GV_DYNNR = '0110'.
    WHEN 'TAB100_2'.
      GV_DYNNR = '0120'.
    WHEN 'TAB100_3'.
      GV_DYNNR = '0130'.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_GROUP_SLIP_NO
*&---------------------------------------------------------------------*
*       그룹전표 생성
*----------------------------------------------------------------------*
FORM CREATE_GROUP_SLIP_NO .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_ANSWER    TYPE C.
  DATA: LV_ERROR     TYPE YEZ_ERROR_YN.
  DATA: LV_MESSAGE   TYPE NATXT.

  DATA: BEGIN OF LS_BELNR,
          BUKRS TYPE BKPF-BUKRS,
          BELNR TYPE BKPF-BELNR,
          GJAHR TYPE BKPF-GJAHR,
        END OF LS_BELNR.

  DATA: LT_BELNR   LIKE STANDARD TABLE OF LS_BELNR.

  DATA: LS_YEZFIT0030   TYPE YEZFIT0030.
  DATA: LS_YEZFIT0040   TYPE YEZFIT0040.

  CLEAR: LV_ANSWER.
  CLEAR: LV_ERROR.
  CLEAR: LV_MESSAGE.

  CLEAR: LT_BELNR[].
  CLEAR: LS_BELNR.

  CLEAR: LS_YEZFIT0030.
  CLEAR: LS_YEZFIT0040.

*----------------------------------------------------------------------*
* 선택 여부 점검
*----------------------------------------------------------------------*
* 선택 건 중 그룹전표 미생성건만 추출
  LOOP AT GT_PARK INTO DATA(LS_PARK) WHERE SELYN = ABAP_TRUE
                                       AND GRP_SLIP_NO IS INITIAL.
    LS_BELNR-BUKRS = LS_PARK-BUKRS.
    LS_BELNR-BELNR = LS_PARK-BELNR.
    LS_BELNR-GJAHR = LS_PARK-GJAHR.

    APPEND LS_BELNR TO LT_BELNR.
    CLEAR LS_BELNR.
  ENDLOOP.

* 대상 전표가 존재하지 않는 경우
  IF ( LT_BELNR[] IS INITIAL ).
    MESSAGE E017(YEZFIM).                   " 처리대상 자료를 선택하세요.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 사용자 CONFIRM
*----------------------------------------------------------------------*
  PERFORM CONFIRM_POPUP IN PROGRAM YEZFIS0000
                        USING TEXT-001      " 알림
                              TEXT-002      " 선택된 전표에 대해서 그룹전표를 생성하시겠습니까?
                              '1'           " 예
                        CHANGING LV_ANSWER.

  CHECK ( LV_ANSWER = '1' ).

*----------------------------------------------------------------------*
* ENQUEUE FI DOCUMENT FOR UPDATE
*----------------------------------------------------------------------*
  LOOP AT LT_BELNR INTO LS_BELNR.
    PERFORM ENQUEUE_FIDOC_FOR_UPDATE USING    LS_BELNR-BUKRS
                                              LS_BELNR-BELNR
                                              LS_BELNR-GJAHR
                                     CHANGING LV_ERROR
                                              LV_MESSAGE.

    IF ( LV_ERROR = ABAP_TRUE ).
      EXIT.
    ENDIF.
  ENDLOOP.

  IF ( LV_ERROR = ABAP_TRUE ).
    CALL FUNCTION 'DEQUEUE_ALL'.
    MESSAGE E001(YEZFIM)  WITH LV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 전표번호별 그룹전표번호 생성
*----------------------------------------------------------------------*
  LOOP AT LT_BELNR INTO LS_BELNR.
    LS_YEZFIT0030-BUKRS       = LS_BELNR-BUKRS.
    LS_YEZFIT0030-BELNR       = LS_BELNR-BELNR.
    LS_YEZFIT0030-GJAHR       = LS_BELNR-GJAHR.
    LS_YEZFIT0030-GRP_SLIP_NO = '0000000000001'.

    MODIFY YEZFIT0030 FROM LS_YEZFIT0030.

    IF ( SY-SUBRC <> 0 ).
      LV_ERROR   = ABAP_TRUE.
      LV_MESSAGE = TEXT-E03.    " 그룹전표번호 생성 시 오류가 발생하였습니다. (&1)
      REPLACE '&1' IN LV_MESSAGE WITH 'YEZFIT0030'.
      EXIT.
    ENDIF.

    CLEAR: LS_YEZFIT0030.
  ENDLOOP.

  IF ( LV_ERROR = ABAP_TRUE ).
    ROLLBACK WORK.
    CALL FUNCTION 'DEQUEUE_ALL'.
    MESSAGE E001(YEZFIM)  WITH LV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 전표번호별 결재진행상태 생성
*----------------------------------------------------------------------*
  LOOP AT LT_BELNR INTO LS_BELNR.
    LS_YEZFIT0040-BUKRS = LS_BELNR-BUKRS.
    LS_YEZFIT0040-BELNR = LS_BELNR-BELNR.
    LS_YEZFIT0040-GJAHR = LS_BELNR-GJAHR.
    LS_YEZFIT0040-XSTAT = '0'.             " 미상신

    MODIFY YEZFIT0040 FROM LS_YEZFIT0040.

    IF ( SY-SUBRC <> 0 ).
      LV_ERROR   = ABAP_TRUE.
      LV_MESSAGE = TEXT-E03.    " 그룹전표번호 생성 시 오류가 발생하였습니다. (&1)
      REPLACE '&1' IN LV_MESSAGE WITH 'YEZFIT0030'.
      EXIT.
    ENDIF.

    CLEAR: LS_YEZFIT0040.
  ENDLOOP.

  IF ( LV_ERROR = ABAP_TRUE ).
    ROLLBACK WORK.
    CALL FUNCTION 'DEQUEUE_ALL'.
    MESSAGE E001(YEZFIM)  WITH LV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 성공 메시지 출력
*----------------------------------------------------------------------*
  CALL FUNCTION 'DEQUEUE_ALL'.

  MESSAGE S000(YEZFIM) WITH TEXT-S01.   " 그룹전표를 생성하였습니다.

*----------------------------------------------------------------------*
* 처리결과 반영
*----------------------------------------------------------------------*
  SORT GT_DDTEXT BY DOMNAME DOMVALUE_L.

  LOOP AT GT_PARK INTO LS_PARK WHERE SELYN = ABAP_TRUE
                                 AND GRP_SLIP_NO IS INITIAL.
    DATA(LV_INDEX) = SY-TABIX.

    LS_PARK-XSTAT = '0'.

    READ TABLE GT_DDTEXT INTO DATA(LS_DDTEXT)
                         WITH KEY DOMNAME    = 'YEZ_XSTAT'
                                  DOMVALUE_L = LS_PARK-XSTAT
                         BINARY SEARCH.

    IF ( SY-SUBRC = 0 ).
      LS_PARK-STATU = LS_DDTEXT-DDTEXT.
    ELSE.
      LS_PARK-STATU = SPACE.
    ENDIF.

    LS_PARK-GRP_SLIP_NO = '0000000000001'.

    MODIFY GT_PARK FROM LS_PARK INDEX LV_INDEX
                   TRANSPORTING XSTAT STATU GRP_SLIP_NO.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DELETE_GROUP_SLIP_NO
*&---------------------------------------------------------------------*
*       그룹전표 삭제
*----------------------------------------------------------------------*
FORM DELETE_GROUP_SLIP_NO .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_ANSWER    TYPE C.
  DATA: LV_ERROR     TYPE YEZ_ERROR_YN.
  DATA: LV_MESSAGE   TYPE NATXT.

  DATA: BEGIN OF LS_BELNR,
          BUKRS TYPE BKPF-BUKRS,
          BELNR TYPE BKPF-BELNR,
          GJAHR TYPE BKPF-GJAHR,
        END OF LS_BELNR.

  DATA: LT_BELNR   LIKE STANDARD TABLE OF LS_BELNR.

  DATA: LS_YEZFIT0030   TYPE YEZFIT0030.
  DATA: LS_YEZFIT0040   TYPE YEZFIT0040.

  CLEAR: LV_ANSWER.
  CLEAR: LV_ERROR.
  CLEAR: LV_MESSAGE.

  CLEAR: LT_BELNR[].
  CLEAR: LS_BELNR.

  CLEAR: LS_YEZFIT0030.
  CLEAR: LS_YEZFIT0040.

*----------------------------------------------------------------------*
* 선택 여부 점검
*----------------------------------------------------------------------*
* 선택 건 중 그룹전표 미생성건만 추출
  LOOP AT GT_PARK INTO DATA(LS_PARK) WHERE SELYN = ABAP_TRUE
                                       AND GRP_SLIP_NO IS NOT INITIAL.
    LS_BELNR-BUKRS = LS_PARK-BUKRS.
    LS_BELNR-BELNR = LS_PARK-BELNR.
    LS_BELNR-GJAHR = LS_PARK-GJAHR.

    APPEND LS_BELNR TO LT_BELNR.
    CLEAR LS_BELNR.
  ENDLOOP.

* 대상 전표가 존재하지 않는 경우
  IF ( LT_BELNR[] IS INITIAL ).
    MESSAGE E017(YEZFIM).                   " 처리대상 자료를 선택하세요.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 사용자 CONFIRM
*----------------------------------------------------------------------*
  PERFORM CONFIRM_POPUP IN PROGRAM YEZFIS0000
                        USING TEXT-001      " 알림
                              TEXT-003      " 선택된 전표에 대해서 그룹전표를 삭제하시겠습니까?
                              '2'           " 아니오
                        CHANGING LV_ANSWER.

  CHECK ( LV_ANSWER = '1' ).

*----------------------------------------------------------------------*
* ENQUEUE FI DOCUMENT FOR UPDATE
*----------------------------------------------------------------------*
  LOOP AT LT_BELNR INTO LS_BELNR.
    PERFORM ENQUEUE_FIDOC_FOR_UPDATE USING    LS_BELNR-BUKRS
                                              LS_BELNR-BELNR
                                              LS_BELNR-GJAHR
                                     CHANGING LV_ERROR
                                              LV_MESSAGE.

    IF ( LV_ERROR = ABAP_TRUE ).
      EXIT.
    ENDIF.
  ENDLOOP.

  IF ( LV_ERROR = ABAP_TRUE ).
    CALL FUNCTION 'DEQUEUE_ALL'.
    MESSAGE E001(YEZFIM)  WITH LV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 전표번호별 그룹전표번호 삭제
*----------------------------------------------------------------------*
  LOOP AT LT_BELNR INTO LS_BELNR.
    LS_YEZFIT0030-BUKRS       = LS_BELNR-BUKRS.
    LS_YEZFIT0030-BELNR       = LS_BELNR-BELNR.
    LS_YEZFIT0030-GJAHR       = LS_BELNR-GJAHR.
    LS_YEZFIT0030-GRP_SLIP_NO = SPACE.

    MODIFY YEZFIT0030 FROM LS_YEZFIT0030.

    IF ( SY-SUBRC <> 0 ).
      LV_ERROR   = ABAP_TRUE.
      LV_MESSAGE = TEXT-E04.    " 그룹전표번호 삭제 시 오류가 발생하였습니다. (&1)
      REPLACE '&1' IN LV_MESSAGE WITH 'YEZFIT0030'.
      EXIT.
    ENDIF.

    CLEAR: LS_YEZFIT0030.
  ENDLOOP.

  IF ( LV_ERROR = ABAP_TRUE ).
    ROLLBACK WORK.
    CALL FUNCTION 'DEQUEUE_ALL'.
    MESSAGE E001(YEZFIM)  WITH LV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 전표번호별 결재진행상태 생성
*----------------------------------------------------------------------*
  LOOP AT LT_BELNR INTO LS_BELNR.
    LS_YEZFIT0040-BUKRS = LS_BELNR-BUKRS.
    LS_YEZFIT0040-BELNR = LS_BELNR-BELNR.
    LS_YEZFIT0040-GJAHR = LS_BELNR-GJAHR.
    LS_YEZFIT0040-XSTAT = '0'.             " 미상신

    MODIFY YEZFIT0040 FROM LS_YEZFIT0040.

    IF ( SY-SUBRC <> 0 ).
      LV_ERROR   = ABAP_TRUE.
      LV_MESSAGE = TEXT-E04.    " 그룹전표번호 삭제 시 오류가 발생하였습니다. (&1)
      REPLACE '&1' IN LV_MESSAGE WITH 'YEZFIT0040'.
      EXIT.
    ENDIF.

    CLEAR: LS_YEZFIT0040.
  ENDLOOP.

  IF ( LV_ERROR = ABAP_TRUE ).
    ROLLBACK WORK.
    CALL FUNCTION 'DEQUEUE_ALL'.
    MESSAGE E001(YEZFIM)  WITH LV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 전표번호별 결재진행상태 생성
*----------------------------------------------------------------------*
  CALL FUNCTION 'DEQUEUE_ALL'.

  MESSAGE S000(YEZFIM) WITH TEXT-S02.   " 그룹전표를 삭제하였습니다.

*----------------------------------------------------------------------*
* 처리결과 반영
*----------------------------------------------------------------------*
  SORT GT_DDTEXT BY DOMNAME DOMVALUE_L.

  LOOP AT GT_PARK INTO LS_PARK WHERE SELYN = ABAP_TRUE
                                 AND GRP_SLIP_NO IS INITIAL.
    DATA(LV_INDEX) = SY-TABIX.

    LS_PARK-XSTAT = '0'.

    READ TABLE GT_DDTEXT INTO DATA(LS_DDTEXT)
                         WITH KEY DOMNAME    = 'YEZ_XSTAT'
                                  DOMVALUE_L = LS_PARK-XSTAT
                         BINARY SEARCH.

    IF ( SY-SUBRC = 0 ).
      LS_PARK-STATU = LS_DDTEXT-DDTEXT.
    ELSE.
      LS_PARK-STATU = SPACE.
    ENDIF.

    LS_PARK-GRP_SLIP_NO = SPACE.

    MODIFY GT_PARK FROM LS_PARK INDEX LV_INDEX
                   TRANSPORTING XSTAT STATU GRP_SLIP_NO.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DOMAIN_VALUE_TEXT
*&---------------------------------------------------------------------*
*       Domain Value 텍스트 구성
*----------------------------------------------------------------------*
FORM GET_DOMAIN_VALUE_TEXT  TABLES   PT_DDTEXT STRUCTURE DD07T
                            USING    PV_DOMNAME.

  SELECT *
    FROM DD07T
   WHERE DOMNAME    = @PV_DOMNAME
     AND DDLANGUAGE = @SY-LANGU
     AND AS4LOCAL   = 'A'
    INTO TABLE @DATA(LT_DD07T).

  IF ( LT_DD07T[] IS NOT INITIAL ).
    LOOP AT LT_DD07T INTO DATA(LS_DD07T).
      APPEND LS_DD07T TO PT_DDTEXT.
      CLEAR LS_DD07T.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_XSTAT_TEXT
*&---------------------------------------------------------------------*
*       결재진행상태 텍스트 결정
*----------------------------------------------------------------------*
FORM GET_XSTAT_TEXT  TABLES   PT_TABLE STRUCTURE YEZFIS0200.

  SORT GT_DDTEXT BY DOMNAME DOMVALUE_L.

  LOOP AT PT_TABLE INTO DATA(LS_WA).
    DATA(LV_INDEX) = SY-TABIX.

    IF ( LS_WA-XSTAT IS INITIAL ).
      LS_WA-XSTAT = '0'.
    ENDIF.

    READ TABLE GT_DDTEXT INTO DATA(LS_DDTEXT)
                         WITH KEY DOMNAME    = 'YEZ_XSTAT'
                                  DOMVALUE_L = LS_WA-XSTAT
                         BINARY SEARCH.

    IF ( SY-SUBRC = 0 ).
      LS_WA-STATU = LS_DDTEXT-DDTEXT.
    ENDIF.

    MODIFY PT_TABLE FROM LS_WA INDEX LV_INDEX
                    TRANSPORTING XSTAT STATU.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_DOCUMENT_HEADER
*&---------------------------------------------------------------------*
*       전표 헤더 SELECT
*----------------------------------------------------------------------*
FORM SELECT_DOCUMENT_HEADER  TABLES   PT_TABLE STRUCTURE YEZFIS0200.

*PPNAM
*PPDAT
*PPTME

  SELECT C~XSTAT       AS XSTAT
       , A~BUKRS       AS BUKRS
       , A~BELNR       AS BELNR
       , A~GJAHR       AS GJAHR
       , A~MONAT       AS MONAT
       , B~GRP_SLIP_NO AS GRP_SLIP_NO
       , A~BLART       AS BLART
       , D~LTEXT       AS LTEXT
       , A~BLDAT       AS BLDAT
       , A~BUDAT       AS BUDAT
       , A~XBLNR       AS XBLNR
       , A~LDGRP       AS LDGRP
       , A~BKTXT       AS BKTXT
       , A~BSTAT       AS BSTAT
       , A~STBLG       AS STBLG
       , A~STJAH       AS STJAH
       , A~XREVERSAL   AS XREVERSAL
       , A~XREF1_HD    AS XREF1_HD
       , A~XREF2_HD    AS XREF2_HD
       , A~WAERS       AS WAERS
       , A~CPUDT       AS CPUDT
       , A~CPUTM       AS CPUTM
       , A~USNAM       AS USNAM
       , @SPACE        AS SELYN
    FROM BKPF AS A LEFT OUTER JOIN YEZFIT0030 AS B  ON B~BUKRS = A~BUKRS
                                                   AND B~BELNR = A~BELNR
                                                   AND B~GJAHR = A~GJAHR
                   LEFT OUTER JOIN YEZFIT0040 AS C  ON C~BUKRS = A~BUKRS
                                                   AND C~BELNR = A~BELNR
                                                   AND C~GJAHR = A~GJAHR
                   LEFT OUTER JOIN T003T      AS D  ON D~SPRAS = @SY-LANGU
                                                   AND D~BLART = A~BLART
   WHERE A~BUKRS =  @P_BUKRS
     AND A~BLART    IN @S_BLART
     AND A~BUDAT    IN @S_BUDAT
     AND A~BLDAT    IN @S_BLDAT
     AND A~GJAHR    IN @S_GJAHR
     AND A~BELNR    IN @S_BELNR
     AND A~XBLNR    IN @S_XBLNR
     AND A~XREF1_HD IN @S_XREF1H
     AND A~XREF2_HD IN @S_XREF2H
     AND A~CPUDT    IN @S_CPUDT
     AND A~USNAM    IN @S_USNAM
     AND A~BSTAT    IN @GT_R_BSTAT
    INTO CORRESPONDING FIELDS OF TABLE @PT_TABLE.

* 역분개 포함이 선택되지 않은 경우 역분개 전표 삭제
  IF ( P_REV IS INITIAL ).
    DELETE PT_TABLE WHERE STBLG IS NOT INITIAL.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_RANGE_BSTAT
*&---------------------------------------------------------------------*
*       전표상태 RANGE 구성
*----------------------------------------------------------------------*
FORM MAKE_RANGE_BSTAT  USING    PV_BSTAT.

  DATA: LS_R_BSTAT   LIKE LINE OF GT_R_BSTAT.

  CLEAR: LS_R_BSTAT.

  LS_R_BSTAT-SIGN   = 'I'.
  LS_R_BSTAT-OPTION = 'EQ'.
  LS_R_BSTAT-LOW    = PV_BSTAT.

  APPEND LS_R_BSTAT TO GT_R_BSTAT.
  CLEAR: LS_R_BSTAT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  APPEND_MENU
*&---------------------------------------------------------------------*
*       MENU 에서 제외 대상 명령어 추가
*----------------------------------------------------------------------*
FORM APPEND_MENU  USING    VALUE(PV_UCOMM).

  DATA: LS_EXCLUDE   TYPE TY_S_EXCLUDE.

  CLEAR: LS_EXCLUDE.

  LS_EXCLUDE-UCOMM = PV_UCOMM.
  APPEND LS_EXCLUDE TO GT_EXCLUDE.
  CLEAR: LS_EXCLUDE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_FIDOC_FOR_UPDATE
*&---------------------------------------------------------------------*
*       FI 전표 처리를 위한 LOCK 설정
*----------------------------------------------------------------------*
FORM ENQUEUE_FIDOC_FOR_UPDATE  USING    PV_BUKRS
                                        PV_BELNR
                                        PV_GJAHR
                               CHANGING PV_ERROR
                                        PV_MESSAGE.

  DATA: LV_USER   TYPE XUBNAME.

  CLEAR: LV_USER.

  CALL FUNCTION 'ENQUEUE_EFBKPF'
    EXPORTING
      MODE_BKPF      = 'E'
      MANDT          = SY-MANDT
      BUKRS          = PV_BUKRS
      BELNR          = PV_BELNR
      GJAHR          = PV_GJAHR
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF ( SY-SUBRC <> 0 ).
    PV_ERROR = ABAP_TRUE.

    CASE SY-SUBRC.
      WHEN 1.
        LV_USER = SY-MSGV1.
        PV_MESSAGE = TEXT-E01.    " 전표 &1 &2을(를) 사용자 &3이(가) 보류하여 처리할 수 없습니다.
        REPLACE '&1' IN PV_MESSAGE WITH PV_BELNR.
        REPLACE '&2' IN PV_MESSAGE WITH PV_GJAHR.
        REPLACE '&2' IN PV_MESSAGE WITH LV_USER.
      WHEN 2 OR 3.
        PV_MESSAGE = TEXT-E02.    " 전표 &1 &2에 대한 잠금설정 오류로 인하여 처리할 수 없습니다.
        REPLACE '&1' IN PV_MESSAGE WITH PV_BELNR.
        REPLACE '&2' IN PV_MESSAGE WITH PV_GJAHR.
    ENDCASE.
  ENDIF.

ENDFORM.
