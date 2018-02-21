# Common to all versions of K
# ===========================

.PHONY: all clean deps k-deps ocaml-deps build defn sphinx split-tests \
		test test-all vm-test vm-test-all bchain-test bchain-test-all proof-test proof-test-all
.SECONDARY:

all: build split-tests

clean:
	rm -rf .build/java .build/plugin-ocaml .build/plugin-node .build/ocaml .build/node .build/logs tests/proofs .build/k/make.timestamp .build/local .build/vm

build: .build/ocaml/driver-kompiled/interpreter .build/java/driver-kompiled/timestamp .build/vm/kevm-vm

# Dependencies
# ------------

K_SUBMODULE=$(CURDIR)/.build/k
BUILD_LOCAL=$(CURDIR)/.build/local
PKG_CONFIG_LOCAL=$(BUILD_LOCAL)/lib/pkgconfig

deps: k-deps ocaml-deps
k-deps: $(K_SUBMODULE)/make.timestamp

$(K_SUBMODULE)/make.timestamp:
	git submodule update --init -- $(K_SUBMODULE)
	cd $(K_SUBMODULE) \
		&& mvn package -q -DskipTests -U
	touch $(K_SUBMODULE)/make.timestamp

ocaml-deps: .build/local/lib/pkgconfig/libsecp256k1.pc
	opam init --quiet --no-setup
	opam repository add k "$(K_SUBMODULE)/k-distribution/target/release/k/lib/opam" \
		|| opam repository set-url k "$(K_SUBMODULE)/k-distribution/target/release/k/lib/opam"
	opam update
	opam switch 4.03.0+k
	eval $$(opam config env) \
	export PKG_CONFIG_PATH=$(PKG_CONFIG_LOCAL) ; \
	opam install --yes mlgmp zarith uuidm cryptokit secp256k1.0.3.2 bn128 ocaml-protoc rlp yojson hex

# install secp256k1 from bitcoin-core
.build/local/lib/pkgconfig/libsecp256k1.pc:
	git submodule update --init -- .build/secp256k1/
	cd .build/secp256k1/ \
		&& ./autogen.sh \
		&& ./configure --enable-module-recovery --prefix="$(BUILD_LOCAL)" \
		&& make -s -j4 \
		&& make install

K_BIN=$(K_SUBMODULE)/k-distribution/target/release/k/bin

# Building
# --------

# Tangle definition from *.md files

k_files:=driver.k data.k evm.k analysis.k krypto.k verification.k evm-node.k
ocaml_files:=$(patsubst %,.build/ocaml/%,$(k_files))
java_files:=$(patsubst %,.build/java/%,$(k_files))
node_files:=$(patsubst %,.build/node/%,$(k_files))
defn_files:=$(ocaml_files) $(java_files) $(node_files)

defn: $(defn_files)

.build/java/%.k: %.md
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to tangle.lua --metadata=code:java $< > $@

.build/ocaml/%.k: %.md
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to tangle.lua --metadata=code:ocaml $< > $@

.build/node/%.k: %.md
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to tangle.lua --metadata=code:node $< > $@

# Java Backend

.build/java/driver-kompiled/timestamp: $(java_files)
	@echo "== kompile: $@"
	$(K_BIN)/kompile --debug --main-module ETHEREUM-SIMULATION --backend java \
					--syntax-module ETHEREUM-SIMULATION $< --directory .build/java

# OCAML Backend

ifeq ($(BYTE),yes)
EXT=cmo
LIBEXT=cma
DLLEXT=cma
OCAMLC=c
LIBFLAG=-a
else
EXT=cmx
LIBEXT=cmxa
DLLEXT=cmxs
OCAMLC=opt -O3
LIBFLAG=-shared
endif

.build/%/driver-kompiled/constants.$(EXT): $(defn_files)
	@echo "== kompile: $@"
	eval $$(opam config env) && \
	${K_BIN}/kompile --debug --main-module ETHEREUM-SIMULATION \
					--syntax-module ETHEREUM-SIMULATION .build/$*/driver.k --directory .build/$* \
					--hook-namespaces "KRYPTO MANTIS" --gen-ml-only -O3 --non-strict && \
	cd .build/$*/driver-kompiled && ocamlfind $(OCAMLC) -c -g constants.ml -package gmp -package zarith -safe-string

