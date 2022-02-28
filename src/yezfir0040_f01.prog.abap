*&---------------------------------------------------------------------*
*&  Include           YEZFIR0040_F01
*&---------------------------------------------------------------------*
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
*&      Form  DISPLAY_DOCUMENT_DETAIL
*&---------------------------------------------------------------------*
*       전표 상세내역 조회
*----------------------------------------------------------------------*
FORM DISPLAY_DOCUMENT_DETAIL .

* 전표정보 메모리 세팅
  SET PARAMETER ID 'BUK' FIELD YEZFIS0060-BUKRS.
  SET PARAMETER ID 'BLN' FIELD YEZFIS0060-BELNR.
  SET PARAMETER ID 'GJR' FIELD YEZFIS0060-GJAHR.

* 200번 화면 호출
  GV_BUZEI = '001'.

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

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LS_BKPF      TYPE YEZFISBKPF.
  DATA: LT_BSEG      TYPE STANDARD TABLE OF YEZFISBSEG.
  DATA: LS_BSEG      TYPE YEZFISBSEG.

  DATA: LV_RETURN    TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE   TYPE BAPI_MSG.

  CLEAR: LS_BKPF.
  CLEAR: LT_BSEG[].
  CLEAR: LS_BSEG.

  CLEAR: LV_RETURN.
  CLEAR: LV_MESSAGE.

*----------------------------------------------------------------------*
* 전표정보 추출 함수 호출
*----------------------------------------------------------------------*
  CALL FUNCTION 'Y_EZFI_FI_DOCUMENT_READ'
    EXPORTING
      IV_BUKRS   = YEZFIS0060-BUKRS
      IV_BELNR   = YEZFIS0060-BELNR
      IV_GJAHR   = YEZFIS0060-GJAHR
    IMPORTING
      ES_BKPF    = LS_BKPF
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE
    TABLES
      ET_BSEG    = LT_BSEG.

* 추출 성공
  IF ( LV_RETURN = 'S' ).
    MOVE-CORRESPONDING LS_BKPF TO YEZFIS0070.

    LOOP AT LT_BSEG INTO LS_BSEG.
      MOVE-CORRESPONDING LS_BSEG TO GS_OUTTAB.
      APPEND GS_OUTTAB TO GT_OUTTAB.
      CLEAR GS_OUTTAB.
    ENDLOOP.

    SORT GT_OUTTAB BY BUZEI.
* 추출 오류
  ELSE.
    MESSAGE E000(YEZFIM) WITH LV_MESSAGE.
  ENDIF.

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
  CALL FUNCTION 'Y_EZFI_GET_BUKRS_INFO'
    EXPORTING
      IV_BUKRS   = YEZFIS0060-BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE
      ES_BUKRS   = GS_BUKRS.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YEZFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_PROC .

  CLEAR: YEZFIS0060.
  CLEAR: YEZFIS0070.
  CLEAR: YEZFIS0080.
  CLEAR: T001.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_BUKRS.
  CLEAR: GV_BSTAT.
  CLEAR: GV_BUZEI.
  CLEAR: GV_CALLD.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GO_SPLITTER_HOR.
  CLEAR: GO_CUST_0211.
  CLEAR: GO_GRID_0211.
  .
  CLEAR: GT_FCAT_0211.
  CLEAR: GS_FCAT_0211.
  CLEAR: GT_SORT_0211.

  CLEAR: GS_LAYOUT_0211.
  CLEAR: GS_VARIANT_0211.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_BELNR_PARAMETER
*&---------------------------------------------------------------------*
*       메모리의 전표번호 반영
*----------------------------------------------------------------------*
FORM GET_BELNR_PARAMETER .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_BUKRS   TYPE BKPF-BUKRS.
  DATA: LV_BELNR   TYPE BKPF-BELNR.
  DATA: LV_GJAHR   TYPE BKPF-GJAHR.

  CLEAR: LV_BUKRS.
  CLEAR: LV_BELNR.
  CLEAR: LV_GJAHR.

*----------------------------------------------------------------------*
* 회사코드 정보 설정
*----------------------------------------------------------------------*
  YEZFIS0060-BUKRS = GS_SUBLOGIN-BUKRS.
  YEZFIS0060-BUTXT = GS_SUBLOGIN-BUTXT.

  PERFORM GET_COMPANY_INFO.

  MOVE-CORRESPONDING GS_BUKRS TO T001.

