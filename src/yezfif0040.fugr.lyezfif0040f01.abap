*----------------------------------------------------------------------*
***INCLUDE LYFIF0040F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  EXCEL_TEMPLATE_FILL_SHEET
*&---------------------------------------------------------------------*
*       엑셀 템플릿의 Work Sheet 작성
*----------------------------------------------------------------------*
*      --> PO_APPLICATION  Ole Object
*      --> PV_ROW          Row Number
*      --> PV_COL          Column Number
*      --> PV_VALUE        Cell Value
*----------------------------------------------------------------------*
FORM EXCEL_TEMPLATE_FILL_SHEET  USING    PO_APPLICATION   TYPE OLE2_OBJECT
                                         PV_ROW
                                         PV_COL
                                         PV_VALUE.
  DATA: LV_ECELL   TYPE OLE2_OBJECT.

  CALL METHOD OF PO_APPLICATION 'Cells' = LV_ECELL
    EXPORTING
      #1 = PV_ROW
      #2 = PV_COL.

  SET PROPERTY OF LV_ECELL 'Value' = PV_VALUE.

ENDFORM.
