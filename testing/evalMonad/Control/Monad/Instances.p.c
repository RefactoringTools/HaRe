#include "newmacros.h"
#include "runtime.h"

#define v330	((void*)startLabel+22)
#define v331	((void*)startLabel+34)
#define CT_v338	((void*)startLabel+176)
#define CT_v346	((void*)startLabel+328)
#define CT_v350	((void*)startLabel+424)
#define FN_LAMBDA326	((void*)startLabel+468)
#define CT_v354	((void*)startLabel+532)
#define F0_LAMBDA326	((void*)startLabel+540)
#define CT_v358	((void*)startLabel+624)
#define CT_v362	((void*)startLabel+716)
#define CT_v366	((void*)startLabel+816)
#define CT_v370	((void*)startLabel+916)
#define CT_v374	((void*)startLabel+1024)
#define CT_v378	((void*)startLabel+1136)
#define CT_v382	((void*)startLabel+1256)
#define CT_v386	((void*)startLabel+1364)
#define ST_v328	((void*)startLabel+1396)
#define ST_v372	((void*)startLabel+1420)
#define ST_v368	((void*)startLabel+1448)
#define ST_v380	((void*)startLabel+1480)
#define ST_v342	((void*)startLabel+1508)
#define ST_v384	((void*)startLabel+1540)
#define ST_v333	((void*)startLabel+1572)
#define ST_v376	((void*)startLabel+1608)
#define ST_v364	((void*)startLabel+1636)
#define ST_v348	((void*)startLabel+1664)
#define PP_LAMBDA326	((void*)startLabel+1693)
#define PC_LAMBDA326	((void*)startLabel+1693)
#define ST_v352	((void*)startLabel+1693)
#define ST_v360	((void*)startLabel+1736)
#define ST_v356	((void*)startLabel+1768)
#define PS_v369	((void*)startLabel+1800)
#define PS_v367	((void*)startLabel+1812)
#define PS_v357	((void*)startLabel+1824)
#define PS_v355	((void*)startLabel+1836)
#define PS_v347	((void*)startLabel+1848)
#define PS_v349	((void*)startLabel+1860)
#define PS_v344	((void*)startLabel+1872)
#define PS_v345	((void*)startLabel+1884)
#define PS_v341	((void*)startLabel+1896)
#define PS_v336	((void*)startLabel+1908)
#define PS_v335	((void*)startLabel+1920)
#define PS_v337	((void*)startLabel+1932)
#define PS_v332	((void*)startLabel+1944)
#define PS_v365	((void*)startLabel+1956)
#define PS_v363	((void*)startLabel+1968)
#define PS_v361	((void*)startLabel+1980)
#define PS_v359	((void*)startLabel+1992)
#define PS_v375	((void*)startLabel+2004)
#define PS_v377	((void*)startLabel+2016)
#define PS_v371	((void*)startLabel+2028)
#define PS_v373	((void*)startLabel+2040)
#define PS_v381	((void*)startLabel+2052)
#define PS_v379	((void*)startLabel+2064)
#define PS_v385	((void*)startLabel+2076)
#define PS_v383	((void*)startLabel+2088)
#define PS_v353	((void*)startLabel+2100)
#define PS_v351	((void*)startLabel+2112)
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_Prelude_46const[];
extern Node FN_Prelude_46_95_46fail[];
extern Node CF_Prelude_46Monad_46Prelude_46_45_62[];
extern Node FN_Prelude_46_95_46_62_62[];
extern Node FN_Prelude_46_46[];
extern Node PC_Prelude_46_46[];
extern Node PC_Prelude_46const[];
extern Node PC_NHC_46Internal_46_95apply1[];
extern Node PC_Prelude_462[];
extern Node PC_Prelude_46Left[];
extern Node PC_Prelude_46Right[];
extern Node PC_Prelude_46_95_46_62_62[];
extern Node PC_Prelude_46_95_46fail[];
extern Node PC_Prelude_464[];
extern Node PC_Prelude_461[];

static Node startLabel[] = {
  bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v338)
