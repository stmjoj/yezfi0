FUNCTION Y_EZFI_SUBLOGIN.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IV_UNAME) TYPE  SYST_UNAME DEFAULT SY-UNAME
*"     REFERENCE(IV_SKIP) TYPE  FLAG DEFAULT ABAP_TRUE
*"  EXPORTING
*"     REFERENCE(ES_SUBLOGIN) TYPE  YEZFIS0040
*"     REFERENCE(EV_RETURN) TYPE  BAPI_MTYPE
*"     REFERENCE(EV_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
************************************************************************
* Function ID : Y_FI_SUBLOGIN
* Title       : [FI] SubLogin
* Module      : FI
* Type        : Function
* Description : 발의자 사번 및 발의부서를 선택한다.
************************************************************************

*----------------------------------------------------------------------*
* 변수 선언 및 초기화
*----------------------------------------------------------------------*
* Function Return 변수 초기화
  CLEAR: ES_SUBLOGIN.
  CLEAR: EV_RETURN.
  CLEAR: EV_MESSAGE.

* 광역변수 초기화
  PERFORM INIT_PROC.

* Input Parameter Move
  GV_UNAME = IV_UNAME.

* 부서코드 목록 READ
  PERFORM GET_ORGCD_LIST.

*----------------------------------------------------------------------*
* SAP User ID 에 Assign 된 사원번호 추출
*----------------------------------------------------------------------*
  PERFORM GET_EMPNO_FROM_UNAME.

  IF ( GV_RETURN = 'E' ).
    EV_RETURN  = GV_RETURN.
    EV_MESSAGE = GV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 기 로그인 여부 점검하여 로그인 된 경우 SKIP
*----------------------------------------------------------------------*
  IF ( IV_SKIP = ABAP_TRUE ).
    PERFORM CHECK_SUBLOGIN.

    IF ( GV_RETURN = 'S' ).
      ES_SUBLOGIN = GS_SUBLOGIN.
      EV_RETURN   = GV_RETURN.
      EV_MESSAGE  = GV_MESSAGE.
      EXIT.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* 발의자 및 발의부서 선택
*----------------------------------------------------------------------*
  PERFORM SET_ISSUER_INFO.

*----------------------------------------------------------------------*
* 결과 RETURN
*----------------------------------------------------------------------*
  IF ( GV_RETURN = 'S' ).
    SET PARAMETER ID 'BUK'       FIELD GS_SUBLOGIN-BUKRS.
    SET PARAMETER ID 'YEZ_EMPNO' FIELD GS_SUBLOGIN-EMPNO.
    SET PARAMETER ID 'YEZ_ORGCD' FIELD GS_SUBLOGIN-ORGCD.

    ES_SUBLOGIN = GS_SUBLOGIN.
  ENDIF.

  EV_RETURN  = GV_RETURN.
  EV_MESSAGE = GV_MESSAGE.

ENDFUNCTION.
