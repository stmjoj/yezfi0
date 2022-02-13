*&---------------------------------------------------------------------*
*&  Include           YEZFIR0030_F01
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
  P_BEMPNO = GS_SUBLOGIN-EMPNO.
  P_BEMPNM = GS_SUBLOGIN-EMPNM.
  P_BORGCD = GS_SUBLOGIN-ORGCD.
  P_BORGNM = GS_SUBLOGIN-ORGNM.

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
  CALL FUNCTION 'Y_FI_CHECK_BUKRS_AUTH'
    EXPORTING
      IV_BUKRS   = P_BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
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

  CLEAR: GV_TOT_CNT.
  CLEAR: GV_UPD_CNT.

  CLEAR: GV_MODE.

  CLEAR: GT_EXCEL[].
  CLEAR: GS_EXCEL.

  CLEAR: GT_UPLOAD[].
  CLEAR: GS_UPLOAD.

  CLEAR: GT_OUTTAB[].
  CLEAR: GS_OUTTAB.

  CLEAR: GT_RESULT[].
  CLEAR: GS_RESULT.

  CLEAR: GT_SKB1[].
  CLEAR: GS_SKB1.

  CLEAR: GT_BDCTAB[].
  CLEAR: GS_BDCTAB.

  CLEAR: GT_BDCMSG[].
  CLEAR: GS_BDCMSG.

  CLEAR: GV_MSGTYP.
  CLEAR: GV_MSGTXT.

  GV_TITLE = SY-TITLE.
  GV_MODE  = 'N'.              " BDC MODE : DEFAULT 'M'

*----------------------------------------------------------------------*
* ALV 변수 초기화
*----------------------------------------------------------------------*
* 100번 화면
  CLEAR: GO_CONTAINER_0100.
  CLEAR: GO_GRID_0100.

  CLEAR: GT_FCAT_0100.
  CLEAR: GS_FCAT_0100.
  CLEAR: GT_SORT_0100.

  CLEAR: GS_LAYOUT_0100.
  CLEAR: GS_VARIANT_0100.

* 200번 화면
  CLEAR: GO_CONTAINER_0200.
  CLEAR: GO_GRID_0200.

  CLEAR: GT_FCAT_0200.
  CLEAR: GS_FCAT_0200.
  CLEAR: GT_SORT_0200.

  CLEAR: GS_LAYOUT_0200.
  CLEAR: GS_VARIANT_0200.

*----------------------------------------------------------------------*
* 초기값 설정
*----------------------------------------------------------------------*
  PERFORM GET_COMPANY_INFO.           " 회사코드 정보 설정

  PERFORM GET_GLACCT_LIST.            " G/L 계정 목록

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SUBLOGIN_PROC
*&---------------------------------------------------------------------*
*       Sublogin 에 대한 사용자 정보를 가져 온다.
*----------------------------------------------------------------------*
FORM CHECK_SUBLOGIN_PROC .

  DATA: LV_RETURN   TYPE BAPI_MTYPE.
  DATA: LV_MESSAGE  TYPE BAPI_MSG.

  CALL FUNCTION 'Y_FI_SUBLOGIN'
*   EXPORTING
*     IV_UNAME    = SY-UNAME
*     IV_SKIP     = ABAP_TRUE
    IMPORTING
      ES_SUBLOGIN = GS_SUBLOGIN
      EV_RETURN   = LV_RETURN
      EV_MESSAGE  = LV_MESSAGE.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE E012(YFIM).    " 발의부서를 결정할 수 없습니다.
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
    IF ( SCREEN-NAME = 'P_BUKRS'  ) OR
       ( SCREEN-NAME = 'P_BEMPNO' ) OR
       ( SCREEN-NAME = 'P_BORGCD' ).
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
* 지역변수 선언 및 초기화
*----------------------------------------------------------------------*
  CALL FUNCTION 'Y_FI_GET_BUKRS_INFO'
    EXPORTING
      IV_BUKRS   = P_BUKRS
    IMPORTING
      EV_RETURN  = LV_RETURN
      EV_MESSAGE = LV_MESSAGE
      ES_BUKRS   = GS_BUKRS.

  IF ( LV_RETURN <> 'S' ).
    MESSAGE I000(YFIM) WITH LV_MESSAGE DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXCEL_TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*       EXCEL TEMPLATE DOWNLOAD
