#include "newmacros.h"
#include "runtime.h"

#define CT_v288	((void*)startLabel+44)
#define CT_v290	((void*)startLabel+96)
#define CT_v292	((void*)startLabel+156)
#define CT_v294	((void*)startLabel+224)
#define ST_v286	((void*)startLabel+248)
#define ST_v287	((void*)startLabel+258)
#define ST_v289	((void*)startLabel+283)
#define ST_v291	((void*)startLabel+308)
#define ST_v293	((void*)startLabel+333)
extern Node TM_System_46IO[];
extern Node C0__40_41[];
extern Node FN_Prelude_46return[];
extern Node F0_IO_46openFile[];
extern Node FN_NHC_46Internal_46_95apply2[];
extern Node FN_IO_46bracket[];
extern Node F0_IO_46hClose[];
extern Node FN_IO_46openFile[];

static Node startLabel[] = {
  bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v288)
,};
Node FN_System_46IO_46hSetBinaryMode[] = {
  useLabel(TM_System_46IO)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,NEEDHEAP_I32,PUSH_CVAL_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 4000001
, useLabel(ST_v287)
,	/* CT_v288: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_System_46IO_46hSetBinaryMode[] = {
  CAPTAG(useLabel(FN_System_46IO_46hSetBinaryMode),3)
, useLabel(C0__40_41)
, VAPTAG(useLabel(FN_Prelude_46return))
, bytes2word(0,0,0,0)
, useLabel(CT_v290)
,};
Node FN_System_46IO_46openBinaryFile[] = {
  useLabel(TM_System_46IO)
, bytes2word(NEEDSTACK_I16,PUSH_CVAL_P1,3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 3990001
, useLabel(ST_v289)
,	/* CT_v290: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_System_46IO_46openBinaryFile[] = {
  VAPTAG(useLabel(FN_System_46IO_46openBinaryFile))
, useLabel(F0_IO_46openFile)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v292)
,};
Node FN_System_46IO_46withBinaryFile[] = {
  useLabel(TM_System_46IO)
, bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(2,HEAP_ARG_ARG,1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1,5)
, bytes2word(HEAP_CVAL_P1,6,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 3780001
, useLabel(ST_v291)
,	/* CT_v292: (byte 0) */
  HW(4,2)
, 0
,};
Node F0_System_46IO_46withBinaryFile[] = {
  CAPTAG(useLabel(FN_System_46IO_46withBinaryFile),2)
, VAPTAG(useLabel(FN_System_46IO_46openBinaryFile))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, CAPTAG(useLabel(FN_IO_46bracket),1)
, useLabel(F0_IO_46hClose)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v294)
,};
Node FN_System_46IO_46withFile[] = {
  useLabel(TM_System_46IO)
, bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG_ARG,1)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(4,HEAP_CVAL_I5,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 3710001
, useLabel(ST_v293)
,	/* CT_v294: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_System_46IO_46withFile[] = {
  CAPTAG(useLabel(FN_System_46IO_46withFile),2)
, VAPTAG(useLabel(FN_IO_46openFile))
, CAPTAG(useLabel(FN_IO_46bracket),1)
, useLabel(F0_IO_46hClose)
,};
Node PM_System_46IO[] = {
 	/* ST_v286: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
,	/* ST_v287: (byte 2) */
  bytes2word(79,0,83,121)
, bytes2word(115,116,101,109)
, bytes2word(46,73,79,46)
, bytes2word(104,83,101,116)
, bytes2word(66,105,110,97)
, bytes2word(114,121,77,111)
,	/* ST_v289: (byte 3) */
  bytes2word(100,101,0,83)
, bytes2word(121,115,116,101)
, bytes2word(109,46,73,79)
, bytes2word(46,111,112,101)
, bytes2word(110,66,105,110)
, bytes2word(97,114,121,70)
,	/* ST_v291: (byte 4) */
  bytes2word(105,108,101,0)
, bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(79,46,119,105)
, bytes2word(116,104,66,105)
, bytes2word(110,97,114,121)
, bytes2word(70,105,108,101)
,	/* ST_v293: (byte 1) */
  bytes2word(0,83,121,115)
, bytes2word(116,101,109,46)
, bytes2word(73,79,46,119)
, bytes2word(105,116,104,70)
, bytes2word(105,108,101,0)
,};
