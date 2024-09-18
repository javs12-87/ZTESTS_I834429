CLASS lhc_ZTEST_1234 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ztest_1234 RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE ztest_1234.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE ztest_1234.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE ztest_1234.

    METHODS read FOR READ
      IMPORTING keys FOR READ ztest_1234 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK ztest_1234.

ENDCLASS.

CLASS lhc_ZTEST_1234 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA(lv_test) = 1.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZTEST_1234 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZTEST_1234 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
