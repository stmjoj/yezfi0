FUNCTION Y_EZFI_FI_DOCUMENT_READ.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IV_BUKRS) TYPE  BUKRS
*"     REFERENCE(IV_BELNR) TYPE  BELNR_D
*"     REFERENCE(IV_GJAHR) TYPE  GJAHR
*"  EXPORTING
*"     REFERENCE(ES_BKPF) TYPE  YEZFISBKPF
*"     REFERENCE(EV_RETURN) TYPE  BAPI_MTYPE
*"     REFERENCE(EV_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      ET_BSEG STRUCTURE  YEZFISBSEG
*"----------------------------------------------------------------------
************************************************************************
* Function ID : Y_EZFI_FI_DOCUMENT_READ
* Title       : [FI] 전표 정보 추출
* Module      : FI
* Type        : Function
* Description : 전표 조회를 위한 정보 구성
************************************************************************

*----------------------------------------------------------------------*
* 광역변수 초기화
*----------------------------------------------------------------------*
  PERFORM INIT_PROC.

*----------------------------------------------------------------------*
* Input Parameter Move
*----------------------------------------------------------------------*
  GV_BUKRS = IV_BUKRS.
  GV_BELNR = IV_BELNR.
  GV_GJAHR = IV_GJAHR.

*----------------------------------------------------------------------*
* 필수필드 점검
*----------------------------------------------------------------------*
  PERFORM CHECK_REQUIRED_FIELD.

  IF ( GV_RETURN = 'E' ).
    EV_RETURN  = GV_RETURN.
    EV_MESSAGE = GV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 전표 헤더 정보 READ
*----------------------------------------------------------------------*
  PERFORM FI_DOCUMENT_HEADER_READ.

  IF ( GV_RETURN = 'E' ).
    EV_RETURN  = GV_RETURN.
    EV_MESSAGE = GV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 전표 개별항목 정보 READ
*----------------------------------------------------------------------*
* 임시전표
  IF ( GS_BKPF-STATV IS NOT INITIAL ).
    PERFORM PARKING_DOCUMENT_READ.
* 전기전표
  ELSE.
    IF ( GS_BKPF-BSTAT = 'L' ).
      PERFORM LEDGER_DOCUMENT_ITEM_READ.
    ELSE.
      PERFORM POSTING_DOCUMENT_ITEM_READ.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* 전표 정보 구성
*----------------------------------------------------------------------*
  PERFORM FILL_DOCUMENT_INFO.

*----------------------------------------------------------------------*
* 결과 RETURN
*----------------------------------------------------------------------*
  MOVE-CORRESPONDING GS_BKPF TO ES_BKPF.
  ET_BSEG[] = GT_BSEG[].

  EV_RETURN = 'S'.
* MESSAGE : 성공적으로 수행하였습니다.
  MESSAGE S015(YEZFIM) INTO EV_MESSAGE.

ENDFUNCTION.