,};
Node FN_Prelude_46Functor_46Prelude_46Either_46fmap[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v330: (byte 2) */
  bytes2word(TOP(16),BOT(16),UNPACK,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,7,HEAP_CVAL_N1)
, bytes2word(12,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
,	/* v331: (byte 2) */
  bytes2word(HEAP_I1,RETURN,UNPACK,1)
, bytes2word(HEAP_CVAL_P1,7,HEAP_CVAL_N1,17)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_ARG)
, bytes2word(1,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,22,HEAP_CVAL_N1,27)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(12,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v337)
, 0
, 0
, 0
, 0
, CONSTR(1,1,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v336)
, 0
, 0
, 0
, 0
, useLabel(PS_v335)
, 0
, 0
, 0
, 0
, CONSTR(0,1,0)
, 0
, 0
, 0
, 0
, 300009
, useLabel(ST_v333)
,	/* CT_v338: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Functor_46Prelude_46Either_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46Either_46fmap),2)
, useLabel(PS_v332)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v346)
,};
Node FN_Prelude_46Functor_46Prelude_462_46fmap[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(UNPACK,2,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,12,HEAP_CVAL_N1)
, bytes2word(17,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_I1,HEAP_OFF_N1,13,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v345)
, 0
, 0
, 0
, 0
, CONSTR(0,2,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v344)
, 0
, 0
, 0
, 0
, 270009
, useLabel(ST_v342)
,	/* CT_v346: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Functor_46Prelude_462_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_462_46fmap),2)
, useLabel(PS_v341)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v350)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG,1,2)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v349)
, 0
, 0
, 0
, 0
, 240009
, useLabel(ST_v348)
,	/* CT_v350: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61),2)
, useLabel(PS_v347)
, 0
, 0
, 0
, CAPTAG(useLabel(FN_LAMBDA326),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v354)
,	/* FN_LAMBDA326: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG,1,3)
, bytes2word(PUSH_ARG_I3,PUSH_I1,PUSH_ARG_I2,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v353)
, 0
, 0
, 0
, 0
, 240019
, useLabel(ST_v352)
,	/* CT_v354: (byte 0) */
  HW(1,3)
, 0
,	/* F0_LAMBDA326: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA326),3)
, useLabel(PS_v351)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(1,0,0,1)
, useLabel(CT_v358)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46return[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v357)
, 0
, 0
, 0
, 0
, 230009
, useLabel(ST_v356)
,	/* CT_v358: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46return[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46return),1)
, useLabel(PS_v355)
, 0
, 0
, 0
, CAPTAG(useLabel(FN_Prelude_46const),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v362)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46fail[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v361)
, 0
, 0
, 0
, 0
, 220010
, useLabel(ST_v360)
,	/* CT_v362: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46fail[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46fail),1)
, useLabel(PS_v359)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46fail))
, useLabel(CF_Prelude_46Monad_46Prelude_46_45_62)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v366)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v365)
, 0
, 0
, 0
, 0
, 220010
, useLabel(ST_v364)
,	/* CT_v366: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62_46_62_62),2)
, useLabel(PS_v363)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46_62_62))
, useLabel(CF_Prelude_46Monad_46Prelude_46_45_62)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v370)
,};
Node FN_Prelude_46Functor_46Prelude_46_45_62_46fmap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG_RET_EVAL,1,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v369)
, 0
, 0
, 0
, 0
, 200009
, useLabel(ST_v368)
,	/* CT_v370: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Functor_46Prelude_46_45_62_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_45_62_46fmap),2)
, useLabel(PS_v367)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_46))
, bytes2word(0,0,0,0)
, useLabel(CT_v374)
,};
Node FN_Prelude_46Functor_46Prelude_46_45_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v373)
, 0
, 0
, 0
, 0
, CONSTR(0,1,0)
, 0
, 0
, 0
, 0
, 190010
, useLabel(ST_v372)
,	/* CT_v374: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Prelude_46_45_62[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_45_62))
, useLabel(PS_v371)
, 0
, 0
, 0
, useLabel(F0_Prelude_46Functor_46Prelude_46_45_62_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v378)
,};
Node FN_Prelude_46Monad_46Prelude_46_45_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_P1,9,HEAP_CVAL_P1)
, bytes2word(10,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v377)
, 0
, 0
, 0
, 0
, CONSTR(0,4,0)
, 0
, 0
, 0
, 0
, 220010
, useLabel(ST_v376)
,	/* CT_v378: (byte 0) */
  HW(4,0)
, 0
,};
Node CF_Prelude_46Monad_46Prelude_46_45_62[] = {
  VAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_45_62))
