*&---------------------------------------------------------------------*
*&  Include           YEZFIR0010_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       레포트 Initialization 이벤트 처리
*----------------------------------------------------------------------*
FORM INITIALIZATION .

* Sublogin 에 대한 사용자 정보를 가져 온다.
  PERFORM CHECK_SUBLOGIN_PROC.

  GET PARAMETER ID 'BUK'    FIELD P_BUKRS.

  PERFORM SET_BUTXT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_BUTXT
*&---------------------------------------------------------------------*
*       회사코드 명 설정
*----------------------------------------------------------------------*
FORM SET_BUTXT .

  CLEAR: P_BUTXT.

  CHECK ( P_BUKRS IS NOT INITIAL ).

  SELECT SINGLE BUTXT
    FROM T001
   WHERE BUKRS = @P_BUKRS
    INTO @P_BUTXT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_AUTH
*&---------------------------------------------------------------------*
*       회사코드 권한 점검
*----------------------------------------------------------------------*
FORM CHECK_BUKRS_AUTH .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CLEAR: LV_RETURN.
  CLEAR: LV_MESSAGE.

*----------------------------------------------------------------------*
* 회사코드 권한 점검
*----------------------------------------------------------------------*
  CALL FUNCTION 'Y_EZFI_CHECK_BUKRS_AUTH'
    EXPORTING
      IV_BUKRS   = P_BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YEZFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
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
  CLEAR: YEZFIS0010.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_BUKRS.
  CLEAR: GV_TITLE.

  GV_TITLE = SY-TITLE.

*----------------------------------------------------------------------*
* ALV 변수 초기화
*----------------------------------------------------------------------*
  CLEAR: GO_CONTAINER_0100.
  CLEAR: GO_GRID_0100.

  CLEAR: GT_FCAT_0100.
  CLEAR: GS_FCAT_0100.
  CLEAR: GT_SORT_0100.

  CLEAR: GS_LAYOUT_0100.
  CLEAR: GS_VARIANT_0100.

*----------------------------------------------------------------------*
* 초기값 설정
*----------------------------------------------------------------------*
  PERFORM GET_COMPANY_INFO.           " 회사코드 정보 설정

  PERFORM GET_ORGCD_LIST.             " 부서코드 목록 READ

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_OUTTAB
*&---------------------------------------------------------------------*
*       출력자료 구성
*----------------------------------------------------------------------*
FORM MAKE_OUTTAB .

* 사원정보 SELECT
  SELECT EMPNO
       , BNAME
       , EMPNM
       , ORGCD
       , EMAIL
       , TITLE
       , ACTIV
       , ERDAT
       , ERZET
       , ERNAM
       , AEDAT
       , AEZET
       , AENAM
    FROM YEZFIT0010
   WHERE BUKRS =  @GS_BUKRS-BUKRS
     AND EMPNO IN @S_EMPNO
     AND BNAME IN @S_BNAME
     AND EMPNM IN @S_EMPNM
     AND ORGCD IN @S_ORGCD
    INTO CORRESPONDING FIELDS OF TABLE @GT_OUTTAB.

* 부서정보 MAPPING
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    DATA(LV_INDEX) = SY-TABIX.

    CLEAR GS_ORGCD.
    READ TABLE GT_ORGCD INTO GS_ORGCD
                        WITH KEY ORGCD = GS_OUTTAB-ORGCD
                        BINARY SEARCH
                        TRANSPORTING ORGNM KOSTL.

    IF ( SY-SUBRC = 0 ).
      GS_OUTTAB-ORGNM = GS_ORGCD-ORGNM.
      GS_OUTTAB-KOSTL = GS_ORGCD-KOSTL.

      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX
                       TRANSPORTING ORGNM KOSTL.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_OUTTAB
*&---------------------------------------------------------------------*
*       자료 출력
*----------------------------------------------------------------------*
FORM DISPLAY_OUTTAB .

  YEZFIS0010-BUKRS = GS_BUKRS-BUKRS.
  YEZFIS0010-BUTXT = GS_BUKRS-BUTXT.
  YEZFIS0010-DTCNT = LINES( GT_OUTTAB[] ).

  IF ( GT_OUTTAB[] IS INITIAL ).
    " 조건을 만족하는 데이터가 없습니다.
    MESSAGE S004(YEZFIM).
  ENDIF.

  CALL SCREEN 100.

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
*&      Form  GET_ORGCD_LIST
*&---------------------------------------------------------------------*
*       부서코드 목록 READ
*----------------------------------------------------------------------*
FORM GET_ORGCD_LIST .

* 부서코드 정보 전체 선택 ( READ BINARY SEARCH 목적 )
  SELECT A~ORGCD    AS ORGCD
       , A~ORGNM    AS ORGNM
       , A~KOSTL    AS KOSTL
    FROM YEZFIT0020 AS A
   WHERE BUKRS = @P_BUKRS
     AND DATBI = ( SELECT MAX( B~DATBI )
                     FROM YEZFIT0020 AS B
                    WHERE B~BUKRS = A~BUKRS
                      AND B~ORGCD = A~ORGCD )
    INTO CORRESPONDING FIELDS OF TABLE @GT_ORGCD.

  SORT GT_ORGCD BY ORGCD.

ENDFORM.