*----------------------------------------------------------------------*
* 메모리의 전표정보 가져오기
*----------------------------------------------------------------------*
* 메모리 추출
  GET PARAMETER ID 'BUK' FIELD LV_BUKRS.
  GET PARAMETER ID 'BLN' FIELD LV_BELNR.
  GET PARAMETER ID 'GJR' FIELD LV_GJAHR.

* 메모리와 Sublogin 의 회사코드 동일 - 메모리 전표정보 세팅
  IF ( LV_BUKRS = YEZFIS0060-BUKRS ).
    YEZFIS0060-BELNR = LV_BELNR.
    YEZFIS0060-GJAHR = LV_GJAHR.
* 메모리와 Sublogin 의 회사코드 상이 - 초기화
  ELSE.
    CLEAR: YEZFIS0060-BELNR.
    CLEAR: YEZFIS0060-GJAHR.
  ENDIF.

*----------------------------------------------------------------------*
* 타프로그램 호출 여부
*----------------------------------------------------------------------*
* 타프로그램 호출 여부 가져 오기
  GET PARAMETER ID 'YEZ_CALLD' FIELD GV_CALLD.

* 가져온 후 CLEAR
  SET PARAMETER ID 'YEZ_CALLD' FIELD ABAP_FALSE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_FOR_NEW_ENTRY
*&---------------------------------------------------------------------*
*       새로운 전표 조회 시 광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_FOR_NEW_ENTRY .

  CLEAR: YEZFIS0070.
  CLEAR: YEZFIS0080.

  CLEAR: GV_BSTAT.
  CLEAR: GV_BUZEI.

  CLEAR: GO_SPLITTER_HOR.
  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GO_CUST_0211.
  CLEAR: GO_GRID_0211.

  CLEAR: GT_FCAT_0211.
  CLEAR: GS_FCAT_0211.
  CLEAR: GT_SORT_0211.

  CLEAR: GS_LAYOUT_0211.
  CLEAR: GS_VARIANT_0211.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       초기화
*----------------------------------------------------------------------*
FORM INITIALIZATION .

* Sublogin 에 대한 사용자 정보를 가져 온다.
  PERFORM CHECK_SUBLOGIN_PROC.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0100
*&---------------------------------------------------------------------*
*       전표번호 선택화면 호출
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0100 .

  CALL SCREEN 0100.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  SET_BUZEI_0212  OUTPUT
*&---------------------------------------------------------------------*
*       212 번 화면 개별항목 세팅
*----------------------------------------------------------------------*
MODULE SET_BUZEI_0212 OUTPUT.

  CLEAR GS_OUTTAB.
  READ TABLE GT_OUTTAB INTO GS_OUTTAB
                       WITH KEY BUZEI = GV_BUZEI
                       BINARY SEARCH
                       TRANSPORTING ALL FIELDS.

  CLEAR YEZFIS0080.
  MOVE-CORRESPONDING GS_OUTTAB TO YEZFIS0080.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  CALL_STD_FB03
*&---------------------------------------------------------------------*
*       전표번호 더블 클릭 시 FB03 호출
*----------------------------------------------------------------------*
FORM CALL_STD_FB03 .

  DATA: LV_FIELD(30)       VALUE IS INITIAL.        " 현재필드

  GET CURSOR FIELD LV_FIELD.

  CHECK ( LV_FIELD = 'YEZFIS0070-BELNR' ).

  IF ( YEZFIS0070-STATV IS NOT INITIAL ).
    SET PARAMETER ID 'BLN' FIELD YEZFIS0070-BELNR. " 전기전표이면 'BLN'
    SET PARAMETER ID 'BUK' FIELD YEZFIS0070-BUKRS.
    SET PARAMETER ID 'GJR' FIELD YEZFIS0070-GJAHR.

    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ELSE.
    SET PARAMETER ID 'BLP' FIELD YEZFIS0070-BELNR. " 임시전표이면 'BLP'
    SET PARAMETER ID 'BUK' FIELD YEZFIS0070-BUKRS.
    SET PARAMETER ID 'GJR' FIELD YEZFIS0070-GJAHR.

    CALL TRANSACTION 'FBV3' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFORM.
