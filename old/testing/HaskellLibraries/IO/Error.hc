#include "newmacros.h"
#include "runtime.h"

#define C0_System_46IO_46Error_46UserError	((void*)startLabel+4)
#define C0_System_46IO_46Error_46PermissionDenied	((void*)startLabel+8)
#define C0_System_46IO_46Error_46IllegalOperation	((void*)startLabel+12)
#define C0_System_46IO_46Error_46EOF	((void*)startLabel+16)
#define C0_System_46IO_46Error_46ResourceExhausted	((void*)startLabel+20)
#define C0_System_46IO_46Error_46ResourceBusy	((void*)startLabel+24)
#define C0_System_46IO_46Error_46NoSuchThing	((void*)startLabel+28)
#define C0_System_46IO_46Error_46AlreadyExists	((void*)startLabel+32)
#define v234	((void*)startLabel+66)
#define v233	((void*)startLabel+70)
#define v230	((void*)startLabel+75)
#define CT_v235	((void*)startLabel+92)
#define v240	((void*)startLabel+134)
#define v239	((void*)startLabel+138)
#define v236	((void*)startLabel+143)
#define CT_v241	((void*)startLabel+160)
#define v246	((void*)startLabel+202)
#define v245	((void*)startLabel+206)
#define v242	((void*)startLabel+211)
#define CT_v247	((void*)startLabel+228)
#define v252	((void*)startLabel+270)
#define v251	((void*)startLabel+274)
#define v248	((void*)startLabel+279)
#define CT_v253	((void*)startLabel+296)
#define v258	((void*)startLabel+338)
#define v257	((void*)startLabel+342)
#define v254	((void*)startLabel+347)
#define CT_v259	((void*)startLabel+364)
#define v264	((void*)startLabel+406)
#define v263	((void*)startLabel+410)
#define v260	((void*)startLabel+415)
#define CT_v265	((void*)startLabel+432)
#define v270	((void*)startLabel+474)
#define v269	((void*)startLabel+478)
#define v266	((void*)startLabel+483)
#define CT_v271	((void*)startLabel+500)
#define v276	((void*)startLabel+542)
#define v275	((void*)startLabel+546)
#define v272	((void*)startLabel+551)
#define CT_v277	((void*)startLabel+568)
#define CT_v278	((void*)startLabel+608)
#define CT_v279	((void*)startLabel+648)
#define CT_v280	((void*)startLabel+688)
#define CT_v281	((void*)startLabel+728)
#define CT_v282	((void*)startLabel+768)
#define CT_v283	((void*)startLabel+808)
#define CT_v284	((void*)startLabel+848)
#define CT_v285	((void*)startLabel+888)

static Node startLabel[] = {
  42
,	/* C0_System_46IO_46Error_46UserError: (byte 0) */
  CONSTR(7,0,0)
,	/* C0_System_46IO_46Error_46PermissionDenied: (byte 0) */
  CONSTR(6,0,0)
,	/* C0_System_46IO_46Error_46IllegalOperation: (byte 0) */
  CONSTR(5,0,0)
,	/* C0_System_46IO_46Error_46EOF: (byte 0) */
  CONSTR(4,0,0)
,	/* C0_System_46IO_46Error_46ResourceExhausted: (byte 0) */
  CONSTR(3,0,0)
,	/* C0_System_46IO_46Error_46ResourceBusy: (byte 0) */
  CONSTR(2,0,0)
,	/* C0_System_46IO_46Error_46NoSuchThing: (byte 0) */
  CONSTR(1,0,0)
,	/* C0_System_46IO_46Error_46AlreadyExists: (byte 0) */
  CONSTR(0,0,0)
, bytes2word(1,0,0,1)
, useLabel(CT_v235)
,};
Node FN_System_46IO_46Error_46isUserErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
,	/* v234: (byte 2) */
  bytes2word(TOP(20),BOT(20),POP_I1,JUMP)
