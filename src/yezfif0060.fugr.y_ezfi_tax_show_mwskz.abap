FUNCTION Y_EZFI_TAX_SHOW_MWSKZ.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) LIKE  BKPF-BUKRS
*"     REFERENCE(I_MWSKZ) LIKE  BSET-MWSKZ
*"     VALUE(I_TXJCD) LIKE  BSET-TXJCD OPTIONAL
*"     REFERENCE(I_TXDAT) LIKE  BSET-TXDAT OPTIONAL
*"     REFERENCE(I_SHOW_INACTIVE) TYPE  C DEFAULT 'X'
*"     REFERENCE(I_SCREEN_START_COLUMN) TYPE  I DEFAULT 5
*"     REFERENCE(I_SCREEN_START_LINE) TYPE  I DEFAULT 5
*"     REFERENCE(I_SCREEN_END_COLUMN) TYPE  I DEFAULT 60
*"     REFERENCE(I_SCREEN_END_LINE) TYPE  I DEFAULT 15
*"  EXPORTING
*"     REFERENCE(ES_MWSKZ) TYPE  YEZFIS0090
*"  EXCEPTIONS
*"      READING_MWSKZ
*"      READING_PRICING_DATA
*"      READING_CONDITION_TYPES
*"      DETERMINE_TXJCD
*"      READING_TAX_ACCOUNTS
*"      ERROR_ALV_CALL
*"      READING_TTXD
*"      TXDAT_NECESSARY
*"----------------------------------------------------------------------

  TYPE-POOLS: SLIS.

  TABLES : KONP , T683T, T685T.

  DATA : L_T683S LIKE T683S OCCURS 1 WITH HEADER LINE,
         L_A053  LIKE A053 OCCURS 1 WITH HEADER LINE,
         L_T030K LIKE T030K OCCURS 1 WITH HEADER LINE,
         L_T030B LIKE T030B OCCURS 1 WITH HEADER LINE,
         L_T007A LIKE T007A,
         L_TTXD  LIKE TTXD.

  DATA : BEGIN OF LT_OUTTAB OCCURS 5,
           VTEXT      LIKE T683T-VTEXT,
           KSCHL      LIKE T683S-KSCHL,
           KTOSL      LIKE T030K-KTOSL,
           PERCENTAGE TYPE P DECIMALS 3,
           ACTIVE     TYPE C,
           KSTAT      LIKE T683S-KSTAT,
           KOFRM      LIKE T683S-KOFRM,
           HKONT      LIKE BSET-HKONT,
           KOFRA      LIKE T683S-KOFRA.
  DATA : END OF LT_OUTTAB.

  DATA : L_REPID      LIKE SY-REPID,        "Program name (ALV)
         LT_ALV_EVENT TYPE SLIS_T_EVENT, "Table of Events
         LT_FIELDCAT  TYPE SLIS_T_FIELDCAT_ALV, "Infos about
         X_ERRORCODE.

  IF NOT I_TXJCD IS INITIAL.
    IF I_TXDAT IS INITIAL.
      X_ERRORCODE = 'X'.
      PERFORM ERROR_HANDLING_MWSKZ USING 8.
    ENDIF.
  ENDIF.
  CHECK X_ERRORCODE IS INITIAL.

