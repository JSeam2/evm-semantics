module FORWARDTOHOTWALLET-SUCCESS-2-SPEC
  imports ETHEREUM-SIMULATION

  rule
    <k> #execute => (RETURN RET_ADDR:Int 32 ~> _) </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> BYZANTIUM </schedule>
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
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack("0x6060604052600436106100a4576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806316ada547146100a957806329113bc8146100d25780633943380c146101275780635c975abb1461017c5780636be13c92146101a95780638da5cb5b146101fe578063ab23151114610253578063bde27f4a1461027c578063cdc18424146102b3578063f848d54114610308575b600080fd5b34156100b457600080fd5b6100bc610331565b6040518082815260200191505060405180910390f35b34156100dd57600080fd5b6100e5610339565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561013257600080fd5b61013a61035f565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561018757600080fd5b61018f610384565b604051808215151515815260200191505060405180910390f35b34156101b457600080fd5b6101bc610397565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561020957600080fd5b6102116103bd565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561025e57600080fd5b6102666103e3565b6040518082815260200191505060405180910390f35b341561028757600080fd5b61029d60048080359060200190919050506103e9565b6040518082815260200191505060405180910390f35b34156102be57600080fd5b6102c66104b8565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561031357600080fd5b61031b6104de565b6040518082815260200191505060405180910390f35b600042905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600660149054906101000a900460ff1681565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600660009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60055481565b6000806000600660149054906101000a900460ff1615151561040a57600080fd5b600360009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561046657600080fd5b60008411151561047557600080fd5b61047d610331565b915062015180600554018211151561049457600080fd5b8390506004548111156104a75760045490505b816005819055508092505050919050565b600360009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600454815600a165627a7a723058205ef4dd4b46242121ef284c2e4e845500e9d0eb84ebd7c272212a1f3a94e295fc0029"), BYZANTIUM)) </program>
          <programBytes> #parseByteStack("0x6060604052600436106100a4576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806316ada547146100a957806329113bc8146100d25780633943380c146101275780635c975abb1461017c5780636be13c92146101a95780638da5cb5b146101fe578063ab23151114610253578063bde27f4a1461027c578063cdc18424146102b3578063f848d54114610308575b600080fd5b34156100b457600080fd5b6100bc610331565b6040518082815260200191505060405180910390f35b34156100dd57600080fd5b6100e5610339565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561013257600080fd5b61013a61035f565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561018757600080fd5b61018f610384565b604051808215151515815260200191505060405180910390f35b34156101b457600080fd5b6101bc610397565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561020957600080fd5b6102116103bd565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561025e57600080fd5b6102666103e3565b6040518082815260200191505060405180910390f35b341561028757600080fd5b61029d60048080359060200190919050506103e9565b6040518082815260200191505060405180910390f35b34156102be57600080fd5b6102c66104b8565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561031357600080fd5b61031b6104de565b6040518082815260200191505060405180910390f35b600042905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600660149054906101000a900460ff1681565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600660009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60055481565b6000806000600660149054906101000a900460ff1615151561040a57600080fd5b600360009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561046657600080fd5b60008411151561047557600080fd5b61047d610331565b915062015180600554018211151561049457600080fd5b8390506004548111156104a75760045490505b816005819055508092505050919050565b600360009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600454815600a165627a7a723058205ef4dd4b46242121ef284c2e4e845500e9d0eb84ebd7c272212a1f3a94e295fc0029") </programBytes>

          <id> ACCT_ID </id> // contract owner
          <caller> CALLER_ID </caller> // who called this contract; in the begining, origin // msg.sender

          <callData> #abiCallData("forwardToHotWallet", #uint256(AMOUNT)) </callData>

          <callValue> 0 </callValue>
          <wordStack> .WordStack => _ </wordStack>
          <localMem> .Map => ( .Map[ RET_ADDR := #asByteStackInWidth(RET_VAL, 32) ] _:Map ) </localMem>
          <pc> 0 => _ </pc>
          <gas> 100000 => _ </gas>
          <previousGas> _ => _ </previousGas>

          <static> false </static> // NOTE: non-static call
        </txExecState>

        <substate>
          <selfDestruct> _ </selfDestruct>
          <log> _ </log>
          <refund> _ </refund> // TODO: more detail
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
        <timestamp> NOW </timestamp> // block.timestamp // now
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
            <code> #parseByteStack("0x6060604052600436106100a4576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806316ada547146100a957806329113bc8146100d25780633943380c146101275780635c975abb1461017c5780636be13c92146101a95780638da5cb5b146101fe578063ab23151114610253578063bde27f4a1461027c578063cdc18424146102b3578063f848d54114610308575b600080fd5b34156100b457600080fd5b6100bc610331565b6040518082815260200191505060405180910390f35b34156100dd57600080fd5b6100e5610339565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561013257600080fd5b61013a61035f565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561018757600080fd5b61018f610384565b604051808215151515815260200191505060405180910390f35b34156101b457600080fd5b6101bc610397565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561020957600080fd5b6102116103bd565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561025e57600080fd5b6102666103e3565b6040518082815260200191505060405180910390f35b341561028757600080fd5b61029d60048080359060200190919050506103e9565b6040518082815260200191505060405180910390f35b34156102be57600080fd5b6102c66104b8565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b341561031357600080fd5b61031b6104de565b6040518082815260200191505060405180910390f35b600042905090565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600660149054906101000a900460ff1681565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600660009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60055481565b6000806000600660149054906101000a900460ff1615151561040a57600080fd5b600360009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561046657600080fd5b60008411151561047557600080fd5b61047d610331565b915062015180600554018211151561049457600080fd5b8390506004548111156104a75760045490505b816005819055508092505050919050565b600360009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600454815600a165627a7a723058205ef4dd4b46242121ef284c2e4e845500e9d0eb84ebd7c272212a1f3a94e295fc0029") </code>
            <storage>
              #hashedLocation("Solidity", 3,       .IntList) |-> WITHDRAWER
#hashedLocation("Solidity", 4,    .IntList) |-> WITHDRAWLIMIT
#hashedLocation("Solidity", 5, .IntList) |-> ( LASTWITHDRAWTIME => NOW )
#hashedLocation("Solidity", 6,           .IntList) |-> PAUSED
_:Map
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
     andBool 0 <=Int NOW        andBool NOW        <Int (2 ^Int 256)
     andBool 0 <=Int CALL_DEPTH andBool CALL_DEPTH <Int 1024
     andBool 0 <=Int AMOUNT             andBool AMOUNT              <Int (2 ^Int 256)
andBool 0 <=Int WITHDRAWER         andBool WITHDRAWER          <Int (2 ^Int 160)
andBool 0 <=Int WITHDRAWLIMIT      andBool WITHDRAWLIMIT       <Int (2 ^Int 256)
andBool 0 <=Int LASTWITHDRAWTIME   andBool LASTWITHDRAWTIME    <Int (2 ^Int 256)
andBool 0 <=Int PAUSED             andBool PAUSED              <Int (2 ^Int 256)
andBool PAUSED ==Int 0                                     // notPaused
andBool CALLER_ID ==Int WITHDRAWER                         // onlyWithdrawer
andBool AMOUNT >Int 0                                      // require(_amount > 0);
andBool NOW >Int LASTWITHDRAWTIME +Word (24 *Int 3600)     // require(_time > (lastWithdrawTime + 24 hours));
andBool AMOUNT >Int WITHDRAWLIMIT // if (amount > withdrawLimit) { ... }
ensures  RET_VAL ==Int WITHDRAWLIMIT


  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2int(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2int(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2int(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2int(W  ==Int 0 ) ~> #push ... </k> [trusted]

endmodule

