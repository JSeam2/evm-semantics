```{.k .node}
module EVM-NODE
    imports EVM
    imports K-REFLECTION
    imports COLLECTIONS

    syntax AccountCode ::= "#unloaded"

    syntax Int ::= #getBalance(Int) [function, hook(MANTIS.getBalance)]
                 | #getNonce(Int) [function, hook(MANTIS.getNonce)]
    syntax Bool ::= #isCodeEmpty(Int) [function, hook(MANTIS.isCodeEmpty)]
                  | #accountExists(Int) [function, hook(MANTIS.accountExists)]
 // --------------------------------------------------------------------------
    rule <k> #loadAccount ACCT => . ... </k>
         <activeAccounts> ACCTS (.Set => SetItem(ACCT)) </activeAccounts>
         <accounts>
           ( .Bag
          => <account>
               <acctID> ACCT </acctID>
               <balance> #getBalance(ACCT) </balance>
               <code> #if #isCodeEmpty(ACCT) #then .WordStack #else #unloaded #fi </code>
               <storage> .Map </storage>
               <nonce> #getNonce(ACCT) </nonce>
             </account>
           )
           ...
         </accounts>
      requires notBool ACCT in ACCTS andBool #accountExists(ACCT)

    rule <k> #loadAccount ACCT => . ... </k>
         <activeAccounts> ACCTS </activeAccounts>
      requires ACCT in ACCTS orBool notBool #accountExists(ACCT)

    syntax Int ::= #getStorageData(Int, Int) [function, hook(MANTIS.getStorageData)]
 // --------------------------------------------------------------------------------
    rule <k> #lookupStorage(ACCT, INDEX) => . ... </k>
         <account>
           <acctID>  ACCT                                                         </acctID>
           <storage> STORAGE => STORAGE [ INDEX <- #getStorageData(ACCT, INDEX) ] </storage>
           ...
         </account>
      requires notBool INDEX in_keys(STORAGE)

    rule <k> #lookupStorage(ACCT, INDEX) => . ... </k>
         <account>
           <acctID> ACCT </acctID>
           <storage> ... INDEX |-> _ ... </storage>
           ...
         </account>

    syntax String ::= #getCode(Int) [function, hook(MANTIS.getCode)]
 // ----------------------------------------------------------------
    rule <k> #lookupCode(ACCT) => . ... </k>
         <account>
           <acctID> ACCT </acctID>
           <code> #unloaded => #parseByteStackRaw(#getCode(ACCT)) </code>
           ...
         </account>

    rule <k> #lookupCode(ACCT) => . ... </k>
         <account>
           <acctID> ACCT </acctID>
           <code> _:WordStack </code>
           ...
         </account>

    rule #lookupCode(ACCT) => .
      requires notBool #accountExists(ACCT)

    syntax Int ::= #getBlockhash(Int) [function, hook(MANTIS.getBlockhash)]
 // -----------------------------------------------------------------------
    rule <k> BLOCKHASH N => #getBlockhash(N) ~> #push ... </k> <mode> NORMAL </mode>
      requires N >=Int 0 andBool N <Int 256
    rule <k> BLOCKHASH N => 0 ~> #push ... </k> <mode> NORMAL </mode>
      requires N <Int 0 orBool N >=Int 256

    syntax EthereumSimulation ::= runVM(iscreate: Bool, to: Int, from: Int, code: String, args: String, value: Int, gasprice: Int, gas: Int, beneficiary: Int, difficulty: Int, number: Int, gaslimit: Int, timestamp: Int, unused: String)
 
    rule <k> (.K => #loadAccount ACCTFROM) ~> runVM(... from: ACCTFROM) ... </k>
         <activeAccounts> .Set </activeAccounts>

    rule <k> runVM(true, _, ACCTFROM, _, ARGS, VALUE, GPRICE, GAVAIL, CB, DIFF, NUMB, GLIMIT, TS, _)
          => #loadAccount(#newAddr(ACCTFROM, NONCE -Int 1))
          ~> #create ACCTFROM #newAddr(ACCTFROM, NONCE -Int 1) GAVAIL VALUE #parseByteStackRaw(ARGS)
          ~> #codeDeposit #newAddr(ACCTFROM, NONCE -Int 1)
          ~> #endCreate
         ...
         </k>
         <schedule> SCHED </schedule>
         <gasPrice> _ => GPRICE </gasPrice>
         <origin> _ => ACCTFROM </origin>
         <callDepth> _ => -1 </callDepth>
         <coinbase> _ => CB </coinbase>
         <difficulty> _ => DIFF </difficulty>
         <number> _ => NUMB </number>
         <gasLimit> _ => GLIMIT </gasLimit>
         <timestamp> _ => TS </timestamp>
         <account>
           <acctID> ACCTFROM </acctID>
           <nonce> NONCE </nonce>
           ...
         </account>
         <touchedAccounts> _ => SetItem(CB) </touchedAccounts>
         <activeAccounts> ACCTS </activeAccounts>
      requires ACCTFROM in ACCTS

    rule <k> runVM(false, ACCTTO, ACCTFROM, _, ARGS, VALUE, GPRICE, GAVAIL, CB, DIFF, NUMB, GLIMIT, TS, _)
          => #loadAccount(ACCTTO)
          ~> #lookupCode(ACCTTO)
          ~> #call ACCTFROM ACCTTO ACCTTO GAVAIL VALUE VALUE #parseByteStackRaw(ARGS) false
          ~> #endVM
         ...
         </k>
         <schedule> SCHED </schedule>
         <gasPrice> _ => GPRICE </gasPrice>
         <origin> _ => ACCTFROM </origin>
         <callDepth> _ => -1 </callDepth>
         <coinbase> _ => CB </coinbase>
         <difficulty> _ => DIFF </difficulty>
         <number> _ => NUMB </number>
         <gasLimit> _ => GLIMIT </gasLimit>
         <timestamp> _ => TS </timestamp>
         <touchedAccounts> _ => SetItem(CB) </touchedAccounts>
         <activeAccounts> ACCTS </activeAccounts>
      requires ACCTFROM in ACCTS

    syntax EthereumCommand ::= "#endVM" | "#endCreate"
 // --------------------------------------------------
    rule <k> #exception ~> #endVM => #popCallStack ~> #popWorldState ~> #popSubstate ~> 0 </k>
         <output> _ => .WordStack </output>
    rule <k> #revert ~> #endVM => #popCallStack ~> #popWorldState ~> #popSubstate ~> #refund GAVAIL ~> 0 </k>
         <gas> GAVAIL </gas>       

    rule <k> #end ~> #endVM => #popCallStack ~> #dropWorldState ~> #dropSubstate ~> #refund GAVAIL ~> 1 </k>
         <gas> GAVAIL </gas>

    rule <k> #endCreate => W ... </k> <wordStack> W : WS </wordStack>

    syntax KItem ::= vmResult(return: String,gas: Int,refund: Int,status: Int,selfdestruct: List,logs: List,AccountsCell, touched: List)
    syntax KItem ::= extractConfig(GeneratedTopCell) [function]
 // -----------------------------------------------------------
    rule extractConfig(<generatedTop>... <output> OUT </output> <gas> GAVAIL </gas> <refund> REFUND </refund> <k> STATUS:Int </k> <selfDestruct> SD </selfDestruct> <log> LOGS </log> <accounts> ACCTS </accounts> <touchedAccounts> TOUCHED </touchedAccounts> ... </generatedTop>) => vmResult(#unparseByteStack(OUT),GAVAIL,REFUND,STATUS,Set2List(SD),LOGS,<accounts> ACCTS </accounts>, Set2List(TOUCHED))

    syntax String ::= contractBytes(WordStack) [function]
 // -----------------------------------------------------
    rule contractBytes(WS) => #unparseByteStack(WS)

endmodule
```