*save repid for alv
  L_REPID = SY-REPID.

  CALL FUNCTION 'FI_TAX_GET_MWSKZ_EXISTENCE' "Tax indicator properties
    EXPORTING
      I_BUKRS         = I_BUKRS
      I_MWSKZ         = I_MWSKZ
    IMPORTING
      E_T007A         = L_T007A
    EXCEPTIONS
      MWSKZ_NOT_FOUND = 1.

  IF SY-SUBRC <> 0.
    X_ERRORCODE = 'X'.
    PERFORM ERROR_HANDLING_MWSKZ USING 1.
  ENDIF.
  CHECK X_ERRORCODE IS INITIAL.

  CALL FUNCTION 'FI_TAX_GET_PRICING_DATA'
    EXPORTING
      I_BUKRS = I_BUKRS
    TABLES
      T_T683S = L_T683S
    EXCEPTIONS
      OTHERS  = 4.
  IF SY-SUBRC <> 0.
    X_ERRORCODE = 'X'.
    PERFORM ERROR_HANDLING_MWSKZ USING 2.
  ENDIF.
  CHECK X_ERRORCODE IS INITIAL.


  CALL FUNCTION 'FI_TAX_GET_CONDITION_TYPES'
    EXPORTING
      I_BUKRS         = I_BUKRS
      I_MWSKZ         = I_MWSKZ
      I_TXJCD         = I_TXJCD
      I_PRSDT         = I_TXDAT           "#EC DOM_EQUAL
      I_XDEEP         = 'X'
    TABLES
      T_A053          = L_A053
    EXCEPTIONS
      TXJCD_NOT_FOUND = 6
      INVALID_LENGTH  = 7
      OTHERS          = 9.

  CASE SY-SUBRC.
    WHEN 0.
    WHEN 6 OR 7.
      X_ERRORCODE = 'X'.
      PERFORM ERROR_HANDLING_MWSKZ USING 4.
    WHEN OTHERS.
      X_ERRORCODE = 'X'.
      PERFORM ERROR_HANDLING_MWSKZ USING 3.
  ENDCASE.
  CHECK X_ERRORCODE IS INITIAL.

  IF NOT I_TXJCD IS INITIAL.

    CALL FUNCTION 'FI_TAX_GET_TXJCD_STRUCTURE'
      EXPORTING
        I_BUKRS = I_BUKRS
      IMPORTING
        E_TTXD  = L_TTXD
      EXCEPTIONS
        OTHERS  = 4.
    IF SY-SUBRC <> 0.
      X_ERRORCODE = 'X'.
      PERFORM ERROR_HANDLING_MWSKZ USING 7.
    ENDIF.
    CHECK X_ERRORCODE IS INITIAL.

    DESCRIBE TABLE L_A053.
    CASE SY-TFILL.
      WHEN '0'.
        X_ERRORCODE = 'X'.
      WHEN '1'.
        IF L_TTXD-LENG2 NE 0.
          X_ERRORCODE = 'X'.
        ENDIF.
      WHEN '2'.
        IF L_TTXD-LENG3 NE 0.
          X_ERRORCODE = 'X'.
        ENDIF.
      WHEN '3'.
        IF L_TTXD-LENG4 NE 0.
          X_ERRORCODE = 'X'.
        ENDIF.
      WHEN '4'.
        IF L_TTXD-LENG4 EQ 0.
          X_ERRORCODE = 'X'.
        ENDIF.
    ENDCASE.

    IF X_ERRORCODE = 'X'.
      PERFORM ERROR_HANDLING_MWSKZ USING 4.
    ENDIF.
    CHECK X_ERRORCODE IS INITIAL.
  ENDIF.

  CALL FUNCTION 'FI_TAX_GET_TAX_ACC_BY_KSCHL'
    EXPORTING
      I_BUKRS       = I_BUKRS
      I_MWSKZ       = I_MWSKZ
      I_TXJCD       = I_TXJCD
    TABLES
      T_T030K       = L_T030K
      T_T030B       = L_T030B
    EXCEPTIONS
      T030_NO_ENTRY = 9
      OTHERS        = 4.
  IF SY-SUBRC <> 0 AND SY-SUBRC <> 9.
    X_ERRORCODE = 'X'.
    PERFORM ERROR_HANDLING_MWSKZ USING 5.
  ENDIF.
  CHECK X_ERRORCODE IS INITIAL.


  LOOP AT L_T683S.

    CLEAR LT_OUTTAB.
    CLEAR KONP.
    LOOP AT L_A053 WHERE KSCHL = L_T683S-KSCHL.
      SELECT SINGLE * FROM KONP WHERE KNUMH = L_A053-KNUMH.
      LT_OUTTAB-PERCENTAGE = KONP-KBETR / 10.
      LT_OUTTAB-ACTIVE     = 'X'.
    ENDLOOP.

    IF I_SHOW_INACTIVE IS INITIAL.
      CHECK NOT LT_OUTTAB-ACTIVE IS INITIAL.
    ENDIF.

    SELECT SINGLE * FROM T685T WHERE SPRAS = SY-LANGU
                                 AND   KVEWE = L_T683S-KVEWE
                                 AND   KAPPL = L_T683S-KAPPL
                                 AND   KSCHL = L_T683S-KSCHL.
