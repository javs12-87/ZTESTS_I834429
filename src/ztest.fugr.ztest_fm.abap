FUNCTION ztest_fm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(NUMBER) TYPE  INT8
*"----------------------------------------------------------------------
number =  cl_abap_random=>create(  )->int8( ).
number = 1.

ENDFUNCTION.
