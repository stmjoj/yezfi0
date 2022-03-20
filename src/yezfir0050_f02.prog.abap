*&---------------------------------------------------------------------*
*&  Include           YEZFIR0050_F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER_0100
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0100 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CUST_0100
    EXPORTING
      CONTAINER_NAME              = C_CON_0100
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

  IF ( SY-SUBRC = 0 ).
*   Create an instance of alv control
    CREATE OBJECT GO_GRID_0100
      EXPORTING
        I_PARENT = GO_CUST_0100.
  ELSE.
*   ALV Container 를 생성할 수 없습니다.
    MESSAGE A005(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LAYOUT_0100
*&---------------------------------------------------------------------*
*       ALV Layout setting
*----------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0100 .

  GS_LAYO_0100-SEL_MODE   = 'A'.
  GS_LAYO_0100-ZEBRA      = ABAP_TRUE.
  GS_LAYO_0100-CWIDTH_OPT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0100
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0100 .

  PERFORM SET_SORTORDER_PROC IN PROGRAM YEZFIS0010
                        TABLES GT_SORT_0100[]
                        USING  SY-REPID
                               SY-DYNNR
                               C_CON_0100.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0100
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0100 .

  PERFORM SET_FIELDCAT_PROC IN PROGRAM YEZFIS0010
                       TABLES GT_FCAT_0100[]
                       USING  SY-REPID
                              SY-DYNNR
                              C_CON_0100.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ALV_ALV_DISPLAY_0100
*&---------------------------------------------------------------------*
*       ALV 를 조회할 수 있도록 한다.
*----------------------------------------------------------------------*
FORM ALV_ALV_DISPLAY_0100 .

  GS_VARI_0100-REPORT  = SY-REPID.

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
      IS_LAYOUT          = GS_LAYO_0100
      I_SAVE             = 'A'
      IS_VARIANT         = GS_VARI_0100
    CHANGING
      IT_OUTTAB          = GT_OUTTAB[]
      IT_FIELDCATALOG    = GT_FCAT_0100[]
      IT_SORT            = GT_SORT_0100[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV_0100
*&---------------------------------------------------------------------*
*       ALV Grid 새로고침
*----------------------------------------------------------------------*
FORM REFRESH_ALV_0100 .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LS_STABLE   TYPE LVC_S_STBL.

  CLEAR: LS_STABLE.

*----------------------------------------------------------------------*
* ALV Grid 새로고침
*----------------------------------------------------------------------*
  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

  CALL METHOD GO_GRID_0100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE         " With Stable Rows/Columns
      I_SOFT_REFRESH = ' '.              " Without Sort, Filter, etc

  CALL METHOD GO_GRID_0100->SET_OPTIMIZE_ALL_COLS.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0100 .

  CREATE OBJECT GO_EVENT_RECEIVER.
  SET HANDLER GO_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GO_GRID_0100.

ENDFORM.
