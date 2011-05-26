#include "newmacros.h"
#include "runtime.h"

#define CT_v172	((void*)startLabel+68)
#define ST_v170	((void*)startLabel+88)
#define ST_v171	((void*)startLabel+97)
extern Node TM_Data_46Ord[];
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_Prelude_46compare[];

static Node startLabel[] = {
  bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v172)
,};
Node FN_Data_46Ord_46comparing[] = {
  useLabel(TM_Data_46Ord)
, bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(2,3,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG_ARG,2,4,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,ZAP_ARG,4)
, bytes2word(ZAP_STACK_P1,4,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 340001
, useLabel(ST_v171)
,	/* CT_v172: (byte 0) */
  HW(2,4)
, 0
,};
Node F0_Data_46Ord_46comparing[] = {
  CAPTAG(useLabel(FN_Data_46Ord_46comparing),4)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46compare))
,};
Node PM_Data_46Ord[] = {
 	/* ST_v170: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,79,114,100)
,	/* ST_v171: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,79,114)
, bytes2word(100,46,99,111)
, bytes2word(109,112,97,114)
, bytes2word(105,110,103,0)
,};