.build/plugin-%/semantics.$(LIBEXT): $(wildcard plugin/plugin/*.ml plugin/plugin/*.mli) .build/%/driver-kompiled/constants.$(EXT)
	mkdir -p .build/plugin-$*
	cp plugin/plugin/*.ml plugin/plugin/*.mli .build/plugin-$*
	eval $$(opam config env) && \
	ocaml-protoc plugin/plugin/proto/*.proto -ml_out .build/plugin-$* && \
	cd .build/plugin-$* && ocamlfind $(OCAMLC) -c -g -I ../$*/driver-kompiled msg_types.mli msg_types.ml msg_pb.mli msg_pb.ml threadLocal.mli threadLocal.ml world.mli world.ml caching.mli caching.ml MANTIS.ml KRYPTO.ml -package cryptokit -package secp256k1 -package bn128 -package ocaml-protoc -safe-string -thread && \
	ocamlfind $(OCAMLC) -a -o semantics.$(LIBEXT) KRYPTO.$(EXT) msg_types.$(EXT) msg_pb.$(EXT) threadLocal.$(EXT) world.$(EXT) caching.$(EXT) MANTIS.$(EXT) -thread && \
	ocamlfind remove ethereum-semantics-plugin-$* && \
	ocamlfind install ethereum-semantics-plugin-$* ../../plugin/plugin/META semantics.* *.cmi *.$(EXT)

.build/%/driver-kompiled/interpreter: .build/plugin-%/semantics.$(LIBEXT)
	eval $$(opam config env) && \
	ocamllex .build/$*/driver-kompiled/lexer.mll && \
	ocamlyacc .build/$*/driver-kompiled/parser.mly && \
	cd .build/$*/driver-kompiled && ocamlfind $(OCAMLC) -c -g -package gmp -package zarith -package uuidm -safe-string prelude.ml plugin.ml parser.mli parser.ml lexer.ml run.ml -thread && \
	ocamlfind $(OCAMLC) -c -g -w -11-26 -package gmp -package zarith -package uuidm -package ethereum-semantics-plugin-$* -safe-string realdef.ml -match-context-rows 2 && \
	ocamlfind $(OCAMLC) $(LIBFLAG) -o realdef.$(DLLEXT) realdef.$(EXT) && \
	ocamlfind $(OCAMLC) -g -o interpreter constants.$(EXT) prelude.$(EXT) plugin.$(EXT) parser.$(EXT) lexer.$(EXT) run.$(EXT) interpreter.ml -package gmp -package dynlink -package zarith -package str -package uuidm -package unix -package ethereum-semantics-plugin-$* -linkpkg -linkall -thread -safe-string

.build/vm/kevm-vm: $(wildcard plugin/vm/*.ml plugin/vm/*.mli) .build/node/driver-kompiled/interpreter 
	mkdir -p .build/vm
	cp plugin/vm/*.ml plugin/vm/*.mli .build/vm
	eval $$(opam config env) && \
	cd .build/vm && ocamlfind $(OCAMLC) -g -I ../node/driver-kompiled -o kevm-vm constants.$(EXT) prelude.$(EXT) plugin.$(EXT) parser.$(EXT) lexer.$(EXT) realdef.$(EXT) run.$(EXT) VM.mli VM.ml vmNetworkServer.ml -package gmp -package dynlink -package zarith -package str -package uuidm -package unix -package ethereum-semantics-plugin-node -package rlp -package yojson -package hex -linkpkg -linkall -thread -safe-string

# Tests
# -----

# Override this with `make TEST=echo` to list tests instead of running
TEST=./kevm test

test-all: vm-test-all bchain-test-all proof-test-all interactive-test-all
test: vm-test bchain-test proof-test interactive-test

split-tests: tests/ethereum-tests/make.timestamp split-proof-tests

tests/ethereum-tests/make.timestamp:
	@echo "==  git submodule: cloning upstreams test repository"
	git submodule update --init -- tests/ethereum-tests
	touch $@

tests/ethereum-tests/%.json: tests/ethereum-tests/make.timestamp

# VMTests

vm_tests=$(wildcard tests/ethereum-tests/VMTests/*/*.json)
slow_vm_tests=$(wildcard tests/ethereum-tests/VMTests/vmPerformance/*.json)
quick_vm_tests=$(filter-out $(slow_vm_tests), $(vm_tests))

vm-test-all: $(vm_tests:=.test)
vm-test: $(quick_vm_tests:=.test)

tests/ethereum-tests/VMTests/%.test: tests/ethereum-tests/VMTests/% build
	$(TEST) $<

# BlockchainTests

bchain_tests=$(wildcard tests/ethereum-tests/BlockchainTests/GeneralStateTests/*/*.json)
slow_bchain_tests=$(wildcard tests/ethereum-tests/BlockchainTests/GeneralStateTests/stQuadraticComplexityTest/*.json) \
                  $(wildcard tests/ethereum-tests/BlockchainTests/GeneralStateTests/stStaticCall/static_Call50000*.json) \
                  $(wildcard tests/ethereum-tests/BlockchainTests/GeneralStateTests/stStaticCall/static_Return50000*.json) \
                  $(wildcard tests/ethereum-tests/BlockchainTests/GeneralStateTests/stStaticCall/static_Call1MB1024Calldepth_d1g0v0.json)
                  # $(wildcard tests/BlockchainTests/GeneralStateTests/*/*/*_Constantinople.json)
quick_bchain_tests=$(filter-out $(slow_bchain_tests), $(bchain_tests))

bchain-test-all: $(bchain_tests:=.test)
bchain-test: $(quick_bchain_tests:=.test)

tests/ethereum-tests/BlockchainTests/%.test: tests/ethereum-tests/BlockchainTests/% build
	$(TEST) $<

# ProofTests

proof_dir=tests/proofs
proof_tests=$(proof_dir)/sum-to-n-spec.k \
            $(proof_dir)/hkg/allowance-spec.k \
            $(proof_dir)/hkg/approve-spec.k \
            $(proof_dir)/hkg/balanceOf-spec.k \
            $(proof_dir)/hkg/transfer-else-spec.k $(proof_dir)/hkg/transfer-then-spec.k \
            $(proof_dir)/hkg/transferFrom-else-spec.k $(proof_dir)/hkg/transferFrom-then-spec.k

proof-test-all: proof-test
proof-test: $(proof_tests:=.test)

tests/proofs/%.test: tests/proofs/% build
	$(TEST) $<

split-proof-tests: $(proof_tests)

tests/proofs/sum-to-n-spec.k: proofs/sum-to-n.md
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to tangle.lua --metadata=code:sum-to-n $< > $@

tests/proofs/hkg/%-spec.k: proofs/hkg.md
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to tangle.lua --metadata=code:$* $< > $@

# InteractiveTests

interactive-test-all: interactive-test
interactive-test: \
	tests/interactive/gas-analysis/sumTo10.evm.test \
	tests/interactive/add0.json.test \
	tests/interactive/log3_MaxTopic_d0g0v0.json.test

tests/interactive/%.test: tests/interactive/% tests/interactive/%.out build
	$(TEST) $<

# Sphinx HTML Documentation
# -------------------------

# You can set these variables from the command line.
SPHINXOPTS     =
SPHINXBUILD    = sphinx-build
PAPER          =
SPHINXBUILDDIR = .build/sphinx-docs

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d ../$(SPHINXBUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .
# the i18n builder cannot share the environment and doctrees with the others
I18NSPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .

sphinx:
	mkdir $(SPHINXBUILDDIR); \
	cp -r *.md proofs $(SPHINXBUILDDIR)/.; \
	cd $(SPHINXBUILDDIR); \
	pandoc --from markdown --to rst README.md --output index.rst; \
	sed -i 's/{.k[ a-zA-Z.-]*}/k/g' *.md proofs/*.md; \
	$(SPHINXBUILD) -b dirhtml $(ALLSPHINXOPTS) html; \
	$(SPHINXBUILD) -b text $(ALLSPHINXOPTS) html/text; \
	echo "[+] HTML generated in $(SPHINXBUILDDIR)/html, text in $(SPHINXBUILDDIR)/html/text"
