#include "newmacros.h"
#include "runtime.h"

#define CT_v290	((void*)startLabel+72)
#define CT_v293	((void*)startLabel+136)
#define CT_v299	((void*)startLabel+292)
#define CT_v304	((void*)startLabel+428)
#define ST_v286	((void*)startLabel+468)
#define ST_v288	((void*)startLabel+480)
#define ST_v292	((void*)startLabel+508)
#define ST_v295	((void*)startLabel+536)
#define ST_v301	((void*)startLabel+564)
#define PS_v303	((void*)startLabel+584)
#define PS_v302	((void*)startLabel+596)
#define PS_v300	((void*)startLabel+608)
#define PS_v298	((void*)startLabel+620)
#define PS_v297	((void*)startLabel+632)
#define PS_v294	((void*)startLabel+644)
#define PS_v296	((void*)startLabel+656)
#define PS_v291	((void*)startLabel+668)
#define PS_v289	((void*)startLabel+680)
#define PS_v287	((void*)startLabel+692)
extern Node C0__40_41[];
extern Node FN_Prelude_46return[];
extern Node F0_IO_46openFile[];
extern Node FN_NHC_46Internal_46_95apply2[];
extern Node FN_IO_46bracket[];
extern Node F0_IO_46hClose[];
extern Node FN_IO_46openFile[];
extern Node PC_IO_46bracket[];
extern Node PC_IO_46openFile[];
extern Node PC_NHC_46Internal_46_95apply2[];
extern Node PC_Prelude_46return[];

static Node startLabel[] = {
  bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v290)
,};
Node FN_System_46IO_46hSetBinaryMode[] = {
  bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,NEEDHEAP_I32,PUSH_CVAL_P1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,ZAP_ARG_I1)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,1)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v289)
, 0
, 0
, 0
, 0
, 4000001
, useLabel(ST_v288)
,	/* CT_v290: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_System_46IO_46hSetBinaryMode[] = {
  CAPTAG(useLabel(FN_System_46IO_46hSetBinaryMode),3)
, useLabel(PS_v287)
, 0
, 0
, 0
, useLabel(C0__40_41)
, VAPTAG(useLabel(FN_Prelude_46return))
, bytes2word(0,0,0,0)
, useLabel(CT_v293)
,};
Node FN_System_46IO_46openBinaryFile[] = {
  bytes2word(NEEDSTACK_I16,PUSH_CVAL_P1,7,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 3990001
, useLabel(ST_v292)
,	/* CT_v293: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_System_46IO_46openBinaryFile[] = {
  VAPTAG(useLabel(FN_System_46IO_46openBinaryFile))
, useLabel(PS_v291)
, 0
, 0
, 0
, useLabel(F0_IO_46openFile)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v299)
,};
Node FN_System_46IO_46withBinaryFile[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(10,HEAP_ARG_ARG,1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_CVAL_N1)
, bytes2word(17,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,13,HEAP_CVAL_P1,10)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v298)
, 0
, 0
, 0
, 0
, useLabel(PS_v297)
, 0
, 0
, 0
, 0
, useLabel(PS_v296)
, 0
, 0
, 0
, 0
, 3780001
, useLabel(ST_v295)
,	/* CT_v299: (byte 0) */
  HW(4,2)
, 0
,};
Node F0_System_46IO_46withBinaryFile[] = {
  CAPTAG(useLabel(FN_System_46IO_46withBinaryFile),2)
, useLabel(PS_v294)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_System_46IO_46openBinaryFile))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, CAPTAG(useLabel(FN_IO_46bracket),1)
, useLabel(F0_IO_46hClose)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v304)
,};
Node FN_System_46IO_46withFile[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(12,HEAP_CVAL_P1,9,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v303)
, 0
, 0
, 0
, 0
, useLabel(PS_v302)
, 0
, 0
, 0
, 0
, 3710001
, useLabel(ST_v301)
,	/* CT_v304: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_System_46IO_46withFile[] = {
  CAPTAG(useLabel(FN_System_46IO_46withFile),2)
, useLabel(PS_v300)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_IO_46openFile))
, CAPTAG(useLabel(FN_IO_46bracket),1)
, useLabel(F0_IO_46hClose)
,};
Node PM_System_46IO[] = {
 	/* ST_v286: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(79,0,0,0)
,};
Node PP_System_46IO_46hSetBinaryMode[] = {
 };
Node PC_System_46IO_46hSetBinaryMode[] = {
 	/* ST_v288: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(79,46,104,83)
, bytes2word(101,116,66,105)
, bytes2word(110,97,114,121)
, bytes2word(77,111,100,101)
, bytes2word(0,0,0,0)
,};
Node PP_System_46IO_46openBinaryFile[] = {
 };
Node PC_System_46IO_46openBinaryFile[] = {
 	/* ST_v292: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(79,46,111,112)
, bytes2word(101,110,66,105)
, bytes2word(110,97,114,121)
, bytes2word(70,105,108,101)
, bytes2word(0,0,0,0)
,};
Node PP_System_46IO_46withBinaryFile[] = {
 };
Node PC_System_46IO_46withBinaryFile[] = {
 	/* ST_v295: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(79,46,119,105)
, bytes2word(116,104,66,105)
, bytes2word(110,97,114,121)
, bytes2word(70,105,108,101)
, bytes2word(0,0,0,0)
,};
Node PP_System_46IO_46withFile[] = {
 };
Node PC_System_46IO_46withFile[] = {
 	/* ST_v301: (byte 0) */
  bytes2word(83,121,115,116)
, bytes2word(101,109,46,73)
, bytes2word(79,46,119,105)
, bytes2word(116,104,70,105)
, bytes2word(108,101,0,0)
,	/* PS_v303: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46withFile)
, useLabel(PC_IO_46bracket)
,	/* PS_v302: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46withFile)
, useLabel(PC_IO_46openFile)
,	/* PS_v300: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46withFile)
, useLabel(PC_System_46IO_46withFile)
,	/* PS_v298: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46withBinaryFile)
, useLabel(PC_IO_46bracket)
,	/* PS_v297: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46withBinaryFile)
, useLabel(PC_NHC_46Internal_46_95apply2)
,	/* PS_v294: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46withBinaryFile)
, useLabel(PC_System_46IO_46withBinaryFile)
,	/* PS_v296: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46withBinaryFile)
, useLabel(PC_System_46IO_46openBinaryFile)
,	/* PS_v291: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46openBinaryFile)
, useLabel(PC_System_46IO_46openBinaryFile)
,	/* PS_v289: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46hSetBinaryMode)
, useLabel(PC_Prelude_46return)
,	/* PS_v287: (byte 0) */
  useLabel(PM_System_46IO)
, useLabel(PP_System_46IO_46hSetBinaryMode)
, useLabel(PC_System_46IO_46hSetBinaryMode)
,};
