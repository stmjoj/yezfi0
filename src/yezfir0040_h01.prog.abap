*----------------------------------------------------------------------*
***INCLUDE YEZFIR0040_H01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VALUEREQUEST_ZTERM_0212  INPUT
*&---------------------------------------------------------------------*
*       지급조건 F4 HELP 처리
*----------------------------------------------------------------------*
MODULE VALUEREQUEST_ZTERM_0212 INPUT.

  CALL FUNCTION 'FI_F4_ZTERM'
    EXPORTING
      I_KOART = YEZFIS0080-KOART
      I_ZTERM = YEZFIS0080-ZTERM
      I_XSHOW = 'X'.
*    IMPORTING
*      E_ZTERM = ZTERM.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUEREQUEST_MWSKZ_0212  INPUT
*&---------------------------------------------------------------------*
*       세금코드 F4 HELP 처리
*----------------------------------------------------------------------*
MODULE VALUEREQUEST_MWSKZ_0212 INPUT.

  CALL FUNCTION 'FI_F4_MWSKZ'
    EXPORTING
      I_KALSM = GS_BUKRS-KALSM
      I_STBUK = GS_BUKRS-BUKRS
      I_XSHOW = 'X'.
*    IMPORTING
*      E_MWSKZ = MWSKZ.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUEREQUEST_BVTYP_0212  INPUT
*&---------------------------------------------------------------------*
*       파트너은행유형 F4 HELP 처리
*----------------------------------------------------------------------*
MODULE VALUEREQUEST_BVTYP_0212 INPUT.

  CALL FUNCTION 'FI_F4_BVTYP'
    EXPORTING
      I_KUNNR = YEZFIS0080-KUNNR
      I_LIFNR = YEZFIS0080-LIFNR
      I_XSHOW = 'X'.
*    IMPORTING
*      E_BVTYP = BVTYP.

ENDMODULE.
