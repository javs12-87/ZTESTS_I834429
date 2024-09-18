CLASS zcl_test_1234 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST_1234 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(top)               = io_request->get_paging( )->get_page_size( ).
    DATA(skip)              = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)        = io_request->get_sort_elements( ).

    IF io_request->is_data_requested( ).

      DATA(lt_req_elements) = io_request->get_requested_elements( ).
      DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
      DATA(filter_tree) = io_request->get_filter( )->get_as_tree( ).

    ENDIF.

    TRY.
        DATA(filter_condition) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
    ENDTRY.

    DATA lt_response TYPE TABLE OF ztest_1234.

    APPEND VALUE #( id = 'hi' id2 = 'hi' ) TO lt_response.

    io_response->set_data( lt_response ).
    io_response->set_total_number_of_records( lines( lt_response ) ).

  ENDMETHOD.
ENDCLASS.
