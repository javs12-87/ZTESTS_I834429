CLASS zcl_dms_connect_list_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DMS_CONNECT_LIST_REPO IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA:
      lv_user        TYPE string,
      ls_user        TYPE string,
      ls_object_id   TYPE string,
      ls_children    TYPE cmis_s_object_in_folder_list,
      ro_cmis_client TYPE REF TO if_cmis_client,
      mo_cmis_client TYPE REF TO if_cmis_client,
      ro_cmis_query  TYPE cmis_s_object_list.

* Create a client instance:
**********************************************************************
* Get the logged-in user                                                                                   *
***********************************************************************
*
*    TRY.
*        CALL METHOD cl_abap_context_info=>get_user_formatted_name
*          RECEIVING
*            rv_formatted_name = ls_user.
*      CATCH cx_abap_context_info_error.
*    ENDTRY.

***********************************************************************
* Get the CMIS Client                                                                                      *
**********************************************************************

    IF mo_cmis_client IS NOT BOUND.

      CALL METHOD cl_cmis_client_factory=>get_instance
        RECEIVING
          ro_client = mo_cmis_client.
    ENDIF.

    "Return the cmis-client
    ro_cmis_client = mo_cmis_client.

*    ro_cmis_client = z_cl_get_cmis_client=>get_client( ).

** Get Repositories in the Service Instance:
*    CALL METHOD ro_cmis_client->get_repositories
*      IMPORTING
*        et_repository_infos = DATA(lt_repository_infos).
*
*    out->write( '-----------' ).
*
** loop at all the repositories and write out, for each of them, Id and some info:
*
*    LOOP AT lt_repository_infos INTO DATA(ls_repository_info).
*      DATA(lv_repository_id) = ls_repository_info-id.
*      DATA(lv_repository_name) = ls_repository_info-name.
*      DATA(lv_root_folder_id) = ls_repository_info-root_folder_id.
*      out->write( | Repository ID: { lv_repository_id } | ).
*      out->write( | Repository Name: { lv_repository_name } | ).
*      out->write( | Root Folder ID: { lv_root_folder_id } | ).
*      out->write( '-----------' ).
*    ENDLOOP.

*Get the repository                                                                                         *
***********************************************************************
*    CALL METHOD ro_cmis_client->get_repository_info
*      EXPORTING
*        iv_repository_id   = 'I834429' "pass the id of the created repository
*      IMPORTING
*        es_repository_info = DATA(ls_repository).

***********************************************************************
** Get all the children of the Root Folder                                                            *
***********************************************************************
*    CALL METHOD ro_cmis_client->get_children
*      EXPORTING
*        iv_folder_id     = ls_repository-root_folder_id
*        iv_repository_id = ls_repository-id
*      IMPORTING
*        es_children      = ls_children.
*
*    LOOP AT ls_children-objects_in_folder INTO DATA(lv_object).
*      DATA(lv_properties) = lv_object-object-properties-properties.
*      READ TABLE lv_properties INTO DATA(ls_objectid_prop)  WITH KEY id = cl_cmis_property_ids=>object_id.
*      READ TABLE ls_objectid_prop-value INTO DATA(ls_objectid) INDEX 1.
*      READ TABLE lv_properties INTO DATA(ls_object_type_id_prop)  WITH KEY id = cl_cmis_property_ids=>object_type_id.
*      READ TABLE ls_object_type_id_prop-value INTO DATA(ls_object_type_id) INDEX 1.
*      out->write( ls_objectid ).
*      out->write( ls_object_type_id ).
*    ENDLOOP.

    CALL METHOD ro_cmis_client->query
      EXPORTING
        iv_repository_id = 'I834429'
        iv_statement     = 'SELECT cmis:objectId FROM cmis:document where cmis:name = ''registrationform.docx'''
*       iv_search_all_versions       =
*       iv_include_relationships     =
*       iv_rendition_filter          =
*       iv_include_allowable_actions =
*       iv_max_items     =
*       iv_skip_count    =
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
      CALL METHOD ro_cmis_client->get_content_stream
        EXPORTING
          iv_repository_id = 'I834429'  " '<Repository ID>'
          iv_object_id     = ls_object_id " '<ID of the custom-type created>'
        IMPORTING
          es_content       = DATA(ls_content). "File-name, file-type, content-length and content are parts of es_content

      DATA: lv_test1  TYPE string,
            lv_string TYPE string.

      lv_test1 = ls_content-stream.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
