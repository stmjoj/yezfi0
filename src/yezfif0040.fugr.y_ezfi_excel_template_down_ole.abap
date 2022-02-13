FUNCTION Y_EZFI_EXCEL_TEMPLATE_DOWN_OLE.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IV_PRGID) TYPE  PROGRAMM
*"     REFERENCE(IV_TXTID) TYPE  YEZ_TEXTID8
*"  EXPORTING
*"     REFERENCE(EV_RETURN) TYPE  BAPI_MTYPE
*"     REFERENCE(EV_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
* Local 변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_DEFAULT_DIR   TYPE STRING.
  DATA: LV_FILENAME      TYPE STRING.
  DATA: LV_PATH          TYPE STRING.
  DATA: LV_FULL_PATH     TYPE STRING.
  DATA: LV_USER_ACTION   TYPE I.

  DATA: LO_APPLICATION   TYPE OLE2_OBJECT.
  DATA: LO_WORKBOOK      TYPE OLE2_OBJECT.
  DATA: LO_SHEET         TYPE OLE2_OBJECT.
  DATA: LO_CELLS         TYPE OLE2_OBJECT.
  DATA: LO_COLUMNS       TYPE OLE2_OBJECT.

  CLEAR: LV_DEFAULT_DIR.
  CLEAR: LV_FILENAME.
  CLEAR: LV_PATH.
  CLEAR: LV_FULL_PATH.
  CLEAR: LV_USER_ACTION.

  CLEAR: LO_APPLICATION.
  CLEAR: LO_WORKBOOK.
  CLEAR: LO_SHEET.
  CLEAR: LO_CELLS.

  CLEAR: EV_RETURN.
  CLEAR: EV_MESSAGE.

*----------------------------------------------------------------------*
* 프로그램 별 Excel Template 정보 가져오기
*----------------------------------------------------------------------*
  SELECT SEQNO
       , COLNM
    INTO TABLE @DATA(LT_COLNM)
    FROM YEZFIT1000
   WHERE PRGID = @IV_PRGID
     AND TXTID = @IV_TXTID
   ORDER BY SEQNO.

  IF ( LT_COLNM[] IS INITIAL ).
    EV_RETURN  = 'E'.
    " TEXT-E01 : 프로그램 &1 에 대한 Excel Template 정보를 찾을 수 없습니다.
    EV_MESSAGE = TEXT-E01.
    REPLACE '&1' IN EV_MESSAGE WITH IV_PRGID.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* File 저장위치 결정
*----------------------------------------------------------------------*
* 데스크탑 디렉토리 결정
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY
    CHANGING
      DESKTOP_DIRECTORY    = LV_DEFAULT_DIR
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.

  CALL METHOD CL_GUI_CFW=>UPDATE_VIEW
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2
      OTHERS            = 3.

  IF ( LV_DEFAULT_DIR IS INITIAL ).
    LV_DEFAULT_DIR = 'C:\'.
  ENDIF.

* 파일저장위치 결정 팝업
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE         = CONV STRING( TEXT-001 )       " 저장
      DEFAULT_EXTENSION    = 'XLSX'
      DEFAULT_FILE_NAME    = 'DEFAULT_FILE'
      WITH_ENCODING        = 'X'
      FILE_FILTER          = 'EXCEL FILES (*.XLS)|*.XLS|EXCEL FILES (*.XLSX)|*.XLSX|'
      INITIAL_DIRECTORY    = LV_DEFAULT_DIR
    CHANGING
      FILENAME             = LV_FILENAME
      PATH                 = LV_PATH
      FULLPATH             = LV_FULL_PATH
      USER_ACTION          = LV_USER_ACTION
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.

  IF ( SY-SUBRC = 0 ).
    IF ( LV_USER_ACTION <> CL_GUI_FRONTEND_SERVICES=>ACTION_OK ).
      EV_RETURN  = 'E'.
      " MESSAGE : 수행을 취소하였습니다.
      MESSAGE S009(YFIM) INTO EV_MESSAGE.
      EXIT.
    ENDIF.
  ELSE.
    EV_RETURN  = 'E'.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
       INTO EV_MESSAGE.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* Excel Template 실행
*----------------------------------------------------------------------*
* OLE OBJECT 생성 & 실행
  CREATE OBJECT LO_APPLICATION 'Excel.Application'.

* 화면 DISPLAY 설정 (1을 설정하면 DISPLAY)
  SET PROPERTY OF LO_APPLICATION 'VISIBLE' = 1.

* WORKBOOK 및 WORKBOOK 설정 & OPEN
  CALL METHOD OF LO_APPLICATION 'Workbooks' = LO_WORKBOOK.
  CALL METHOD OF LO_WORKBOOK 'Add'.

* 최초 실행 SHEET는 첫번째
  CALL METHOD OF LO_APPLICATION 'WORKSHEETS' = LO_SHEET
    EXPORTING
      #1 = 1.

  CALL METHOD OF LO_SHEET 'Activate'.
  SET PROPERTY OF LO_SHEET 'Name' = 'Sheet1'.
  GET PROPERTY OF LO_APPLICATION 'ActiveWorkbook' = LO_WORKBOOK.

* Excel Template 데이터 입력
  LOOP AT LT_COLNM INTO DATA(LS_COLNM).
    PERFORM EXCEL_TEMPLATE_FILL_SHEET USING LO_APPLICATION
                                            01
                                            LS_COLNM-SEQNO
                                            LS_COLNM-COLNM.
  ENDLOOP.

* Column 자동맞춤
  CALL METHOD OF LO_APPLICATION 'Cells' = LO_CELLS.

  CALL METHOD OF LO_CELLS 'Select' .
  GET PROPERTY OF LO_CELLS 'COLUMNS' = LO_COLUMNS.
  SET PROPERTY OF LO_COLUMNS 'AutoFit' = 2.

* 실행 파일 저장
  CALL METHOD OF LO_WORKBOOK 'SaveAs' EXPORTING #1 = LV_FULL_PATH.

ENDFUNCTION.
