FUNCTION-POOL YEZFIF0060.                   "MESSAGE-ID ..

* INCLUDE LYEZFIF0060D...                    " Local class definition

DEFINE message_raise.
  message id sy-msgid type sy-msgty number sy-msgno
  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*   raising &2.
  raising &1.
* endif.
END-OF-DEFINITION.
