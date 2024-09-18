CLASS zcl_send_mail DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SEND_MAIL IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA lv_response type string.
    DATA ls_email type c length 512.
    DATA(lt_param) = request->get_form_fields( ).
    READ TABLE lt_param REFERENCE INTO DATA(lr_email) WITH KEY name = 'email'.
    READ TABLE lt_param REFERENCE INTO DATA(lr_template) WITH KEY name = 'template'.

    IF sy-subrc = 0.

      ls_email = lr_email->value.
      "lv_xml = NEW zcl_fixedasset_integration( )->fetch_data_from_backend( lr_asset_key->value ).
      lv_response = NEW zcl_send_email_proc_aut( )->send_mail(
                                                   ls_email    = ls_email
                                                   ls_template = lr_template->value
                                                 ).
      response->set_text( 'Email sent' ).

    ELSE.
      response->set_status( i_code = 400 i_reason = 'Error').
    ENDIF.

  ENDMETHOD.
ENDCLASS.
