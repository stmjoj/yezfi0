*&---------------------------------------------------------------------*
*&  Include           YEZFIR0090_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       레포트 Initialization 이벤트 처리
*----------------------------------------------------------------------*
FORM INITIALIZATION .

* Sublogin 에 대한 사용자 정보를 가져 온다.
  PERFORM CHECK_SUBLOGIN_PROC.

  P_BUKRS  = GS_SUBLOGIN-BUKRS.
  P_BUTXT  = GS_SUBLOGIN-BUTXT.

* Selection Screen Function Key 텍스트
  CONCATENATE ICON_XLS
              TEXT-002                        " Excel Template
         INTO SSCRFIELDS-FUNCTXT_01.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_AUTH
*&---------------------------------------------------------------------*
*       회사코드 권한 점검
*----------------------------------------------------------------------*
FORM CHECK_BUKRS_AUTH .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CLEAR: LV_RETURN.
  CLEAR: LV_MESSAGE.

*----------------------------------------------------------------------*
* 회사코드 권한 점검
*----------------------------------------------------------------------*
  CALL FUNCTION 'Y_EZFI_CHECK_BUKRS_AUTH'
    EXPORTING
      IV_BUKRS   = P_BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YEZFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       광역변수 초기화
*----------------------------------------------------------------------*
FORM INIT_PROC .

*----------------------------------------------------------------------*
* 광역변수 초기화
*----------------------------------------------------------------------*
  CLEAR: SAVE_OK.
  CLEAR: OK_CODE.

  CLEAR: GS_BUKRS.
  CLEAR: GV_TITLE.
  CLEAR: GV_BEZEI.

  CLEAR: GV_TOT_CNT.
  CLEAR: GV_UPD_CNT.

  CLEAR: GT_EXCEL[].
  CLEAR: GS_EXCEL.

  CLEAR: GT_UPLOAD[].
  CLEAR: GS_UPLOAD.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GT_RESULT[].
  CLEAR: GS_RESULT.

  CLEAR: GT_CEPC[].
  CLEAR: GS_CEPC.

  GV_TITLE = SY-TITLE.

*----------------------------------------------------------------------*
* ALV 변수 초기화
*----------------------------------------------------------------------*
* 100번 화면
  CLEAR: GO_CONT_0100.
  CLEAR: GO_GRID_0100.

  CLEAR: GT_FCAT_0100.
  CLEAR: GS_FCAT_0100.
  CLEAR: GT_SORT_0100.

  CLEAR: GS_LAYO_0100.
  CLEAR: GS_VARI_0100.

* 200번 화면
  CLEAR: GO_CONT_0200.
  CLEAR: GO_GRID_0200.

  CLEAR: GT_FCAT_0200.
  CLEAR: GS_FCAT_0200.
  CLEAR: GT_SORT_0200.

  CLEAR: GS_LAYO_0200.
  CLEAR: GS_VARI_0200.

*----------------------------------------------------------------------*
* 초기값 설정
*----------------------------------------------------------------------*
  PERFORM GET_COMPANY_INFO.           " 회사코드 정보 설정

  PERFORM GET_PRCTR_LIST.             " 기존 손익센터 목록

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SUBLOGIN_PROC
*&---------------------------------------------------------------------*
*       Sublogin 에 대한 사용자 정보를 가져 온다.
*----------------------------------------------------------------------*
FORM CHECK_SUBLOGIN_PROC .

  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CALL FUNCTION 'Y_EZFI_SUBLOGIN'
*   EXPORTING
*     IV_UNAME    = SY-UNAME
*     IV_SKIP     = ABAP_TRUE
    IMPORTING
      ES_SUBLOGIN = GS_SUBLOGIN
      EV_RETURN   = LV_RETURN
      EV_MESSAGE  = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE E012(YEZFIM).    " 발의부서를 결정할 수 없습니다.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MODIFY_SELSCR
*&---------------------------------------------------------------------*
*       SLECTION-SCREEN 수정
*----------------------------------------------------------------------*
FORM MODIFY_SELSCR .

  LOOP AT SCREEN.
    IF ( SCREEN-NAME = 'P_BUKRS' ).
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_COMPANY_INFO
*&---------------------------------------------------------------------*
*       회사코드 정보 설정
*----------------------------------------------------------------------*
FORM GET_COMPANY_INFO .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CLEAR: LV_RETURN.
  CLEAR: LV_MESSAGE.

