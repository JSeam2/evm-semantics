KEVM Verification
=================

Using K's reachability logic theorem prover, we're able to verify many properties about EVM programs as reachability claims.
This module defines some helpers which make writing specifications simpler.

```{.k .uiuck}
requires "evm.k"

module VERIFICATION
    imports EVM
```

Sum to N
--------

As a demonstration of simple reachability claims involing a circularity, we prove the EVM [Sum to N](proofs/sum-to-n.md) program correct.
This program sums the numbers from 1 to N (for sufficiently small N), including pre-conditions dis-allowing integer under/overflow and stack overflow.

```{.k .uiuck}
    syntax Map ::= "sumTo" "(" Int ")" [function]
 // ---------------------------------------------
    rule sumTo(N)
      => #asMapOpCodes( PUSH(1, 0) ; PUSH(32, N)                // s = 0 ; n = N
                      ; JUMPDEST                                // label:loop
                      ; DUP(1) ; ISZERO ; PUSH(1, 52) ; JUMPI   // if n == 0, jump to end
                      ; DUP(1) ; SWAP(2) ; ADD                  // s = s + n
                      ; SWAP(1) ; PUSH(1, 1) ; SWAP(1) ; SUB    // n = n - 1
                      ; PUSH(1, 35) ; JUMP                      // jump to loop
                      ; JUMPDEST                                // label:end
                      ; .OpCodes
                      ) [macro]
```

EVM Memory Abstraction
----------------------