*----------------------------------------------------------------------*
FORM EXCEL_TEMPLATE_DOWNLOAD .

  CALL FUNCTION 'Y_FI_EXCEL_TEMPLATE_DOWN_OLE'
    EXPORTING
      IV_PRGID = 'YFIR0030'
      IV_TXTID = SPACE.

  BREAK-POINT.
  RETURN.

*----------------------------------------------------------------------*
* Local 변수 선언 및 초기화
*----------------------------------------------------------------------*
  DATA: LO_APPLICATION TYPE OLE2_OBJECT.
  DATA: LO_WORKBOOK    TYPE OLE2_OBJECT.
  DATA: LO_SHEET       TYPE OLE2_OBJECT.
  DATA: LO_CELLS       TYPE OLE2_OBJECT.

  CLEAR: LO_APPLICATION.
  CLEAR: LO_WORKBOOK.
  CLEAR: LO_SHEET.
  CLEAR: LO_CELLS.

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
  PERFORM EXCEL_TEMPLATE_FILL_SHEET USING LO_APPLICATION 01: 01 'G/L계정코드',
                                                             02 'G/L계정내역',
                                                             03 'G/L계정설명',
                                                             04 '대차대조표 계정여부',
                                                             05 '계정유형',
                                                             06 '계정그룹번호',
                                                             07 '계정통화',
                                                             08 '현지통화만관리',
                                                             09 '세금범주',
                                                             10 '세금코드필수여부',
                                                             11 '조정계정구분',
                                                             12 '외부시스템관리',
                                                             13 '미결항목',
                                                             14 '개별항목조회',
                                                             15 '필드상태그룹',
                                                             16 '자동으로만전기',
                                                             17 '전기시조정계정입력'.

* 파일명 설정
*  CONCATENATE GV_DIRECTORY '\' P_KEY_OBJID '.xlsx' INTO GV_PATH.  //'

* 실행 파일 저장
*  CALL METHOD OF GO_WBOOK 'SaveAs' EXPORTING #1 = GV_PATH.
  CALL METHOD OF LO_WORKBOOK 'SaveAs' EXPORTING #1 = 'C:\TEST.xlsx'.

ENDFORM.

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
    MESSAGE I000(YFIM) WITH TEXT-004.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF ( GT_EXCEL IS INITIAL ).
*   MESSAGE : 데이터가 존재하지 않습니다.
    MESSAGE I013(YFIM).
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
      TEXT_QUESTION  = TEXT-008     " G/L 계정 업로드를 취소합니다. 계속하시겠습니까?
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
    MESSAGE S001(YFIM).
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
    MESSAGE S014(YFIM).
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
      TEXT_QUESTION = TEXT-013         " G/L계정을 생성/변경합니다. 계속하시겠습니까?
      TEXT_BUTTON_1 = TEXT-011         " 예
      TEXT_BUTTON_2 = TEXT-012         " 아니오
    IMPORTING
      ANSWER        = LV_ANSWER.

  IF ( LV_ANSWER <> 1 ).
*   MESSAGE : 수행을 취소하였습니다.
    MESSAGE S009(YFIM).
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* BDC 를 통한 G/L 계정 생성/변경
*----------------------------------------------------------------------*
  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE STATU = ICON_CREATE
                                      OR STATU = ICON_CHANGE.
    CLEAR: GT_BDCTAB[].
    CLEAR: GS_BDCTAB.

    CLEAR: GT_BDCMSG[].
    CLEAR: GS_BDCMSG.

    CLEAR: GV_MSGTXT.

    CASE GS_OUTTAB-STATU.
      WHEN ICON_CREATE.             " 신규
        PERFORM GL_ACCOUNT_CREATE.
      WHEN ICON_CHANGE.             " 변경
        PERFORM GL_ACCOUNT_CHANGE.
    ENDCASE.

*   처리결과 구성
    PERFORM MAKE_RESULT.
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
    MESSAGE S001(YFIM).
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
    MESSAGE I013(YFIM).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_GLACCT_LIST
