*----------------------------------------------------------------------*
***INCLUDE LYFIF0020F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT
*&---------------------------------------------------------------------*
*       입력값 점검
*----------------------------------------------------------------------*
FORM CHECK_INPUT .

  IF ( GV_BUKRS IS INITIAL ).
    GV_RETURN = 'E'.

    " 필수 필드 &1에 값을 입력하십시오.
    MESSAGE S006(YEZFIM) INTO GV_MESSAGE.
    EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_BUKRS_INFO
*&---------------------------------------------------------------------*
*       회사코드 기본정보 추출
*----------------------------------------------------------------------*
FORM SELECT_BUKRS_INFO .

  SELECT SINGLE
         A~BUKRS    AS BUKRS
         A~BUTXT    AS BUTXT
         A~LAND1    AS LAND1
         A~WAERS    AS WAERS
         A~KTOPL    AS KTOPL
         A~PERIV    AS PERIV
         B~KALSM    AS KALSM
    INTO CORRESPONDING FIELDS OF GS_BUKRS
    FROM T001 AS A LEFT OUTER JOIN
         T005 AS B
      ON B~LAND1 = A~LAND1
   WHERE A~BUKRS = GV_BUKRS.

  IF ( SY-SUBRC <> 0 ).
    GV_RETURN = 'E'.

    " 회사코드 &을(를) 정의하지 않았습니다
    MESSAGE S165(F5) INTO GV_MESSAGE.
    EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CO_AREA
*&---------------------------------------------------------------------*
*       관리회계영역 결정
*----------------------------------------------------------------------*
FORM GET_CO_AREA .

  SELECT SINGLE
         KOKRS
    FROM TKA02
   WHERE BUKRS = @GV_BUKRS
     AND GSBER = @SPACE
    INTO @GS_BUKRS-KOKRS.

ENDFORM.