*----------------------------------------------------------------------*
* 회사코드 정보 가져오기
*----------------------------------------------------------------------*
  CALL FUNCTION 'Y_EZFI_GET_BUKRS_INFO'
    EXPORTING
      IV_BUKRS   = P_BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE
      ES_BUKRS   = GS_BUKRS.

  IF ( LV_RETURN = 'S' ).
    SELECT SINGLE BEZEI
      FROM TKA01
     WHERE KOKRS = @GS_BUKRS-KOKRS
      INTO @GV_BEZEI.
  ELSE.
    MESSAGE I000(YEZFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXCEL_TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*       EXCEL TEMPLATE DOWNLOAD
*----------------------------------------------------------------------*
FORM EXCEL_TEMPLATE_DOWNLOAD .

  DATA: LV_PRGID   TYPE PROGRAMM.
  DATA: LV_RETURN  TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE TYPE BAPI_MSG.

  CLEAR: LV_PRGID.
  CLEAR: LV_RETURN.
  CLEAR: LV_MESSAGE.

  LV_PRGID = SY-REPID.

  CALL FUNCTION 'Y_EZFI_EXCEL_TEMPLATE_DOWN_OLE'
    EXPORTING
      IV_PRGID   = LV_PRGID
      IV_TXTID   = SPACE
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YEZFIM) WITH LV_MESSAGE.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELSCR_FUNC_KEY_PROC
*&---------------------------------------------------------------------*
*       SELECTION SCREEN 기능키 처리
*----------------------------------------------------------------------*
FORM SELSCR_FUNC_KEY_PROC .

  CASE SY-UCOMM.
    WHEN 'FC01'.
      PERFORM EXCEL_TEMPLATE_DOWNLOAD.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_FILE_PATH
*&---------------------------------------------------------------------*
*       파일 검색 및 선택
*----------------------------------------------------------------------*
FORM GET_FILE_PATH .

* 선택된 파일의 주소를 P_FILE 입력칸에 할당
* METHOD 사용
  DATA: LT_FILE   TYPE FILETABLE.
  DATA: LS_FILE   TYPE FILE_TABLE.
  DATA: LV_RC     TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    CHANGING
      FILE_TABLE = LT_FILE
      RC         = LV_RC.

  READ TABLE LT_FILE INTO LS_FILE INDEX 1.

  IF ( SY-SUBRC = 0 ).
    P_FILE = LS_FILE-FILENAME.
  ENDIF.

* FUNCTION 사용시: CALL FUNCTION 'F4_FILENAME'

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CONVERT_FROM_EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERT_FROM_EXCEL_UPLOAD .

  FIELD-SYMBOLS: <FS>   TYPE ANY.

* 엑셀 데이터 넣기
  LOOP AT GT_EXCEL INTO GS_EXCEL.
    IF ( <FS> IS ASSIGNED ).
      UNASSIGN <FS>.
    ENDIF.

    ASSIGN COMPONENT GS_EXCEL-COL OF STRUCTURE GS_UPLOAD TO <FS>.
    <FS> = GS_EXCEL-VALUE.

    AT END OF ROW.
      APPEND GS_UPLOAD TO GT_UPLOAD.
      CLEAR: GS_UPLOAD.
    ENDAT.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILE_UPLOAD
*&---------------------------------------------------------------------*
*       파일 업로드 진행
*----------------------------------------------------------------------*
FORM FILE_UPLOAD .

  PERFORM UPLOAD_FROM_EXCEL.

  PERFORM CONVERT_FROM_EXCEL_UPLOAD.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_FROM_EXCEL
*&---------------------------------------------------------------------*
*       엑셀 업로드 실행
*----------------------------------------------------------------------*
FORM UPLOAD_FROM_EXCEL .

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FILE      " 파일경로
      I_BEGIN_COL             = 1           " 인식 시작 열 번호
      I_BEGIN_ROW             = 2           " 인식 시작 행 번호
      I_END_COL               = 100         " 필드 수
      I_END_ROW               = 6500        " 최대 행 수
    TABLES
      INTERN                  = GT_EXCEL
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF ( SY-SUBRC <> 0 ).
*   MESSAGE : 엑셀 파일을 불러오는 중 오류가 발생했습니다.
    MESSAGE I000(YEZFIM) WITH TEXT-004.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF ( GT_EXCEL IS INITIAL ).
