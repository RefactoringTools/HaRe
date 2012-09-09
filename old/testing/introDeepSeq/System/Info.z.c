#include "newmacros.h"
#include "runtime.h"

#define FN_System_46Info_46compilerVersionRaw	((void*)startLabel+8)
#define CT_v203	((void*)startLabel+32)
#define CF_System_46Info_46compilerVersionRaw	((void*)startLabel+40)
#define CT_v205	((void*)startLabel+76)
#define FN_LAMBDA196	((void*)startLabel+100)
#define CT_v208	((void*)startLabel+132)
#define CF_LAMBDA196	((void*)startLabel+140)
#define CT_v210	((void*)startLabel+176)
#define FN_LAMBDA197	((void*)startLabel+200)
#define CT_v213	((void*)startLabel+232)
#define CF_LAMBDA197	((void*)startLabel+240)
#define CT_v215	((void*)startLabel+276)
#define FN_LAMBDA198	((void*)startLabel+300)
#define CT_v218	((void*)startLabel+332)
#define CF_LAMBDA198	((void*)startLabel+340)
#define CT_v220	((void*)startLabel+424)
#define FN_LAMBDA200	((void*)startLabel+460)
#define CT_v222	((void*)startLabel+484)
#define F0_LAMBDA200	((void*)startLabel+492)
#define FN_LAMBDA199	((void*)startLabel+504)
#define CT_v224	((void*)startLabel+528)
#define F0_LAMBDA199	((void*)startLabel+536)
#define ST_v217	((void*)startLabel+540)
#define ST_v201	((void*)startLabel+548)
#define ST_v209	((void*)startLabel+560)
#define ST_v211	((void*)startLabel+577)
#define ST_v204	((void*)startLabel+603)
#define ST_v206	((void*)startLabel+628)
#define ST_v219	((void*)startLabel+665)
#define ST_v223	((void*)startLabel+693)
#define ST_v221	((void*)startLabel+733)
#define ST_v202	((void*)startLabel+773)
#define ST_v214	((void*)startLabel+804)
#define ST_v216	((void*)startLabel+819)
#define ST_v207	((void*)startLabel+843)
#define ST_v212	((void*)startLabel+849)
extern Node TM_System_46Info[];
extern Node TMSUB_System_46Info[];
extern Node FN_Prelude_46Integral_46Prelude_46Int_46divMod[];

static Node startLabel[] = {
  bytes2word(0,0,0,0)
, useLabel(CT_v203)
,	/* FN_System_46Info_46compilerVersionRaw: (byte 0) */
  useLabel(TM_System_46Info)
, bytes2word(NEEDSTACK_I16,PUSH_INT_P1,119,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 480001
, useLabel(ST_v202)
,	/* CT_v203: (byte 0) */
  HW(0,0)
, 0
,	/* CF_System_46Info_46compilerVersionRaw: (byte 0) */
  VAPTAG(useLabel(FN_System_46Info_46compilerVersionRaw))
, bytes2word(0,0,0,0)
, useLabel(CT_v205)
,};
Node FN_System_46Info_46compilerName[] = {
  useLabel(TM_System_46Info)
, bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 470001
, useLabel(ST_v204)
,	/* CT_v205: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_System_46Info_46compilerName[] = {
  VAPTAG(useLabel(FN_System_46Info_46compilerName))
, VAPTAG(useLabel(FN_LAMBDA196))
, bytes2word(0,0,0,0)
, useLabel(CT_v208)
,	/* FN_LAMBDA196: (byte 0) */
  useLabel(TMSUB_System_46Info)
, bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,4,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v207)
, 470016
, useLabel(ST_v206)
,	/* CT_v208: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA196: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA196))
, bytes2word(0,0,0,0)
, useLabel(CT_v210)
,};
Node FN_System_46Info_46arch[] = {
  useLabel(TM_System_46Info)
, bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 20001
, useLabel(ST_v209)
,	/* CT_v210: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_System_46Info_46arch[] = {
  VAPTAG(useLabel(FN_System_46Info_46arch))
, VAPTAG(useLabel(FN_LAMBDA197))
, bytes2word(0,0,0,0)
, useLabel(CT_v213)
,	/* FN_LAMBDA197: (byte 0) */
  useLabel(TMSUB_System_46Info)
, bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,4,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v212)
, 20008
, useLabel(ST_v211)
,	/* CT_v213: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA197: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA197))
, bytes2word(0,0,0,0)
, useLabel(CT_v215)
,};
Node FN_System_46Info_46os[] = {
  useLabel(TM_System_46Info)
, bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 10001
, useLabel(ST_v214)
,	/* CT_v215: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_System_46Info_46os[] = {
  VAPTAG(useLabel(FN_System_46Info_46os))
, VAPTAG(useLabel(FN_LAMBDA198))
, bytes2word(0,0,0,0)
, useLabel(CT_v218)
,	/* FN_LAMBDA198: (byte 0) */
  useLabel(TMSUB_System_46Info)
, bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,4,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v217)
, 10008
, useLabel(ST_v216)
,	/* CT_v218: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA198: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA198))
, bytes2word(0,0,0,0)
, useLabel(CT_v220)
,};
Node FN_System_46Info_46compilerVersion[] = {
  useLabel(TM_System_46Info)
, bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_INT_P1,100,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,4,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(6,HEAP_OFF_N1,6,HEAP_CVAL_IN3)
, bytes2word(HEAP_CVAL_N1,4,HEAP_P1,0)
, bytes2word(HEAP_OFF_N1,3,HEAP_CVAL_N1,4)
, bytes2word(HEAP_I1,HEAP_OFF_N1,5,HEAP_CVAL_IN3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,5,HEAP_OFF_N1)
, bytes2word(5,HEAP_OFF_N1,3,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
, 300001
, useLabel(ST_v219)
,	/* CT_v220: (byte 0) */
  HW(4,0)
, 0
,};
Node CF_System_46Info_46compilerVersion[] = {
  VAPTAG(useLabel(FN_System_46Info_46compilerVersion))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Int_46divMod))
, useLabel(CF_System_46Info_46compilerVersionRaw)
, VAPTAG(useLabel(FN_LAMBDA199))
, VAPTAG(useLabel(FN_LAMBDA200))
, bytes2word(1,0,0,1)
, useLabel(CT_v222)
,	/* FN_LAMBDA200: (byte 0) */
  useLabel(TMSUB_System_46Info)
, bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 310014
, useLabel(ST_v221)
,	/* CT_v222: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA200: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA200),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v224)
,	/* FN_LAMBDA199: (byte 0) */
  useLabel(TMSUB_System_46Info)
, bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 310010
, useLabel(ST_v223)
,	/* CT_v224: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA199: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA199),1)
,	/* ST_v217: (byte 0) */
  bytes2word(68,97,114,119)
, bytes2word(105,110,56,0)
,};
Node PM_System_46Info[] = {
 	/* ST_v201: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
,	/* ST_v209: (byte 4) */
  bytes2word(110,102,111,0)
, bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(110,102,111,46)
, bytes2word(97,114,99,104)
,	/* ST_v211: (byte 1) */
  bytes2word(0,83,121,115)
, bytes2word(116,101,109,46)
, bytes2word(73,110,102,111)
, bytes2word(46,97,114,99)
, bytes2word(104,58,50,58)
, bytes2word(56,45,50,58)
,	/* ST_v204: (byte 3) */
  bytes2word(49,54,0,83)
, bytes2word(121,115,116,101)
, bytes2word(109,46,73,110)
, bytes2word(102,111,46,99)
, bytes2word(111,109,112,105)
, bytes2word(108,101,114,78)
,	/* ST_v206: (byte 4) */
  bytes2word(97,109,101,0)
, bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(110,102,111,46)
, bytes2word(99,111,109,112)
, bytes2word(105,108,101,114)
, bytes2word(78,97,109,101)
, bytes2word(58,52,55,58)
, bytes2word(49,54,45,52)
, bytes2word(55,58,50,50)
,	/* ST_v219: (byte 1) */
  bytes2word(0,83,121,115)
, bytes2word(116,101,109,46)
, bytes2word(73,110,102,111)
, bytes2word(46,99,111,109)
, bytes2word(112,105,108,101)
, bytes2word(114,86,101,114)
, bytes2word(115,105,111,110)
,	/* ST_v223: (byte 1) */
  bytes2word(0,83,121,115)
, bytes2word(116,101,109,46)
, bytes2word(73,110,102,111)
, bytes2word(46,99,111,109)
, bytes2word(112,105,108,101)
, bytes2word(114,86,101,114)
, bytes2word(115,105,111,110)
, bytes2word(58,51,49,58)
, bytes2word(49,48,45,51)
, bytes2word(49,58,49,50)
,	/* ST_v221: (byte 1) */
  bytes2word(0,83,121,115)
, bytes2word(116,101,109,46)
, bytes2word(73,110,102,111)
, bytes2word(46,99,111,109)
, bytes2word(112,105,108,101)
, bytes2word(114,86,101,114)
, bytes2word(115,105,111,110)
, bytes2word(58,51,49,58)
, bytes2word(49,52,45,51)
, bytes2word(49,58,49,54)
,	/* ST_v202: (byte 1) */
  bytes2word(0,83,121,115)
, bytes2word(116,101,109,46)
, bytes2word(73,110,102,111)
, bytes2word(46,99,111,109)
, bytes2word(112,105,108,101)
, bytes2word(114,86,101,114)
, bytes2word(115,105,111,110)
,	/* ST_v214: (byte 4) */
  bytes2word(82,97,119,0)
, bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(110,102,111,46)
,	/* ST_v216: (byte 3) */
  bytes2word(111,115,0,83)
, bytes2word(121,115,116,101)
, bytes2word(109,46,73,110)
, bytes2word(102,111,46,111)
, bytes2word(115,58,49,58)
, bytes2word(56,45,49,58)
,	/* ST_v207: (byte 3) */
  bytes2word(49,54,0,110)
, bytes2word(104,99,57,56)
,	/* ST_v212: (byte 1) */
  bytes2word(0,112,111,119)
, bytes2word(101,114,112,99)
, bytes2word(0,0,0,0)
,};
