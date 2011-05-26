#include "newmacros.h"
#include "runtime.h"

#define CT_v171	((void*)startLabel+56)
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_Prelude_46compare[];

static Node startLabel[] = {
  bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v171)
,};
Node FN_Data_46Ord_46comparing[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(2,3,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG_ARG,2,4,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,ZAP_ARG,4)
, bytes2word(ZAP_STACK_P1,4,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v171: (byte 0) */
  HW(2,4)
, 0
,};
Node F0_Data_46Ord_46comparing[] = {
  CAPTAG(useLabel(FN_Data_46Ord_46comparing),4)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46compare))
,};
