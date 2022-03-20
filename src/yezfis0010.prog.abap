*&---------------------------------------------------------------------*
*& Report YEZFIS0010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YEZFIS0010.

*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT_PROC
*&---------------------------------------------------------------------*
*       화면 별 FIELD CATALOG 구성
*----------------------------------------------------------------------*
FORM SET_FIELDCAT_PROC  TABLES   PT_FIELDCAT STRUCTURE LVC_S_FCAT
                        USING    PV_PROGNAME
                                 PV_DYNNUMB
                                 PV_SCRFNAME.

  DATA: LT_FIELDCAT   TYPE STANDARD TABLE OF YEZFIS1010.
  DATA: LS_FIELDCAT   TYPE YEZFIS1010.
  DATA: LS_FCAT       TYPE LVC_S_FCAT.

  PERFORM SELECT_FIELDCAT_PROC TABLES LT_FIELDCAT[]
                               USING  PV_PROGNAME
                                      PV_DYNNUMB
                                      PV_SCRFNAME.

  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
    PERFORM FILL_FIELDCAT IN PROGRAM YEZFIS0010
                          TABLES PT_FIELDCAT USING:
             " STRUCTURE START/END   FIELDNAME      VALUE
               LS_FCAT   'S'         'COL_POS'      LS_FIELDCAT-COL_POS,
               LS_FCAT   ' '         'FIELDNAME'    LS_FIELDCAT-FIELDNAME,
               LS_FCAT   ' '         'KEY'          LS_FIELDCAT-KEY_FIELD,
               LS_FCAT   ' '         'REF_TABLE'    LS_FIELDCAT-REF_TABLE,
               LS_FCAT   ' '         'REF_FIELD'    LS_FIELDCAT-REF_FIELD,
               LS_FCAT   ' '         'CFIELDNAME'   LS_FIELDCAT-CFIELDNAME,
               LS_FCAT   ' '         'CHECKBOX'     LS_FIELDCAT-CHECKBOX,
               LS_FCAT   ' '         'HOTSPOT'      LS_FIELDCAT-HOTSPOT,
               LS_FCAT   ' '         'JUST'         LS_FIELDCAT-JUST,
               LS_FCAT   ' '         'DO_SUM'       LS_FIELDCAT-DO_SUM,
               LS_FCAT   ' '         'NO_OUT'       LS_FIELDCAT-NO_OUT,
               LS_FCAT   ' '         'TECH'         LS_FIELDCAT-TECH,
               LS_FCAT   ' '         'F4AVAILABL'   LS_FIELDCAT-F4AVAILABL,
               LS_FCAT   'E'         'REPTEXT'      LS_FIELDCAT-REPTEXT.
  ENDLOOP.

ENDFORM.

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
         A~F4AVAILABL AS F4AVAILABL
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
*&      Form  SET_SORTORDER_PROC
*&---------------------------------------------------------------------*
*       화면 별 FIELD CATALOG 구성
*----------------------------------------------------------------------*
FORM SET_SORTORDER_PROC  TABLES   PT_SORT STRUCTURE LVC_S_SORT
                         USING    PV_PROGNAME
                                  PV_DYNNUMB
                                  PV_SCRFNAME.

  DATA: LT_SORT   TYPE STANDARD TABLE OF YEZFIS1020.
  DATA: LS_SORT   TYPE YEZFIS1020.

  PERFORM SELECT_SORT_ORDER_PROC TABLES LT_SORT[]
                                 USING  PV_PROGNAME
                                        PV_DYNNUMB
                                        PV_SCRFNAME.

  LOOP AT LT_SORT INTO LS_SORT.
    CHECK ( LS_SORT-SPOS IS NOT INITIAL ).

    PERFORM FILL_ALV_SORT TABLES  PT_SORT USING:
             LS_SORT-SPOS              " SPOS
             LS_SORT-FIELDNAME         " FIELDNAME
             LS_SORT-UP                " UP
             LS_SORT-DOWN              " DOWN
             LS_SORT-SUBTOT.           " SUBTOT
  ENDLOOP.

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

*&---------------------------------------------------------------------*
*&      Form  FILL_ALV_SORT
*&---------------------------------------------------------------------*
*       ALV 정렬기준 구성
*----------------------------------------------------------------------*
*      <--PT_SORT
*      -->PV_SPOS
*      -->PV_FIELDNAME
*      -->PV_UP
*      -->PV_DOWN
*      -->PV_SUBTOT
*----------------------------------------------------------------------*
FORM FILL_ALV_SORT  TABLES   PT_SORT   STRUCTURE LVC_S_SORT
                    USING    VALUE(PV_SPOS)
                             VALUE(PV_FIELDNAME)
                             VALUE(PV_UP)
                             VALUE(PV_DOWN)
                             VALUE(PV_SUBTOT).

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LS_SORT   TYPE LVC_S_SORT.

  CLEAR: LS_SORT.

*----------------------------------------------------------------------*
* 정렬순서 지정
*----------------------------------------------------------------------*
  LS_SORT-SPOS      = PV_SPOS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP        = PV_UP.
  LS_SORT-DOWN      = PV_DOWN.
  LS_SORT-SUBTOT    = PV_SUBTOT.

  APPEND LS_SORT TO PT_SORT.
  CLEAR: LS_SORT.

ENDFORM.
