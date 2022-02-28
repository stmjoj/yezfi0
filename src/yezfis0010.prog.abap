*&---------------------------------------------------------------------*
*& Report YEZFIS0010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YEZFIS0010.

*&---------------------------------------------------------------------*
*&      Form  SELECT_FIELDCAT_PROC
*&---------------------------------------------------------------------*
*       화면 별 FIELD CATALOG 가져오기
*----------------------------------------------------------------------*
FORM SELECT_FIELDCAT_PROC  TABLES   PT_FIELDCAT STRUCTURE YEZFIS1010
                           USING    PV_PROGNAME
                                    PV_DYNNUMB
                                    PV_SCRFNAME.

  CLEAR: PT_FIELDCAT[].

  SELECT A~COL_POS    AS COL_POS
         A~FIELDNAME  AS FIELDNAME
         A~KEY_FIELD  AS KEY_FIELD
         A~REF_TABLE  AS REF_TABLE
         A~REF_FIELD  AS REF_FIELD
         A~CFIELDNAME AS CFIELDNAME
         A~CHECKBOX   AS CHECKBOX
         A~HOTSPOT    AS HOTSPOT
         A~JUST       AS JUST
         A~DO_SUM     AS DO_SUM
         A~NO_OUT     AS NO_OUT
         A~TECH       AS TECH
         B~REPTEXT    AS REPTEXT
         A~SPOS       AS SPOS
         A~UP         AS UP
         A~DOWN       AS DOWN
         A~SUBTOT     AS SUBTOT
    INTO CORRESPONDING FIELDS OF TABLE PT_FIELDCAT
    FROM YEZFIT1010 AS A LEFT OUTER JOIN
         YEZFIT1020 AS B
      ON B~PROGNAME = A~PROGNAME
     AND B~DYNNUMB  = A~DYNNUMB
     AND B~SCRFNAME = A~SCRFNAME
     AND B~COL_POS  = A~COL_POS
     AND B~SPRAS    = SY-LANGU
   WHERE A~PROGNAME = PV_PROGNAME
     AND A~DYNNUMB  = PV_DYNNUMB
     AND A~SCRFNAME = PV_SCRFNAME.

  SORT PT_FIELDCAT[] BY COL_POS.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_SORT_ORDER_PROC
*&---------------------------------------------------------------------*
*       화면 별 ALV SORT ORDER 가져오기
*----------------------------------------------------------------------*
FORM SELECT_SORT_ORDER_PROC  TABLES   PT_SORT STRUCTURE YEZFIS1020
                             USING    PV_PROGNAME
                                      PV_DYNNUMB
                                      PV_SCRFNAME.

  CLEAR: PT_SORT[].

  SELECT SPOS
         FIELDNAME
         UP
         DOWN
         SUBTOT
    INTO CORRESPONDING FIELDS OF TABLE PT_SORT
    FROM YEZFIT1010
   WHERE PROGNAME = PV_PROGNAME
     AND DYNNUMB  = PV_DYNNUMB
     AND SCRFNAME = PV_SCRFNAME.

  SORT PT_SORT[] BY SPOS.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       FIELD CATALOG 구성
*----------------------------------------------------------------------*
*      <--PT_FCAT
*      -->PV_GUBUN
*      -->PV_FNAME
*      -->PV_VALUE
*----------------------------------------------------------------------*
FORM FILL_FIELDCAT  TABLES   PT_FCAT   STRUCTURE LVC_S_FCAT
                    USING    PS_FCAT   TYPE LVC_S_FCAT
                             VALUE(PV_GUBUN)
                             VALUE(PV_FNAME)
                             VALUE(PV_VALUE).

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_FNAME(40)   TYPE C.

  FIELD-SYMBOLS: <FS>   TYPE ANY.

  CLEAR: LV_FNAME.

*----------------------------------------------------------------------*
* FIELD CATALOG 구성
*----------------------------------------------------------------------*
  IF ( PV_GUBUN = 'S' ).
    CLEAR: PS_FCAT.
  ENDIF.

  CONCATENATE 'PS_FCAT-' PV_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS>.
  <FS> = PV_VALUE.

  IF ( PV_FNAME = 'REPTEXT' ).
    PS_FCAT-SCRTEXT_L  = PV_VALUE.
    PS_FCAT-SCRTEXT_M  = PV_VALUE.
    PS_FCAT-SCRTEXT_S  = PV_VALUE.
    PS_FCAT-COLDDICTXT = 'L'.
  ENDIF.

  IF ( PV_GUBUN = 'E' ).
    APPEND PS_FCAT TO PT_FCAT.
  ENDIF.

ENDFORM.
