
  python3 tests/gen-spec.py tmpl.k spec-WarmWallet.ini pgm-WarmWallet.ini forwardToHotWallet-success-1 >forwardToHotWallet-success-1-spec.k
  python3 tests/gen-spec.py tmpl.k spec-WarmWallet.ini pgm-WarmWallet.ini forwardToHotWallet-success-2 >forwardToHotWallet-success-2-spec.k
# python3 tests/gen-spec.py tmpl.k spec-WarmWallet.ini pgm-WarmWallet.ini forwardToHotWallet-failure   >forwardToHotWallet-failure-spec.k
  python3 tests/gen-spec.py tmpl.k spec-WarmWallet.ini pgm-WarmWallet.ini forwardToHotWallet-failure-1 >forwardToHotWallet-failure-1-spec.k
  python3 tests/gen-spec.py tmpl.k spec-WarmWallet.ini pgm-WarmWallet.ini forwardToHotWallet-failure-2 >forwardToHotWallet-failure-2-spec.k
  python3 tests/gen-spec.py tmpl.k spec-WarmWallet.ini pgm-WarmWallet.ini forwardToHotWallet-failure-3 >forwardToHotWallet-failure-3-spec.k
  python3 tests/gen-spec.py tmpl.k spec-WarmWallet.ini pgm-WarmWallet.ini forwardToHotWallet-failure-4 >forwardToHotWallet-failure-4-spec.k

  time krun --prove forwardToHotWallet-success-1-spec.k    -d .build/java -cSCHEDULE=BYZANTIUM -cMODE=NORMAL tests/templates/dummy-proof-input.json --z3-executable
  time krun --prove forwardToHotWallet-success-2-spec.k    -d .build/java -cSCHEDULE=BYZANTIUM -cMODE=NORMAL tests/templates/dummy-proof-input.json --z3-executable
# time krun --prove forwardToHotWallet-failure-spec.k      -d .build/java -cSCHEDULE=BYZANTIUM -cMODE=NORMAL tests/templates/dummy-proof-input.json --z3-executable
  time krun --prove forwardToHotWallet-failure-1-spec.k    -d .build/java -cSCHEDULE=BYZANTIUM -cMODE=NORMAL tests/templates/dummy-proof-input.json --z3-executable
  time krun --prove forwardToHotWallet-failure-2-spec.k    -d .build/java -cSCHEDULE=BYZANTIUM -cMODE=NORMAL tests/templates/dummy-proof-input.json --z3-executable
  time krun --prove forwardToHotWallet-failure-3-spec.k    -d .build/java -cSCHEDULE=BYZANTIUM -cMODE=NORMAL tests/templates/dummy-proof-input.json --z3-executable
  time krun --prove forwardToHotWallet-failure-4-spec.k    -d .build/java -cSCHEDULE=BYZANTIUM -cMODE=NORMAL tests/templates/dummy-proof-input.json --z3-executable