* read text
    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING T685T TO LT_OUTTAB.
    ELSE.
      SELECT SINGLE * FROM T683T WHERE SPRAS = SY-LANGU
                                 AND   KVEWE = L_T683S-KVEWE
                                 AND   KAPPL = L_T683S-KAPPL
                                 AND   KALSM = L_T683S-KALSM
                                 AND   STUNR = L_T683S-STUNR.
      MOVE-CORRESPONDING T683T TO LT_OUTTAB.
    ENDIF.

    MOVE-CORRESPONDING L_T683S TO LT_OUTTAB.
    LT_OUTTAB-KTOSL = L_T683S-KVSL1.

    LOOP AT L_T030K WHERE KTOSL = L_T683S-KVSL1.
      IF LT_OUTTAB-ACTIVE = 'X'.
        LT_OUTTAB-HKONT = L_T030K-KONTS.

* Begin of 로직추가
        MOVE-CORRESPONDING LT_OUTTAB TO ES_MWSKZ.
* End of 로직추가
      ENDIF.
    ENDLOOP.

    APPEND LT_OUTTAB.

  ENDLOOP.

* Begin of 주석처리
*  PERFORM DETERMINE_HEADER USING  L_T683S-KALSM
*                                  I_MWSKZ
*                                  I_TXJCD
*                                  I_TXDAT
*                                  'X'. "fill statics variables
*
*  PERFORM PREPARE_ALV_MWSKZ   USING    L_REPID
*                              CHANGING LT_FIELDCAT
*                                       LT_ALV_EVENT.
*
*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*    EXPORTING
*      I_CALLBACK_PROGRAM    = L_REPID
*      IT_FIELDCAT           = LT_FIELDCAT
*      I_DEFAULT             = 'X'
*      I_SAVE                = 'A'
*      IT_EVENTS             = LT_ALV_EVENT
*      I_SCREEN_START_COLUMN = I_SCREEN_START_COLUMN
*      I_SCREEN_START_LINE   = I_SCREEN_START_LINE
*      I_SCREEN_END_COLUMN   = I_SCREEN_END_COLUMN
*      I_SCREEN_END_LINE     = I_SCREEN_END_LINE
*    TABLES
*      T_OUTTAB              = LT_OUTTAB
*    EXCEPTIONS
*      OTHERS                = 8.
*
*  IF SY-SUBRC <> 0.
*    X_ERRORCODE = 'X'.
*    PERFORM ERROR_HANDLING_MWSKZ USING 6.
*  ENDIF.
* End of 주석처리

ENDFUNCTION.

*---------------------------------------------------------------------*
*       FORM prepare_alv                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  u_repid                                                       *
*  -->  lt_fieldcat                                                   *
*  -->  lt_alv_event                                                  *
*---------------------------------------------------------------------*
FORM PREPARE_ALV_MWSKZ USING    U_REPID TYPE SY-REPID
                       CHANGING LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV
                                LT_ALV_EVENT TYPE SLIS_T_EVENT.

  DATA: L_ALV_EVENT TYPE SLIS_ALV_EVENT.      "Field String

* Append the necessary fields to LT_FIELDCAT
  PERFORM APPEND_FIELDCAT_MWSKZ TABLES LT_FIELDCAT
                                USING:
                                'PERCENTAGE' SPACE  SPACE ,
                                'ACTIVE'     SPACE  'X',
                                'VTEXT' 'T685T' SPACE,
                                'KTOSL' 'T030K' SPACE,
                                'HKONT' 'BSET'  SPACE,
                                'KSTAT' 'T683S' SPACE,
                                'KSCHL' 'T683S' SPACE,
                                'KOFRM' 'T683S' SPACE,
                                'KOFRA' 'T683S' SPACE.

* Insert some events into lt_alv_event
  L_ALV_EVENT-NAME = SLIS_EV_TOP_OF_LIST.
  L_ALV_EVENT-FORM = 'PRINT_HEADER_MWSKZ'.
  APPEND L_ALV_EVENT TO LT_ALV_EVENT.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM append_fieldcat_mwskz                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  l_lt_fieldcat                                                 *
