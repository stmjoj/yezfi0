FUNCTION Y_EZFI_CHECK_BUKRS_AUTH.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"  IMPORTING
*"     REFERENCE(IV_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     REFERENCE(EV_RETURN) TYPE  BAPI_MTYPE
*"     REFERENCE(EV_MESSAGE) TYPE  BAPI_MSG
*"--------------------------------------------------------------------
************************************************************************
* Function ID : Y_FI_CHECK_BUKRS_AUTH
* Title       : [FI] 회사코드 권한 점검
* Module      : FI
* Type        : Function
* Description : SAP 사용자 기준으로 회사코드 권한이 존재하는지 점검한다.
************************************************************************

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  CLEAR: EV_RETURN.
  CLEAR: EV_MESSAGE.

*----------------------------------------------------------------------*
* 회사코드 권한 점검
*----------------------------------------------------------------------*
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
                  ID     'BUKRS'
                  FIELD  IV_BUKRS.

  IF ( SY-SUBRC = 0 ).
    EV_RETURN = 'S'.
    " 처리가 완료되었습니다.
    MESSAGE S007(YFIM) INTO EV_MESSAGE.
  ELSE.
    EV_RETURN = 'E'.
    " 회사코드 &에 대한 권한이 없습니다.
    MESSAGE E800(FR) WITH IV_BUKRS INTO EV_MESSAGE.
  ENDIF.

ENDFUNCTION.
