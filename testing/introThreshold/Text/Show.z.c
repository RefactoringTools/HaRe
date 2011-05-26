#include "newmacros.h"
#include "runtime.h"

#define FN_Text_46Show_46showList_95_95	((void*)startLabel+12)
#define v202	((void*)startLabel+26)
#define v203	((void*)startLabel+35)
#define CT_v206	((void*)startLabel+84)
#define F0_Text_46Show_46showList_95_95	((void*)startLabel+92)
#define FN_Text_46Show_46Prelude_46159_46showl	((void*)startLabel+128)
#define v208	((void*)startLabel+142)
#define v209	((void*)startLabel+150)
#define CT_v212	((void*)startLabel+196)
#define F0_Text_46Show_46Prelude_46159_46showl	((void*)startLabel+204)
#define FN_LAMBDA199	((void*)startLabel+228)
#define CT_v215	((void*)startLabel+260)
#define CF_LAMBDA199	((void*)startLabel+268)
#define CT_v217	((void*)startLabel+304)
#define ST_v200	((void*)startLabel+320)
#define ST_v216	((void*)startLabel+330)
#define ST_v204	((void*)startLabel+353)
#define ST_v213	((void*)startLabel+374)
#define ST_v210	((void*)startLabel+407)
#define ST_v214	((void*)startLabel+439)
extern Node TM_Text_46Show[];
extern Node FN_Prelude_46_43_43[];
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_NHC_46Internal_46_95apply2[];
extern Node TMSUB_Text_46Show[];

static Node startLabel[] = {
  bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v206)
,	/* FN_Text_46Show_46showList_95_95: (byte 0) */
  useLabel(TM_Text_46Show)
, bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v202: (byte 2) */
  bytes2word(TOP(13),BOT(13),POP_I1,HEAP_CVAL_I3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,2)
,	/* v203: (byte 3) */
  bytes2word(HEAP_ARG,3,RETURN_EVAL,UNPACK)
, bytes2word(2,HEAP_CVAL_I5,HEAP_ARG_ARG,3)
, bytes2word(1,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(4,HEAP_I1,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_P1,0)
, bytes2word(HEAP_OFF_N1,6,PUSH_HEAP,HEAP_CVAL_IN3)
, bytes2word(HEAP_CHAR_P1,91,HEAP_OFF_N1,6)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
, 420001
, useLabel(ST_v204)
,	/* CT_v206: (byte 0) */
  HW(5,3)
, 0
,	/* F0_Text_46Show_46showList_95_95: (byte 0) */
  CAPTAG(useLabel(FN_Text_46Show_46showList_95_95),3)
, VAPTAG(useLabel(FN_LAMBDA199))
, VAPTAG(useLabel(FN_Prelude_46_43_43))
, CAPTAG(useLabel(FN_Text_46Show_46Prelude_46159_46showl),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v212)
,	/* FN_Text_46Show_46Prelude_46159_46showl: (byte 0) */
  useLabel(TMSUB_Text_46Show)
, bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v208: (byte 2) */
  bytes2word(TOP(12),BOT(12),POP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_IN3,HEAP_CHAR_P1,93,HEAP_ARG)
,	/* v209: (byte 2) */
  bytes2word(1,RETURN,UNPACK,2)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,4,HEAP_I1)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,2,HEAP_P1)
, bytes2word(0,HEAP_OFF_N1,6,PUSH_HEAP)
, bytes2word(HEAP_CVAL_IN3,HEAP_CHAR_P1,44,HEAP_OFF_N1)
, bytes2word(6,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
, 450005
, useLabel(ST_v210)
,	/* CT_v212: (byte 0) */
  HW(3,3)
, 0
,	/* F0_Text_46Show_46Prelude_46159_46showl: (byte 0) */
  CAPTAG(useLabel(FN_Text_46Show_46Prelude_46159_46showl),3)
, CAPTAG(useLabel(FN_Text_46Show_46Prelude_46159_46showl),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(0,0,0,0)
, useLabel(CT_v215)
,	/* FN_LAMBDA199: (byte 0) */
  useLabel(TMSUB_Text_46Show)
, bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,4,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v214)
, 420029
, useLabel(ST_v213)
,	/* CT_v215: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA199: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA199))
, bytes2word(0,0,0,0)
, useLabel(CT_v217)
,};
Node FN_Text_46Show_46showListWith[] = {
  useLabel(TM_Text_46Show)
, bytes2word(NEEDSTACK_I16,PUSH_CVAL_P1,3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 380001
, useLabel(ST_v216)
,	/* CT_v217: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Text_46Show_46showListWith[] = {
  VAPTAG(useLabel(FN_Text_46Show_46showListWith))
, useLabel(F0_Text_46Show_46showList_95_95)
,};
Node PM_Text_46Show[] = {
 	/* ST_v200: (byte 0) */
  bytes2word(84,101,120,116)
, bytes2word(46,83,104,111)
,	/* ST_v216: (byte 2) */
  bytes2word(119,0,84,101)
, bytes2word(120,116,46,83)
, bytes2word(104,111,119,46)
, bytes2word(115,104,111,119)
, bytes2word(76,105,115,116)
, bytes2word(87,105,116,104)
,	/* ST_v204: (byte 1) */
  bytes2word(0,84,101,120)
, bytes2word(116,46,83,104)
, bytes2word(111,119,46,115)
, bytes2word(104,111,119,76)
, bytes2word(105,115,116,95)
,	/* ST_v213: (byte 2) */
  bytes2word(95,0,84,101)
, bytes2word(120,116,46,83)
, bytes2word(104,111,119,46)
, bytes2word(115,104,111,119)
, bytes2word(76,105,115,116)
, bytes2word(95,95,58,52)
, bytes2word(50,58,50,57)
, bytes2word(45,52,50,58)
,	/* ST_v210: (byte 3) */
  bytes2word(51,50,0,84)
, bytes2word(101,120,116,46)
, bytes2word(83,104,111,119)
, bytes2word(46,115,104,111)
, bytes2word(119,76,105,115)
, bytes2word(116,95,95,58)
, bytes2word(52,53,58,53)
, bytes2word(45,52,54,58)
,	/* ST_v214: (byte 3) */
  bytes2word(52,51,0,91)
, bytes2word(93,0,0,0)
,};
