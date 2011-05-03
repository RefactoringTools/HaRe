#include "newmacros.h"
#include "runtime.h"

#define v330	((void*)startLabel+22)
#define v331	((void*)startLabel+29)
#define CT_v333	((void*)startLabel+56)
#define CT_v337	((void*)startLabel+116)
#define CT_v338	((void*)startLabel+156)
#define FN_LAMBDA326	((void*)startLabel+184)
#define CT_v339	((void*)startLabel+208)
#define F0_LAMBDA326	((void*)startLabel+216)
#define CT_v340	((void*)startLabel+244)
#define CT_v341	((void*)startLabel+280)
#define CT_v342	((void*)startLabel+324)
#define CT_v343	((void*)startLabel+368)
#define CT_v344	((void*)startLabel+412)
#define CT_v345	((void*)startLabel+460)
#define CT_v346	((void*)startLabel+516)
#define CT_v347	((void*)startLabel+560)
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_Prelude_46const[];
extern Node FN_Prelude_46_95_46fail[];
extern Node CF_Prelude_46Monad_46Prelude_46_45_62[];
extern Node FN_Prelude_46_95_46_62_62[];
extern Node FN_Prelude_46_46[];

static Node startLabel[] = {
  bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v333)
,};
Node FN_Prelude_46Functor_46Prelude_46Either_46fmap[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v330: (byte 2) */
  bytes2word(TOP(11),BOT(11),UNPACK,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_I1)
,	/* v331: (byte 1) */
  bytes2word(RETURN,UNPACK,1,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_OFF_N1)
, bytes2word(4,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(1,1,0)
, CONSTR(0,1,0)
,	/* CT_v333: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Functor_46Prelude_46Either_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46Either_46fmap),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v337)
,};
Node FN_Prelude_46Functor_46Prelude_462_46fmap[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_I1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_I1,HEAP_OFF_N1,5)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v337: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Functor_46Prelude_462_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_462_46fmap),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v338)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v338: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61),2)
, CAPTAG(useLabel(FN_LAMBDA326),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v339)
,	/* FN_LAMBDA326: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,3,PUSH_ARG_I3,PUSH_I1)
, bytes2word(PUSH_ARG_I2,ZAP_ARG_I1,ZAP_ARG_I2,ZAP_ARG_I3)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v339: (byte 0) */
  HW(1,3)
, 0
,	/* F0_LAMBDA326: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA326),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(1,0,0,1)
, useLabel(CT_v340)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46return[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v340: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46return[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46return),1)
, CAPTAG(useLabel(FN_Prelude_46const),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v341)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46fail[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v341: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46fail[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46fail),1)
, VAPTAG(useLabel(FN_Prelude_46_95_46fail))
, useLabel(CF_Prelude_46Monad_46Prelude_46_45_62)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v342)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v342: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62),2)
, VAPTAG(useLabel(FN_Prelude_46_95_46_62_62))
, useLabel(CF_Prelude_46Monad_46Prelude_46_45_62)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v343)
,};
Node FN_Prelude_46Functor_46Prelude_46_45_62_46fmap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v343: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Functor_46Prelude_46_45_62_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_45_62_46fmap),2)
, VAPTAG(useLabel(FN_Prelude_46_46))
, bytes2word(0,0,0,0)
, useLabel(CT_v344)
,};
Node FN_Prelude_46Functor_46Prelude_46_45_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v344: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Prelude_46_45_62[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_45_62))
, useLabel(F0_Prelude_46Functor_46Prelude_46_45_62_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v345)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,4,0)
,	/* CT_v345: (byte 0) */
  HW(4,0)
, 0
,};
Node CF_Prelude_46Monad_46Prelude_46_45_62[] = {
  VAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62))
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61)
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62)
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46fail)
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46return)
, bytes2word(0,0,0,0)
, useLabel(CT_v346)
,};
Node FN_Prelude_46Functor_46Prelude_462[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v346: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Prelude_462[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_462))
, useLabel(F0_Prelude_46Functor_46Prelude_462_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v347)
,};
Node FN_Prelude_46Functor_46Prelude_46Either[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v347: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Prelude_46Either[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46Either))
, useLabel(F0_Prelude_46Functor_46Prelude_46Either_46fmap)
,};