,	/* v233: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v230: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v235: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isUserErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isUserErrorType),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v241)
,};
Node FN_System_46IO_46Error_46isPermissionErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(20),BOT(20))
,	/* v240: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,JUMP)
,	/* v239: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v236: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v241: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isPermissionErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isPermissionErrorType),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v247)
,};
Node FN_System_46IO_46Error_46isIllegalOperationErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(20),BOT(20),TOP(16),BOT(16))
,	/* v246: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,JUMP)
,	/* v245: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v242: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v247: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isIllegalOperationErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isIllegalOperationErrorType),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v253)
,};
Node FN_System_46IO_46Error_46isEOFErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(20),BOT(20))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
,	/* v252: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,JUMP)
,	/* v251: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v248: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v253: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isEOFErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isEOFErrorType),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v259)
,};
Node FN_System_46IO_46Error_46isFullErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(20),BOT(20),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
,	/* v258: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,JUMP)
,	/* v257: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v254: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v259: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isFullErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isFullErrorType),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v265)
,};
Node FN_System_46IO_46Error_46isAlreadyInUseErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(20),BOT(20))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
,	/* v264: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,JUMP)
,	/* v263: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v260: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v265: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isAlreadyInUseErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isAlreadyInUseErrorType),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v271)
,};
Node FN_System_46IO_46Error_46isDoesNotExistErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(16),BOT(16))
, bytes2word(TOP(20),BOT(20),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
,	/* v270: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,JUMP)
,	/* v269: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v266: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v271: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isDoesNotExistErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isDoesNotExistErrorType),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v277)
,};
Node FN_System_46IO_46Error_46isAlreadyExistsErrorType[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,8,TOP(20),BOT(20))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
, bytes2word(TOP(16),BOT(16),TOP(16),BOT(16))
,	/* v276: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,JUMP)
,	/* v275: (byte 2) */
  bytes2word(7,0,POP_I1,PUSH_HEAP)
,	/* v272: (byte 3) */
  bytes2word(HEAP_CVAL_N1,1,RETURN,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v277: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_System_46IO_46Error_46isAlreadyExistsErrorType[] = {
  CAPTAG(useLabel(FN_System_46IO_46Error_46isAlreadyExistsErrorType),1)
, bytes2word(0,0,0,0)
, useLabel(CT_v278)
,};
Node FN_System_46IO_46Error_46userErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(7,0,0)
,	/* CT_v278: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46userErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46userErrorType))
, bytes2word(0,0,0,0)
, useLabel(CT_v279)
,};
Node FN_System_46IO_46Error_46permissionErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(6,0,0)
,	/* CT_v279: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46permissionErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46permissionErrorType))
, bytes2word(0,0,0,0)
, useLabel(CT_v280)
,};
Node FN_System_46IO_46Error_46illegalOperationErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(5,0,0)
,	/* CT_v280: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46illegalOperationErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46illegalOperationErrorType))
, bytes2word(0,0,0,0)
, useLabel(CT_v281)
,};
Node FN_System_46IO_46Error_46eofErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(4,0,0)
,	/* CT_v281: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46eofErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46eofErrorType))
, bytes2word(0,0,0,0)
, useLabel(CT_v282)
,};
Node FN_System_46IO_46Error_46fullErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(3,0,0)
,	/* CT_v282: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46fullErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46fullErrorType))
, bytes2word(0,0,0,0)
, useLabel(CT_v283)
,};
Node FN_System_46IO_46Error_46alreadyInUseErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,0,0)
,	/* CT_v283: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46alreadyInUseErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46alreadyInUseErrorType))
, bytes2word(0,0,0,0)
, useLabel(CT_v284)
,};
Node FN_System_46IO_46Error_46doesNotExistErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,0,0)
,	/* CT_v284: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46doesNotExistErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46doesNotExistErrorType))
, bytes2word(0,0,0,0)
, useLabel(CT_v285)
,};
Node FN_System_46IO_46Error_46alreadyExistsErrorType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,0,0)
,	/* CT_v285: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_System_46IO_46Error_46alreadyExistsErrorType[] = {
  VAPTAG(useLabel(FN_System_46IO_46Error_46alreadyExistsErrorType))
,};