*  -->  u_l_fieldname                                                 *
*  -->  u_l_ref_tabname                                               *
*  -->  u_l_no_out                                                    *
*---------------------------------------------------------------------*
FORM APPEND_FIELDCAT_MWSKZ
      TABLES
        L_LT_FIELDCAT
      USING
        U_L_FIELDNAME   TYPE SLIS_FIELDCAT_ALV-FIELDNAME
        U_L_REF_TABNAME TYPE SLIS_FIELDCAT_ALV-REF_TABNAME
        U_L_NO_OUT       TYPE SLIS_FIELDCAT_ALV-NO_OUT.

  DATA: L_FIELDCAT TYPE SLIS_FIELDCAT_ALV.        "field string

  CASE U_L_FIELDNAME.
    WHEN 'PERCENTAGE'.
      L_FIELDCAT-SELTEXT_S = TEXT-014.
      L_FIELDCAT-OUTPUTLEN = 7.
    WHEN 'ACTIVE'.     L_FIELDCAT-SELTEXT_S = TEXT-015.
    WHEN OTHERS.       L_FIELDCAT-SELTEXT_S = SPACE.
  ENDCASE.

  L_FIELDCAT-FIELDNAME      = U_L_FIELDNAME.
  L_FIELDCAT-REF_TABNAME    = U_L_REF_TABNAME.
  L_FIELDCAT-NO_OUT         = U_L_NO_OUT.
  APPEND L_FIELDCAT TO L_LT_FIELDCAT.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM determine_header                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  u_l_kalsm                                                     *
*  -->  u_l_mwskz                                                     *
*  -->  u_l_txjcd                                                     *
*  -->  u_l_txdat                                                     *
*  -->  u_l_fill_statics                                              *
*---------------------------------------------------------------------*
FORM DETERMINE_HEADER USING U_L_KALSM
                            U_L_MWSKZ
                            U_L_TXJCD
                            U_L_TXDAT
                            U_L_FILL_STATICS.
  STATICS: LS_MWSKZ LIKE BSET-MWSKZ,
           LS_KALSM LIKE T683S-KALSM,
           LS_TXJCD LIKE BSET-TXJCD,
           LS_TXDAT LIKE BSET-TXDAT,
           LS_T007S LIKE T007S.
  IF NOT U_L_FILL_STATICS IS INITIAL.
    LS_MWSKZ = U_L_MWSKZ.
    LS_KALSM = U_L_KALSM.
    LS_TXJCD = U_L_TXJCD.
    LS_TXDAT = U_L_TXDAT.

    CALL FUNCTION 'MM_T007S_READ'
      EXPORTING
        I_SPRAS = SY-LANGU
        I_KALSM = LS_KALSM
        I_MWSKZ = LS_MWSKZ
      IMPORTING
        E_T007S = LS_T007S
      EXCEPTIONS
        OTHERS  = 4.
  ELSE.
    WRITE : /  LS_T007S-TEXT1(25), ':' COLOR COL_HEADING INVERSE,
               LS_MWSKZ, LS_KALSM.

    IF NOT LS_TXJCD IS INITIAL.
      WRITE : / LS_TXJCD, LS_TXDAT.
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM print_header                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PRINT_HEADER_MWSKZ.                                    "#EC CALLED

  PERFORM DETERMINE_HEADER USING SPACE SPACE SPACE SPACE SPACE.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM error_handling_mwskz                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  error_no                                                      *
*---------------------------------------------------------------------*
FORM ERROR_HANDLING_MWSKZ USING ERROR_NO LIKE SY-SUBRC.

  CHECK NOT ERROR_NO IS INITIAL.
  CASE ERROR_NO.
    WHEN 1.    MESSAGE_RAISE READING_MWSKZ .
    WHEN 2.    MESSAGE_RAISE READING_PRICING_DATA.
    WHEN 3.    MESSAGE_RAISE READING_CONDITION_TYPES.
    WHEN 4.    MESSAGE_RAISE DETERMINE_TXJCD.
    WHEN 5.    MESSAGE_RAISE READING_TAX_ACCOUNTS.
    WHEN 6.    MESSAGE_RAISE ERROR_ALV_CALL.
    WHEN 7.    MESSAGE_RAISE READING_TTXD.
    WHEN 8.    MESSAGE_RAISE TXDAT_NECESSARY.
  ENDCASE.                             "error_no

ENDFORM.                               "error_handling.