```{.k .uiuck}
  syntax Bool ::= #isConcrete(K) [function, hook(KREFLECTION.isConcrete)]

  rule (I1 +Int I2) +Int I3 => I1 +Int (I2 +Int I3) when #isConcrete(I2) andBool #isConcrete(I3)
  rule (I1 +Int I2) -Int I3 => I1 +Int (I2 -Int I3) when #isConcrete(I2) andBool #isConcrete(I3)
  rule (I1 -Int I2) +Int I3 => I1 -Int (I2 -Int I3) when #isConcrete(I2) andBool #isConcrete(I3)
  rule (I1 -Int I2) -Int I3 => I1 -Int (I2 +Int I3) when #isConcrete(I2) andBool #isConcrete(I3)

  rule 0 +Int N => N
  rule N +Int 0 => N

  rule N -Int 0 => N

  rule 1 *Int N => N
  rule N *Int 1 => N
  rule 0 *Int _ => 0
  rule _ *Int 0 => 0

  rule N /Int 1 => N

  rule 0 |Int N => N
  rule N |Int 0 => N
  rule N |Int N => N

  rule 0 &Int N => 0
  rule N &Int 0 => 0
  rule N &Int N => N

  syntax Int ::= bool2int(Bool) [function] // [smtlib(smt_bool2int)]
  rule bool2int(B) => 1 requires B
  rule bool2int(B) => 0 requires notBool(B)

  rule bool2int(A) |Int bool2int(B) => bool2int(A  orBool B)
  rule bool2int(A) &Int bool2int(B) => bool2int(A andBool B)

  rule bool2int(A)  ==K 0 => notBool(A)
  rule bool2int(A)  ==K 1 => A
  rule bool2int(A) =/=K 0 => A
  rule bool2int(A) =/=K 1 => notBool(A)

  rule chop(bool2int(B)) => bool2int(B)

  // for gas calculation
  rule A -Int (#ifInt C #then B1 #else B2 #fi) => #ifInt C #then (A -Int B1) #else (A -Int B2) #fi
  rule (#ifInt C #then B1 #else B2 #fi) -Int A => #ifInt C #then (B1 -Int A) #else (B2 -Int A) #fi

  // TODO: change semantics
  rule chop(I) => I modInt /* pow256 */ 115792089237316195423570985008687907853269984665640564039457584007913129639936 [concrete, smt-lemma]

  syntax Int ::= nthbyteof(Int, Int, Int) [function, smtlib(smt_nthbyteof)]

  rule nthbyteof(V, I, N) => nthbyteof(V /Int 256, I, N -Int 1) when N  >Int (I +Int 1) [concrete]
  rule nthbyteof(V, I, N) =>           V %Int 256               when N ==Int (I +Int 1) [concrete]

  rule 0 <=Int nthbyteof(V, I, N)          => true
  rule         nthbyteof(V, I, N) <Int 256 => true

  rule 0 <=Int chop(V)                     => true
  rule         chop(V) <Int /* 2 ^Int 256 */ 115792089237316195423570985008687907853269984665640564039457584007913129639936 => true

  // syntactic sugar
  syntax WordStack ::= int2wordstack(Int, Int) [function]
                     | int2wordstackaux(Int, Int, Int, WordStack) [function]
  rule int2wordstack(X, N) => int2wordstackaux(X, N -Int 1, N, .WordStack)
  rule int2wordstackaux(X, I, N, WS) => int2wordstackaux(X, I -Int 1, N, nthbyteof(X, I, N) : WS) when I >Int 0
  rule int2wordstackaux(X, 0, N, WS) => nthbyteof(X, 0, N) : WS

  rule #asWord( nthbyteof(V,  0, 32)
              : nthbyteof(V,  1, 32)
              : nthbyteof(V,  2, 32)
              : nthbyteof(V,  3, 32)
              : nthbyteof(V,  4, 32)
              : nthbyteof(V,  5, 32)
              : nthbyteof(V,  6, 32)
              : nthbyteof(V,  7, 32)
              : nthbyteof(V,  8, 32)
              : nthbyteof(V,  9, 32)
              : nthbyteof(V, 10, 32)
              : nthbyteof(V, 11, 32)
              : nthbyteof(V, 12, 32)
              : nthbyteof(V, 13, 32)
              : nthbyteof(V, 14, 32)
              : nthbyteof(V, 15, 32)
              : nthbyteof(V, 16, 32)
              : nthbyteof(V, 17, 32)
              : nthbyteof(V, 18, 32)
              : nthbyteof(V, 19, 32)
              : nthbyteof(V, 20, 32)
              : nthbyteof(V, 21, 32)
              : nthbyteof(V, 22, 32)
              : nthbyteof(V, 23, 32)
              : nthbyteof(V, 24, 32)
              : nthbyteof(V, 25, 32)
              : nthbyteof(V, 26, 32)
              : nthbyteof(V, 27, 32)
              : nthbyteof(V, 28, 32)
              : nthbyteof(V, 29, 32)
              : nthbyteof(V, 30, 32)
              : nthbyteof(V, 31, 32)
              : .WordStack ) => V
    requires 0 <=Int V andBool V <Int (2 ^Int 256)

  rule #asByteStack(V) => int2wordstack(V, 32)
    requires 0 <=Int V andBool V <Int (2 ^Int 256)

  // for extracting first four bytes of function signature
  rule #asByteStack(#asWord(WS)) => WS
    requires noOverflow(WS)

  syntax Bool ::= noOverflow(WordStack)    [function]
                | noOverflowAux(WordStack) [function]
  rule noOverflow(WS) => #sizeWordStack(WS) <=Int 32 andBool noOverflowAux(WS)
  rule noOverflowAux(W : WS) => 0 <=Int W andBool W <Int 256 andBool noOverflowAux(WS)
  rule noOverflowAux(.WordStack) => true



  // for medeling collision-free hash function
  syntax Int ::= hash(Int) [smtlib(smt_hash)]

  syntax Int ::= sha3(Int) [function]
  rule sha3(V) => keccak(#padToWidth(32, #asByteStack(V)))

  rule keccak( nthbyteof(V,  0, 32)
             : nthbyteof(V,  1, 32)
             : nthbyteof(V,  2, 32)
             : nthbyteof(V,  3, 32)
             : nthbyteof(V,  4, 32)
             : nthbyteof(V,  5, 32)
             : nthbyteof(V,  6, 32)
             : nthbyteof(V,  7, 32)
             : nthbyteof(V,  8, 32)
             : nthbyteof(V,  9, 32)
             : nthbyteof(V, 10, 32)
             : nthbyteof(V, 11, 32)
             : nthbyteof(V, 12, 32)
             : nthbyteof(V, 13, 32)
             : nthbyteof(V, 14, 32)
             : nthbyteof(V, 15, 32)
             : nthbyteof(V, 16, 32)
             : nthbyteof(V, 17, 32)
             : nthbyteof(V, 18, 32)
             : nthbyteof(V, 19, 32)
             : nthbyteof(V, 20, 32)
             : nthbyteof(V, 21, 32)
             : nthbyteof(V, 22, 32)
             : nthbyteof(V, 23, 32)
             : nthbyteof(V, 24, 32)
             : nthbyteof(V, 25, 32)
             : nthbyteof(V, 26, 32)
             : nthbyteof(V, 27, 32)
             : nthbyteof(V, 28, 32)
             : nthbyteof(V, 29, 32)
             : nthbyteof(V, 30, 32)
             : nthbyteof(V, 31, 32)
             : .WordStack ) => hash(V)
    requires 0 <=Int V andBool V <Int (2 ^Int 256)
```

