#include "newmacros.h"
#include "runtime.h"

#define CT_v174	((void*)startLabel+88)
#define FN_LAMBDA168	((void*)startLabel+132)
#define CT_v178	((void*)startLabel+200)
#define F0_LAMBDA168	((void*)startLabel+208)
#define ST_v169	((void*)startLabel+228)
#define ST_v171	((void*)startLabel+244)
#define PP_LAMBDA168	((void*)startLabel+267)
#define PC_LAMBDA168	((void*)startLabel+267)
#define ST_v176	((void*)startLabel+267)
#define PS_v170	((void*)startLabel+304)
#define PS_v173	((void*)startLabel+316)
#define PS_v172	((void*)startLabel+328)
#define PS_v177	((void*)startLabel+340)
#define PS_v175	((void*)startLabel+352)
extern Node FN_Prelude_46Functor_46NHC_46Internal_46IO_46fmap[];
extern Node PC_Prelude_46Functor_46NHC_46Internal_46IO_46fmap[];
extern Node PC_Prelude_46Just[];

static Node startLabel[] = {
  bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v174)
,};
Node FN_System_46Timeout_46timeout[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,10,HEAP_ARG)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v173)
, 0
, 0
, 0
, 0
, useLabel(PS_v172)
, 0
, 0
, 0
, 0
, 200001
, useLabel(ST_v171)
,	/* CT_v174: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_System_46Timeout_46timeout[] = {
  CAPTAG(useLabel(FN_System_46Timeout_46timeout),2)
, useLabel(PS_v170)
, 0
, 0
, 0
, CAPTAG(useLabel(FN_LAMBDA168),1)
, VAPTAG(useLabel(FN_Prelude_46Functor_46NHC_46Internal_46IO_46fmap))
, bytes2word(1,0,0,1)
, useLabel(CT_v178)
,	/* FN_LAMBDA168: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v177)
, 0
, 0
, 0
, 0
, CONSTR(1,1,0)
, 0
, 0
, 0
, 0
, 200020
, useLabel(ST_v176)
,	/* CT_v178: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA168: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA168),1)
, useLabel(PS_v175)
, 0
, 0
, 0
,};
Node PM_System_46Timeout[] = {
 	/* ST_v169: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,84)
, bytes2word(105,109,101,111)
, bytes2word(117,116,0,0)
,};
Node PP_System_46Timeout_46timeout[] = {
 };
Node PC_System_46Timeout_46timeout[] = {
 	/* ST_v171: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,84)
, bytes2word(105,109,101,111)
, bytes2word(117,116,46,116)
, bytes2word(105,109,101,111)
,	/* PP_LAMBDA168: (byte 3) */
 	/* PC_LAMBDA168: (byte 3) */
 	/* ST_v176: (byte 3) */
  bytes2word(117,116,0,83)
, bytes2word(121,115,116,101)
, bytes2word(109,46,84,105)
, bytes2word(109,101,111,117)
, bytes2word(116,46,116,105)
, bytes2word(109,101,111,117)
, bytes2word(116,58,50,48)
, bytes2word(58,50,48,45)
, bytes2word(50,48,58,50)
, bytes2word(51,0,0,0)
,	/* PS_v170: (byte 0) */
  useLabel(PM_System_46Timeout)
, useLabel(PP_System_46Timeout_46timeout)
, useLabel(PC_System_46Timeout_46timeout)
,	/* PS_v173: (byte 0) */
  useLabel(PM_System_46Timeout)
, useLabel(PP_System_46Timeout_46timeout)
, useLabel(PC_Prelude_46Functor_46NHC_46Internal_46IO_46fmap)
,	/* PS_v172: (byte 0) */
  useLabel(PM_System_46Timeout)
, useLabel(PP_System_46Timeout_46timeout)
, useLabel(PC_LAMBDA168)
,	/* PS_v177: (byte 0) */
  useLabel(PM_System_46Timeout)
, useLabel(PP_LAMBDA168)
, useLabel(PC_Prelude_46Just)
,	/* PS_v175: (byte 0) */
  useLabel(PM_System_46Timeout)
, useLabel(PP_LAMBDA168)
, useLabel(PC_LAMBDA168)
,};
