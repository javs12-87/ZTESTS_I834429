CLASS lhc_z5s2f_reg_view DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR z5s2f_reg_view RESULT result.

    METHODS SendMail FOR READ
      IMPORTING keys FOR FUNCTION z5s2f_reg_view~SendMail RESULT result.

ENDCLASS.

CLASS lhc_z5s2f_reg_view IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD SendMail.

    DATA lv_response TYPE string.
    DATA lv_email type c length 512.
    DATA lv_template type string.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      lv_email = <ls_key>-%param-email.
      lv_template = <ls_key>-%param-template.

    ENDLOOP.

      "lv_xml = NEW zcl_fixedasset_integration( )->fetch_data_from_backend( lr_asset_key->value ).
      lv_response = NEW zcl_send_email_proc_aut( )->send_mail(
                                                       ls_email    = lv_email
                                                       ls_template = lv_template
                                                       ).
    ENDMETHOD.

ENDCLASS.
