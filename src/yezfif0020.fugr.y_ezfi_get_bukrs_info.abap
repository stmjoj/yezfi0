FUNCTION Y_EZFI_GET_BUKRS_INFO.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IV_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     REFERENCE(EV_RETURN) TYPE  BAPI_MTYPE
*"     REFERENCE(EV_MESSAGE) TYPE  BAPI_MSG
*"     REFERENCE(ES_BUKRS) TYPE  YEZFIS0020
*"----------------------------------------------------------------------
************************************************************************
* Function ID : Y_FI_GET_BUKRS_INFO
* Title       : [FI] 회사코드 정보 추출
* Module      : FI
* Type        : Function
* Description : 회사코드의 기존정보를 추출한다.
************************************************************************

*----------------------------------------------------------------------*
* 변수 선언 및 초기화
*----------------------------------------------------------------------*
  CLEAR: EV_RETURN.
  CLEAR: EV_MESSAGE.
  CLEAR: ES_BUKRS.

  CLEAR: GV_RETURN.
  CLEAR: GV_MESSAGE.
  CLEAR: GS_BUKRS.

  GV_BUKRS = IV_BUKRS.

*----------------------------------------------------------------------*
* 입력값 점검
*----------------------------------------------------------------------*
  PERFORM CHECK_INPUT.

  IF ( GV_RETURN = 'E' ).
    EV_RETURN  = GV_RETURN.
    EV_MESSAGE = GV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 회사코드 기본정보 추출
*----------------------------------------------------------------------*
  PERFORM SELECT_BUKRS_INFO.

  IF ( GV_RETURN = 'E' ).
    EV_RETURN  = GV_RETURN.
    EV_MESSAGE = GV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 관리회계영역 결정
*----------------------------------------------------------------------*
  PERFORM GET_CO_AREA.

*----------------------------------------------------------------------*
* 결과 RETURN
*----------------------------------------------------------------------*
  ES_BUKRS   = GS_BUKRS.
  EV_RETURN  = 'S'.

  " 처리가 완료되었습니다.
  MESSAGE S007(YEZFIM) INTO EV_MESSAGE.

ENDFUNCTION.
