module {module}-SPEC
  imports ETHEREUM-SIMULATION

  rule
    <k> {k} </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> DEFAULT </schedule> // TODO: pick a right one
    <analysis> .Map </analysis> // not part of evm

    <ethereum>
      <evm>
        <output> _ </output>
        <memoryUsed> 0 => _ </memoryUsed>
        <callDepth> CALL_DEPTH </callDepth>
        <callStack> _ => _ </callStack>
        <interimStates> _ </interimStates>
        <substateStack> _ </substateStack>
        <callLog> .Set </callLog> // for vmtest only

        <txExecState>
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({code}), DEFAULT)) </program>
          <programBytes> #parseByteStack({code}) </programBytes>

          <id> ACCT_ID </id> // contract owner
          <caller> CALLER_ID </caller> // who called this contract; in the begining, origin

          <callData> {calldata} </callData>

          <callValue> 0 </callValue>
          <wordStack> .WordStack => _ </wordStack>
          <localMem>
            {localmem}
          </localMem>
          <pc> 0 => _ </pc>
          <gas> {gas} </gas>
          <previousGas> _ => _ </previousGas>

          <static> false </static> // NOTE: non-static call
        </txExecState>

        <substate>
          <selfDestruct> _ </selfDestruct>
          <log>
            {log}
          </log>
          <refund> {refund} </refund> // TODO: more detail
        </substate>

        <gasPrice> _ </gasPrice>
        <origin> ORIGIN_ID </origin> // who fires tx

        <previousHash> _ </previousHash>
        <ommersHash> _ </ommersHash>
        <coinbase> _ </coinbase>
        <stateRoot> _ </stateRoot>
        <transactionsRoot> _ </transactionsRoot>
        <receiptsRoot> _ </receiptsRoot>
        <logsBloom> _ </logsBloom>
        <difficulty> _ </difficulty>
        <number> _ </number>
        <gasLimit> _ </gasLimit>
        <gasUsed> _ </gasUsed>
        <timestamp> _ </timestamp>
        <extraData> _ </extraData>
        <mixHash> _ </mixHash>
        <blockNonce> _ </blockNonce>

        <ommerBlockHeaders> _ </ommerBlockHeaders>
        <blockhash> _ </blockhash>
      </evm>

      <network>
        <activeAccounts> ACCT_ID |-> false _:Map </activeAccounts>

        <accounts>
          <account>
            <acctID> ACCT_ID </acctID>
            <balance> _ </balance>
            <code> #parseByteStack({code}) </code>
            <storage>
              {storage}
            </storage>
            <nonce> _ </nonce>
          </account>
       // ... // TODO: fix
        </accounts>

        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires 0 <=Int ACCT_ID    andBool ACCT_ID    <Int (2 ^Int 160)
     andBool 0 <=Int CALLER_ID  andBool CALLER_ID  <Int (2 ^Int 160)
     andBool 0 <=Int ORIGIN_ID  andBool ORIGIN_ID  <Int (2 ^Int 160)
     andBool 0 <=Int CALL_DEPTH andBool CALL_DEPTH <Int 1024
     {requires}

{comments}

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2int(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2int(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2int(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2int(W  ==Int 0 ) ~> #push ... </k> [trusted]

endmodule