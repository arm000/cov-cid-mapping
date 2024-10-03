COV_DIR=
COV_CONFIGURE=$(COV_DIR)/bin/cov-configure
COV_BUILD=$(COV_DIR)/bin/cov-build
COV_ANALYZE=$(COV_DIR)/bin/cov-analyze
COV_FORMAT_ERRORS=$(COV_DIR)/bin/cov-format-errors
COV_COMMIT=$(COV_DIR)/bin/cov-commit-defects
COV_MISRA_C=$(COV_DIR)/config/coding-standards/misrac2012/misrac2012-all.config
COV_MISRA_CPP=$(COV_DIR)/config/coding-standards/misracpp2008/misracpp2008-all.config
COV_CERTC=$(COV_DIR)/config/coding-standards/cert-c/cert-c-all.config
COV_AUTOSAR=$(COV_DIR)/config/coding-standards/autosarcpp14/autosarcpp14-all.config
COV_SSL_CERT=$(COV_DIR)/SSLCert/ca-chain.crt
COV_SERVER=commit://localhost:9090
COV_USER=$(USER)
COV_STREAM=$(USER)_test

# coverity output directory
COV_OUT=cov-out

# build target
TARGET=main

# compiler
CC=gcc

CODING_STANDARDS= \
	--coding-standard-config $(COV_AUTOSAR)

CODING_STANDARDS= \
	--coding-standard-config $(COV_MISRA_C) \
	--coding-standard-config $(COV_MISRA_CPP) \
	--coding-standard-config $(COV_CERTC) \
	--coding-standard-config $(COV_AUTOSAR)

CODING_STANDARDS= \
	--coding-standard-config $(COV_MISRA_C) \
	--coding-standard-config $(COV_CERTC)

default: print-summary $(COV_OUT)/output/violations.json

$(TARGET): main.o addone.o subone.o
$(wildcard *.o): Makefile ifacev1.h ifacev2.h addone.h subone.h

$(COV_OUT):
	mkdir -p $(COV_OUT)

$(COV_OUT)/coverity_config.xml:
	mkdir -p $(COV_OUT)
	$(COV_CONFIGURE) --gcc --config $@

$(COV_OUT)/emit/chrome/emit-db: $(COV_OUT)/coverity_config.xml Makefile $(wildcard *.c) $(wildcard *.h)
	$(COV_BUILD) --config $(COV_OUT)/coverity_config.xml --dir $(COV_OUT) make $(TARGET)

$(COV_OUT)/output/summary.txt: $(COV_OUT)/emit/chrome/emit-db $(COV_OUT)/coverity_config.xml
	$(COV_ANALYZE) \
		--config $(COV_OUT)/coverity_config.xml \
		$(CODING_STANDARDS) \
		-dir $(COV_OUT)

$(COV_OUT)/output/violations.json: $(COV_OUT)/output/summary.txt
	$(COV_FORMAT_ERRORS) --json-output-v10 $(COV_OUT)/output/violations.json --dir $(COV_OUT)

.PHONY: print-summary
print-summary: $(COV_OUT)/output/summary.txt
	$(COV_FORMAT_ERRORS) --text-output-style oneline --dir $(COV_OUT)

.PHONY: commit
commit: $(COV_OUT)/output/summary.txt
	$(COV_COMMIT) --dir $(COV_OUT) --certs $(COV_SSL_CERT) --url $(COV_SERVER) --on-new-cert trust --user $(COV_USER) --stream $(COV_STREAM)

.PHONY: clean
clean:
	rm -rf $(TARGET) *.o $(COV_OUT) *~
