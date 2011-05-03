#include "newmacros.h"
#include "runtime.h"

#define CT_v229	((void*)startLabel+40)
#define FN_LAMBDA227	((void*)startLabel+84)
#define CT_v230	((void*)startLabel+120)
#define F0_LAMBDA227	((void*)startLabel+128)
#define FN_LAMBDA226	((void*)startLabel+164)
#define CT_v231	((void*)startLabel+176)
#define F0_LAMBDA226	((void*)startLabel+184)
#define FN_LAMBDA225	((void*)startLabel+196)
#define CT_v232	((void*)startLabel+208)
#define F0_LAMBDA225	((void*)startLabel+216)
#define CT_v233	((void*)startLabel+260)
extern Node FN_NHC_46IOExtras_46readIORef[];
extern Node FN_Prelude_46Monad_46NHC_46Internal_46IO_46_62_62_61[];
extern Node FN_Prelude_46_36[];
extern Node F0_NHC_46IOExtras_46excludeFinalisers[];
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_NHC_46IOExtras_46writeIORef[];
extern Node FN_Prelude_46Monad_46NHC_46Internal_46IO_46return[];
extern Node FN_Prelude_46Monad_46NHC_46Internal_46IO_46_62_62[];
extern Node FN_Prelude_46_46[];
extern Node FN_Prelude_46_61_60_60[];
extern Node CF_Prelude_46Monad_46NHC_46Internal_46IO[];

static Node startLabel[] = {
  bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v229)
,};
Node FN_Data_46IORef_46atomicModifyIORef[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,2,1)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,6,HEAP_OFF_N1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,5)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v229: (byte 0) */
  HW(5,2)
, 0
,};
Node F0_Data_46IORef_46atomicModifyIORef[] = {
  CAPTAG(useLabel(FN_Data_46IORef_46atomicModifyIORef),2)
, VAPTAG(useLabel(FN_NHC_46IOExtras_46readIORef))
, CAPTAG(useLabel(FN_LAMBDA227),1)
, VAPTAG(useLabel(FN_Prelude_46Monad_46NHC_46Internal_46IO_46_62_62_61))
, VAPTAG(useLabel(FN_Prelude_46_36))
, useLabel(F0_NHC_46IOExtras_46excludeFinalisers)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v230)
,	/* FN_LAMBDA227: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,3,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,4,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,6,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,2,HEAP_I1,HEAP_CVAL_P1)
, bytes2word(7,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_OFF_N1,6)
, bytes2word(HEAP_OFF_N1,4,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v230: (byte 0) */
  HW(6,3)
, 0
,	/* F0_LAMBDA227: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA227),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_LAMBDA225))
, VAPTAG(useLabel(FN_LAMBDA226))
, VAPTAG(useLabel(FN_NHC_46IOExtras_46writeIORef))
, VAPTAG(useLabel(FN_Prelude_46Monad_46NHC_46Internal_46IO_46return))
, VAPTAG(useLabel(FN_Prelude_46Monad_46NHC_46Internal_46IO_46_62_62))
, bytes2word(1,0,0,1)
, useLabel(CT_v231)
,	/* FN_LAMBDA226: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v231: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA226: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA226),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v232)
,	/* FN_LAMBDA225: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v232: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA225: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA225),1)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v233)
,};
Node FN_Data_46IORef_46modifyIORef[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,6,HEAP_CVAL_P1)
, bytes2word(7,HEAP_OFF_N1,7,HEAP_OFF_N1)
, bytes2word(5,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v233: (byte 0) */
  HW(5,2)
, 0
,};
Node F0_Data_46IORef_46modifyIORef[] = {
  CAPTAG(useLabel(FN_Data_46IORef_46modifyIORef),2)
, CAPTAG(useLabel(FN_NHC_46IOExtras_46writeIORef),1)
, VAPTAG(useLabel(FN_Prelude_46_46))
, VAPTAG(useLabel(FN_NHC_46IOExtras_46readIORef))
, VAPTAG(useLabel(FN_Prelude_46_61_60_60))
, useLabel(CF_Prelude_46Monad_46NHC_46Internal_46IO)
,};
