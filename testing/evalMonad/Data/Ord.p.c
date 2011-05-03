#include "newmacros.h"
#include "runtime.h"

#define CT_v175	((void*)startLabel+120)
#define ST_v170	((void*)startLabel+156)
#define ST_v172	((void*)startLabel+168)
#define PS_v173	((void*)startLabel+188)
#define PS_v174	((void*)startLabel+200)
#define PS_v171	((void*)startLabel+212)
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_Prelude_46compare[];
extern Node PC_NHC_46Internal_46_95apply1[];
extern Node PC_Prelude_46compare[];

static Node startLabel[] = {
  bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v175)
,};
Node FN_Data_46Ord_46comparing[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG,2,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,2,4,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_ARG)
, bytes2word(1,ZAP_ARG_I1,ZAP_ARG_I2,ZAP_ARG_I3)
, bytes2word(ZAP_ARG,4,ZAP_STACK_P1,4)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v174)
, 0
, 0
, 0
, 0
, useLabel(PS_v173)
, 0
, 0
, 0
, 0
, 340001
, useLabel(ST_v172)
,	/* CT_v175: (byte 0) */
  HW(2,4)
, 0
,};
Node F0_Data_46Ord_46comparing[] = {
  CAPTAG(useLabel(FN_Data_46Ord_46comparing),4)
, useLabel(PS_v171)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46compare))
,};
Node PM_Data_46Ord[] = {
 	/* ST_v170: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,79,114,100)
, bytes2word(0,0,0,0)
,};
Node PP_Data_46Ord_46comparing[] = {
 };
Node PC_Data_46Ord_46comparing[] = {
 	/* ST_v172: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,79,114,100)
, bytes2word(46,99,111,109)
, bytes2word(112,97,114,105)
, bytes2word(110,103,0,0)
,	/* PS_v173: (byte 0) */
  useLabel(PM_Data_46Ord)
, useLabel(PP_Data_46Ord_46comparing)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v174: (byte 0) */
  useLabel(PM_Data_46Ord)
, useLabel(PP_Data_46Ord_46comparing)
, useLabel(PC_Prelude_46compare)
,	/* PS_v171: (byte 0) */
  useLabel(PM_Data_46Ord)
, useLabel(PP_Data_46Ord_46comparing)
, useLabel(PC_Data_46Ord_46comparing)
,};
