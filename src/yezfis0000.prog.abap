*&---------------------------------------------------------------------*
*& Report YEZFIS0010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YEZFIS0000.

*&---------------------------------------------------------------------*
*&      Form  CONFIRM_POPUP
*&---------------------------------------------------------------------*
*       사용자 확인을 위한 POPUP 호출
*----------------------------------------------------------------------*
*      -->PV_TITLEBAR  POPUP 창 제목
*      -->PV_QUESTION  사용자 확인 메시지
*      -->PV_BUTTON    DEFAULT BUTTON ( '1' : 예, '2' : 아니오 )
*      <--PV_ANSWER    결과값
*----------------------------------------------------------------------*
FORM CONFIRM_POPUP  USING    PV_TITLEBAR
                             PV_QUESTION
                             PV_BUTTON
                    CHANGING PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLEBAR
      TEXT_QUESTION         = PV_QUESTION
      DEFAULT_BUTTON        = PV_BUTTON
      DISPLAY_CANCEL_BUTTON = ''
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF ( PV_ANSWER <> '1' ).
    MESSAGE S009(YEZFIM).          " 수행을 취소하였습니다.
  ENDIF.

ENDFORM.                    " CONFIRM_POPUP