*&---------------------------------------------------------------------*
*       G/L 계정 목록
*----------------------------------------------------------------------*
FORM GET_GLACCT_LIST .

  SELECT A~SAKNR   AS SAKNR
       , C~TXT20   AS TXT20
       , C~TXT50   AS TXT50
       , A~XBILK   AS XBILK
       , A~GVTYP   AS GVTYP
       , A~KTOKS   AS KTOKS
       , B~WAERS   AS WAERS
       , B~XSALH   AS XSALH
       , B~MWSKZ   AS MWSKZ
       , B~XMWNO   AS XMWNO
       , B~MITKZ   AS MITKZ
       , B~ALTKT   AS ALTKT
       , B~WMETH   AS WMETH
       , B~XOPVW   AS XOPVW
       , B~XKRES   AS XKRES
       , B~ZUAWA   AS ZUAWA
       , B~FSTAG   AS FSTAG
       , B~XINTB   AS XINTB
       , B~XMITK   AS XMITK
    INTO CORRESPONDING FIELDS OF TABLE @GT_SKB1
    FROM SKA1 AS A INNER JOIN      SKB1 AS B ON B~BUKRS = @P_BUKRS
                                            AND B~SAKNR = A~SAKNR
                   LEFT OUTER JOIN SKAT AS C ON C~SPRAS = @SY-LANGU
                                            AND C~KTOPL = A~KTOPL
                                            AND C~SAKNR = A~SAKNR
   WHERE A~KTOPL = @GS_BUKRS-KTOPL.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MAKE_OUTTAB_PROC
*&---------------------------------------------------------------------*
*       조회를 위한 자료 구성
*----------------------------------------------------------------------*
FORM MAKE_OUTTAB_PROC .

  SORT GT_SKB1 BY SAKNR.

  LOOP AT GT_UPLOAD INTO GS_UPLOAD.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = GS_UPLOAD-SAKNR
      IMPORTING
        OUTPUT = GS_UPLOAD-SAKNR.

    MOVE-CORRESPONDING GS_UPLOAD TO GS_OUTTAB.

*   처리유형 구분
    IF ( GS_OUTTAB-SAKNR IS NOT INITIAL ).
      READ TABLE GT_SKB1 INTO GS_SKB1
                         WITH KEY SAKNR = GS_OUTTAB-SAKNR
                         BINARY SEARCH
                         TRANSPORTING ALL FIELDS.

      IF ( SY-SUBRC = 0 ).
        IF ( GS_UPLOAD = GS_SKB1 ).
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
*&      Form  GL_ACCOUNT_CREATE
*&---------------------------------------------------------------------*
*       G/L 계정 생성
*----------------------------------------------------------------------*
FORM GL_ACCOUNT_CREATE .

  DATA: LV_COUNT   TYPE I.

  CLEAR: LV_COUNT.

* 계정 선택
  PERFORM BDC_DYNPRO_PROC USING: 'X' 'SAPMF02H'     '0402',
                                 ' ' 'BDC_OKCODE'   '/00',
                                 ' ' 'RF02H-SAKNR'  GS_OUTTAB-SAKNR,   " G/L 계정
                                 ' ' 'RF02H-BUKRS'  P_BUKRS.           " 회사 코드

* 유형/내역 탭
  PERFORM BDC_DYNPRO_PROC USING: 'X' 'SAPMF02H'     '0310',
                                 ' ' 'BDC_OKCODE'   '/00',
                                 ' ' 'SKAT-TXT20'   GS_OUTTAB-TXT20,   " 내역
                                 ' ' 'SKAT-TXT50'   GS_OUTTAB-TXT50,   " G/L 계정 설명
                                 ' ' 'SKA1-XBILK'   GS_OUTTAB-XBILK,   " 대차대조표 계정
                                 ' ' 'SKA1-GVTYP'   GS_OUTTAB-GVTYP,   " 손익계산서 계정 유형
                                 ' ' 'SKA1-KTOKS'   GS_OUTTAB-KTOKS.   " 계정 그룹

* 제어 데이터 탭
  PERFORM BDC_DYNPRO_PROC USING: 'X' 'SAPMF02H'     '0110',
                                 ' ' 'BDC_OKCODE'   '=SICH',
                                 ' ' 'SKB1-WAERS'   GS_OUTTAB-WAERS,   " 계정 통화
                                 ' ' 'SKB1-XSALH'   GS_OUTTAB-XSALH,   " 잔액(현지 통화)만
                                 ' ' 'SKB1-MWSKZ'   GS_OUTTAB-MWSKZ,   " 세금 범주
                                 ' ' 'SKB1-XMWNO'   GS_OUTTAB-XMWNO,   " 세금 없이 전기 허용
                                 ' ' 'SKB1-MITKZ'   GS_OUTTAB-MITKZ,   " 계정 유형에 대한 조정 계정
                                 ' ' 'SKB1-ALTKT'   GS_OUTTAB-ALTKT,   " 대체 계정 번호
                                 ' ' 'SKB1-WMETH'   GS_OUTTAB-WMETH,   " 외부 시스템에서 관리되는 계정
                                 ' ' 'SKB1-XOPVW'   GS_OUTTAB-XOPVW,   " 미결 항목 관리
                                 ' ' 'SKB1-XKRES'   GS_OUTTAB-XKRES,   " 개별 항목 조회
                                 ' ' 'SKB1-ZUAWA'   GS_OUTTAB-ZUAWA,   " 정렬 키
                                 ' ' 'SKB1-FSTAG'   GS_OUTTAB-FSTAG,   " 필드상태그룹
                                 ' ' 'SKB1-XINTB'   GS_OUTTAB-XINTB,   " 자동 전기만
                                 ' ' 'SKB1-XMITK'   GS_OUTTAB-XMITK.   " 조정 계정 입력 가능
