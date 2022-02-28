*----------------------------------------------------------------------*
***INCLUDE LYFIF0030F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_EMPNO_FROM_UNAME
*&---------------------------------------------------------------------*
*       SAP User ID 에 Assign 된 사원번호 및 발의부서 권한 추출
*----------------------------------------------------------------------*
FORM GET_EMPNO_FROM_UNAME .

*----------------------------------------------------------------------*
* 사원정보 및 권한 SELECT
*----------------------------------------------------------------------*
  SELECT A~BUKRS    AS BUKRS
       , C~BUTXT    AS BUTXT
       , A~EMPNO    AS EMPNO
       , A~EMPNM    AS EMPNM
       , A~TITLE    AS TITLE
       , B~ORGCD    AS ORGCD
       , B~AUTYP    AS AUTYP
       , B~ACTIV    AS ACTIV
    FROM YEZFIT0010 AS A INNER JOIN YEZFIT0011 AS B ON B~BUKRS = A~BUKRS
                                                   AND B~EMPNO = A~EMPNO
                         LEFT OUTER JOIN T001  AS C ON C~BUKRS = A~BUKRS
   WHERE A~BNAME = @GV_UNAME
     AND A~ACTIV = @ABAP_TRUE                    " 발의가능여부 = TRUE
    INTO CORRESPONDING FIELDS OF TABLE @GT_EMP.

  IF ( GT_EMP[] IS INITIAL ).
    GV_RETURN = 'E'.
    " 발의부서 권한을 찾을 수 없습니다.
    MESSAGE S008(YEZFIM) INTO GV_MESSAGE.
    EXIT.
  ENDIF.

  SORT GT_EMP BY BUKRS EMPNO ORGCD AUTYP.
  DELETE ADJACENT DUPLICATES FROM GT_EMP COMPARING BUKRS EMPNO ORGCD AUTYP.

*----------------------------------------------------------------------*
* 조직정보 반영
*----------------------------------------------------------------------*
  LOOP AT GT_EMP INTO GS_EMP.
    DATA(LV_INDEX) = SY-TABIX.

    CLEAR: GS_ORG.
    READ TABLE GT_ORG INTO GS_ORG
                      WITH KEY BUKRS = GS_EMP-BUKRS
                               ORGCD = GS_EMP-ORGCD
                      BINARY SEARCH
                      TRANSPORTING ORGNM.

    IF ( SY-SUBRC = 0 ).
      GS_EMP-ORGNM = GS_ORG-ORGNM.
      MODIFY GT_EMP FROM GS_EMP INDEX LV_INDEX
                    TRANSPORTING ORGNM.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ISSUER_INFO
*&---------------------------------------------------------------------*
*       발의자 및 발의부서 선택
*----------------------------------------------------------------------*
FORM SET_ISSUER_INFO .

  DATA(LV_LINES) = LINES( GT_EMP[] ).

  CLEAR GS_EMP.
  READ TABLE GT_EMP INTO GS_EMP INDEX 1.

*----------------------------------------------------------------------*
* SAP User ID : 사원정보 = 1 : 1
*----------------------------------------------------------------------*
  IF ( LV_LINES = 1 ).
    GS_SUBLOGIN-BUKRS  = GS_EMP-BUKRS.
    GS_SUBLOGIN-BUTXT  = GS_EMP-BUTXT.
    GS_SUBLOGIN-EMPNO  = GS_EMP-EMPNO.
    GS_SUBLOGIN-EMPNM  = GS_EMP-EMPNM.
    GS_SUBLOGIN-ORGCD  = GS_EMP-ORGCD.
    GS_SUBLOGIN-ORGNM  = GS_EMP-ORGNM.

    GV_RETURN = 'S'.

    " 처리가 완료되었습니다.
    MESSAGE S007(YEZFIM) INTO GV_MESSAGE.
*----------------------------------------------------------------------*
* SAP User ID : 사원정보 = 1 : N
*----------------------------------------------------------------------*
  ELSE.
    YEZFIS0030-BUKRS = GS_EMP-BUKRS.     " 기본값 설정 ( 첫번째 권한의 회사코드 )
    YEZFIS0030-EMPNO = GS_EMP-EMPNO.     " 기본값 설정 ( 첫번째 권한의 사원번호 )

    PERFORM MAKE_VRM_BUKRS.              " 회사코드 F4 HELP 를 위한 Value Set 구성
    PERFORM MAKE_VRM_EMPNO.              " 사원번호 F4 HELP 를 위한 Value Set 구성

    DATA(LV_LINES_BUKRS) = LINES( GT_VRM_BUKRS[] ).
    DATA(LV_LINES_EMPNO) = LINES( GT_VRM_EMPNO[] ).

