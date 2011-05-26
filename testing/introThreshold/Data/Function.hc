#include "newmacros.h"
#include "runtime.h"

#define CT_v182	((void*)startLabel+24)
#define FN_LAMBDA178	((void*)startLabel+56)
#define CT_v183	((void*)startLabel+92)
#define F0_LAMBDA178	((void*)startLabel+100)
#define CT_v184	((void*)startLabel+132)
extern Node FN_NHC_46Internal_46_95apply1[];

static Node startLabel[] = {
  bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v182)
,};
Node FN_Data_46Function_46on[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(2,1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v182: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Data_46Function_46on[] = {
  CAPTAG(useLabel(FN_Data_46Function_46on),2)
, CAPTAG(useLabel(FN_LAMBDA178),2)
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v183)
,	/* FN_LAMBDA178: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,3,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG_ARG,1,4,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_ARG_I2)
, bytes2word(ZAP_ARG_I1,ZAP_ARG_I2,ZAP_ARG_I3,ZAP_ARG)
, bytes2word(4,ZAP_STACK_P1,4,ZAP_STACK_P1)
, bytes2word(3,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v183: (byte 0) */
  HW(1,4)
, 0
,	/* F0_LAMBDA178: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA178),4)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(1,0,0,1)
, useLabel(CT_v184)
,};
Node FN_Data_46Function_46fix[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,2,PUSH_P1)
, bytes2word(0,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v184: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Data_46Function_46fix[] = {
  CAPTAG(useLabel(FN_Data_46Function_46fix),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
,};
