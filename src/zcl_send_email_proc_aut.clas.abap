CLASS zcl_send_email_proc_aut DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS: co_repositoryID  TYPE string VALUE 'I834429',
               co_startimage000 TYPE string VALUE 'registrationform.docx',
               co_startimage001 TYPE string VALUE 'start_image001.png',
               co_startimage002 TYPE string VALUE 'start_image002.png',
               co_startimage003 TYPE string VALUE 'start_image003.jpg'.

    METHODS get_attachment
      IMPORTING
        ls_attachment        TYPE string
      RETURNING
        VALUE(lt_attachment) TYPE cmis_s_content_raw.

    METHODS send_mail
      IMPORTING
        ls_email      TYPE c
        ls_template   TYPE string
      RETURNING
        VALUE(r_sent) TYPE string.

    METHODS get_template
      IMPORTING
        ls_template       TYPE string
      RETURNING
        VALUE(r_template) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SEND_EMAIL_PROC_AUT IMPLEMENTATION.


  METHOD get_attachment.

    DATA:
      ls_object_id   TYPE string,
      ls_children    TYPE cmis_s_object_in_folder_list,
      mo_cmis_client TYPE REF TO if_cmis_client,
      ro_cmis_query  TYPE cmis_s_object_list.

    IF mo_cmis_client IS NOT BOUND.

      CALL METHOD cl_cmis_client_factory=>get_instance
        RECEIVING
          ro_client = mo_cmis_client.
    ENDIF.

    CALL METHOD mo_cmis_client->query
      EXPORTING
        iv_repository_id = zcl_send_email_proc_aut=>co_repositoryid
        iv_statement     = 'SELECT cmis:objectId FROM cmis:document where cmis:name =' && '''' && ls_attachment && ''''
      IMPORTING
        es_query_result  = ro_cmis_query.

    LOOP AT ro_cmis_query-objects INTO DATA(lv_objects).
      DATA(lv_properties) = lv_objects-properties-properties.
      READ TABLE lv_properties INTO DATA(ls_objectid_prop)  WITH KEY id = cl_cmis_property_ids=>object_id.
      READ TABLE ls_objectid_prop-value INTO DATA(ls_objectid) INDEX 1.
      IF ls_objectid_prop-id CS 'cmis:objectID'.
        IF ls_objectid-string_value IS NOT INITIAL.
          ls_object_id = ls_objectid-string_value.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF ls_object_id IS NOT INITIAL.
      CALL METHOD mo_cmis_client->get_content_stream
        EXPORTING
          iv_repository_id = zcl_send_email_proc_aut=>co_repositoryid
          iv_object_id     = ls_object_id " '<ID of the custom-type created>'
        IMPORTING
          es_content       = DATA(ls_content). "File-name, file-type, content-length and content are parts of es_content

      lt_attachment = ls_content.

    ENDIF.

  ENDMETHOD.


  METHOD send_mail.

    TRY.

        DATA(lo_config) = cl_bcs_mail_system_config=>create_instance( ).

        lo_config->modify_default_sender_address( iv_default_address = 'jorge.baltazar@sap.com'
                            iv_default_name = 'Baltazar, Jorge' ).

        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
        lo_mail->set_sender( 'jorge.baltazar@sap.com' ).
        lo_mail->add_recipient( ls_email ).
        " lo_mail->add_recipient( iv_address = 'recipient2@yourcompany.com' iv_copy = cl_bcs_mail_message=>cc ).
        lo_mail->set_subject( '5 Steps to Fiori Bootcamp for Customers' ) ##NO_TEXT.
        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
          iv_content      = get_template( ls_template )
          iv_content_type = 'text/html'
        ) ).

        DATA: ls_content TYPE cmis_s_content_raw,
              ls_mime    TYPE c LENGTH 128.

        IF ls_template = '1'.
          ls_content = get_attachment( ls_attachment = zcl_send_email_proc_aut=>co_startimage000 ).
          ls_mime = ls_content-mime_type.

          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
            iv_content      = ls_content-stream
            iv_content_type = ls_mime
            iv_filename     = '5Steps2Fiori_RegistrationForm.docx'
          ) ).

          ls_content = get_attachment( ls_attachment = zcl_send_email_proc_aut=>co_startimage001 ).
          ls_mime = ls_content-mime_type.

          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
            iv_content      = ls_content-stream
            iv_content_type = ls_mime
            iv_filename     = 'image001.png'
          ) ).

          ls_content = get_attachment( ls_attachment = zcl_send_email_proc_aut=>co_startimage002 ).
          ls_mime = ls_content-mime_type.

          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
            iv_content      = ls_content-stream
            iv_content_type = ls_mime
            iv_filename     = 'image002.png'
          ) ).

          ls_content = get_attachment( ls_attachment = zcl_send_email_proc_aut=>co_startimage003 ).
          ls_mime = ls_content-mime_type.

          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
            iv_content      = ls_content-stream
            iv_content_type = ls_mime
            iv_filename     = 'image003.jpg'
          ) ).

        ENDIF.

        IF ls_template = '2'.
          ls_content = get_attachment( ls_attachment = zcl_send_email_proc_aut=>co_startimage001 ).
          ls_mime = ls_content-mime_type.

          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
            iv_content      = ls_content-stream
            iv_content_type = ls_mime
            iv_filename     = 'image001.png'
          ) ).

          ls_content = get_attachment( ls_attachment = zcl_send_email_proc_aut=>co_startimage002 ).
          ls_mime = ls_content-mime_type.

          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
            iv_content      = ls_content-stream
            iv_content_type = ls_mime
            iv_filename     = 'image002.png'
          ) ).

          ls_content = get_attachment( ls_attachment = zcl_send_email_proc_aut=>co_startimage003 ).
          ls_mime = ls_content-mime_type.

          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance(
            iv_content      = ls_content-stream
            iv_content_type = ls_mime
            iv_filename     = 'image003.jpg'
          ) ).

        ENDIF.

        lo_mail->send( IMPORTING et_status = DATA(lt_status) ).

        IF sy-subrc = '0'.
          r_sent = 'Email sent'.
        ENDIF.

      CATCH cx_bcs_mail_config INTO DATA(write_error).
        "handle exception
        r_sent = 'Error1'.
      CATCH cx_bcs_mail INTO DATA(lx_mail).
        " handle exceptions here
        r_sent = 'Error2'.
    ENDTRY.


  ENDMETHOD.


  METHOD get_template.

    IF ls_template = '1'.
      r_template = '<html xmlns:v="urn:schemas-microsoft-com:vml"' && |\n|  &&
                   'xmlns:o="urn:schemas-microsoft-com:office:office"' && |\n|  &&
                   'xmlns:w="urn:schemas-microsoft-com:office:word"' && |\n|  &&
                   'xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"' && |\n|  &&
                   'xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"' && |\n|  &&
                   'xmlns="http://www.w3.org/TR/REC-html40">' && |\n|  &&
                   |\n|  &&
                   '<head>' && |\n|  &&
                   '<meta http-equiv=Content-Type content="text/html; charset=utf-8">' && |\n|  &&
                   '<meta name=ProgId content=Word.Document>' && |\n|  &&
                   '<meta name=Generator content="Microsoft Word 15">' && |\n|  &&
                   '<meta name=Originator content="Microsoft Word 15">' && |\n|  &&
                   '<link rel=File-List href="Start%20Registration.fld/filelist.xml">' && |\n|  &&
                   '<link rel=Edit-Time-Data href="Start%20Registration.fld/editdata.mso">' && |\n|  &&
                   '<!--[if !mso]>' && |\n|  &&
                   '<style>' && |\n|  &&
                   'v\:* {behavior:url(#default#VML);}' && |\n|  &&
                   'o\:* {behavior:url(#default#VML);}' && |\n|  &&
                   'w\:* {behavior:url(#default#VML);}' && |\n|  &&
                   '.shape {behavior:url(#default#VML);}' && |\n|  &&
                   '</style>' && |\n|  &&
                   '<![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                   ' <o:DocumentProperties>' && |\n|  &&
                   '  <o:Author>Franke, Miriam</o:Author>' && |\n|  &&
                   '  <o:LastAuthor>Baltazar, Jorge</o:LastAuthor>' && |\n|  &&
                   '  <o:Revision>2</o:Revision>' && |\n|  &&
                   '  <o:TotalTime>47</o:TotalTime>' && |\n|  &&
                   '  <o:Created>2023-05-16T20:00:00Z</o:Created>' && |\n|  &&
                   '  <o:LastSaved>2023-05-16T20:00:00Z</o:LastSaved>' && |\n|  &&
                   '  <o:Pages>2</o:Pages>' && |\n|  &&
                   '  <o:Words>299</o:Words>' && |\n|  &&
                   '  <o:Characters>1706</o:Characters>' && |\n|  &&
                   '  <o:Lines>14</o:Lines>' && |\n|  &&
                   '  <o:Paragraphs>4</o:Paragraphs>' && |\n|  &&
                   '  <o:CharactersWithSpaces>2001</o:CharactersWithSpaces>' && |\n|  &&
                   '  <o:Version>16.00</o:Version>' && |\n|  &&
                   ' </o:DocumentProperties>' && |\n|  &&
                   ' <o:CustomDocumentProperties>' && |\n|  &&
                   '  <o:ContentTypeId dt:dt="string">0x010100152218F3AB2BA94F8E39A19C9CC1D1A5</o:ContentTypeId>' && |\n|  &&
                   '  <o:MediaServiceImageTags dt:dt="string"></o:MediaServiceImageTags>' && |\n|  &&
                   ' </o:CustomDocumentProperties>' && |\n|  &&
                   ' <o:OfficeDocumentSettings>' && |\n|  &&
                   '  <o:AllowPNG/>' && |\n|  &&
                   ' </o:OfficeDocumentSettings>' && |\n|  &&
                   '</xml><![endif]-->' && |\n|  &&
                   '<link rel=dataStoreItem href="Start%20Registration.fld/item0001.xml"' && |\n|  &&
                   'target="Start%20Registration.fld/props002.xml">' && |\n|  &&
                   '<link rel=dataStoreItem href="Start%20Registration.fld/item0003.xml"' && |\n|  &&
                   'target="Start%20Registration.fld/props004.xml">' && |\n|  &&
                   '<link rel=dataStoreItem href="Start%20Registration.fld/item0005.xml"' && |\n|  &&
                   'target="Start%20Registration.fld/props006.xml">' && |\n|  &&
                   '<link rel=themeData href="Start%20Registration.fld/themedata.thmx">' && |\n|  &&
                   '<link rel=colorSchemeMapping' && |\n|  &&
                   'href="Start%20Registration.fld/colorschememapping.xml">' && |\n|  &&
                   '<!--[if gte mso 9]><xml>' && |\n|  &&
                   ' <w:WordDocument>' && |\n|  &&
                   '  <w:HideSpellingErrors/>' && |\n|  &&
                   '  <w:HideGrammaticalErrors/>' && |\n|  &&
                   '  <w:SpellingState>Clean</w:SpellingState>' && |\n|  &&
                   '  <w:GrammarState>Clean</w:GrammarState>' && |\n|  &&
                   '  <w:TrackMoves>false</w:TrackMoves>' && |\n|  &&
                   '  <w:TrackFormatting/>' && |\n|  &&
                   '  <w:PunctuationKerning/>' && |\n|  &&
                   '  <w:ValidateAgainstSchemas/>' && |\n|  &&
                   '  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>' && |\n|  &&
                   '  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>' && |\n|  &&
                   '  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>' && |\n|  &&
                   '  <w:DoNotPromoteQF/>' && |\n|  &&
                   '  <w:LidThemeOther>en-MX</w:LidThemeOther>' && |\n|  &&
                   '  <w:LidThemeAsian>X-NONE</w:LidThemeAsian>' && |\n|  &&
                   '  <w:LidThemeComplexScript>X-NONE</w:LidThemeComplexScript>' && |\n|  &&
                   '  <w:Compatibility>' && |\n|  &&
                   '   <w:BreakWrappedTables/>' && |\n|  &&
                   '   <w:SnapToGridInCell/>' && |\n|  &&
                   '   <w:WrapTextWithPunct/>' && |\n|  &&
                   '   <w:UseAsianBreakRules/>' && |\n|  &&
                   '   <w:DontGrowAutofit/>' && |\n|  &&
                   '   <w:SplitPgBreakAndParaMark/>' && |\n|  &&
                   '   <w:EnableOpenTypeKerning/>' && |\n|  &&
                   '   <w:DontFlipMirrorIndents/>' && |\n|  &&
                   '   <w:OverrideTableStyleHps/>' && |\n|  &&
                   '  </w:Compatibility>' && |\n|  &&
                   '  <m:mathPr>' && |\n|  &&
                   '   <m:mathFont m:val="Cambria Math"/>' && |\n|  &&
                   '   <m:brkBin m:val="before"/>' && |\n|  &&
                   '   <m:brkBinSub m:val="&#45;-"/>' && |\n|  &&
                   '   <m:smallFrac m:val="off"/>' && |\n|  &&
                   '   <m:dispDef/>' && |\n|  &&
                   '   <m:lMargin m:val="0"/>' && |\n|  &&
                   '   <m:rMargin m:val="0"/>' && |\n|  &&
                   '   <m:defJc m:val="centerGroup"/>' && |\n|  &&
                   '   <m:wrapIndent m:val="1440"/>' && |\n|  &&
                   '   <m:intLim m:val="subSup"/>' && |\n|  &&
                   '   <m:naryLim m:val="undOvr"/>' && |\n|  &&
                   '  </m:mathPr></w:WordDocument>' && |\n|  &&
                   '</xml><![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                   ' <w:LatentStyles DefLockedState="false" DefUnhideWhenUsed="false"' && |\n|  &&
                   '  DefSemiHidden="false" DefQFormat="false" DefPriority="99"' && |\n|  &&
                   '  LatentStyleCount="376">' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="0" QFormat="true" Name="Normal"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 7"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 8"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="heading 9"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 7"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 8"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index 9"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 7"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 8"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="toc 9"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Normal Indent"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="footnote text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="annotation text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="header"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="footer"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="index heading"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="35" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="caption"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="table of figures"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="envelope address"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="envelope return"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="footnote reference"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="annotation reference"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="line number"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="page number"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="endnote reference"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="endnote text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="table of authorities"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="macro"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="toa heading"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Bullet"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Number"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Bullet 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Bullet 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Bullet 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Bullet 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Number 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Number 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Number 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Number 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="10" QFormat="true" Name="Title"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Closing"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Signature"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="1" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="Default Paragraph Font"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text Indent"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Continue"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Continue 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Continue 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Continue 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="List Continue 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Message Header"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="11" QFormat="true" Name="Subtitle"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Salutation"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Date"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text First Indent"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text First Indent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Note Heading"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text Indent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Body Text Indent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Block Text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Hyperlink"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="FollowedHyperlink"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="22" QFormat="true" Name="Strong"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="20" QFormat="true" Name="Emphasis"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Document Map"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Plain Text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="E-mail Signature"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Top of Form"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Bottom of Form"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Normal (Web)"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Acronym"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Address"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Cite"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Code"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Definition"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Keyboard"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Preformatted"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Sample"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Typewriter"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="HTML Variable"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Normal Table"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="annotation subject"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="No List"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Outline List 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Outline List 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Outline List 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Simple 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Simple 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Simple 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Classic 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Classic 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Classic 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Classic 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Colorful 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Colorful 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Colorful 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Columns 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Columns 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Columns 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Columns 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Columns 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 7"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Grid 8"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 7"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table List 8"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table 3D effects 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table 3D effects 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table 3D effects 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Contemporary"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Elegant"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Professional"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Subtle 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Subtle 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Web 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Web 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Web 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Balloon Text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" Name="Table Grid"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Table Theme"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" Name="Placeholder Text"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="1" QFormat="true" Name="No Spacing"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="60" Name="Light Shading"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="61" Name="Light List"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="62" Name="Light Grid"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="70" Name="Dark List"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="72" Name="Colorful List"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" Name="Revision"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="34" QFormat="true"' && |\n|  &&
                   '   Name="List Paragraph"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="29" QFormat="true" Name="Quote"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="30" QFormat="true"' && |\n|  &&
                   '   Name="Intense Quote"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="19" QFormat="true"' && |\n|  &&
                   '   Name="Subtle Emphasis"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="21" QFormat="true"' && |\n|  &&
                   '   Name="Intense Emphasis"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="31" QFormat="true"' && |\n|  &&
                   '   Name="Subtle Reference"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="32" QFormat="true"' && |\n|  &&
                   '   Name="Intense Reference"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="33" QFormat="true" Name="Book Title"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="37" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" Name="Bibliography"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                   '   UnhideWhenUsed="true" QFormat="true" Name="TOC Heading"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="41" Name="Plain Table 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="42" Name="Plain Table 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="43" Name="Plain Table 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="44" Name="Plain Table 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="45" Name="Plain Table 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="40" Name="Grid Table Light"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="Grid Table 1 Light Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="Grid Table 6 Colorful Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="Grid Table 7 Colorful Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="Grid Table 1 Light Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="Grid Table 6 Colorful Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="Grid Table 7 Colorful Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="Grid Table 1 Light Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="Grid Table 6 Colorful Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="Grid Table 7 Colorful Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="Grid Table 1 Light Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="Grid Table 6 Colorful Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="Grid Table 7 Colorful Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="Grid Table 1 Light Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="Grid Table 6 Colorful Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="Grid Table 7 Colorful Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="Grid Table 1 Light Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="Grid Table 6 Colorful Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="Grid Table 7 Colorful Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="List Table 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="List Table 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="List Table 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="List Table 1 Light Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="List Table 6 Colorful Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="List Table 7 Colorful Accent 1"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="List Table 1 Light Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="List Table 6 Colorful Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="List Table 7 Colorful Accent 2"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="List Table 1 Light Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="List Table 6 Colorful Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="List Table 7 Colorful Accent 3"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="List Table 1 Light Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="List Table 6 Colorful Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="List Table 7 Colorful Accent 4"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="List Table 1 Light Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="List Table 6 Colorful Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="List Table 7 Colorful Accent 5"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                   '   Name="List Table 1 Light Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                   '   Name="List Table 6 Colorful Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                   '   Name="List Table 7 Colorful Accent 6"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Mention"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Smart Hyperlink"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Hashtag"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Unresolved Mention"/>' && |\n|  &&
                   '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                   '   Name="Smart Link"/>' && |\n|  &&
                   ' </w:LatentStyles>' && |\n|  &&
                   '</xml><![endif]-->' && |\n|  &&
                   '<style>' && |\n|  &&
                   '<!--' && |\n|  &&
                   ' /* Font Definitions */' && |\n|  &&
                   ' @font-face' && |\n|  &&
                   '    {font-family:Wingdings;' && |\n|  &&
                   '    panose-1:5 0 0 0 0 0 0 0 0 0;' && |\n|  &&
                   '    mso-font-charset:2;' && |\n|  &&
                   '    mso-generic-font-family:auto;' && |\n|  &&
                   '    mso-font-pitch:variable;' && |\n|  &&
                   '    mso-font-signature:0 268435456 0 0 -2147483648 0;}' && |\n|  &&
                   '@font-face' && |\n|  &&
                   '    {font-family:"Cambria Math";' && |\n|  &&
                   '    panose-1:2 4 5 3 5 4 6 3 2 4;' && |\n|  &&
                   '    mso-font-charset:0;' && |\n|  &&
                   '    mso-generic-font-family:roman;' && |\n|  &&
                   '    mso-font-pitch:variable;' && |\n|  &&
                   '    mso-font-signature:3 0 0 0 1 0;}' && |\n|  &&
                   '@font-face' && |\n|  &&
                   '    {font-family:Calibri;' && |\n|  &&
                   '    panose-1:2 15 5 2 2 2 4 3 2 4;' && |\n|  &&
                   '    mso-font-charset:0;' && |\n|  &&
                   '    mso-generic-font-family:swiss;' && |\n|  &&
                   '    mso-font-pitch:variable;' && |\n|  &&
                   '    mso-font-signature:-469750017 -1073732485 9 0 511 0;}' && |\n|  &&
                   ' /* Style Definitions */' && |\n|  &&
                   ' p.MsoNormal, li.MsoNormal, div.MsoNormal' && |\n|  &&
                   '    {mso-style-unhide:no;' && |\n|  &&
                   '    mso-style-qformat:yes;' && |\n|  &&
                   '    mso-style-parent:"";' && |\n|  &&
                   '    margin:0cm;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                   'p.MsoHeader, li.MsoHeader, div.MsoHeader' && |\n|  &&
                   '    {mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-link:"Header Char";' && |\n|  &&
                   '    margin:0cm;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    tab-stops:center 234.0pt right 468.0pt;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                   'p.MsoFooter, li.MsoFooter, div.MsoFooter' && |\n|  &&
                   '    {mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-link:"Footer Char";' && |\n|  &&
                   '    margin:0cm;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    tab-stops:center 234.0pt right 468.0pt;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                   'a:link, span.MsoHyperlink' && |\n|  &&
                   '    {mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    color:#0563C1;' && |\n|  &&
                   '    text-decoration:underline;' && |\n|  &&
                   '    text-underline:single;}' && |\n|  &&
                   'a:visited, span.MsoHyperlinkFollowed' && |\n|  &&
                   '    {mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    color:#954F72;' && |\n|  &&
                   '    mso-themecolor:followedhyperlink;' && |\n|  &&
                   '    text-decoration:underline;' && |\n|  &&
                   '    text-underline:single;}' && |\n|  &&
                   'p' && |\n|  &&
                   '    {mso-style-priority:99;' && |\n|  &&
                   '    mso-margin-top-alt:auto;' && |\n|  &&
                   '    margin-right:0cm;' && |\n|  &&
                   '    mso-margin-bottom-alt:auto;' && |\n|  &&
                   '    margin-left:0cm;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-fareast-theme-font:minor-latin;}' && |\n|  &&
                   'p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph' && |\n|  &&
                   '    {mso-style-priority:34;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    mso-style-qformat:yes;' && |\n|  &&
                   '    margin-top:0cm;' && |\n|  &&
                   '    margin-right:0cm;' && |\n|  &&
                   '    margin-bottom:0cm;' && |\n|  &&
                   '    margin-left:36.0pt;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-fareast-theme-font:minor-latin;' && |\n|  &&
                   '    mso-ansi-language:EN-IN;}' && |\n|  &&
                   'p.Header1, li.Header1, div.Header1' && |\n|  &&
                   '    {mso-style-name:Header1;' && |\n|  &&
                   '    mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    margin-top:0cm;' && |\n|  &&
                   '    margin-right:0cm;' && |\n|  &&
                   '    margin-bottom:3.75pt;' && |\n|  &&
                   '    margin-left:0cm;' && |\n|  &&
                   '    mso-line-height-alt:17.25pt;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:18.0pt;' && |\n|  &&
                   '    font-family:"Arial",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                   '    color:black;' && |\n|  &&
                   '    font-weight:bold;}' && |\n|  &&
                   'p.subheader, li.subheader, div.subheader' && |\n|  &&
                   '    {mso-style-name:subheader;' && |\n|  &&
                   '    mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    margin-top:3.75pt;' && |\n|  &&
                   '    margin-right:0cm;' && |\n|  &&
                   '    margin-bottom:3.75pt;' && |\n|  &&
                   '    margin-left:0cm;' && |\n|  &&
                   '    line-height:15.0pt;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:15.0pt;' && |\n|  &&
                   '    font-family:"Arial",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                   '    color:black;}' && |\n|  &&
                   'p.Footer1, li.Footer1, div.Footer1' && |\n|  &&
                   '    {mso-style-name:Footer1;' && |\n|  &&
                   '    mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    margin-top:4.5pt;' && |\n|  &&
                   '    margin-right:0cm;' && |\n|  &&
                   '    margin-bottom:9.0pt;' && |\n|  &&
                   '    margin-left:0cm;' && |\n|  &&
                   '    line-height:9.0pt;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:7.5pt;' && |\n|  &&
                   '    font-family:"Arial",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                   '    color:#666666;}' && |\n|  &&
                   'span.subheader1' && |\n|  &&
                   '    {mso-style-name:subheader1;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    mso-ansi-font-size:15.0pt;' && |\n|  &&
                   '    mso-bidi-font-size:15.0pt;' && |\n|  &&
                   '    font-family:"Arial",sans-serif;' && |\n|  &&
                   '    mso-ascii-font-family:Arial;' && |\n|  &&
                   '    mso-hansi-font-family:Arial;' && |\n|  &&
                   '    mso-bidi-font-family:Arial;' && |\n|  &&
                   '    color:black;' && |\n|  &&
                   '    font-weight:normal;}' && |\n|  &&
                   'span.disclaimer1' && |\n|  &&
                   '    {mso-style-name:disclaimer1;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    mso-ansi-font-size:7.0pt;' && |\n|  &&
                   '    mso-bidi-font-size:7.0pt;' && |\n|  &&
                   '    font-family:"Arial",sans-serif;' && |\n|  &&
                   '    mso-ascii-font-family:Arial;' && |\n|  &&
                   '    mso-hansi-font-family:Arial;' && |\n|  &&
                   '    mso-bidi-font-family:Arial;' && |\n|  &&
                   '    color:#555555;' && |\n|  &&
                   '    mso-text-animation:none;' && |\n|  &&
                   '    font-weight:normal;' && |\n|  &&
                   '    font-style:normal;' && |\n|  &&
                   '    text-decoration:none;' && |\n|  &&
                   '    text-underline:none;' && |\n|  &&
                   '    text-decoration:none;' && |\n|  &&
                   '    text-line-through:none;}' && |\n|  &&
                   'span.HeaderChar' && |\n|  &&
                   '    {mso-style-name:"Header Char";' && |\n|  &&
                   '    mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    mso-style-locked:yes;' && |\n|  &&
                   '    mso-style-link:Header;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-ascii-font-family:Calibri;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-hansi-font-family:Calibri;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                   'span.FooterChar' && |\n|  &&
                   '    {mso-style-name:"Footer Char";' && |\n|  &&
                   '    mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    mso-style-locked:yes;' && |\n|  &&
                   '    mso-style-link:Footer;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-ascii-font-family:Calibri;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-hansi-font-family:Calibri;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                   'span.SpellE' && |\n|  &&
                   '    {mso-style-name:"";' && |\n|  &&
                   '    mso-spl-e:yes;}' && |\n|  &&
                   'span.GramE' && |\n|  &&
                   '    {mso-style-name:"";' && |\n|  &&
                   '    mso-gram-e:yes;}' && |\n|  &&
                   '.MsoChpDefault' && |\n|  &&
                   '    {mso-style-type:export-only;' && |\n|  &&
                   '    mso-default-props:yes;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    mso-ansi-font-size:11.0pt;' && |\n|  &&
                   '    mso-bidi-font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-ascii-font-family:Calibri;' && |\n|  &&
                   '    mso-ascii-theme-font:minor-latin;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-fareast-theme-font:minor-latin;' && |\n|  &&
                   '    mso-hansi-font-family:Calibri;' && |\n|  &&
                   '    mso-hansi-theme-font:minor-latin;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";' && |\n|  &&
                   '    mso-bidi-theme-font:minor-bidi;' && |\n|  &&
                   '    mso-font-kerning:0pt;' && |\n|  &&
                   '    mso-ligatures:none;}' && |\n|  &&
                   '.MsoPapDefault' && |\n|  &&
                   '    {mso-style-type:export-only;' && |\n|  &&
                   '    margin-bottom:8.0pt;' && |\n|  &&
                   '    line-height:107%;}' && |\n|  &&
                   ' /* Page Definitions */' && |\n|  &&
                   ' @page' && |\n|  &&
                   '    {mso-footnote-separator:url("Start%20Registration.fld/header.html") fs;' && |\n|  &&
                   '    mso-footnote-continuation-separator:url("Start%20Registration.fld/header.html") fcs;' && |\n|  &&
                   '    mso-footnote-continuation-notice:url("Start%20Registration.fld/header.html") fcn;' && |\n|  &&
                   '    mso-endnote-separator:url("Start%20Registration.fld/header.html") es;' && |\n|  &&
                   '    mso-endnote-continuation-separator:url("Start%20Registration.fld/header.html") ecs;' && |\n|  &&
                   '    mso-endnote-continuation-notice:url("Start%20Registration.fld/header.html") ecn;}' && |\n|  &&
                   '@page WordSection1' && |\n|  &&
                   '    {size:595.3pt 841.9pt;' && |\n|  &&
                   '    margin:72.0pt 72.0pt 72.0pt 72.0pt;' && |\n|  &&
                   '    mso-header-margin:35.4pt;' && |\n|  &&
                   '    mso-footer-margin:35.4pt;' && |\n|  &&
                   '    mso-paper-source:0;}' && |\n|  &&
                   'div.WordSection1' && |\n|  &&
                   '    {page:WordSection1;}' && |\n|  &&
                   ' /* List Definitions */' && |\n|  &&
                   ' @list l0' && |\n|  &&
                   '    {mso-list-id:451630024;' && |\n|  &&
                   '    mso-list-type:hybrid;' && |\n|  &&
                   '    mso-list-template-ids:-724905110 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675;}' && |\n|  &&
                   '@list l0:level1' && |\n|  &&
                   '    {mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l0:level2' && |\n|  &&
                   '    {mso-level-number-format:alpha-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l0:level3' && |\n|  &&
                   '    {mso-level-number-format:roman-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:right;' && |\n|  &&
                   '    text-indent:-9.0pt;}' && |\n|  &&
                   '@list l0:level4' && |\n|  &&
                   '    {mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l0:level5' && |\n|  &&
                   '    {mso-level-number-format:alpha-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l0:level6' && |\n|  &&
                   '    {mso-level-number-format:roman-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:right;' && |\n|  &&
                   '    text-indent:-9.0pt;}' && |\n|  &&
                   '@list l0:level7' && |\n|  &&
                   '    {mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l0:level8' && |\n|  &&
                   '    {mso-level-number-format:alpha-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l0:level9' && |\n|  &&
                   '    {mso-level-number-format:roman-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:right;' && |\n|  &&
                   '    text-indent:-9.0pt;}' && |\n|  &&
                   '@list l1' && |\n|  &&
                   '    {mso-list-id:831213213;' && |\n|  &&
                   '    mso-list-type:hybrid;' && |\n|  &&
                   '    mso-list-template-ids:743322282 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675;}' && |\n|  &&
                   '@list l1:level1' && |\n|  &&
                   '    {mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l1:level2' && |\n|  &&
                   '    {mso-level-number-format:alpha-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l1:level3' && |\n|  &&
                   '    {mso-level-number-format:roman-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:right;' && |\n|  &&
                   '    text-indent:-9.0pt;}' && |\n|  &&
                   '@list l1:level4' && |\n|  &&
                   '    {mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l1:level5' && |\n|  &&
                   '    {mso-level-number-format:alpha-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l1:level6' && |\n|  &&
                   '    {mso-level-number-format:roman-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:right;' && |\n|  &&
                   '    text-indent:-9.0pt;}' && |\n|  &&
                   '@list l1:level7' && |\n|  &&
                   '    {mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l1:level8' && |\n|  &&
                   '    {mso-level-number-format:alpha-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;}' && |\n|  &&
                   '@list l1:level9' && |\n|  &&
                   '    {mso-level-number-format:roman-lower;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:right;' && |\n|  &&
                   '    text-indent:-9.0pt;}' && |\n|  &&
                   '@list l2' && |\n|  &&
                   '    {mso-list-id:1590625064;' && |\n|  &&
                   '    mso-list-type:hybrid;' && |\n|  &&
                   '    mso-list-template-ids:1752230816 536870913 536870915 536870917 536870913 536870915 536870917 536870913 536870915 536870917;}' && |\n|  &&
                   '@list l2:level1' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:Symbol;}' && |\n|  &&
                   '@list l2:level2' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:o;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:"Courier New";}' && |\n|  &&
                   '@list l2:level3' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:Wingdings;}' && |\n|  &&
                   '@list l2:level4' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:Symbol;}' && |\n|  &&
                   '@list l2:level5' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:o;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:"Courier New";}' && |\n|  &&
                   '@list l2:level6' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:Wingdings;}' && |\n|  &&
                   '@list l2:level7' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:Symbol;}' && |\n|  &&
                   '@list l2:level8' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:o;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:"Courier New";}' && |\n|  &&
                   '@list l2:level9' && |\n|  &&
                   '    {mso-level-number-format:bullet;' && |\n|  &&
                   '    mso-level-text:;' && |\n|  &&
                   '    mso-level-tab-stop:none;' && |\n|  &&
                   '    mso-level-number-position:left;' && |\n|  &&
                   '    text-indent:-18.0pt;' && |\n|  &&
                   '    font-family:Wingdings;}' && |\n|  &&
                   'ol' && |\n|  &&
                   '    {margin-bottom:0cm;}' && |\n|  &&
                   'ul' && |\n|  &&
                   '    {margin-bottom:0cm;}' && |\n|  &&
                   '-->' && |\n|  &&
                   '</style>' && |\n|  &&
                   '<!--[if gte mso 10]>' && |\n|  &&
                   '<style>' && |\n|  &&
                   ' /* Style Definitions */' && |\n|  &&
                   ' table.MsoNormalTable' && |\n|  &&
                   '    {mso-style-name:"Table Normal";' && |\n|  &&
                   '    mso-tstyle-rowband-size:0;' && |\n|  &&
                   '    mso-tstyle-colband-size:0;' && |\n|  &&
                   '    mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-parent:"";' && |\n|  &&
                   '    mso-padding-alt:0cm 5.4pt 0cm 5.4pt;' && |\n|  &&
                   '    mso-para-margin-top:0cm;' && |\n|  &&
                   '    mso-para-margin-right:0cm;' && |\n|  &&
                   '    mso-para-margin-bottom:8.0pt;' && |\n|  &&
                   '    mso-para-margin-left:0cm;' && |\n|  &&
                   '    line-height:107%;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-ascii-font-family:Calibri;' && |\n|  &&
                   '    mso-ascii-theme-font:minor-latin;' && |\n|  &&
                   '    mso-hansi-font-family:Calibri;' && |\n|  &&
                   '    mso-hansi-theme-font:minor-latin;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";' && |\n|  &&
                   '    mso-bidi-theme-font:minor-bidi;}' && |\n|  &&
                   'table.NormaleTabelle' && |\n|  &&
                   '    {mso-style-name:"Normale Tabelle";' && |\n|  &&
                   '    mso-tstyle-rowband-size:0;' && |\n|  &&
                   '    mso-tstyle-colband-size:0;' && |\n|  &&
                   '    mso-style-noshow:yes;' && |\n|  &&
                   '    mso-style-priority:99;' && |\n|  &&
                   '    mso-style-unhide:no;' && |\n|  &&
                   '    mso-style-parent:"";' && |\n|  &&
                   '    mso-padding-alt:0cm 5.4pt 0cm 5.4pt;' && |\n|  &&
                   '    mso-para-margin:0cm;' && |\n|  &&
                   '    mso-pagination:widow-orphan;' && |\n|  &&
                   '    font-size:11.0pt;' && |\n|  &&
                   '    font-family:"Calibri",sans-serif;' && |\n|  &&
                   '    mso-fareast-font-family:Calibri;' && |\n|  &&
                   '    mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                   '</style>' && |\n|  &&
                   '<![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                   ' <o:shapedefaults v:ext="edit" spidmax="2051"/>' && |\n|  &&
                   '</xml><![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                   ' <o:shapelayout v:ext="edit">' && |\n|  &&
                   '  <o:idmap v:ext="edit" data="2"/>' && |\n|  &&
                   ' </o:shapelayout></xml><![endif]-->' && |\n|  &&
                   '</head>' && |\n|  &&
                   |\n|  &&
                   '<body lang=en-MX link="#0563C1" vlink="#954F72" style=''tab-interval:36.0pt;' && |\n|  &&
                   'word-wrap:break-word''>' && |\n|  &&
                   |\n|  &&
                   '<div class=WordSection1>' && |\n|  &&
                   |\n|  &&
                   '<div align=center>' && |\n|  &&
                   |\n|  &&
                   '<table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0 width=630' && |\n|  &&
                   ' style=''width:472.5pt;border-collapse:collapse;mso-yfti-tbllook:1184;' && |\n|  &&
                   ' mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   ' <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes''>' && |\n|  &&
                   '  <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '  <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0 width=630' && |\n|  &&
                   '   style=''width:472.5pt;border-collapse:collapse;mso-yfti-tbllook:1184;' && |\n|  &&
                   '   mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '   <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes''>' && |\n|  &&
                   '    <td width=25 style=''width:18.75pt;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '    <p class=MsoNormal><span style=''font-size:1.0pt;mso-fareast-font-family:' && |\n|  &&
                   '    "Times New Roman"''>&nbsp;</span><span style=''mso-fareast-font-family:"Times New Roman"''>' && |\n|  &&
                   '    <o:p></o:p></span></p>' && |\n|  &&
                   '    <p class=MsoNormal><span style=''mso-fareast-font-family:"Times New Roman"''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   '    </td>' && |\n|  &&
                   '    <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '    <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0 width=580' && |\n|  &&
                   '     style=''width:435.0pt;border-collapse:collapse;mso-yfti-tbllook:1184;' && |\n|  &&
                   '     mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '     <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;height:56.25pt''>' && |\n|  &&
                   '      <td style=''padding:0cm 0cm 0cm 0cm;height:56.25pt''>' && |\n|  &&
                   '      <div align=center>' && |\n|  &&
                   '      <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0' && |\n|  &&
                   '       width=580 style=''width:435.0pt;border-collapse:collapse;mso-yfti-tbllook:' && |\n|  &&
                   '       1184;mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '       <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;' && |\n|  &&
                   '        height:56.25pt''>' && |\n|  &&
                   '        <td width=580 valign=top style=''width:435.0pt;padding:0cm 0cm 0cm 0cm;' && |\n|  &&
                   '        height:56.25pt''>' && |\n|  &&
                   '        <p class=MsoNormal><!--[if gte vml 1]><v:shapetype id="_x0000_t75"' && |\n|  &&
                   '         coordsize="21600,21600" o:spt="75" o:preferrelative="t" path="m@4@5l@4@11@9@11@9@5xe"' && |\n|  &&
                   '         filled="f" stroked="f">' && |\n|  &&
                   '         <v:stroke joinstyle="miter"/>' && |\n|  &&
                   '         <v:formulas>' && |\n|  &&
                   '          <v:f eqn="if lineDrawn pixelLineWidth 0"/>' && |\n|  &&
                   '          <v:f eqn="sum @0 1 0"/>' && |\n|  &&
                   '          <v:f eqn="sum 0 0 @1"/>' && |\n|  &&
                   '          <v:f eqn="prod @2 1 2"/>' && |\n|  &&
                   '          <v:f eqn="prod @3 21600 pixelWidth"/>' && |\n|  &&
                   '          <v:f eqn="prod @3 21600 pixelHeight"/>' && |\n|  &&
                   '          <v:f eqn="sum @0 0 1"/>' && |\n|  &&
                   '          <v:f eqn="prod @6 1 2"/>' && |\n|  &&
                   '          <v:f eqn="prod @7 21600 pixelWidth"/>' && |\n|  &&
                   '          <v:f eqn="sum @8 21600 0"/>' && |\n|  &&
                   '          <v:f eqn="prod @7 21600 pixelHeight"/>' && |\n|  &&
                   '          <v:f eqn="sum @10 21600 0"/>' && |\n|  &&
                   '         </v:formulas>' && |\n|  &&
                   '         <v:path o:extrusionok="f" gradientshapeok="t" o:connecttype="rect"/>' && |\n|  &&
                   '         <o:lock v:ext="edit" aspectratio="t"/>' && |\n|  &&
                   '        </v:shapetype><v:shape id="Picture_x0020_3" o:spid="_x0000_s2050"' && |\n|  &&
                   '         type="#_x0000_t75" alt="SAP Logo" style=''position:absolute;' && |\n|  &&
                   '         margin-left:84.55pt;margin-top:0;width:135.75pt;height:51pt;z-index:251658240;' && |\n|  &&
                   '         visibility:visible;mso-wrap-style:square;mso-width-percent:0;' && |\n|  &&
                   '         mso-height-percent:0;mso-wrap-distance-left:0;mso-wrap-distance-top:0;' && |\n|  &&
                   '         mso-wrap-distance-right:0;mso-wrap-distance-bottom:0;' && |\n|  &&
                   '         mso-position-horizontal:right;mso-position-horizontal-relative:text;' && |\n|  &&
                   '         mso-position-vertical:absolute;mso-position-vertical-relative:line;' && |\n|  &&
                   '         mso-width-percent:0;mso-height-percent:0;mso-width-relative:page;' && |\n|  &&
                   '         mso-height-relative:page'' o:allowoverlap="f">' && |\n|  &&
                   '         <v:imagedata src="image001.png" o:title="SAP Logo"/>' && |\n|  &&
                   '         <w:wrap type="square" anchory="line"/>' && |\n|  &&
                   '        </v:shape><![endif]--><![if !vml]><img width=136 height=51' && |\n|  &&
                   '        src="image001.png" align=right alt="SAP Logo"' && |\n|  &&
                   '        v:shapes="Picture_x0020_3"><![endif]><span style=''mso-fareast-font-family:' && |\n|  &&
                   '        "Times New Roman"''><o:p></o:p></span></p>' && |\n|  &&
                   '        </td>' && |\n|  &&
                   '       </tr>' && |\n|  &&
                   '      </table>' && |\n|  &&
                   '      </div>' && |\n|  &&
                   '      </td>' && |\n|  &&
                   '     </tr>' && |\n|  &&
                   '     <tr style=''mso-yfti-irow:1''>' && |\n|  &&
                   '      <td style=''background:black;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '      <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0' && |\n|  &&
                   '       style=''border-collapse:collapse;mso-yfti-tbllook:1184;mso-padding-alt:' && |\n|  &&
                   '       0cm 5.4pt 0cm 5.4pt''>' && |\n|  &&
                   '       <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;' && |\n|  &&
                   '        height:123.75pt''>' && |\n|  &&
                   '        <td width=25 style=''width:18.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                   '        height:123.75pt''>' && |\n|  &&
                   '        <p><span style=''mso-bidi-font-family:"Times New Roman"''>&nbsp;<o:p></o:p></span></p>' && |\n|  &&
                   '        </td>' && |\n|  &&
                   '        <td width=365 style=''width:273.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                   '        height:123.75pt''>' && |\n|  &&
                   '        <p class=Header1><a name="Top_e"><span lang=EN-US style=''color:white;' && |\n|  &&
                   '        mso-ansi-language:EN-US''>5 Steps to Fiori</span></a><span' && |\n|  &&
                   '        style=''mso-bookmark:Top_e''><span lang=EN-US style=''color:#FFC000;' && |\n|  &&
                   '        mso-ansi-language:EN-US''> Bootcamp</span></span><span style=''mso-bookmark:' && |\n|  &&
                   '        Top_e''><span style=''color:white''><o:p></o:p></span></span></p>' && |\n|  &&
                   '        <p class=subheader style=''margin:0cm''><span style=''mso-bookmark:Top_e''><span' && |\n|  &&
                   '        class=subheader1><span lang=EN-US style=''color:white;mso-ansi-language:' && |\n|  &&
                   '        EN-US''>Confirmation of Registration</span></span></span><span' && |\n|  &&
                   '        style=''mso-bookmark:Top_e''><span lang=EN-US style=''mso-ansi-language:' && |\n|  &&
                   '        EN-US''><o:p></o:p></span></span></p>' && |\n|  &&
                   '        </td>' && |\n|  &&
                   '        <span style=''mso-bookmark:Top_e''></span>' && |\n|  &&
                   '        <td width=165 style=''width:123.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                   '        height:123.75pt''>' && |\n|  &&
                   '        <p class=MsoNormal align=center style=''text-align:center''><span' && |\n|  &&
                   '        style=''mso-fareast-font-family:"Times New Roman";mso-no-proof:yes''><!--[if gte vml 1]><v:shape' && |\n|  &&
                   '         id="Picture_x0020_2" o:spid="_x0000_i1026" type="#_x0000_t75" style=''width:124pt;' && |\n|  &&
                   '         height:124pt;visibility:visible;mso-wrap-style:square''>' && |\n|  &&
                   '         <v:imagedata src="image002.png" o:title=""/>' && |\n|  &&
                   '        </v:shape><![endif]--><![if !vml]><img width=124 height=124' && |\n|  &&
                   '        src="image002.png" v:shapes="Picture_x0020_2"><![endif]></span><span' && |\n|  &&
                   '        style=''mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:' && |\n|  &&
                   '        Calibri;color:#222222''><o:p></o:p></span></p>' && |\n|  &&
                   '        </td>' && |\n|  &&
                   '        <td width=25 style=''width:18.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                   '        height:123.75pt''>' && |\n|  &&
                   '        <p><span style=''mso-bidi-font-family:"Times New Roman"''>&nbsp;<o:p></o:p></span></p>' && |\n|  &&
                   '        </td>' && |\n|  &&
                   '       </tr>' && |\n|  &&
                   '      </table>' && |\n|  &&
                   '      </td>' && |\n|  &&
                   '      <span style=''mso-bookmark:Top_e''></span>' && |\n|  &&
                   '     </tr>' && |\n|  &&
                   '     <tr style=''mso-yfti-irow:2''>' && |\n|  &&
                   '      <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '      <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0' && |\n|  &&
                   '       width=580 style=''width:435.0pt;border-collapse:collapse;mso-yfti-tbllook:' && |\n|  &&
                   '       1184;mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '       <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes''>' && |\n|  &&
                   '        <td style=''padding:7.5pt 0cm 7.5pt 0cm''></td>' && |\n|  &&
                   '        <span style=''mso-bookmark:Top_e''></span>' && |\n|  &&
                   '       </tr>' && |\n|  &&
                   '       <tr style=''mso-yfti-irow:1;mso-yfti-lastrow:yes''>' && |\n|  &&
                   '        <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '        <p style=''line-height:16.5pt''><b><span style=''font-family:"Arial",sans-serif''>Dear' && |\n|  &&
                   '        </span></b><b><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''>Participant</span></b><b><span' && |\n|  &&
                   '        style=''font-family:"Arial",sans-serif''>,<o:p></o:p></span></b></p>' && |\n|  &&
                   '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''>Your registration to the</span><span' && |\n|  &&
                   '        style=''font-family:"Arial",sans-serif''> 5Steps2Fiori bootcamp</span><span' && |\n|  &&
                   '        lang=EN-US style=''font-family:"Arial",sans-serif;mso-ansi-language:' && |\n|  &&
                   '        EN-US''> has been <span class=GramE>confirmed<span lang=EN-US' && |\n|  &&
                   '        style=''mso-ansi-language:#0C00''><span lang=EN-US>.</span></span>In</span>' && |\n|  &&
                   '        the next days you and the team members will receive additional emails' && |\n|  &&
                   '        with instructions on how to prepare for the training.<o:p></o:p></span></p>' && |\n|  &&
                   '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''>In the meantime, please complete the following' && |\n|  &&
                   '        action items:<o:p></o:p></span></p>' && |\n|  &&
                   '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   '        <p class=MsoNormal><b><span style=''font-family:"Arial",sans-serif''>Action' && |\n|  &&
                   '        </span></b><b><span lang=ES style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:ES''>i</span></b><b><span style=''font-family:"Arial",sans-serif''>tems</span></b><b><span' && |\n|  &&
                   '        lang=ES style=''font-family:"Arial",sans-serif;mso-ansi-language:ES''>:<o:p></o:p></span></b></p>' && |\n|  &&
                   '        <p class=MsoListParagraph style=''text-indent:-18.0pt;mso-list:l0 level1 lfo3''><![if !supportLists]><span' && |\n|  &&
                   '        lang=EN-IN style=''font-family:"Arial",sans-serif;mso-fareast-font-family:' && |\n|  &&
                   '        Arial''><span style=''mso-list:Ignore''>1.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;' && |\n|  &&
                   '        </span></span></span><![endif]><span lang=EN-IN style=''font-family:' && |\n|  &&
                   '        "Arial",sans-serif''>Please review the system prerequisites and' && |\n|  &&
                   '        connectivity checks documents where you will find additional details on' && |\n|  &&
                   '        how to prepare for the training.</span><span lang=EN-IN' && |\n|  &&
                   '        style=''font-family:"Arial",sans-serif;mso-fareast-font-family:"Times New Roman"''><o:p></o:p></span></p>' && |\n|  &&
                   '        <p class=MsoListParagraph><span lang=EN-IN style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-fareast-font-family:"Times New Roman"''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   '        <p class=MsoListParagraph style=''text-indent:-18.0pt;mso-list:l0 level1 lfo3''><![if !supportLists]><span' && |\n|  &&
                   '        lang=EN-IN style=''font-family:"Arial",sans-serif;mso-fareast-font-family:' && |\n|  &&
                   '        Arial''><span style=''mso-list:Ignore''>2.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;' && |\n|  &&
                   '        </span></span></span><![endif]><b><i><span lang=EN-IN style=''font-family:' && |\n|  &&
                   '        "Arial",sans-serif;mso-fareast-font-family:"Times New Roman"''>Guests:</span></i></b><span' && |\n|  &&
                   '        lang=EN-IN style=''font-family:"Arial",sans-serif;mso-fareast-font-family:' && |\n|  &&
                   '        "Times New Roman"''> In the attached excel file you can register as many' && |\n|  &&
                   '        people as you wish. <span class=SpellE>The</span> people registered in' && |\n|  &&
                   '        this file would be considered listeners and will be able to join the' && |\n|  &&
                   '        live sessions but have no responsibility on running the hands-on' && |\n|  &&
                   '        exercises, only people listed as team members (basis, functional,' && |\n|  &&
                   '        developer, security, analytics) would be responsible of running the' && |\n|  &&
                   '        provided exercises. Fill in this document and send it back to us at' && |\n|  &&
                   '        your earliest convenience.<o:p></o:p></span></p>' && |\n|  &&
                   '        <p class=MsoNormal><span style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-fareast-font-family:"Times New Roman"''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   '        <p class=MsoListParagraph style=''text-indent:-18.0pt;mso-list:l0 level1 lfo3''><![if !supportLists]><span' && |\n|  &&
                   '        lang=EN-IN style=''font-family:"Arial",sans-serif;mso-fareast-font-family:' && |\n|  &&
                   '        Arial''><span style=''mso-list:Ignore''>3.<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;' && |\n|  &&
                   '        </span></span></span><![endif]><b><span lang=EN-IN style=''font-family:' && |\n|  &&
                   '        "Arial",sans-serif''>Environment for bootcamp:</span></b><b><span' && |\n|  &&
                   '        lang=EN-IN style=''font-family:"Arial",sans-serif;mso-ansi-language:' && |\n|  &&
                   '        EN-US''> </span></b><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''>You need to provide your own system which is' && |\n|  &&
                   '        where you will run the exercises on - </span><span lang=EN-IN' && |\n|  &&
                   '        style=''font-family:"Arial",sans-serif''>SAP S/4HANA 202</span><span' && |\n|  &&
                   '        lang=EN-US style=''font-family:"Arial",sans-serif;mso-ansi-language:' && |\n|  &&
                   '        EN-US''>2</span><span lang=EN-IN style=''font-family:"Arial",sans-serif''>' && |\n|  &&
                   '        or 202</span><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''>1</span><span lang=EN-IN style=''font-family:' && |\n|  &&
                   '        "Arial",sans-serif''> system with embedded Fiori frontend server (Bring' && |\n|  &&
                   '        Your Own sandbox or SAP Cloud Appliance Library Instance)</span><span' && |\n|  &&
                   '        lang=EN-US style=''font-family:"Arial",sans-serif;mso-ansi-language:' && |\n|  &&
                   '        EN-US''>. Let us know if there are any outstanding questions on this' && |\n|  &&
                   '        topic.</span><span lang=EN-IN style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-fareast-font-family:"Times New Roman"''><o:p></o:p></span></p>' && |\n|  &&
                   '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   '        <p style=''line-height:16.5pt''><span style=''font-family:"Arial",sans-serif''>Kind' && |\n|  &&
                   '        </span><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                   '        mso-ansi-language:EN-US''>regards</span><span style=''font-family:"Arial",sans-serif''><o:p></o:p></span></p>' && |\n|  &&
                   '        <p style=''line-height:16.5pt''><b><span lang=EN-US style=''font-family:' && |\n|  &&
                   '        "Arial",sans-serif;mso-ansi-language:EN-US''>The 5 Steps to Fiori team<o:p></o:p></span></b></p>' && |\n|  &&
                   '        <p style=''line-height:16.5pt''><span style=''font-size:8.0pt;font-family:' && |\n|  &&
                   '        "Arial",sans-serif''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   '        </td>' && |\n|  &&
                   '       </tr>' && |\n|  &&
                   '      </table>' && |\n|  &&
                   '      </td>' && |\n|  &&
                   '     </tr>' && |\n|  &&
                   '     <tr style=''mso-yfti-irow:3''>' && |\n|  &&
                   '      <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '      <p class=MsoNormal><a name="Top_d"></a><span style=''mso-fareast-font-family:' && |\n|  &&
                   '      "Times New Roman";mso-no-proof:yes''><!--[if gte vml 1]><v:shape id="Picture_x0020_1"' && |\n|  &&
                   '       o:spid="_x0000_i1025" type="#_x0000_t75" alt="Divider" style=''width:435pt;' && |\n|  &&
                   '       height:2pt;visibility:visible;mso-wrap-style:square''>' && |\n|  &&
                   '       <v:imagedata src="image003.jpg" o:title="Divider"/>' && |\n|  &&
                   '      </v:shape><![endif]--><![if !vml]><img width=435 height=2' && |\n|  &&
                   '      src="image003.jpg" alt=Divider v:shapes="Picture_x0020_1"><![endif]></span><span' && |\n|  &&
                   '      style=''mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:' && |\n|  &&
                   '      Calibri;color:#222222''><o:p></o:p></span></p>' && |\n|  &&
                   '      </td>' && |\n|  &&
                   '     </tr>' && |\n|  &&
                   '     <tr style=''mso-yfti-irow:4;height:12.0pt''>' && |\n|  &&
                   '      <td width=580 style=''width:435.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt''>' && |\n|  &&
                   '      <p class=Footer1 align=right style=''margin-top:9.0pt;mso-margin-bottom-alt:' && |\n|  &&
                   '      auto;text-align:right''>&nbsp;&nbsp; <a href="http://www.sap.com/copyright"' && |\n|  &&
                   '      target="_blank"><span style=''color:#7F7F7F;text-decoration:none;' && |\n|  &&
                   '      text-underline:none''>Copyright/Trademark</span></a>&nbsp;&nbsp;|&nbsp;&nbsp;' && |\n|  &&
                   '      <a href="http://www.sap.com/about/legal/privacy.html" target="_blank"><span' && |\n|  &&
                   '      style=''color:#7F7F7F;text-decoration:none;text-underline:none''>Privacy</span></a>&nbsp;&nbsp;|&nbsp;&nbsp;' && |\n|  &&
                   '      <a href="http://www.sap.com/about/legal/impressum.html" target="_blank"><span' && |\n|  &&
                   '      style=''color:#7F7F7F;text-decoration:none;text-underline:none''>Impressum</span></a>&nbsp;&nbsp;' && |\n|  &&
                   '      </p>' && |\n|  &&
                   '      </td>' && |\n|  &&
                   '     </tr>' && |\n|  &&
                   '     <tr style=''mso-yfti-irow:5;height:6.0pt''>' && |\n|  &&
                   '      <td style=''background:white;padding:0cm 0cm 0cm 0cm;height:6.0pt''>' && |\n|  &&
                   '      <p class=MsoNormal align=right style=''text-align:right''><span' && |\n|  &&
                   '      style=''mso-fareast-font-family:"Times New Roman";color:black;mso-color-alt:' && |\n|  &&
                   '      windowtext''>&nbsp;</span><span style=''mso-fareast-font-family:"Times New Roman"''><o:p></o:p></span></p>' && |\n|  &&
                   '      </td>' && |\n|  &&
                   '     </tr>' && |\n|  &&
                   '     <tr style=''mso-yfti-irow:6;mso-yfti-lastrow:yes''>' && |\n|  &&
                   '      <td width=580 style=''width:435.0pt;background:white;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '      <p class=MsoNormal style=''line-height:9.0pt''><span class=disclaimer1><span' && |\n|  &&
                   '      style=''font-size:7.0pt;mso-fareast-font-family:"Times New Roman"''>SAP SE,' && |\n|  &&
                   '      Dietmar-Hopp-Allee 16, 69190 Walldorf, Germany</span></span><span' && |\n|  &&
                   '      style=''font-size:7.0pt;font-family:"Arial",sans-serif;mso-fareast-font-family:' && |\n|  &&
                   '      "Times New Roman";color:#555555''><br>' && |\n|  &&
                   '      <br>' && |\n|  &&
                   '      <span class=disclaimer1>This e-mail may contain trade secrets or' && |\n|  &&
                   '      privileged, undisclosed, or otherwise confidential information. If you' && |\n|  &&
                   '      have received this e-mail in error, you are hereby notified that any' && |\n|  &&
                   '      review, copying, or distribution of it is strictly prohibited. Please' && |\n|  &&
                   '      inform us immediately and destroy the original transmittal. Thank you for' && |\n|  &&
                   '      your cooperation.</span><o:p></o:p></span></p>' && |\n|  &&
                   '      </td>' && |\n|  &&
                   '     </tr>' && |\n|  &&
                   '    </table>' && |\n|  &&
                   '    </td>' && |\n|  &&
                   '    <td width=25 style=''width:18.75pt;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                   '    <p class=MsoNormal><span style=''font-size:1.0pt;mso-fareast-font-family:' && |\n|  &&
                   '    "Times New Roman"''>&nbsp;</span><span style=''mso-fareast-font-family:"Times New Roman"''>' && |\n|  &&
                   '    </span><span style=''mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:' && |\n|  &&
                   '    Calibri;color:#222222''><o:p></o:p></span></p>' && |\n|  &&
                   '    </td>' && |\n|  &&
                   '   </tr>' && |\n|  &&
                   '  </table>' && |\n|  &&
                   '  </td>' && |\n|  &&
                   ' </tr>' && |\n|  &&
                   '</table>' && |\n|  &&
                   |\n|  &&
                   '</div>' && |\n|  &&
                   |\n|  &&
                   '<p class=MsoNormal><span style=''mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                   'mso-bidi-font-family:Calibri''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                   |\n|  &&
                   '<p class=MsoNormal><o:p>&nbsp;</o:p></p>' && |\n|  &&
                   |\n|  &&
                   '</div>' && |\n|  &&
                   |\n|  &&
                   '</body>' && |\n|  &&
                   |\n|  &&
                   '</html>'.
    ENDIF.
    IF ls_template = '2'.
        r_template = '<html xmlns:v="urn:schemas-microsoft-com:vml"' && |\n|  &&
                     'xmlns:o="urn:schemas-microsoft-com:office:office"' && |\n|  &&
                     'xmlns:w="urn:schemas-microsoft-com:office:word"' && |\n|  &&
                     'xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"' && |\n|  &&
                     'xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"' && |\n|  &&
                     'xmlns="http://www.w3.org/TR/REC-html40">' && |\n|  &&
                     |\n|  &&
                     '<head>' && |\n|  &&
                     '<meta http-equiv=Content-Type content="text/html; charset=utf-8">' && |\n|  &&
                     '<meta name=ProgId content=Word.Document>' && |\n|  &&
                     '<meta name=Generator content="Microsoft Word 15">' && |\n|  &&
                     '<meta name=Originator content="Microsoft Word 15">' && |\n|  &&
                     '<link rel=File-List href="Start%20Rejection.fld/filelist.xml">' && |\n|  &&
                     '<link rel=Edit-Time-Data href="Start%20Rejection.fld/editdata.mso">' && |\n|  &&
                     '<!--[if !mso]>' && |\n|  &&
                     '<style>' && |\n|  &&
                     'v\:* {behavior:url(#default#VML);}' && |\n|  &&
                     'o\:* {behavior:url(#default#VML);}' && |\n|  &&
                     'w\:* {behavior:url(#default#VML);}' && |\n|  &&
                     '.shape {behavior:url(#default#VML);}' && |\n|  &&
                     '</style>' && |\n|  &&
                     '<![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                     ' <o:DocumentProperties>' && |\n|  &&
                     '  <o:Author>Franke, Miriam</o:Author>' && |\n|  &&
                     '  <o:LastAuthor>Baltazar, Jorge</o:LastAuthor>' && |\n|  &&
                     '  <o:Revision>2</o:Revision>' && |\n|  &&
                     '  <o:TotalTime>62</o:TotalTime>' && |\n|  &&
                     '  <o:Created>2023-05-16T20:44:00Z</o:Created>' && |\n|  &&
                     '  <o:LastSaved>2023-05-16T20:44:00Z</o:LastSaved>' && |\n|  &&
                     '  <o:Pages>1</o:Pages>' && |\n|  &&
                     '  <o:Words>243</o:Words>' && |\n|  &&
                     '  <o:Characters>1386</o:Characters>' && |\n|  &&
                     '  <o:Lines>11</o:Lines>' && |\n|  &&
                     '  <o:Paragraphs>3</o:Paragraphs>' && |\n|  &&
                     '  <o:CharactersWithSpaces>1626</o:CharactersWithSpaces>' && |\n|  &&
                     '  <o:Version>16.00</o:Version>' && |\n|  &&
                     ' </o:DocumentProperties>' && |\n|  &&
                     ' <o:CustomDocumentProperties>' && |\n|  &&
                     '  <o:ContentTypeId dt:dt="string">0x010100152218F3AB2BA94F8E39A19C9CC1D1A5</o:ContentTypeId>' && |\n|  &&
                     '  <o:MediaServiceImageTags dt:dt="string"></o:MediaServiceImageTags>' && |\n|  &&
                     ' </o:CustomDocumentProperties>' && |\n|  &&
                     ' <o:OfficeDocumentSettings>' && |\n|  &&
                     '  <o:AllowPNG/>' && |\n|  &&
                     ' </o:OfficeDocumentSettings>' && |\n|  &&
                     '</xml><![endif]-->' && |\n|  &&
                     '<link rel=dataStoreItem href="Start%20Rejection.fld/item0001.xml"' && |\n|  &&
                     'target="Start%20Rejection.fld/props002.xml">' && |\n|  &&
                     '<link rel=dataStoreItem href="Start%20Rejection.fld/item0003.xml"' && |\n|  &&
                     'target="Start%20Rejection.fld/props004.xml">' && |\n|  &&
                     '<link rel=dataStoreItem href="Start%20Rejection.fld/item0005.xml"' && |\n|  &&
                     'target="Start%20Rejection.fld/props006.xml">' && |\n|  &&
                     '<link rel=themeData href="Start%20Rejection.fld/themedata.thmx">' && |\n|  &&
                     '<link rel=colorSchemeMapping href="Start%20Rejection.fld/colorschememapping.xml">' && |\n|  &&
                     '<!--[if gte mso 9]><xml>' && |\n|  &&
                     ' <w:WordDocument>' && |\n|  &&
                     '  <w:HideSpellingErrors/>' && |\n|  &&
                     '  <w:HideGrammaticalErrors/>' && |\n|  &&
                     '  <w:SpellingState>Clean</w:SpellingState>' && |\n|  &&
                     '  <w:GrammarState>Clean</w:GrammarState>' && |\n|  &&
                     '  <w:TrackMoves>false</w:TrackMoves>' && |\n|  &&
                     '  <w:TrackFormatting/>' && |\n|  &&
                     '  <w:PunctuationKerning/>' && |\n|  &&
                     '  <w:ValidateAgainstSchemas/>' && |\n|  &&
                     '  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>' && |\n|  &&
                     '  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>' && |\n|  &&
                     '  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>' && |\n|  &&
                     '  <w:DoNotPromoteQF/>' && |\n|  &&
                     '  <w:LidThemeOther>en-MX</w:LidThemeOther>' && |\n|  &&
                     '  <w:LidThemeAsian>X-NONE</w:LidThemeAsian>' && |\n|  &&
                     '  <w:LidThemeComplexScript>X-NONE</w:LidThemeComplexScript>' && |\n|  &&
                     '  <w:Compatibility>' && |\n|  &&
                     '   <w:BreakWrappedTables/>' && |\n|  &&
                     '   <w:SnapToGridInCell/>' && |\n|  &&
                     '   <w:WrapTextWithPunct/>' && |\n|  &&
                     '   <w:UseAsianBreakRules/>' && |\n|  &&
                     '   <w:DontGrowAutofit/>' && |\n|  &&
                     '   <w:SplitPgBreakAndParaMark/>' && |\n|  &&
                     '   <w:EnableOpenTypeKerning/>' && |\n|  &&
                     '   <w:DontFlipMirrorIndents/>' && |\n|  &&
                     '   <w:OverrideTableStyleHps/>' && |\n|  &&
                     '  </w:Compatibility>' && |\n|  &&
                     '  <m:mathPr>' && |\n|  &&
                     '   <m:mathFont m:val="Cambria Math"/>' && |\n|  &&
                     '   <m:brkBin m:val="before"/>' && |\n|  &&
                     '   <m:brkBinSub m:val="&#45;-"/>' && |\n|  &&
                     '   <m:smallFrac m:val="off"/>' && |\n|  &&
                     '   <m:dispDef/>' && |\n|  &&
                     '   <m:lMargin m:val="0"/>' && |\n|  &&
                     '   <m:rMargin m:val="0"/>' && |\n|  &&
                     '   <m:defJc m:val="centerGroup"/>' && |\n|  &&
                     '   <m:wrapIndent m:val="1440"/>' && |\n|  &&
                     '   <m:intLim m:val="subSup"/>' && |\n|  &&
                     '   <m:naryLim m:val="undOvr"/>' && |\n|  &&
                     '  </m:mathPr></w:WordDocument>' && |\n|  &&
                     '</xml><![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                     ' <w:LatentStyles DefLockedState="false" DefUnhideWhenUsed="false"' && |\n|  &&
                     '  DefSemiHidden="false" DefQFormat="false" DefPriority="99"' && |\n|  &&
                     '  LatentStyleCount="376">' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="0" QFormat="true" Name="Normal"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 7"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 8"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="9" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="heading 9"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 7"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 8"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index 9"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 7"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 8"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="toc 9"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Normal Indent"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="footnote text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="annotation text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="header"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="footer"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="index heading"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="35" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="caption"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="table of figures"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="envelope address"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="envelope return"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="footnote reference"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="annotation reference"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="line number"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="page number"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="endnote reference"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="endnote text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="table of authorities"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="macro"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="toa heading"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Bullet"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Number"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Bullet 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Bullet 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Bullet 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Bullet 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Number 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Number 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Number 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Number 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="10" QFormat="true" Name="Title"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Closing"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Signature"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="1" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="Default Paragraph Font"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text Indent"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Continue"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Continue 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Continue 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Continue 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="List Continue 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Message Header"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="11" QFormat="true" Name="Subtitle"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Salutation"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Date"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text First Indent"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text First Indent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Note Heading"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text Indent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Body Text Indent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Block Text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Hyperlink"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="FollowedHyperlink"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="22" QFormat="true" Name="Strong"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="20" QFormat="true" Name="Emphasis"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Document Map"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Plain Text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="E-mail Signature"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Top of Form"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Bottom of Form"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Normal (Web)"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Acronym"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Address"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Cite"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Code"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Definition"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Keyboard"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Preformatted"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Sample"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Typewriter"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="HTML Variable"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Normal Table"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="annotation subject"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="No List"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Outline List 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Outline List 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Outline List 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Simple 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Simple 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Simple 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Classic 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Classic 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Classic 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Classic 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Colorful 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Colorful 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Colorful 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Columns 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Columns 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Columns 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Columns 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Columns 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 7"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Grid 8"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 7"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table List 8"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table 3D effects 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table 3D effects 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table 3D effects 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Contemporary"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Elegant"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Professional"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Subtle 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Subtle 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Web 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Web 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Web 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Balloon Text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" Name="Table Grid"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Table Theme"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" Name="Placeholder Text"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="1" QFormat="true" Name="No Spacing"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="60" Name="Light Shading"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="61" Name="Light List"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="62" Name="Light Grid"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="70" Name="Dark List"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="72" Name="Colorful List"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" Name="Revision"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="34" QFormat="true"' && |\n|  &&
                     '   Name="List Paragraph"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="29" QFormat="true" Name="Quote"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="30" QFormat="true"' && |\n|  &&
                     '   Name="Intense Quote"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="60" Name="Light Shading Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="61" Name="Light List Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="62" Name="Light Grid Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="63" Name="Medium Shading 1 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="64" Name="Medium Shading 2 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="65" Name="Medium List 1 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="66" Name="Medium List 2 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="67" Name="Medium Grid 1 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="68" Name="Medium Grid 2 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="69" Name="Medium Grid 3 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="70" Name="Dark List Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="71" Name="Colorful Shading Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="72" Name="Colorful List Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="73" Name="Colorful Grid Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="19" QFormat="true"' && |\n|  &&
                     '   Name="Subtle Emphasis"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="21" QFormat="true"' && |\n|  &&
                     '   Name="Intense Emphasis"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="31" QFormat="true"' && |\n|  &&
                     '   Name="Subtle Reference"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="32" QFormat="true"' && |\n|  &&
                     '   Name="Intense Reference"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="33" QFormat="true" Name="Book Title"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="37" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" Name="Bibliography"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="39" SemiHidden="true"' && |\n|  &&
                     '   UnhideWhenUsed="true" QFormat="true" Name="TOC Heading"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="41" Name="Plain Table 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="42" Name="Plain Table 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="43" Name="Plain Table 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="44" Name="Plain Table 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="45" Name="Plain Table 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="40" Name="Grid Table Light"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46" Name="Grid Table 1 Light"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51" Name="Grid Table 6 Colorful"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52" Name="Grid Table 7 Colorful"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="Grid Table 1 Light Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="Grid Table 6 Colorful Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="Grid Table 7 Colorful Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="Grid Table 1 Light Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="Grid Table 6 Colorful Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="Grid Table 7 Colorful Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="Grid Table 1 Light Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="Grid Table 6 Colorful Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="Grid Table 7 Colorful Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="Grid Table 1 Light Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="Grid Table 6 Colorful Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="Grid Table 7 Colorful Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="Grid Table 1 Light Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="Grid Table 6 Colorful Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="Grid Table 7 Colorful Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="Grid Table 1 Light Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="Grid Table 2 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="Grid Table 3 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="Grid Table 4 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="Grid Table 5 Dark Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="Grid Table 6 Colorful Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="Grid Table 7 Colorful Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46" Name="List Table 1 Light"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="List Table 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="List Table 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="List Table 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51" Name="List Table 6 Colorful"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52" Name="List Table 7 Colorful"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="List Table 1 Light Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="List Table 6 Colorful Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="List Table 7 Colorful Accent 1"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="List Table 1 Light Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="List Table 6 Colorful Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="List Table 7 Colorful Accent 2"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="List Table 1 Light Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="List Table 6 Colorful Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="List Table 7 Colorful Accent 3"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="List Table 1 Light Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="List Table 6 Colorful Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="List Table 7 Colorful Accent 4"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="List Table 1 Light Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="List Table 6 Colorful Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="List Table 7 Colorful Accent 5"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="46"' && |\n|  &&
                     '   Name="List Table 1 Light Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="47" Name="List Table 2 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="48" Name="List Table 3 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="49" Name="List Table 4 Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="50" Name="List Table 5 Dark Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="51"' && |\n|  &&
                     '   Name="List Table 6 Colorful Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" Priority="52"' && |\n|  &&
                     '   Name="List Table 7 Colorful Accent 6"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Mention"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Smart Hyperlink"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Hashtag"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Unresolved Mention"/>' && |\n|  &&
                     '  <w:LsdException Locked="false" SemiHidden="true" UnhideWhenUsed="true"' && |\n|  &&
                     '   Name="Smart Link"/>' && |\n|  &&
                     ' </w:LatentStyles>' && |\n|  &&
                     '</xml><![endif]-->' && |\n|  &&
                     '<style>' && |\n|  &&
                     '<!--' && |\n|  &&
                     ' /* Font Definitions */' && |\n|  &&
                     ' @font-face' && |\n|  &&
                     '  {font-family:Wingdings;' && |\n|  &&
                     '  panose-1:5 0 0 0 0 0 0 0 0 0;' && |\n|  &&
                     '  mso-font-charset:2;' && |\n|  &&
                     '  mso-generic-font-family:auto;' && |\n|  &&
                     '  mso-font-pitch:variable;' && |\n|  &&
                     '  mso-font-signature:0 268435456 0 0 -2147483648 0;}' && |\n|  &&
                     '@font-face' && |\n|  &&
                     '  {font-family:"Cambria Math";' && |\n|  &&
                     '  panose-1:2 4 5 3 5 4 6 3 2 4;' && |\n|  &&
                     '  mso-font-charset:0;' && |\n|  &&
                     '  mso-generic-font-family:roman;' && |\n|  &&
                     '  mso-font-pitch:variable;' && |\n|  &&
                     '  mso-font-signature:3 0 0 0 1 0;}' && |\n|  &&
                     '@font-face' && |\n|  &&
                     '  {font-family:Calibri;' && |\n|  &&
                     '  panose-1:2 15 5 2 2 2 4 3 2 4;' && |\n|  &&
                     '  mso-font-charset:0;' && |\n|  &&
                     '  mso-generic-font-family:swiss;' && |\n|  &&
                     '  mso-font-pitch:variable;' && |\n|  &&
                     '  mso-font-signature:-469750017 -1073732485 9 0 511 0;}' && |\n|  &&
                     ' /* Style Definitions */' && |\n|  &&
                     ' p.MsoNormal, li.MsoNormal, div.MsoNormal' && |\n|  &&
                     '  {mso-style-unhide:no;' && |\n|  &&
                     '  mso-style-qformat:yes;' && |\n|  &&
                     '  mso-style-parent:"";' && |\n|  &&
                     '  margin:0cm;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                     'p.MsoHeader, li.MsoHeader, div.MsoHeader' && |\n|  &&
                     '  {mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-link:"Header Char";' && |\n|  &&
                     '  margin:0cm;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  tab-stops:center 234.0pt right 468.0pt;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                     'p.MsoFooter, li.MsoFooter, div.MsoFooter' && |\n|  &&
                     '  {mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-link:"Footer Char";' && |\n|  &&
                     '  margin:0cm;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  tab-stops:center 234.0pt right 468.0pt;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                     'a:link, span.MsoHyperlink' && |\n|  &&
                     '  {mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  color:#0563C1;' && |\n|  &&
                     '  text-decoration:underline;' && |\n|  &&
                     '  text-underline:single;}' && |\n|  &&
                     'a:visited, span.MsoHyperlinkFollowed' && |\n|  &&
                     '  {mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  color:#954F72;' && |\n|  &&
                     '  mso-themecolor:followedhyperlink;' && |\n|  &&
                     '  text-decoration:underline;' && |\n|  &&
                     '  text-underline:single;}' && |\n|  &&
                     'p' && |\n|  &&
                     '  {mso-style-priority:99;' && |\n|  &&
                     '  mso-margin-top-alt:auto;' && |\n|  &&
                     '  margin-right:0cm;' && |\n|  &&
                     '  mso-margin-bottom-alt:auto;' && |\n|  &&
                     '  margin-left:0cm;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-fareast-theme-font:minor-latin;}' && |\n|  &&
                     'p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph' && |\n|  &&
                     '  {mso-style-priority:34;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  mso-style-qformat:yes;' && |\n|  &&
                     '  margin-top:0cm;' && |\n|  &&
                     '  margin-right:0cm;' && |\n|  &&
                     '  margin-bottom:0cm;' && |\n|  &&
                     '  margin-left:36.0pt;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-fareast-theme-font:minor-latin;' && |\n|  &&
                     '  mso-ansi-language:EN-IN;}' && |\n|  &&
                     'p.Header1, li.Header1, div.Header1' && |\n|  &&
                     '  {mso-style-name:Header1;' && |\n|  &&
                     '  mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  margin-top:0cm;' && |\n|  &&
                     '  margin-right:0cm;' && |\n|  &&
                     '  margin-bottom:3.75pt;' && |\n|  &&
                     '  margin-left:0cm;' && |\n|  &&
                     '  mso-line-height-alt:17.25pt;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:18.0pt;' && |\n|  &&
                     '  font-family:"Arial",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                     '  color:black;' && |\n|  &&
                     '  font-weight:bold;}' && |\n|  &&
                     'p.subheader, li.subheader, div.subheader' && |\n|  &&
                     '  {mso-style-name:subheader;' && |\n|  &&
                     '  mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  margin-top:3.75pt;' && |\n|  &&
                     '  margin-right:0cm;' && |\n|  &&
                     '  margin-bottom:3.75pt;' && |\n|  &&
                     '  margin-left:0cm;' && |\n|  &&
                     '  line-height:15.0pt;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:15.0pt;' && |\n|  &&
                     '  font-family:"Arial",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                     '  color:black;}' && |\n|  &&
                     'p.Footer1, li.Footer1, div.Footer1' && |\n|  &&
                     '  {mso-style-name:Footer1;' && |\n|  &&
                     '  mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  margin-top:4.5pt;' && |\n|  &&
                     '  margin-right:0cm;' && |\n|  &&
                     '  margin-bottom:9.0pt;' && |\n|  &&
                     '  margin-left:0cm;' && |\n|  &&
                     '  line-height:9.0pt;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:7.5pt;' && |\n|  &&
                     '  font-family:"Arial",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                     '  color:#666666;}' && |\n|  &&
                     'span.subheader1' && |\n|  &&
                     '  {mso-style-name:subheader1;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  mso-ansi-font-size:15.0pt;' && |\n|  &&
                     '  mso-bidi-font-size:15.0pt;' && |\n|  &&
                     '  font-family:"Arial",sans-serif;' && |\n|  &&
                     '  mso-ascii-font-family:Arial;' && |\n|  &&
                     '  mso-hansi-font-family:Arial;' && |\n|  &&
                     '  mso-bidi-font-family:Arial;' && |\n|  &&
                     '  color:black;' && |\n|  &&
                     '  font-weight:normal;}' && |\n|  &&
                     'span.disclaimer1' && |\n|  &&
                     '  {mso-style-name:disclaimer1;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  mso-ansi-font-size:7.0pt;' && |\n|  &&
                     '  mso-bidi-font-size:7.0pt;' && |\n|  &&
                     '  font-family:"Arial",sans-serif;' && |\n|  &&
                     '  mso-ascii-font-family:Arial;' && |\n|  &&
                     '  mso-hansi-font-family:Arial;' && |\n|  &&
                     '  mso-bidi-font-family:Arial;' && |\n|  &&
                     '  color:#555555;' && |\n|  &&
                     '  mso-text-animation:none;' && |\n|  &&
                     '  font-weight:normal;' && |\n|  &&
                     '  font-style:normal;' && |\n|  &&
                     '  text-decoration:none;' && |\n|  &&
                     '  text-underline:none;' && |\n|  &&
                     '  text-decoration:none;' && |\n|  &&
                     '  text-line-through:none;}' && |\n|  &&
                     'span.HeaderChar' && |\n|  &&
                     '  {mso-style-name:"Header Char";' && |\n|  &&
                     '  mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  mso-style-locked:yes;' && |\n|  &&
                     '  mso-style-link:Header;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-ascii-font-family:Calibri;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-hansi-font-family:Calibri;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                     'span.FooterChar' && |\n|  &&
                     '  {mso-style-name:"Footer Char";' && |\n|  &&
                     '  mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  mso-style-locked:yes;' && |\n|  &&
                     '  mso-style-link:Footer;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-ascii-font-family:Calibri;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-hansi-font-family:Calibri;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                     'span.SpellE' && |\n|  &&
                     '  {mso-style-name:"";' && |\n|  &&
                     '  mso-spl-e:yes;}' && |\n|  &&
                     'span.GramE' && |\n|  &&
                     '  {mso-style-name:"";' && |\n|  &&
                     '  mso-gram-e:yes;}' && |\n|  &&
                     '.MsoChpDefault' && |\n|  &&
                     '  {mso-style-type:export-only;' && |\n|  &&
                     '  mso-default-props:yes;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  mso-ansi-font-size:11.0pt;' && |\n|  &&
                     '  mso-bidi-font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-ascii-font-family:Calibri;' && |\n|  &&
                     '  mso-ascii-theme-font:minor-latin;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-fareast-theme-font:minor-latin;' && |\n|  &&
                     '  mso-hansi-font-family:Calibri;' && |\n|  &&
                     '  mso-hansi-theme-font:minor-latin;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";' && |\n|  &&
                     '  mso-bidi-theme-font:minor-bidi;' && |\n|  &&
                     '  mso-font-kerning:0pt;' && |\n|  &&
                     '  mso-ligatures:none;}' && |\n|  &&
                     '.MsoPapDefault' && |\n|  &&
                     '  {mso-style-type:export-only;' && |\n|  &&
                     '  margin-bottom:8.0pt;' && |\n|  &&
                     '  line-height:107%;}' && |\n|  &&
                     ' /* Page Definitions */' && |\n|  &&
                     ' @page' && |\n|  &&
                     '  {mso-footnote-separator:url("Start%20Rejection.fld/header.html") fs;' && |\n|  &&
                     '  mso-footnote-continuation-separator:url("Start%20Rejection.fld/header.html") fcs;' && |\n|  &&
                     '  mso-footnote-continuation-notice:url("Start%20Rejection.fld/header.html") fcn;' && |\n|  &&
                     '  mso-endnote-separator:url("Start%20Rejection.fld/header.html") es;' && |\n|  &&
                     '  mso-endnote-continuation-separator:url("Start%20Rejection.fld/header.html") ecs;' && |\n|  &&
                     '  mso-endnote-continuation-notice:url("Start%20Rejection.fld/header.html") ecn;}' && |\n|  &&
                     '@page WordSection1' && |\n|  &&
                     '  {size:595.3pt 841.9pt;' && |\n|  &&
                     '  margin:72.0pt 72.0pt 72.0pt 72.0pt;' && |\n|  &&
                     '  mso-header-margin:35.4pt;' && |\n|  &&
                     '  mso-footer-margin:35.4pt;' && |\n|  &&
                     '  mso-paper-source:0;}' && |\n|  &&
                     'div.WordSection1' && |\n|  &&
                     '  {page:WordSection1;}' && |\n|  &&
                     ' /* List Definitions */' && |\n|  &&
                     ' @list l0' && |\n|  &&
                     '  {mso-list-id:451630024;' && |\n|  &&
                     '  mso-list-type:hybrid;' && |\n|  &&
                     '  mso-list-template-ids:-724905110 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675;}' && |\n|  &&
                     '@list l0:level1' && |\n|  &&
                     '  {mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l0:level2' && |\n|  &&
                     '  {mso-level-number-format:alpha-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l0:level3' && |\n|  &&
                     '  {mso-level-number-format:roman-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:right;' && |\n|  &&
                     '  text-indent:-9.0pt;}' && |\n|  &&
                     '@list l0:level4' && |\n|  &&
                     '  {mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l0:level5' && |\n|  &&
                     '  {mso-level-number-format:alpha-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l0:level6' && |\n|  &&
                     '  {mso-level-number-format:roman-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:right;' && |\n|  &&
                     '  text-indent:-9.0pt;}' && |\n|  &&
                     '@list l0:level7' && |\n|  &&
                     '  {mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l0:level8' && |\n|  &&
                     '  {mso-level-number-format:alpha-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l0:level9' && |\n|  &&
                     '  {mso-level-number-format:roman-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:right;' && |\n|  &&
                     '  text-indent:-9.0pt;}' && |\n|  &&
                     '@list l1' && |\n|  &&
                     '  {mso-list-id:831213213;' && |\n|  &&
                     '  mso-list-type:hybrid;' && |\n|  &&
                     '  mso-list-template-ids:743322282 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675 1074331663 1074331673 1074331675;}' && |\n|  &&
                     '@list l1:level1' && |\n|  &&
                     '  {mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l1:level2' && |\n|  &&
                     '  {mso-level-number-format:alpha-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l1:level3' && |\n|  &&
                     '  {mso-level-number-format:roman-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:right;' && |\n|  &&
                     '  text-indent:-9.0pt;}' && |\n|  &&
                     '@list l1:level4' && |\n|  &&
                     '  {mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l1:level5' && |\n|  &&
                     '  {mso-level-number-format:alpha-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l1:level6' && |\n|  &&
                     '  {mso-level-number-format:roman-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:right;' && |\n|  &&
                     '  text-indent:-9.0pt;}' && |\n|  &&
                     '@list l1:level7' && |\n|  &&
                     '  {mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l1:level8' && |\n|  &&
                     '  {mso-level-number-format:alpha-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;}' && |\n|  &&
                     '@list l1:level9' && |\n|  &&
                     '  {mso-level-number-format:roman-lower;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:right;' && |\n|  &&
                     '  text-indent:-9.0pt;}' && |\n|  &&
                     '@list l2' && |\n|  &&
                     '  {mso-list-id:1428189546;' && |\n|  &&
                     '  mso-list-type:hybrid;' && |\n|  &&
                     '  mso-list-template-ids:2052590232 67698689 67698691 67698693 67698689 67698691 67698693 67698689 67698691 67698693;}' && |\n|  &&
                     '@list l2:level1' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Symbol;}' && |\n|  &&
                     '@list l2:level2' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:o;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:"Courier New";}' && |\n|  &&
                     '@list l2:level3' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Wingdings;}' && |\n|  &&
                     '@list l2:level4' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Symbol;}' && |\n|  &&
                     '@list l2:level5' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:o;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:"Courier New";}' && |\n|  &&
                     '@list l2:level6' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Wingdings;}' && |\n|  &&
                     '@list l2:level7' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Symbol;}' && |\n|  &&
                     '@list l2:level8' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:o;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:"Courier New";}' && |\n|  &&
                     '@list l2:level9' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Wingdings;}' && |\n|  &&
                     '@list l3' && |\n|  &&
                     '  {mso-list-id:1590625064;' && |\n|  &&
                     '  mso-list-type:hybrid;' && |\n|  &&
                     '  mso-list-template-ids:1752230816 536870913 536870915 536870917 536870913 536870915 536870917 536870913 536870915 536870917;}' && |\n|  &&
                     '@list l3:level1' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Symbol;}' && |\n|  &&
                     '@list l3:level2' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:o;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:"Courier New";}' && |\n|  &&
                     '@list l3:level3' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Wingdings;}' && |\n|  &&
                     '@list l3:level4' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Symbol;}' && |\n|  &&
                     '@list l3:level5' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:o;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:"Courier New";}' && |\n|  &&
                     '@list l3:level6' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Wingdings;}' && |\n|  &&
                     '@list l3:level7' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Symbol;}' && |\n|  &&
                     '@list l3:level8' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:o;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:"Courier New";}' && |\n|  &&
                     '@list l3:level9' && |\n|  &&
                     '  {mso-level-number-format:bullet;' && |\n|  &&
                     '  mso-level-text:;' && |\n|  &&
                     '  mso-level-tab-stop:none;' && |\n|  &&
                     '  mso-level-number-position:left;' && |\n|  &&
                     '  text-indent:-18.0pt;' && |\n|  &&
                     '  font-family:Wingdings;}' && |\n|  &&
                     'ol' && |\n|  &&
                     '  {margin-bottom:0cm;}' && |\n|  &&
                     'ul' && |\n|  &&
                     '  {margin-bottom:0cm;}' && |\n|  &&
                     '-->' && |\n|  &&
                     '</style>' && |\n|  &&
                     '<!--[if gte mso 10]>' && |\n|  &&
                     '<style>' && |\n|  &&
                     ' /* Style Definitions */' && |\n|  &&
                     ' table.MsoNormalTable' && |\n|  &&
                     '  {mso-style-name:"Table Normal";' && |\n|  &&
                     '  mso-tstyle-rowband-size:0;' && |\n|  &&
                     '  mso-tstyle-colband-size:0;' && |\n|  &&
                     '  mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-parent:"";' && |\n|  &&
                     '  mso-padding-alt:0cm 5.4pt 0cm 5.4pt;' && |\n|  &&
                     '  mso-para-margin-top:0cm;' && |\n|  &&
                     '  mso-para-margin-right:0cm;' && |\n|  &&
                     '  mso-para-margin-bottom:8.0pt;' && |\n|  &&
                     '  mso-para-margin-left:0cm;' && |\n|  &&
                     '  line-height:107%;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-ascii-font-family:Calibri;' && |\n|  &&
                     '  mso-ascii-theme-font:minor-latin;' && |\n|  &&
                     '  mso-hansi-font-family:Calibri;' && |\n|  &&
                     '  mso-hansi-theme-font:minor-latin;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";' && |\n|  &&
                     '  mso-bidi-theme-font:minor-bidi;}' && |\n|  &&
                     'table.NormaleTabelle' && |\n|  &&
                     '  {mso-style-name:"Normale Tabelle";' && |\n|  &&
                     '  mso-tstyle-rowband-size:0;' && |\n|  &&
                     '  mso-tstyle-colband-size:0;' && |\n|  &&
                     '  mso-style-noshow:yes;' && |\n|  &&
                     '  mso-style-priority:99;' && |\n|  &&
                     '  mso-style-unhide:no;' && |\n|  &&
                     '  mso-style-parent:"";' && |\n|  &&
                     '  mso-padding-alt:0cm 5.4pt 0cm 5.4pt;' && |\n|  &&
                     '  mso-para-margin:0cm;' && |\n|  &&
                     '  mso-pagination:widow-orphan;' && |\n|  &&
                     '  font-size:11.0pt;' && |\n|  &&
                     '  font-family:"Calibri",sans-serif;' && |\n|  &&
                     '  mso-fareast-font-family:Calibri;' && |\n|  &&
                     '  mso-bidi-font-family:"Times New Roman";}' && |\n|  &&
                     '</style>' && |\n|  &&
                     '<![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                     ' <o:shapedefaults v:ext="edit" spidmax="2051"/>' && |\n|  &&
                     '</xml><![endif]--><!--[if gte mso 9]><xml>' && |\n|  &&
                     ' <o:shapelayout v:ext="edit">' && |\n|  &&
                     '  <o:idmap v:ext="edit" data="2"/>' && |\n|  &&
                     ' </o:shapelayout></xml><![endif]-->' && |\n|  &&
                     '</head>' && |\n|  &&
                     |\n|  &&
                     '<body lang=en-MX link="#0563C1" vlink="#954F72" style=''tab-interval:36.0pt;' && |\n|  &&
                     'word-wrap:break-word''>' && |\n|  &&
                     |\n|  &&
                     '<div class=WordSection1>' && |\n|  &&
                     |\n|  &&
                     '<div align=center>' && |\n|  &&
                     |\n|  &&
                     '<table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0 width=630' && |\n|  &&
                     ' style=''width:472.5pt;border-collapse:collapse;mso-yfti-tbllook:1184;' && |\n|  &&
                     ' mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     ' <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes''>' && |\n|  &&
                     '  <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '  <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0 width=630' && |\n|  &&
                     '   style=''width:472.5pt;border-collapse:collapse;mso-yfti-tbllook:1184;' && |\n|  &&
                     '   mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '   <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes''>' && |\n|  &&
                     '    <td width=25 style=''width:18.75pt;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '    <p class=MsoNormal><span style=''font-size:1.0pt;mso-fareast-font-family:' && |\n|  &&
                     '    "Times New Roman"''>&nbsp;</span><span style=''mso-fareast-font-family:"Times New Roman"''>' && |\n|  &&
                     '    <o:p></o:p></span></p>' && |\n|  &&
                     '    <p class=MsoNormal><span style=''mso-fareast-font-family:"Times New Roman"''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                     '    </td>' && |\n|  &&
                     '    <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '    <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0 width=580' && |\n|  &&
                     '     style=''width:435.0pt;border-collapse:collapse;mso-yfti-tbllook:1184;' && |\n|  &&
                     '     mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '     <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;height:56.25pt''>' && |\n|  &&
                     '      <td style=''padding:0cm 0cm 0cm 0cm;height:56.25pt''>' && |\n|  &&
                     '      <div align=center>' && |\n|  &&
                     '      <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0' && |\n|  &&
                     '       width=580 style=''width:435.0pt;border-collapse:collapse;mso-yfti-tbllook:' && |\n|  &&
                     '       1184;mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '       <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;' && |\n|  &&
                     '        height:56.25pt''>' && |\n|  &&
                     '        <td width=580 valign=top style=''width:435.0pt;padding:0cm 0cm 0cm 0cm;' && |\n|  &&
                     '        height:56.25pt''>' && |\n|  &&
                     '        <p class=MsoNormal><!--[if gte vml 1]><v:shapetype id="_x0000_t75"' && |\n|  &&
                     '         coordsize="21600,21600" o:spt="75" o:preferrelative="t" path="m@4@5l@4@11@9@11@9@5xe"' && |\n|  &&
                     '         filled="f" stroked="f">' && |\n|  &&
                     '         <v:stroke joinstyle="miter"/>' && |\n|  &&
                     '         <v:formulas>' && |\n|  &&
                     '          <v:f eqn="if lineDrawn pixelLineWidth 0"/>' && |\n|  &&
                     '          <v:f eqn="sum @0 1 0"/>' && |\n|  &&
                     '          <v:f eqn="sum 0 0 @1"/>' && |\n|  &&
                     '          <v:f eqn="prod @2 1 2"/>' && |\n|  &&
                     '          <v:f eqn="prod @3 21600 pixelWidth"/>' && |\n|  &&
                     '          <v:f eqn="prod @3 21600 pixelHeight"/>' && |\n|  &&
                     '          <v:f eqn="sum @0 0 1"/>' && |\n|  &&
                     '          <v:f eqn="prod @6 1 2"/>' && |\n|  &&
                     '          <v:f eqn="prod @7 21600 pixelWidth"/>' && |\n|  &&
                     '          <v:f eqn="sum @8 21600 0"/>' && |\n|  &&
                     '          <v:f eqn="prod @7 21600 pixelHeight"/>' && |\n|  &&
                     '          <v:f eqn="sum @10 21600 0"/>' && |\n|  &&
                     '         </v:formulas>' && |\n|  &&
                     '         <v:path o:extrusionok="f" gradientshapeok="t" o:connecttype="rect"/>' && |\n|  &&
                     '         <o:lock v:ext="edit" aspectratio="t"/>' && |\n|  &&
                     '        </v:shapetype><v:shape id="Picture_x0020_3" o:spid="_x0000_s2050"' && |\n|  &&
                     '         type="#_x0000_t75" alt="SAP Logo" style=''position:absolute;' && |\n|  &&
                     '         margin-left:84.55pt;margin-top:0;width:135.75pt;height:51pt;z-index:251658240;' && |\n|  &&
                     '         visibility:visible;mso-wrap-style:square;mso-width-percent:0;' && |\n|  &&
                     '         mso-height-percent:0;mso-wrap-distance-left:0;mso-wrap-distance-top:0;' && |\n|  &&
                     '         mso-wrap-distance-right:0;mso-wrap-distance-bottom:0;' && |\n|  &&
                     '         mso-position-horizontal:right;mso-position-horizontal-relative:text;' && |\n|  &&
                     '         mso-position-vertical:absolute;mso-position-vertical-relative:line;' && |\n|  &&
                     '         mso-width-percent:0;mso-height-percent:0;mso-width-relative:page;' && |\n|  &&
                     '         mso-height-relative:page'' o:allowoverlap="f">' && |\n|  &&
                     '         <v:imagedata src="image001.png" o:title="SAP Logo"/>' && |\n|  &&
                     '         <w:wrap type="square" anchory="line"/>' && |\n|  &&
                     '        </v:shape><![endif]--><![if !vml]><img width=136 height=51' && |\n|  &&
                     '        src="image001.png" align=right alt="SAP Logo"' && |\n|  &&
                     '        v:shapes="Picture_x0020_3"><![endif]><span style=''mso-fareast-font-family:' && |\n|  &&
                     '        "Times New Roman"''><o:p></o:p></span></p>' && |\n|  &&
                     '        </td>' && |\n|  &&
                     '       </tr>' && |\n|  &&
                     '      </table>' && |\n|  &&
                     '      </div>' && |\n|  &&
                     '      </td>' && |\n|  &&
                     '     </tr>' && |\n|  &&
                     '     <tr style=''mso-yfti-irow:1''>' && |\n|  &&
                     '      <td style=''background:black;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '      <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0' && |\n|  &&
                     '       style=''border-collapse:collapse;mso-yfti-tbllook:1184;mso-padding-alt:' && |\n|  &&
                     '       0cm 5.4pt 0cm 5.4pt''>' && |\n|  &&
                     '       <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;' && |\n|  &&
                     '        height:123.75pt''>' && |\n|  &&
                     '        <td width=25 style=''width:18.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                     '        height:123.75pt''>' && |\n|  &&
                     '        <p><span style=''mso-bidi-font-family:"Times New Roman"''>&nbsp;<o:p></o:p></span></p>' && |\n|  &&
                     '        </td>' && |\n|  &&
                     '        <td width=365 style=''width:273.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                     '        height:123.75pt''>' && |\n|  &&
                     '        <p class=Header1><a name="Top_e"><span lang=EN-US style=''color:white;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>5 Steps to Fiori</span></a><span' && |\n|  &&
                     '        style=''mso-bookmark:Top_e''><span lang=EN-US style=''color:#FFC000;' && |\n|  &&
                     '        mso-ansi-language:EN-US''> Bootcamp</span></span><span style=''mso-bookmark:' && |\n|  &&
                     '        Top_e''><span style=''color:white''><o:p></o:p></span></span></p>' && |\n|  &&
                     '        <span style=''mso-bookmark:Top_e''></span></td>' && |\n|  &&
                     '        <span style=''mso-bookmark:Top_e''></span>' && |\n|  &&
                     '        <td width=165 style=''width:123.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                     '        height:123.75pt''>' && |\n|  &&
                     '        <p class=MsoNormal align=center style=''text-align:center''><span' && |\n|  &&
                     '        style=''mso-fareast-font-family:"Times New Roman";mso-no-proof:yes''><!--[if gte vml 1]><v:shape' && |\n|  &&
                     '         id="Picture_x0020_2" o:spid="_x0000_i1026" type="#_x0000_t75" style=''width:124pt;' && |\n|  &&
                     '         height:124pt;visibility:visible;mso-wrap-style:square''>' && |\n|  &&
                     '         <v:imagedata src="image002.png" o:title=""/>' && |\n|  &&
                     '        </v:shape><![endif]--><![if !vml]><img width=124 height=124' && |\n|  &&
                     '        src="image002.png" v:shapes="Picture_x0020_2"><![endif]></span><span' && |\n|  &&
                     '        style=''mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:' && |\n|  &&
                     '        Calibri;color:#222222''><o:p></o:p></span></p>' && |\n|  &&
                     '        </td>' && |\n|  &&
                     '        <td width=25 style=''width:18.75pt;padding:.75pt .75pt .75pt .75pt;' && |\n|  &&
                     '        height:123.75pt''>' && |\n|  &&
                     '        <p><span style=''mso-bidi-font-family:"Times New Roman"''>&nbsp;<o:p></o:p></span></p>' && |\n|  &&
                     '        </td>' && |\n|  &&
                     '       </tr>' && |\n|  &&
                     '      </table>' && |\n|  &&
                     '      </td>' && |\n|  &&
                     '      <span style=''mso-bookmark:Top_e''></span>' && |\n|  &&
                     '     </tr>' && |\n|  &&
                     '     <tr style=''mso-yfti-irow:2''>' && |\n|  &&
                     '      <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '      <table class=NormaleTabelle border=0 cellspacing=0 cellpadding=0' && |\n|  &&
                     '       width=580 style=''width:435.0pt;border-collapse:collapse;mso-yfti-tbllook:' && |\n|  &&
                     '       1184;mso-padding-alt:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '       <tr style=''mso-yfti-irow:0;mso-yfti-firstrow:yes''>' && |\n|  &&
                     '        <td style=''padding:7.5pt 0cm 7.5pt 0cm''></td>' && |\n|  &&
                     '        <span style=''mso-bookmark:Top_e''></span>' && |\n|  &&
                     '       </tr>' && |\n|  &&
                     '       <tr style=''mso-yfti-irow:1;mso-yfti-lastrow:yes''>' && |\n|  &&
                     '        <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '        <p style=''line-height:16.5pt''><b><span style=''font-family:"Arial",sans-serif''>Dear' && |\n|  &&
                     '        </span></b><b><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>Participant</span></b><b><span' && |\n|  &&
                     '        style=''font-family:"Arial",sans-serif''>,<o:p></o:p></span></b></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>Thank you for your application to the</span><span' && |\n|  &&
                     '        style=''font-family:"Arial",sans-serif''> 5Steps2Fiori <span class=GramE>bootcamp.<span' && |\n|  &&
                     '        lang=EN-US style=''mso-ansi-language:EN-US''>We</span></span></span><span' && |\n|  &&
                     '        lang=EN-US style=''font-family:"Arial",sans-serif;mso-ansi-language:' && |\n|  &&
                     '        EN-US''> really appreciate your interest in joining our training' && |\n|  &&
                     '        sessions.<o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>After a lot of careful thought, we have decided' && |\n|  &&
                     '        not to approve your registration to the customer bootcamp. Main </span><span' && |\n|  &&
                     '        style=''font-family:"Arial",sans-serif''>reasons for this are</span><span' && |\n|  &&
                     '        lang=EN-US style=''font-family:"Arial",sans-serif;mso-ansi-language:' && |\n|  &&
                     '        EN-US''>:<o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoListParagraph style=''text-indent:-18.0pt;mso-list:l2 level1 lfo4''><![if !supportLists]><span' && |\n|  &&
                     '        lang=EN-US style=''font-family:Symbol;mso-fareast-font-family:Symbol;' && |\n|  &&
                     '        mso-bidi-font-family:Symbol;mso-ansi-language:EN-US''><span' && |\n|  &&
                     '        style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' && |\n|  &&
                     '        </span></span></span><![endif]><span lang=EN-US style=''font-family:' && |\n|  &&
                     '        "Arial",sans-serif;mso-ansi-language:EN-US''>Missing / Incomplete' && |\n|  &&
                     '        information in the registration form<o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoListParagraph style=''text-indent:-18.0pt;mso-list:l2 level1 lfo4''><![if !supportLists]><span' && |\n|  &&
                     '        lang=EN-US style=''font-family:Symbol;mso-fareast-font-family:Symbol;' && |\n|  &&
                     '        mso-bidi-font-family:Symbol;mso-ansi-language:EN-US''><span' && |\n|  &&
                     '        style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' && |\n|  &&
                     '        </span></span></span><![endif]><span lang=EN-US style=''font-family:' && |\n|  &&
                     '        "Arial",sans-serif;mso-ansi-language:EN-US''>Wrong customer details<o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoListParagraph style=''text-indent:-18.0pt;mso-list:l2 level1 lfo4''><![if !supportLists]><span' && |\n|  &&
                     '        lang=EN-US style=''font-family:Symbol;mso-fareast-font-family:Symbol;' && |\n|  &&
                     '        mso-bidi-font-family:Symbol;mso-ansi-language:EN-US''><span' && |\n|  &&
                     '        style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' && |\n|  &&
                     '        </span></span></span><![endif]><span lang=EN-US style=''font-family:' && |\n|  &&
                     '        "Arial",sans-serif;mso-ansi-language:EN-US''>Training is fully <span' && |\n|  &&
                     '        class=GramE>booked</span><o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoListParagraph style=''text-indent:-18.0pt;mso-list:l2 level1 lfo4''><![if !supportLists]><span' && |\n|  &&
                     '        lang=EN-US style=''font-family:Symbol;mso-fareast-font-family:Symbol;' && |\n|  &&
                     '        mso-bidi-font-family:Symbol;mso-ansi-language:EN-US''><span' && |\n|  &&
                     '        style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' && |\n|  &&
                     '        </span></span></span><![endif]><span lang=EN-US style=''font-family:' && |\n|  &&
                     '        "Arial",sans-serif;mso-ansi-language:EN-US''>The request comes from an' && |\n|  &&
                     '        SAP Partner<o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>We <span class=SpellE>trully</span> appreciate' && |\n|  &&
                     '        your time and recommend trying to register for upcoming sessions. If' && |\n|  &&
                     '        you have any questions or need additional information, please don’t' && |\n|  &&
                     '        hesitate to contact us by email.<o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>Please note that if you are indeed member of' && |\n|  &&
                     '        an SAP Partner, registration should be done through the official SAP Partner' && |\n|  &&
                     '        channels in your region, let us know if you need help for finding the' && |\n|  &&
                     '        right person.<o:p></o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                     '        <p class=MsoNormal><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>We wish you have a great rest of the day!<o:p></o:p></span></p>' && |\n|  &&
                     '        <p style=''line-height:16.5pt''><span style=''font-family:"Arial",sans-serif''>Kind' && |\n|  &&
                     '        </span><span lang=EN-US style=''font-family:"Arial",sans-serif;' && |\n|  &&
                     '        mso-ansi-language:EN-US''>regards</span><span style=''font-family:"Arial",sans-serif''><o:p></o:p></span></p>' && |\n|  &&
                     '        <p style=''line-height:16.5pt''><b><span lang=EN-US style=''font-family:' && |\n|  &&
                     '        "Arial",sans-serif;mso-ansi-language:EN-US''>The 5 Steps to Fiori team<o:p></o:p></span></b></p>' && |\n|  &&
                     '        <p style=''line-height:16.5pt''><span style=''font-size:8.0pt;font-family:' && |\n|  &&
                     '        "Arial",sans-serif''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                     '        </td>' && |\n|  &&
                     '       </tr>' && |\n|  &&
                     '      </table>' && |\n|  &&
                     '      </td>' && |\n|  &&
                     '     </tr>' && |\n|  &&
                     '     <tr style=''mso-yfti-irow:3''>' && |\n|  &&
                     '      <td style=''padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '      <p class=MsoNormal><a name="Top_d"></a><span style=''mso-fareast-font-family:' && |\n|  &&
                     '      "Times New Roman";mso-no-proof:yes''><!--[if gte vml 1]><v:shape id="Picture_x0020_1"' && |\n|  &&
                     '       o:spid="_x0000_i1025" type="#_x0000_t75" alt="Divider" style=''width:435pt;' && |\n|  &&
                     '       height:2pt;visibility:visible;mso-wrap-style:square''>' && |\n|  &&
                     '       <v:imagedata src="image003.jpg" o:title="Divider"/>' && |\n|  &&
                     '      </v:shape><![endif]--><![if !vml]><img width=435 height=2' && |\n|  &&
                     '      src="image003.jpg" alt=Divider v:shapes="Picture_x0020_1"><![endif]></span><span' && |\n|  &&
                     '      style=''mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:' && |\n|  &&
                     '      Calibri;color:#222222''><o:p></o:p></span></p>' && |\n|  &&
                     '      </td>' && |\n|  &&
                     '     </tr>' && |\n|  &&
                     '     <tr style=''mso-yfti-irow:4;height:12.0pt''>' && |\n|  &&
                     '      <td width=580 style=''width:435.0pt;padding:0cm 0cm 0cm 0cm;height:12.0pt''>' && |\n|  &&
                     '      <p class=Footer1 align=right style=''margin-top:9.0pt;mso-margin-bottom-alt:' && |\n|  &&
                     '      auto;text-align:right''>&nbsp;&nbsp; <a href="http://www.sap.com/copyright"' && |\n|  &&
                     '      target="_blank"><span style=''color:#7F7F7F;text-decoration:none;' && |\n|  &&
                     '      text-underline:none''>Copyright/Trademark</span></a>&nbsp;&nbsp;|&nbsp;&nbsp;' && |\n|  &&
                     '      <a href="http://www.sap.com/about/legal/privacy.html" target="_blank"><span' && |\n|  &&
                     '      style=''color:#7F7F7F;text-decoration:none;text-underline:none''>Privacy</span></a>&nbsp;&nbsp;|&nbsp;&nbsp;' && |\n|  &&
                     '      <a href="http://www.sap.com/about/legal/impressum.html" target="_blank"><span' && |\n|  &&
                     '      style=''color:#7F7F7F;text-decoration:none;text-underline:none''>Impressum</span></a>&nbsp;&nbsp;' && |\n|  &&
                     '      </p>' && |\n|  &&
                     '      </td>' && |\n|  &&
                     '     </tr>' && |\n|  &&
                     '     <tr style=''mso-yfti-irow:5;height:6.0pt''>' && |\n|  &&
                     '      <td style=''background:white;padding:0cm 0cm 0cm 0cm;height:6.0pt''>' && |\n|  &&
                     '      <p class=MsoNormal align=right style=''text-align:right''><span' && |\n|  &&
                     '      style=''mso-fareast-font-family:"Times New Roman";color:black;mso-color-alt:' && |\n|  &&
                     '      windowtext''>&nbsp;</span><span style=''mso-fareast-font-family:"Times New Roman"''><o:p></o:p></span></p>' && |\n|  &&
                     '      </td>' && |\n|  &&
                     '     </tr>' && |\n|  &&
                     '     <tr style=''mso-yfti-irow:6;mso-yfti-lastrow:yes''>' && |\n|  &&
                     '      <td width=580 style=''width:435.0pt;background:white;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '      <p class=MsoNormal style=''line-height:9.0pt''><span class=disclaimer1><span' && |\n|  &&
                     '      style=''font-size:7.0pt;mso-fareast-font-family:"Times New Roman"''>SAP SE,' && |\n|  &&
                     '      Dietmar-Hopp-Allee 16, 69190 Walldorf, Germany</span></span><span' && |\n|  &&
                     '      style=''font-size:7.0pt;font-family:"Arial",sans-serif;mso-fareast-font-family:' && |\n|  &&
                     '      "Times New Roman";color:#555555''><br>' && |\n|  &&
                     '      <br>' && |\n|  &&
                     '      <span class=disclaimer1>This e-mail may contain trade secrets or' && |\n|  &&
                     '      privileged, undisclosed, or otherwise confidential information. If you' && |\n|  &&
                     '      have received this e-mail in error, you are hereby notified that any' && |\n|  &&
                     '      review, copying, or distribution of it is strictly prohibited. Please inform' && |\n|  &&
                     '      us immediately and destroy the original transmittal. Thank you for your' && |\n|  &&
                     '      cooperation.</span><o:p></o:p></span></p>' && |\n|  &&
                     '      </td>' && |\n|  &&
                     '     </tr>' && |\n|  &&
                     '    </table>' && |\n|  &&
                     '    </td>' && |\n|  &&
                     '    <td width=25 style=''width:18.75pt;padding:0cm 0cm 0cm 0cm''>' && |\n|  &&
                     '    <p class=MsoNormal><span style=''font-size:1.0pt;mso-fareast-font-family:' && |\n|  &&
                     '    "Times New Roman"''>&nbsp;</span><span style=''mso-fareast-font-family:"Times New Roman"''>' && |\n|  &&
                     '    </span><span style=''mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:' && |\n|  &&
                     '    Calibri;color:#222222''><o:p></o:p></span></p>' && |\n|  &&
                     '    </td>' && |\n|  &&
                     '   </tr>' && |\n|  &&
                     '  </table>' && |\n|  &&
                     '  </td>' && |\n|  &&
                     ' </tr>' && |\n|  &&
                     '</table>' && |\n|  &&
                     |\n|  &&
                     '</div>' && |\n|  &&
                     |\n|  &&
                     '<p class=MsoNormal><span style=''mso-fareast-font-family:"Times New Roman";' && |\n|  &&
                     'mso-bidi-font-family:Calibri''><o:p>&nbsp;</o:p></span></p>' && |\n|  &&
                     |\n|  &&
                     '<p class=MsoNormal><o:p>&nbsp;</o:p></p>' && |\n|  &&
                     |\n|  &&
                     '</div>' && |\n|  &&
                     |\n|  &&
                     '</body>' && |\n|  &&
                     |\n|  &&
                     '</html>'.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
