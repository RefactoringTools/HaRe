module SwapTuple.St1Ref where
   import SwapTuple.St1
   
   type Foo_new = (Int, String)

   toNew :: Foo -> Foo_new
   toNew (s,i) = (i,s)

   toOld :: Foo_new -> Foo
   toOld (i,s) = (s,i)
