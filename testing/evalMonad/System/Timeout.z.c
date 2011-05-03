#include "newmacros.h"
#include "runtime.h"

#define CT_v171	((void*)startLabel+40)
#define FN_LAMBDA168	((void*)startLabel+68)
#define CT_v173	((void*)startLabel+100)
#define F0_LAMBDA168	((void*)startLabel+108)
#define ST_v169	((void*)startLabel+112)
#define ST_v170	((void*)startLabel+127)
#define ST_v172	((void*)startLabel+150)
extern Node TM_System_46Timeout[];
extern Node FN_Prelude_46Functor_46NHC_46Internal_46IO_46fmap[];
extern Node TMSUB_System_46Timeout[];

static Node startLabel[] = {
  bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v171)
,};
Node FN_System_46Timeout_46timeout[] = {
  useLabel(TM_System_46Timeout)
, bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,HEAP_CVAL_I3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,2,HEAP_ARG)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 200001
, useLabel(ST_v170)
,	/* CT_v171: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_System_46Timeout_46timeout[] = {
  CAPTAG(useLabel(FN_System_46Timeout_46timeout),2)
, CAPTAG(useLabel(FN_LAMBDA168),1)
, VAPTAG(useLabel(FN_Prelude_46Functor_46NHC_46Internal_46IO_46fmap))
, bytes2word(1,0,0,1)
, useLabel(CT_v173)
,	/* FN_LAMBDA168: (byte 0) */
  useLabel(TMSUB_System_46Timeout)
, bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_IN3,HEAP_ARG)
, bytes2word(1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,1,0)
, 200020
, useLabel(ST_v172)
,	/* CT_v173: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA168: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA168),1)
,};
Node PM_System_46Timeout[] = {
 	/* ST_v169: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,84)
, bytes2word(105,109,101,111)
,	/* ST_v170: (byte 3) */
  bytes2word(117,116,0,83)
, bytes2word(121,115,116,101)
, bytes2word(109,46,84,105)
, bytes2word(109,101,111,117)
, bytes2word(116,46,116,105)
, bytes2word(109,101,111,117)
,	/* ST_v172: (byte 2) */
  bytes2word(116,0,83,121)
, bytes2word(115,116,101,109)
, bytes2word(46,84,105,109)
, bytes2word(101,111,117,116)
, bytes2word(46,116,105,109)
, bytes2word(101,111,117,116)
, bytes2word(58,50,48,58)
, bytes2word(50,48,45,50)
, bytes2word(48,58,50,51)
, bytes2word(0,0,0,0)
,};