*   회사코드 및 사원이 1개
    IF ( LV_LINES_BUKRS = 1 ) AND ( LV_LINES_EMPNO = 1 ).
      GV_SINGLE_EMPNO = ABAP_TRUE.

      PERFORM EMPNO_SELECT_EVENT.
*   회사코드 또는 사원이 N개
    ELSE.
      GV_SINGLE_EMPNO = ABAP_FALSE.

      CALL SCREEN 0100 STARTING AT  17    1
                       ENDING   AT  60    3.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_ORGCD_LIST
*&---------------------------------------------------------------------*
*       부서코드 목록 READ
*----------------------------------------------------------------------*
FORM GET_ORGCD_LIST .

* 부서코드 정보 전체 선택 ( READ BINARY SEARCH 목적 )
  SELECT A~BUKRS    AS BUKRS
       , A~ORGCD    AS ORGCD
       , A~ORGNM    AS ORGNM
    FROM YEZFIT0020 AS A
   WHERE DATBI = ( SELECT MAX( B~DATBI )
                     FROM YEZFIT0020 AS B
                    WHERE B~BUKRS = A~BUKRS
                      AND B~ORGCD = A~ORGCD )
    INTO CORRESPONDING FIELDS OF TABLE @GT_ORG.

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
  CLEAR: YEZFIS0030.

  CLEAR: GV_UNAME.

  CLEAR: GS_SUBLOGIN.
  CLEAR: GV_RETURN.
  CLEAR: GV_MESSAGE.

  CLEAR: GT_ORG[].
  CLEAR: GS_ORG.

  CLEAR: GT_EMP[].
  CLEAR: GS_EMP.

  CLEAR: GT_VRM_BUKRS[].
  CLEAR: GS_VRM_BUKRS.

  CLEAR: GT_VRM_EMPNO[].
  CLEAR: GS_VRM_EMPNO.

  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GV_SINGLE_EMPNO.

*----------------------------------------------------------------------*
* 200번 화면 관련 변수 초기화
*----------------------------------------------------------------------*
  PERFORM INIT_0200_PROC.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CANCEL_SELECT_EMPNO
*&---------------------------------------------------------------------*
*       사원 선택 취소
*----------------------------------------------------------------------*
FORM CANCEL_SELECT_EMPNO.

  DATA: LV_ANSWER   TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR       = TEXT-001     " 경고
      TEXT_QUESTION  = TEXT-005     " 발의자 선택을 취소합니다. 계속하시겠습니까?
      TEXT_BUTTON_1  = TEXT-003     " 예
      TEXT_BUTTON_2  = TEXT-004     " 아니오
      DEFAULT_BUTTON = '2'
    IMPORTING
      ANSWER         = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

  IF ( LV_ANSWER = '1' ).