*                                ' ' 'SKB1-XGKON'   GS_OUTTAB-xgkon.   "현금흐름 관련여부
*                                ' ' 'SKB1-HBKID'   GS_OUTTAB-hbkid,   "거래 은행 단축 키
*                                ' ' 'SKB1-HKTID'   GS_OUTTAB-hktid.   "계정 명세에 대한 ID

* Call Transaction
  CALL TRANSACTION  'FS01'     USING          GT_BDCTAB
                               MODE           GV_MODE
                               UPDATE         'S'
                               MESSAGES INTO  GT_BDCMSG.

* 처리결과 점검
  READ TABLE GT_BDCMSG INTO GS_BDCMSG
                       WITH KEY MSGTYP = 'S'
                                MSGID  = 'FH'
                                MSGNR  = '020'.

  IF ( SY-SUBRC = 0 ).                  " 성공
    GV_MSGTYP = 'S'.
  ELSE.                                 " 실패
    GV_MSGTYP = 'E'.

    LV_COUNT = LINES( GT_BDCMSG[] ).
    READ TABLE GT_BDCMSG INTO GS_BDCMSG
                         INDEX LV_COUNT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GL_ACCOUNT_CHANGE
*&---------------------------------------------------------------------*
*       G/L계정 변경
*----------------------------------------------------------------------*
FORM GL_ACCOUNT_CHANGE .

  DATA: LV_COUNT   TYPE I.

  CLEAR: LV_COUNT.

* 계정 선택
  PERFORM BDC_DYNPRO_PROC USING: 'X' 'SAPMF02H'     '0401',
                                  ' ' 'BDC_OKCODE'   '/00',
                                  ' ' 'RF02H-SAKNR'  GS_OUTTAB-SAKNR,
                                  ' ' 'RF02H-BUKRS'  P_BUKRS.

* 유형/내역 탭
  PERFORM BDC_DYNPRO_PROC USING: 'X' 'SAPMF02H'     '0310',
                                 ' ' 'BDC_OKCODE'   '/00',
                                 ' ' 'SKAT-TXT20'   GS_OUTTAB-TXT20,   " 내역
                                 ' ' 'SKAT-TXT50'   GS_OUTTAB-TXT50,   " G/L 계정 설명
                                 ' ' 'SKA1-XBILK'   GS_OUTTAB-XBILK,   " 대차대조표 계정
                                 ' ' 'SKA1-GVTYP'   GS_OUTTAB-GVTYP,   " 손익계산서 계정 유형
                                 ' ' 'SKA1-KTOKS'   GS_OUTTAB-KTOKS.   " 계정 그룹

* 제어 데이터 탭
  PERFORM BDC_DYNPRO_PROC USING: 'X' 'SAPMF02H'     '0110',
                                 ' ' 'BDC_OKCODE'   '=SICH',
                                 ' ' 'SKB1-WAERS'   GS_OUTTAB-WAERS,   " 계정 통화
                                 ' ' 'SKB1-XSALH'   GS_OUTTAB-XSALH,   " 잔액(현지 통화)만
                                 ' ' 'SKB1-MWSKZ'   GS_OUTTAB-MWSKZ,   " 세금 범주
                                 ' ' 'SKB1-XMWNO'   GS_OUTTAB-XMWNO,   " 세금 없이 전기 허용
                                 ' ' 'SKB1-MITKZ'   GS_OUTTAB-MITKZ,   " 계정 유형에 대한 조정 계정
                                 ' ' 'SKB1-ALTKT'   GS_OUTTAB-ALTKT,   " 대체 계정 번호
                                 ' ' 'SKB1-WMETH'   GS_OUTTAB-WMETH,   " 외부 시스템에서 관리되는 계정
                                 ' ' 'SKB1-XOPVW'   GS_OUTTAB-XOPVW,   " 미결 항목 관리
                                 ' ' 'SKB1-XKRES'   GS_OUTTAB-XKRES,   " 개별 항목 조회
                                 ' ' 'SKB1-ZUAWA'   GS_OUTTAB-ZUAWA,   " 정렬 키
                                 ' ' 'SKB1-FSTAG'   GS_OUTTAB-FSTAG,   " 필드상태그룹
                                 ' ' 'SKB1-XINTB'   GS_OUTTAB-XINTB,   " 자동 전기만
                                 ' ' 'SKB1-XMITK'   GS_OUTTAB-XMITK.   " 조정 계정 입력 가능