, useLabel(PS_v375)
, 0
, 0
, 0
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61)
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46_62_62)
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46fail)
, useLabel(F0_Prelude_46Monad_46Prelude_46_45_62_46return)
, bytes2word(0,0,0,0)
, useLabel(CT_v382)
,};
Node FN_Prelude_46Functor_46Prelude_462[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v381)
, 0
, 0
, 0
, 0
, CONSTR(0,1,0)
, 0
, 0
, 0
, 0
, 260010
, useLabel(ST_v380)
,	/* CT_v382: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Prelude_462[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_462))
, useLabel(PS_v379)
, 0
, 0
, 0
, useLabel(F0_Prelude_46Functor_46Prelude_462_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v386)
,};
Node FN_Prelude_46Functor_46Prelude_46Either[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v385)
, 0
, 0
, 0
, 0
, CONSTR(0,1,0)
, 0
, 0
, 0
, 0
, 290010
, useLabel(ST_v384)
,	/* CT_v386: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Prelude_46Either[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46Either))
, useLabel(PS_v383)
, 0
, 0
, 0
, useLabel(F0_Prelude_46Functor_46Prelude_46Either_46fmap)
,};
Node PM_Control_46Monad_46Instances[] = {
 	/* ST_v328: (byte 0) */
  bytes2word(67,111,110,116)
, bytes2word(114,111,108,46)
, bytes2word(77,111,110,97)
, bytes2word(100,46,73,110)
, bytes2word(115,116,97,110)
, bytes2word(99,101,115,0)
,};
Node PP_Prelude_46Functor_46Prelude_46_45_62[] = {
 };
Node PC_Prelude_46Functor_46Prelude_46_45_62[] = {
 	/* ST_v372: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,117,110,99)
, bytes2word(116,111,114,46)
, bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(45,62,0,0)
,};
Node PP_Prelude_46Functor_46Prelude_46_45_62_46fmap[] = {
 };
Node PC_Prelude_46Functor_46Prelude_46_45_62_46fmap[] = {
 	/* ST_v368: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,117,110,99)
, bytes2word(116,111,114,46)
, bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(45,62,46,102)
, bytes2word(109,97,112,0)
,};
Node PP_Prelude_46Functor_46Prelude_462[] = {
 };
Node PC_Prelude_46Functor_46Prelude_462[] = {
 	/* ST_v380: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,117,110,99)
, bytes2word(116,111,114,46)
, bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(50,0,0,0)
,};
Node PP_Prelude_46Functor_46Prelude_462_46fmap[] = {
 };
Node PC_Prelude_46Functor_46Prelude_462_46fmap[] = {
 	/* ST_v342: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,117,110,99)
, bytes2word(116,111,114,46)
, bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(50,46,102,109)
, bytes2word(97,112,0,0)
,};
Node PP_Prelude_46Functor_46Prelude_46Either[] = {
 };
Node PC_Prelude_46Functor_46Prelude_46Either[] = {
 	/* ST_v384: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,117,110,99)
, bytes2word(116,111,114,46)
, bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,105,116,104)
, bytes2word(101,114,0,0)
,};
Node PP_Prelude_46Functor_46Prelude_46Either_46fmap[] = {
 };
Node PC_Prelude_46Functor_46Prelude_46Either_46fmap[] = {
 	/* ST_v333: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,117,110,99)
, bytes2word(116,111,114,46)
, bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,105,116,104)
, bytes2word(101,114,46,102)
, bytes2word(109,97,112,0)
,};
Node PP_Prelude_46Monad_46Prelude_46_45_62[] = {
 };
Node PC_Prelude_46Monad_46Prelude_46_45_62[] = {
 	/* ST_v376: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(77,111,110,97)
, bytes2word(100,46,80,114)
, bytes2word(101,108,117,100)
, bytes2word(101,46,45,62)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Monad_46Prelude_46_45_62_46_62_62[] = {
 };
Node PC_Prelude_46Monad_46Prelude_46_45_62_46_62_62[] = {
 	/* ST_v364: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(77,111,110,97)
, bytes2word(100,46,80,114)
, bytes2word(101,108,117,100)
, bytes2word(101,46,45,62)
, bytes2word(46,62,62,0)
,};
Node PP_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61[] = {
 };
Node PC_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61[] = {
 	/* ST_v348: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(77,111,110,97)
, bytes2word(100,46,80,114)
, bytes2word(101,108,117,100)
, bytes2word(101,46,45,62)
, bytes2word(46,62,62,61)
,	/* PP_LAMBDA326: (byte 1) */
 	/* PC_LAMBDA326: (byte 1) */
 	/* ST_v352: (byte 1) */
  bytes2word(0,80,114,101)
, bytes2word(108,117,100,101)
, bytes2word(46,77,111,110)
, bytes2word(97,100,46,80)
, bytes2word(114,101,108,117)
, bytes2word(100,101,46,45)
, bytes2word(62,46,62,62)
, bytes2word(61,58,50,52)
, bytes2word(58,49,57,45)
, bytes2word(50,52,58,51)
, bytes2word(52,0,0,0)
,};
Node PP_Prelude_46Monad_46Prelude_46_45_62_46fail[] = {
 };
