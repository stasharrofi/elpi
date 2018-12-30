
help:
	@echo 'Known targets:'
	@echo
	@echo '  tests            runs the entire test suite'
	@echo '  tests ONLY=rex   runs only tests matching rex'
	@echo
	@echo '  git/treeish      checkout treeish and build elpi.git.treeish'
	@echo

INSTALL=_build/install/default
BUILD=_build/default
SHELL:=/bin/bash
TIMEOUT=60.0
RUNNERS=\
  $(shell pwd)/$(INSTALL)/bin/elpi \
  $(addprefix $(shell pwd)/,$(wildcard elpi.git.*)) \
  $(shell if type tjsim >/dev/null 2>&1; then type -P tjsim; else echo; fi)
TIME=$(shell if type -P gtime >/dev/null 2>&1; then type -P gtime; else echo /usr/bin/time; fi)
STACK=32768

tests:
	dune build $(INSTALL)/bin/elpi
	dune build $(BUILD)/tests/test.exe
	ulimit -s $(STACK); \
		$(BUILD)/tests/test.exe \
		--seed $$RANDOM \
		--timeout $(TIMEOUT) \
		--time=$(TIME) \
		--sources=$$PWD/tests/sources/ \
		--plot=$$PWD/tests/plot \
		$(addprefix --name-match ,$(ONLY)) \
		$(addprefix --runner , $(RUNNERS))

git/%:
	rm -rf "$$PWD/elpi-$*"
	mkdir "elpi-$*"
	git clone -l . "elpi-$*"
	cd "elpi-$*" && git checkout "$*"
	cd "elpi-$*" && \
	  if [ -f dune ]; then dune build --root . @install; else make; fi
	cp "elpi-$*/elpi" "elpi.git.$*" || \
		cp "elpi-$*/$(INSTALL)/bin/elpi" "elpi.git.$*"
	rm -rf "$$PWD/elpi-$*"

.PHONY: tests all install uninstall help

