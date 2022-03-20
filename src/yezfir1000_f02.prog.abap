*&---------------------------------------------------------------------*
*&  Include           YEZFIR1000_F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER_0110
*&---------------------------------------------------------------------*
*       ALV Grid 를 위한 Container 생성
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER_0110 .

* Create a custom container control for ALV Control
  CREATE OBJECT GO_CUST_0110
    EXPORTING
      CONTAINER_NAME              = C_CON_0110
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

  IF ( SY-SUBRC = 0 ).
*   Create an instance of alv control
    CREATE OBJECT GO_GRID_0110
      EXPORTING
        I_PARENT = GO_CUST_0110.
  ELSE.
*   ALV Container 를 생성할 수 없습니다.
    MESSAGE A005(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_LAYOUT_0110
*&---------------------------------------------------------------------*
*       ALV Layout setting
*----------------------------------------------------------------------*
FORM SET_ALV_LAYOUT_0110 .

  GS_LAYO_0110-SEL_MODE   = 'A'.
  GS_LAYO_0120-SMALLTITLE = ABAP_TRUE.
  GS_LAYO_0110-ZEBRA      = ABAP_TRUE.
  GS_LAYO_0110-CWIDTH_OPT = ABAP_TRUE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_SORT_0110
*&---------------------------------------------------------------------*
*       ALV 정렬 순서를 정한다.
*----------------------------------------------------------------------*
FORM SET_ALV_SORT_0110 .

  PERFORM SET_SORTORDER_PROC IN PROGRAM YEZFIS0010
                        TABLES GT_SORT_0110[]
                        USING  SY-REPID
                               SY-DYNNR
                               C_CON_0110.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_FIELDCAT_0110
*&---------------------------------------------------------------------*
*       Build Field Catalog for list display
*----------------------------------------------------------------------*
FORM SET_ALV_FIELDCAT_0110 .

  PERFORM SET_FIELDCAT_PROC IN PROGRAM YEZFIS0010
                       TABLES GT_FCAT_0110[]
                       USING  SY-REPID
                              SY-DYNNR
                              C_CON_0110.

  LOOP AT GT_FCAT_0110 INTO GS_FCAT_0110.
    DATA(LV_INDEX) = SY-TABIX.

    CASE GS_FCAT_0110-FIELDNAME.
        " 상태
      WHEN 'STATU'.
        GS_FCAT_0110-EMPHASIZE = 'C700'.
        " 전표번호
      WHEN 'BELNR'.
        GS_FCAT_0110-EMPHASIZE = 'C300'.
        " 그룹전표
      WHEN 'GRP_SLIP_NO'.
        GS_FCAT_0110-EMPHASIZE = 'C400'.
    ENDCASE.

    MODIFY GT_FCAT_0110 FROM GS_FCAT_0110 INDEX LV_INDEX
                        TRANSPORTING EMPHASIZE.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ALV_ALV_DISPLAY_0110
*&---------------------------------------------------------------------*
*       ALV 를 조회할 수 있도록 한다.
*----------------------------------------------------------------------*
FORM ALV_ALV_DISPLAY_0110 .

  GS_VARI_0110-REPORT  = SY-REPID.

  CALL METHOD GO_GRID_0110->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_BYPASSING_BUFFER = 'X'
      I_BUFFER_ACTIVE    = 'X'
      IS_LAYOUT          = GS_LAYO_0110
      I_SAVE             = 'A'
      IS_VARIANT         = GS_VARI_0110
    CHANGING
      IT_OUTTAB          = GT_ALL[]
      IT_FIELDCATALOG    = GT_FCAT_0110[]
      IT_SORT            = GT_SORT_0110[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV_0110
*&---------------------------------------------------------------------*
*       ALV Grid 새로고침
*----------------------------------------------------------------------*
FORM REFRESH_ALV_0110 .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LT_ROWID    TYPE LVC_T_ROID.
  DATA: LS_ROWID    TYPE LVC_S_ROID.
  DATA: LS_STABLE   TYPE LVC_S_STBL.

  CLEAR: LT_ROWID[].
  CLEAR: LS_ROWID.
  CLEAR: LS_STABLE.

*----------------------------------------------------------------------*
* 기존 ALV 선택된 row 정보 가져오기 ( Refresh 후 재설정 위하여 )
*----------------------------------------------------------------------*
  CALL METHOD GO_GRID_0110->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROWID.

*----------------------------------------------------------------------*
* ALV Grid 새로고침
*----------------------------------------------------------------------*
  LS_STABLE-ROW = ABAP_TRUE.
  LS_STABLE-COL = ABAP_TRUE.

* Redisplay Table
  CALL METHOD GO_GRID_0110->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE         " With Stable Rows/Columns
      I_SOFT_REFRESH = ' '.              " Without Sort, Filter, etc

* Column 최적화
  CALL METHOD GO_GRID_0110->SET_OPTIMIZE_ALL_COLS.

* Grid 에서 선택된 row 에 대한 정보를 재설정한다.
  CALL METHOD GO_GRID_0110->SET_SELECTED_ROWS
    EXPORTING
      IT_ROW_NO = LT_ROWID.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER_0110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0110 .

  CREATE OBJECT GO_EVNT_0110.
  SET HANDLER GO_EVNT_0110->HANDLE_HOTSPOT_CLICK FOR GO_GRID_0110.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS_0110
*&---------------------------------------------------------------------*
*       110번 화면 ALV  의 선택된 ROW 정보 가져 오기
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS_0110 .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LT_SELECTED_ROW   TYPE LVC_T_ROW.
  DATA: LS_SELECTED_ROW   TYPE LVC_S_ROW.
  DATA: LS_ALL            TYPE YEZFIS0200.

  CLEAR: LT_SELECTED_ROW[].
  CLEAR: LS_SELECTED_ROW.
  CLEAR: LS_ALL.

*----------------------------------------------------------------------*
* 선택된 라인 가져오기
*----------------------------------------------------------------------*
  CALL METHOD GO_GRID_0110->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_SELECTED_ROW.

*----------------------------------------------------------------------*
* 기존 선택라인 정보 삭제
*----------------------------------------------------------------------*
  LS_ALL-SELYN = SPACE.
  MODIFY GT_ALL FROM LS_ALL TRANSPORTING SELYN WHERE SELYN = ABAP_TRUE.

*----------------------------------------------------------------------*
* 신규 선택라인 정보 반영
*----------------------------------------------------------------------*
  LOOP AT LT_SELECTED_ROW INTO LS_SELECTED_ROW.
    READ TABLE GT_ALL INTO LS_ALL INDEX LS_SELECTED_ROW-INDEX.

    IF ( SY-SUBRC = 0 ).
      LS_ALL-SELYN = ABAP_TRUE.
      MODIFY GT_ALL FROM LS_ALL INDEX LS_SELECTED_ROW-INDEX TRANSPORTING SELYN.
      CLEAR LS_ALL.
    ENDIF.
  ENDLOOP.

ENDFORM.