Node PC_Prelude_46Monad_46Prelude_46_45_62_46fail[] = {
 	/* ST_v360: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(77,111,110,97)
, bytes2word(100,46,80,114)
, bytes2word(101,108,117,100)
, bytes2word(101,46,45,62)
, bytes2word(46,102,97,105)
, bytes2word(108,0,0,0)
,};
Node PP_Prelude_46Monad_46Prelude_46_45_62_46return[] = {
 };
Node PC_Prelude_46Monad_46Prelude_46_45_62_46return[] = {
 	/* ST_v356: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(77,111,110,97)
, bytes2word(100,46,80,114)
, bytes2word(101,108,117,100)
, bytes2word(101,46,45,62)
, bytes2word(46,114,101,116)
, bytes2word(117,114,110,0)
,	/* PS_v369: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46_45_62_46fmap)
, useLabel(PC_Prelude_46_46)
,	/* PS_v367: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46_45_62_46fmap)
, useLabel(PC_Prelude_46Functor_46Prelude_46_45_62_46fmap)
,	/* PS_v357: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46return)
, useLabel(PC_Prelude_46const)
,	/* PS_v355: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46return)
, useLabel(PC_Prelude_46Monad_46Prelude_46_45_62_46return)
,	/* PS_v347: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61)
, useLabel(PC_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61)
,	/* PS_v349: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46_62_62_61)
, useLabel(PC_LAMBDA326)
,	/* PS_v344: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_462_46fmap)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v345: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_462_46fmap)
, useLabel(PC_Prelude_462)
,	/* PS_v341: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_462_46fmap)
, useLabel(PC_Prelude_46Functor_46Prelude_462_46fmap)
,	/* PS_v336: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46Either_46fmap)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v335: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46Either_46fmap)
, useLabel(PC_Prelude_46Left)
,	/* PS_v337: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46Either_46fmap)
, useLabel(PC_Prelude_46Right)
,	/* PS_v332: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46Either_46fmap)
, useLabel(PC_Prelude_46Functor_46Prelude_46Either_46fmap)
,	/* PS_v365: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46_62_62)
, useLabel(PC_Prelude_46_95_46_62_62)
,	/* PS_v363: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46_62_62)
, useLabel(PC_Prelude_46Monad_46Prelude_46_45_62_46_62_62)
,	/* PS_v361: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46fail)
, useLabel(PC_Prelude_46_95_46fail)
,	/* PS_v359: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62_46fail)
, useLabel(PC_Prelude_46Monad_46Prelude_46_45_62_46fail)
,	/* PS_v375: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62)
, useLabel(PC_Prelude_46Monad_46Prelude_46_45_62)
,	/* PS_v377: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Monad_46Prelude_46_45_62)
, useLabel(PC_Prelude_464)
,	/* PS_v371: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46_45_62)
, useLabel(PC_Prelude_46Functor_46Prelude_46_45_62)
,	/* PS_v373: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46_45_62)
, useLabel(PC_Prelude_461)
,	/* PS_v381: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_462)
, useLabel(PC_Prelude_461)
,	/* PS_v379: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_462)
, useLabel(PC_Prelude_46Functor_46Prelude_462)
,	/* PS_v385: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46Either)
, useLabel(PC_Prelude_461)
,	/* PS_v383: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_Prelude_46Functor_46Prelude_46Either)
, useLabel(PC_Prelude_46Functor_46Prelude_46Either)
,	/* PS_v353: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_LAMBDA326)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v351: (byte 0) */
  useLabel(PM_Control_46Monad_46Instances)
, useLabel(PP_LAMBDA326)
, useLabel(PC_LAMBDA326)
,};