*   화면 종료
    GV_RETURN  = 'E'.
    GV_MESSAGE = TEXT-006.           " 발의자 선택을 취소하였습니다.

    LEAVE TO SCREEN 0.
  ELSE.
    " 수행을 취소하였습니다.
    MESSAGE S001(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CANCEL_SELECT_AUTH
*&---------------------------------------------------------------------*
*       권한 선택 취소
*----------------------------------------------------------------------*
FORM CANCEL_SELECT_AUTH .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_ANSWER   TYPE C.

  CLEAR: LV_ANSWER.

*----------------------------------------------------------------------*
* 회사코드 및 사원번호가 1개인 경우
* - 100번 화면 거치지 않고 200번 화면으로 바로 진입한 경우
*----------------------------------------------------------------------*
  IF ( GV_SINGLE_EMPNO IS NOT INITIAL ).
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR       = TEXT-001     " 경고
        TEXT_QUESTION  = TEXT-002     " 발의부서 선택을 취소합니다. 계속하시겠습니까?
        TEXT_BUTTON_1  = TEXT-003     " 예
        TEXT_BUTTON_2  = TEXT-004     " 아니오
        DEFAULT_BUTTON = '2'
      IMPORTING
        ANSWER         = LV_ANSWER
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.

    IF ( LV_ANSWER = '1' ).
*     화면 종료
      GV_RETURN  = 'E'.
      GV_MESSAGE = TEXT-007.           " 발의부서 선택을 취소하였습니다.
    ELSE.
      " 수행을 취소하였습니다.
      MESSAGE S001(YEZFIM).
      EXIT.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* ALV 초기화 및 200번 화면 종료
*----------------------------------------------------------------------*
* 200번 화면 ALV 초기화
  PERFORM FREE_ALV_OBJECT_0200.

* 200번 화면 종료 및 이전화면으로 복귀
  LEAVE TO SCREEN 0.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ORG_AUTH
*&---------------------------------------------------------------------*
*       발의부서 권한 선택
*----------------------------------------------------------------------*
FORM SELECT_ORG_AUTH .


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_HELP_BUKRS
*&---------------------------------------------------------------------*
*       회사코드에 대한 F4 HELP 처리 ( DropDownList )
*----------------------------------------------------------------------*
*      -->PV_FIELDNAME
*----------------------------------------------------------------------*
FORM F4_HELP_BUKRS USING PV_FIELDNAME   TYPE VRM_ID.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_FIELDNAME
      VALUES = GT_VRM_BUKRS[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F4_HELP_EMPNO
*&---------------------------------------------------------------------*
*       사원번호에 대한 F4 HELP 처리 ( DropDownList )
*----------------------------------------------------------------------*
*      -->PV_FIELDNAME
*----------------------------------------------------------------------*
FORM F4_HELP_EMPNO USING PV_FIELDNAME   TYPE VRM_ID.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = PV_FIELDNAME
      VALUES = GT_VRM_EMPNO[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EMPNO_SELECT_EVENT
*&---------------------------------------------------------------------*
*       사원번호 선택 이벤트 처리
*----------------------------------------------------------------------*
FORM EMPNO_SELECT_EVENT .

  CHECK ( YEZFIS0030-EMPNO IS NOT INITIAL ).

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_ACTIV_CNT   TYPE I.

  CLEAR: LV_ACTIV_CNT.

*----------------------------------------------------------------------*
* 200번 화면 관련 변수 초기화
*----------------------------------------------------------------------*
  PERFORM INIT_0200_PROC.

*----------------------------------------------------------------------*
* ALV OUTTAB 구성
*----------------------------------------------------------------------*
  LOOP AT GT_EMP INTO GS_EMP WHERE BUKRS = YEZFIS0030-BUKRS
                               AND EMPNO = YEZFIS0030-EMPNO.
    YEZFIS0030-BUTXT = GS_EMP-BUTXT.
    YEZFIS0030-EMPNM = GS_EMP-EMPNM.
    YEZFIS0030-TITLE = GS_EMP-TITLE.

    MOVE-CORRESPONDING GS_EMP TO GS_AUTH.

    IF ( GS_EMP-ACTIV IS NOT INITIAL ).
      LV_ACTIV_CNT  = LV_ACTIV_CNT + 1.

      " 활성화된 첫번째 부서코드를 기본값으로 선택
      IF ( LV_ACTIV_CNT = 1 ).
        GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON.
      ELSE.
        GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON_EMPTY.
      ENDIF.
    ELSE.
      GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON_EMPTY.
    ENDIF.

    APPEND GS_AUTH TO GT_AUTH.
    CLEAR GS_AUTH.
  ENDLOOP.

  SORT GT_AUTH BY AUTYP ORGCD.

* 활성화된 건이 없는 경우 첫번째 건을 활성화
  IF ( LV_ACTIV_CNT = 0 ).
    CLEAR GS_AUTH.
    READ TABLE GT_AUTH INTO GS_AUTH INDEX 1.

    GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON.

    MODIFY GT_AUTH FROM GS_AUTH INDEX 1
                   TRANSPORTING CHECK.
  ENDIF.

*----------------------------------------------------------------------*
* 200번 화면 호출
*----------------------------------------------------------------------*
  CALL SCREEN 0200 STARTING AT  17    1
                   ENDING   AT  80    8.

* 발의부서 선택된 경우 종료 처리
  IF ( GV_RETURN = 'S' ).
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_0200_PROC
*&---------------------------------------------------------------------*
*       200번 화면 관련 변수 초기화
*----------------------------------------------------------------------*
FORM INIT_0200_PROC .

* ALV OUTTAB 초기화
  CLEAR: GT_AUTH[].
  CLEAR: GS_AUTH.

* ALV OBJECT 변수 초기화
  CLEAR: GO_CONTAINER_0200.
  CLEAR: GO_GRID_0200.

  CLEAR: GT_FCAT_0200.
  CLEAR: GS_FCAT_0200.
  CLEAR: GT_SORT_0200.

  CLEAR: GS_LAYOUT_0200.
  CLEAR: GS_VARIANT_0200.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUTH_SELECT_EVENT
*&---------------------------------------------------------------------*
*       권한 선택 이벤트 처리
*----------------------------------------------------------------------*
FORM AUTH_SELECT_EVENT .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_SELECT_COUNT   TYPE I.

  CLEAR: LV_SELECT_COUNT.

*----------------------------------------------------------------------*
* 선택한 부서코드의 건수 점검
*----------------------------------------------------------------------*
  LOOP AT GT_AUTH INTO GS_AUTH.
    IF ( GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON ).
      LV_SELECT_COUNT = LV_SELECT_COUNT + 1.
    ENDIF.
  ENDLOOP.

* 선택한 건이 없는 경우
  IF ( LV_SELECT_COUNT = 0 ).
    " & 을(를) 선택하세요.
    MESSAGE S010(YEZFIM) WITH TEXT-008.              " 발의부서
    EXIT.
  ENDIF.

* 선택한 건이 여러건인 경우
  IF ( LV_SELECT_COUNT > 1 ).
    " & 은(는) 한건만 선택 가능합니다.
    MESSAGE S011(YEZFIM) WITH TEXT-008.              " 발의부서
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 선택한 부서코드를 발의부서로 적용
*----------------------------------------------------------------------*
  LOOP AT GT_AUTH INTO GS_AUTH.
    IF ( GS_AUTH-CHECK = ICON_WD_RADIO_BUTTON ).
      UPDATE YEZFIT0011
         SET ACTIV = ABAP_TRUE
       WHERE BUKRS = YEZFIS0030-BUKRS
         AND EMPNO = YEZFIS0030-EMPNO
         AND ORGCD = GS_AUTH-ORGCD
         AND AUTYP = GS_AUTH-AUTYP.

      GS_SUBLOGIN-BUKRS  = YEZFIS0030-BUKRS.
      GS_SUBLOGIN-BUTXT  = YEZFIS0030-BUTXT.
      GS_SUBLOGIN-EMPNO  = YEZFIS0030-EMPNO.
      GS_SUBLOGIN-EMPNM  = YEZFIS0030-EMPNM.
      GS_SUBLOGIN-ORGCD  = GS_AUTH-ORGCD.
      GS_SUBLOGIN-ORGNM  = GS_AUTH-ORGNM.

      GV_RETURN = 'S'.

      " 처리가 완료되었습니다.
      MESSAGE S007(YEZFIM) INTO GV_MESSAGE.
    ELSE.
      UPDATE YEZFIT0011
         SET ACTIV = ABAP_FALSE
       WHERE BUKRS = YEZFIS0030-BUKRS
         AND EMPNO = YEZFIS0030-EMPNO
         AND ORGCD = GS_AUTH-ORGCD
         AND AUTYP = GS_AUTH-AUTYP.
    ENDIF.
  ENDLOOP.

  COMMIT WORK.

*----------------------------------------------------------------------*
* ALV 초기화 및 200번 화면 종료
*----------------------------------------------------------------------*
* 200번 화면 ALV 초기화
  PERFORM FREE_ALV_OBJECT_0200.

* 200번 화면 종료 및 이전화면으로 복귀
  LEAVE TO SCREEN 0.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_VRM_BUKRS
*&---------------------------------------------------------------------*
*       회사코드 F4 HELP 를 위한 Value Set 구성
*----------------------------------------------------------------------*
FORM MAKE_VRM_BUKRS .

  LOOP AT GT_EMP INTO GS_EMP.
    GS_VRM_BUKRS-KEY  = GS_EMP-BUKRS.
    GS_VRM_BUKRS-TEXT = GS_EMP-BUTXT.

    APPEND GS_VRM_BUKRS TO GT_VRM_BUKRS.
    CLEAR GS_VRM_BUKRS.
  ENDLOOP.

  SORT GT_VRM_BUKRS BY KEY TEXT.
  DELETE ADJACENT DUPLICATES FROM GT_VRM_BUKRS COMPARING KEY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_VRM_EMPNO
*&---------------------------------------------------------------------*
*       사원번호 F4 HELP 를 위한 Value Set 구성
*----------------------------------------------------------------------*
FORM MAKE_VRM_EMPNO .

  CLEAR: GT_VRM_EMPNO[].
  CLEAR: GS_VRM_EMPNO.

* 선택된 회사코드에 해당하는 사원번호로 구성
  LOOP AT GT_EMP INTO GS_EMP WHERE BUKRS = YEZFIS0030-BUKRS.
    GS_VRM_EMPNO-KEY  = GS_EMP-EMPNO.

    CONCATENATE GS_EMP-EMPNM '/' GS_EMP-TITLE
           INTO GS_VRM_EMPNO-TEXT
      SEPARATED BY SPACE.

    APPEND GS_VRM_EMPNO TO GT_VRM_EMPNO.
    CLEAR GS_VRM_EMPNO.
  ENDLOOP.

  SORT GT_VRM_EMPNO BY KEY TEXT.
  DELETE ADJACENT DUPLICATES FROM GT_VRM_EMPNO COMPARING KEY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  BUKRS_SELECT_EVENT
*&---------------------------------------------------------------------*
*       회사코드 선택 이벤트 처리
*----------------------------------------------------------------------*
FORM BUKRS_SELECT_EVENT .

  CHECK ( YEZFIS0030-BUKRS IS NOT INITIAL ).

  CLEAR GS_EMP.
  READ TABLE GT_EMP INTO GS_EMP
                    WITH KEY BUKRS = YEZFIS0030-BUKRS
                    BINARY SEARCH
                    TRANSPORTING EMPNO.

  IF ( SY-SUBRC = 0 ).
    YEZFIS0030-EMPNO = GS_EMP-EMPNO.
  ENDIF.

  PERFORM MAKE_VRM_EMPNO.     " 사원번호 F4 HELP 를 위한 Value Set 구성

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FREE_ALV_OBJECT_0200
*&---------------------------------------------------------------------*
*       200번 화면 ALV 초기화
*----------------------------------------------------------------------*
FORM FREE_ALV_OBJECT_0200 .

* ALV GRID 초기화
  IF ( GO_GRID_0200 IS NOT INITIAL ).
    CALL METHOD GO_GRID_0200->REFRESH_TABLE_DISPLAY.
    CALL METHOD GO_GRID_0200->FREE.
    CLEAR: GO_GRID_0200.
  ENDIF.

* CONTAINER 초기화
  IF ( GO_CONTAINER_0200 IS NOT INITIAL ).
    CALL METHOD GO_CONTAINER_0200->FREE.
    CLEAR GO_CONTAINER_0200.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SUBLOGIN
*&---------------------------------------------------------------------*
*       기 로그인 여부 점검하여 로그인 된 경우 기존 정보 사용
*----------------------------------------------------------------------*
FORM CHECK_SUBLOGIN .

  GET PARAMETER ID 'BUK'       FIELD GS_SUBLOGIN-BUKRS.
  GET PARAMETER ID 'YEZ_EMPNO' FIELD GS_SUBLOGIN-EMPNO.
  GET PARAMETER ID 'YEZ_ORGCD' FIELD GS_SUBLOGIN-ORGCD.

  IF ( GS_SUBLOGIN-EMPNO IS NOT INITIAL ).
    CLEAR GS_EMP.
    READ TABLE GT_EMP INTO GS_EMP WITH KEY BUKRS = GS_SUBLOGIN-BUKRS
                                           EMPNO = GS_SUBLOGIN-EMPNO
                                           ORGCD = GS_SUBLOGIN-ORGCD
                                  BINARY SEARCH
                                  TRANSPORTING BUTXT EMPNM ORGNM.

    IF ( SY-SUBRC = 0 ).
      GS_SUBLOGIN-BUTXT = GS_EMP-BUTXT.
      GS_SUBLOGIN-EMPNM = GS_EMP-EMPNM.
      GS_SUBLOGIN-ORGNM = GS_EMP-ORGNM.

      GV_RETURN = 'S'.

      " 처리가 완료되었습니다.
      MESSAGE S007(YEZFIM) INTO GV_MESSAGE.
    ENDIF.
  ENDIF.

ENDFORM.