ABI Calls
---------

The ABI Call mechanism provides syntatic sugar to make writing proofs easier.
Instead of manually populating the `<callData>` cell and `<pc>` cell with the right values,
we the sugar allows following conveniences -

 `#abiCallData(*FUNCTION_NAME*, TypedArgs)`, where the typed args to have be of the
 `#uint160(*DATA*)` where the types are from the ABI specification, and enclose
 the data.

The above constructs place the correct values (in accordance with the ABI) in the `<callData>`
cell, allowing proofs of ABI-compliant EVM program to begin at `<pc> 0 </pc>`.

```{.k .uiuck}
    syntax TypedArg ::= "#uint160"      "(" Int ")"
                      | "#address"      "(" Int ")"
                      | "#uint256"      "(" Int ")"

    syntax TypedArgs ::= List{TypedArg, ","}

    syntax WordStack ::= #abiCallData( String , TypedArgs ) [function]
    rule #abiCallData( FNAME , ARGS )
      => #parseByteStack(substrString(Keccak256(#generateSignature(FNAME, ARGS)), 0, 8))
      ++ #encodeArgs(ARGS)

    syntax String ::= #generateSignature        ( String, TypedArgs)    [function]
                    | #generateSignatureAux     ( String, TypedArgs)    [function]
    rule #generateSignature( FNAME , ARGS ) => #generateSignatureAux(FNAME +String "(", ARGS)
    //
    rule #generateSignatureAux(SIGN, TARGA, TARGB, TARGS)  => #generateSignatureAux(SIGN +String #typeName(TARGA) +String ",", TARGB, TARGS)
    rule #generateSignatureAux(SIGN, TARG, .TypedArgs)     => #generateSignatureAux(SIGN +String #typeName(TARG), .TypedArgs)
    rule #generateSignatureAux(SIGN, .TypedArgs)           => SIGN +String ")"

    syntax String ::= #typeName ( TypedArg ) [function]
    rule #typeName(#uint160( _ ))  => "uint160"
    rule #typeName(#address( _ ))  => "address"
    rule #typeName(#uint256( _ ))  => "uint256"

    syntax WordStack ::= "#encodeArgs" "(" TypedArgs ")" [function]
    rule #encodeArgs(ARG, ARGS)    => #getData(ARG) ++ #encodeArgs(ARGS)
    rule #encodeArgs(.TypedArgs)   => .WordStack

    syntax WordStack ::= "#getData" "(" TypedArg ")" [function]
    rule #getData(#uint160( DATA )) => int2wordstack( DATA , 32 )
    rule #getData(#address( DATA )) => int2wordstack( DATA , 32 )
    rule #getData(#uint256( DATA )) => int2wordstack( DATA , 32 )
```

```{.k .uiuck}
endmodule
```