*                                ' ' 'SKB1-XGKON'   GS_OUTTAB-xgkon.   " 현금흐름 관련여부
*                                ' ' 'SKB1-HBKID'   GS_OUTTAB-hbkid,   " 거래 은행 단축 키
*                                ' ' 'SKB1-HKTID'   GS_OUTTAB-hktid.   " 계정 명세에 대한 ID

* Call Transaction
  CALL TRANSACTION  'FS02'     USING          GT_BDCTAB
                               MODE           GV_MODE
                               UPDATE         'S'
                               MESSAGES INTO  GT_BDCMSG.

* 처리결과 점검
  READ TABLE  GT_BDCMSG INTO GS_BDCMSG WITH KEY MSGTYP = 'E'.

  IF ( SY-SUBRC <> 0 ).     " 성공
    GV_MSGTYP        = 'S'.

    GS_BDCMSG-MSGTYP = 'S'.
    GS_BDCMSG-MSGID  = 'FH'.
    GS_BDCMSG-MSGNR  = '512'.  " FH512 : 데이터를 저장했습니다.
  ELSE.
    GV_MSGTYP = 'E'.

    LV_COUNT = LINES( GT_BDCMSG[] ).
    READ TABLE GT_BDCMSG INTO GS_BDCMSG
                         INDEX LV_COUNT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO_PROC
*&---------------------------------------------------------------------*
*       화면값입력                                                     *
*----------------------------------------------------------------------*
*      -->PV_DYNBEGIN   BDC Dynpro 시작
*      -->PV_FNAM       BDC 모듈 풀 또는 필드이름
*      -->PV_FVAL       BDC Dynpro 번호 또는 BDC 필드값
*----------------------------------------------------------------------*
FORM BDC_DYNPRO_PROC USING  PV_DYNBEGIN
                            PV_FNAM
                            PV_FVAL.

  DATA: LS_BDCTAB   TYPE BDCDATA.

  CLEAR LS_BDCTAB.

  IF ( PV_DYNBEGIN = 'X' ).
    LS_BDCTAB-DYNBEGIN = PV_DYNBEGIN.     " BDC Dynpro 시작
    LS_BDCTAB-PROGRAM  = PV_FNAM.         " BDC 모듈 풀
    LS_BDCTAB-DYNPRO   = PV_FVAL.         " BDC Dynpro 번호

    APPEND LS_BDCTAB TO GT_BDCTAB.
    CLEAR LS_BDCTAB.
  ELSE.
    LS_BDCTAB-FNAM = PV_FNAM.             " 필드이름
    LS_BDCTAB-FVAL = PV_FVAL.             " BDC 필드값

    APPEND LS_BDCTAB TO GT_BDCTAB.
    CLEAR LS_BDCTAB.
  ENDIF.

ENDFORM.                    " BDC_DYNPRO_PROC

*&---------------------------------------------------------------------*
*&      Form  MAKE_RESULT
*&---------------------------------------------------------------------*
*       BDC 처리결과 구성
*----------------------------------------------------------------------*
FORM MAKE_RESULT .

  MOVE-CORRESPONDING GS_OUTTAB TO GS_RESULT.

  IF ( GV_MSGTYP = 'S' ).
    GS_RESULT-STATU = ICON_LED_GREEN.
  ELSE.
    GS_RESULT-STATU = ICON_LED_RED.
  ENDIF.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = GS_BDCMSG-MSGID
      MSGNR               = GS_BDCMSG-MSGNR
      MSGV1               = GS_BDCMSG-MSGV1
      MSGV2               = GS_BDCMSG-MSGV2
      MSGV3               = GS_BDCMSG-MSGV3
      MSGV4               = GS_BDCMSG-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = GV_MSGTXT.

  GS_RESULT-NATXT = GV_MSGTXT.

  APPEND GS_RESULT TO GT_RESULT.
  CLEAR: GS_RESULT.

ENDFORM.