*   MESSAGE : 데이터가 존재하지 않습니다.
    MESSAGE I013(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXIT_SCREEN_0100
*&---------------------------------------------------------------------*
*       100번 화면 종료
*----------------------------------------------------------------------*
FORM EXIT_SCREEN_0100 .

  DATA: LV_ANSWER   TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR       = TEXT-005     " 경고
      TEXT_QUESTION  = TEXT-008     " 손익센터 업로드를 취소합니다. 계속하시겠습니까?
      TEXT_BUTTON_1  = TEXT-006     " 예
      TEXT_BUTTON_2  = TEXT-007     " 아니오
      DEFAULT_BUTTON = '2'
    IMPORTING
      ANSWER         = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

  IF ( LV_ANSWER = '1' ).
    LEAVE TO SCREEN 0.
  ELSE.
    " 수행을 취소하였습니다.
    MESSAGE S009(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_0100
*&---------------------------------------------------------------------*
*       100번 화면 저장 이벤트 처리
*----------------------------------------------------------------------*
FORM SAVE_DATA_0100 .

*----------------------------------------------------------------------*
* 처리 대상 건수 점검
*----------------------------------------------------------------------*
  IF ( GV_UPD_CNT = 0 ).
*   MESSAGE : 처리대상 자료가 존재하지 않습니다.
    MESSAGE S014(YEZFIM).
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* 사용자 CONFIRM 수행
*----------------------------------------------------------------------*
  DATA: LV_ANSWER   TYPE C.

  CLEAR: LV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR      = TEXT-010         " 알림
      TEXT_QUESTION = TEXT-013         " 손익센터를 생성/변경합니다. 계속하시겠습니까?
      TEXT_BUTTON_1 = TEXT-011         " 예
      TEXT_BUTTON_2 = TEXT-012         " 아니오
    IMPORTING
      ANSWER        = LV_ANSWER.

  IF ( LV_ANSWER <> 1 ).
*   MESSAGE : 수행을 취소하였습니다.
    MESSAGE S009(YEZFIM).
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* BDC 를 통한 G/L 계정 생성/변경
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE STATU = ICON_CREATE
                                      OR STATU = ICON_CHANGE.

    CASE GS_OUTTAB-STATU.
      WHEN ICON_CREATE.             " 신규
        PERFORM PROFIT_CENTER_CREATE.
      WHEN ICON_CHANGE.             " 변경
        PERFORM PROFIT_CENTER_CHANGE.
    ENDCASE.

*   처리 후 표준계층구조 Lock 으로 에러발생하여 1초 Wait
*   에러 메시지 : "Hierarchy is Locked and therefore cannot be chnaged at present"
    WAIT UP TO 1 SECONDS.
  ENDLOOP.

*----------------------------------------------------------------------*
* 처리결과 조회
*----------------------------------------------------------------------*
  CALL SCREEN 0200.

  LEAVE TO SCREEN 0.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXIT_SCREEN_0200
*&---------------------------------------------------------------------*
*       200번 화면 종료
*----------------------------------------------------------------------*
FORM EXIT_SCREEN_0200 .

  DATA: LV_ANSWER   TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR       = TEXT-010     " 알림
      TEXT_QUESTION  = TEXT-014     " 프로그램을 종료합니다. 계속하시겠습니까?
      TEXT_BUTTON_1  = TEXT-006     " 예
      TEXT_BUTTON_2  = TEXT-007     " 아니오
      DEFAULT_BUTTON = '1'
    IMPORTING
      ANSWER         = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

  IF ( LV_ANSWER = '1' ).
    LEAVE TO SCREEN 0.
  ELSE.
    " 수행을 취소하였습니다.
    MESSAGE S001(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       업로드 데이터 화면 출력
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .

  IF ( GT_OUTTAB[] IS NOT INITIAL ).
    LOOP AT GT_OUTTAB INTO GS_OUTTAB.
      GV_TOT_CNT = GV_TOT_CNT + 1.

      IF ( GS_OUTTAB-STATU = ICON_CREATE ) OR
          ( GS_OUTTAB-STATU = ICON_CHANGE ).
        GV_UPD_CNT = GV_UPD_CNT + 1.
      ENDIF.
    ENDLOOP.

    CALL SCREEN 0100.
  ELSE.
*   MESSAGE : 데이터가 존재하지 않습니다.
    MESSAGE I013(YEZFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_PRCTR_LIST
*&---------------------------------------------------------------------*
*       기존 손익센터 목록
*----------------------------------------------------------------------*
FORM GET_PRCTR_LIST .

  SELECT A~PRCTR   AS PRCTR
       , A~DATBI   AS DATBI
       , A~DATAB   AS DATAB
       , A~VERAK   AS VERAK
       , A~KHINR   AS KHINR
       , B~KTEXT   AS KTEXT
       , B~LTEXT   AS LTEXT
    FROM CEPC  AS A LEFT OUTER JOIN
         CEPCT AS B
      ON B~SPRAS = @SY-LANGU
     AND B~PRCTR = A~PRCTR
     AND B~DATBI = A~DATBI
     AND B~KOKRS = A~KOKRS
   WHERE A~KOKRS = @GS_BUKRS-KOKRS
    INTO CORRESPONDING FIELDS OF TABLE @GT_CEPC.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_OUTTAB_PROC
*&---------------------------------------------------------------------*
*       조회를 위한 자료 구성
*----------------------------------------------------------------------*
FORM MAKE_OUTTAB_PROC .

  SORT GT_CEPC BY PRCTR.

  LOOP AT GT_UPLOAD INTO GS_UPLOAD.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = GS_UPLOAD-PRCTR
      IMPORTING
        OUTPUT = GS_UPLOAD-PRCTR.

    MOVE-CORRESPONDING GS_UPLOAD TO GS_OUTTAB.

*   처리유형 구분
    IF ( GS_OUTTAB-PRCTR IS NOT INITIAL ).
      READ TABLE GT_CEPC INTO GS_CEPC
                         WITH KEY PRCTR = GS_OUTTAB-PRCTR
                         BINARY SEARCH
                         TRANSPORTING ALL FIELDS.

      IF ( SY-SUBRC = 0 ).
        IF ( GS_UPLOAD = GS_CEPC ).
          GS_OUTTAB-STATU = ICON_EQUAL.
          GS_OUTTAB-PRTYP = TEXT-017.      " 변경없음
        ELSE.
          GS_OUTTAB-STATU = ICON_CHANGE.
          GS_OUTTAB-PRTYP = TEXT-015.      " 변경
        ENDIF.
      ELSE.
        GS_OUTTAB-STATU = ICON_CREATE.
        GS_OUTTAB-PRTYP = TEXT-016.        " 신규
      ENDIF.

      APPEND GS_OUTTAB TO GT_OUTTAB.
      CLEAR GS_OUTTAB.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROFIT_CENTER_CREATE
*&---------------------------------------------------------------------*
*       손익센터 생성
*----------------------------------------------------------------------*
FORM PROFIT_CENTER_CREATE.

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LS_RETURN           TYPE BAPIRET2.

  DATA: LS_PROFITCENTERID   TYPE BAPI0015ID2.
  DATA: LS_BASICDATA        TYPE BAPI0015_4.
  DATA: LS_ADDRESS          TYPE BAPI0015_5.

  DATA: LV_VALIDFROM        TYPE SYDATUM.
  DATA: LV_VALIDTO          TYPE SYDATUM.
  DATA: LV_PHINR            TYPE KHINR.
  DATA: LV_MSGTXT           TYPE ZZIFTEXT.

  CLEAR: LS_RETURN.

  CLEAR: LS_PROFITCENTERID.
  CLEAR: LS_BASICDATA.
  CLEAR: LS_ADDRESS.

  CLEAR: LV_VALIDFROM.
  CLEAR: LV_VALIDTO.
  CLEAR: LV_PHINR.
  CLEAR: LV_MSGTXT.

*----------------------------------------------------------------------*
* 손익센터 정보 구성
*----------------------------------------------------------------------*
  LS_PROFITCENTERID-CO_AREA    = GS_BUKRS-KOKRS.            " 관리회계 영역
  LS_PROFITCENTERID-PROFIT_CTR = GS_OUTTAB-PRCTR.           " 손익 센터

  LS_BASICDATA-PRCTR_NAME      = GS_OUTTAB-KTEXT.           " 일반이름
  LS_BASICDATA-LONG_TEXT       = GS_OUTTAB-LTEXT.           " 설명
  LS_BASICDATA-IN_CHARGE       = GS_OUTTAB-VERAK.           " 손익센터 책임자
  LS_BASICDATA-PRCTR_HIER_GRP  = GS_OUTTAB-KHINR.           " 손익센터영역

  LV_VALIDFROM  = GS_OUTTAB-DATAB.                          " Valid-from date
  LV_VALIDTO    = GS_OUTTAB-DATBI.                          " Valid-to date

*----------------------------------------------------------------------*
*  손익센터 생성
*----------------------------------------------------------------------*
  CALL FUNCTION 'BAPI_PROFITCENTER_CREATE'
    EXPORTING
      PROFITCENTERID = LS_PROFITCENTERID
      VALIDFROM      = LV_VALIDFROM
      VALIDTO        = LV_VALIDTO
      BASICDATA      = LS_BASICDATA
      ADDRESS        = LS_ADDRESS
      TESTRUN        = ' '
    IMPORTING
      RETURN         = LS_RETURN.

*----------------------------------------------------------------------*
*  결과 처리
*----------------------------------------------------------------------*
  MOVE-CORRESPONDING GS_OUTTAB TO GS_RESULT.

  GS_RESULT-NATXT = LS_RETURN-MESSAGE.

* 오류
  IF ( LS_RETURN-TYPE = 'E' ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GS_RESULT-STATU = ICON_LED_RED.
* 정상
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    GS_RESULT-STATU = ICON_LED_GREEN.
  ENDIF.

  APPEND GS_RESULT TO GT_RESULT.
  CLEAR: GS_RESULT.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROFIT_CENTER_CHANGE
*&---------------------------------------------------------------------*
*       손익센터 변경
*----------------------------------------------------------------------*
FORM PROFIT_CENTER_CHANGE .

*----------------------------------------------------------------------*
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LS_RETURN         TYPE BAPIRET2.

  DATA: LS_BASICDATA      TYPE BAPI0015_4.
  DATA: LS_BASICDATAX     TYPE BAPI0015_4X.
  DATA: LS_ADDRESS        TYPE BAPI0015_5.
  DATA: LS_ADDRESSX       TYPE BAPI0015_5X.

  DATA: LV_VALIDFROM      TYPE SYDATUM.
  DATA: LV_VALIDTO        TYPE SYDATUM.

  CLEAR: LS_RETURN.

  CLEAR: LS_BASICDATA.
  CLEAR: LS_BASICDATAX.
  CLEAR: LS_ADDRESS.
  CLEAR: LS_ADDRESSX.

  CLEAR: LV_VALIDFROM.
  CLEAR: LV_VALIDTO.

*----------------------------------------------------------------------*
* 손익센터 정보 구성
*----------------------------------------------------------------------*

  LS_BASICDATA-PRCTR_NAME      = GS_OUTTAB-KTEXT.           " 일반이름
  LS_BASICDATA-LONG_TEXT       = GS_OUTTAB-LTEXT.           " 설명
  LS_BASICDATA-IN_CHARGE       = GS_OUTTAB-VERAK.           " 손익센터 책임자
  LS_BASICDATA-PRCTR_HIER_GRP  = GS_OUTTAB-KHINR.           " 손익센터영역

  LV_VALIDFROM  = GS_OUTTAB-DATAB.                          " Valid-from date
  LV_VALIDTO    = GS_OUTTAB-DATBI.                          " Valid-to date

* Update Field Marking
  LS_BASICDATAX = 'XXXXXXXX'.
  LS_ADDRESSX   = 'XXXXXXXXXXXXXX'.

*----------------------------------------------------------------------*
*  손익센터 생성
*----------------------------------------------------------------------*
*...Change Profit Center
  CALL FUNCTION 'BAPI_PROFITCENTER_CHANGE'
    EXPORTING
      PROFITCENTER    = GS_OUTTAB-PRCTR
      CONTROLLINGAREA = GS_BUKRS-KOKRS
      VALIDFROM       = LV_VALIDFROM
      VALIDTO         = LV_VALIDTO
      BASICDATA       = LS_BASICDATA
      ADDRESS         = LS_ADDRESS
      TESTRUN         = ''
      BASICDATAX      = LS_BASICDATAX
      ADDRESSX        = LS_ADDRESSX
    IMPORTING
      RETURN          = LS_RETURN.

*----------------------------------------------------------------------*
*  결과 처리
*----------------------------------------------------------------------*
  MOVE-CORRESPONDING GS_OUTTAB TO GS_RESULT.

  GS_RESULT-NATXT = LS_RETURN-MESSAGE.

* 오류
  IF ( LS_RETURN-TYPE = 'E' ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GS_RESULT-STATU = ICON_LED_GREEN.
* 정상
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    GS_RESULT-STATU = ICON_LED_RED.
  ENDIF.

  APPEND GS_RESULT TO GT_RESULT.
  CLEAR: GS_RESULT.

ENDFORM.
