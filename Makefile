.EXPORT_ALL_VARIABLES:
SHELL=/bin/bash

packages = src/brender-node

KEYNAME := 'Zoltan Fabian'
KEYRING := $(shell echo $$HOME)/.gnupg/secring.gpg
REPOURL := https://dzooli.github.io/helmcharts/


all: $(packages) index.yaml

index.yaml: reindex.txt
	set -e; helm repo index . --url $(REPOURL) 

$(packages): flag.txt
	set -e;	helm package --key $(KEYNAME) --sign --keyring $(KEYRING) $@

flag.txt:
	touch $@
reindex.txt:
	touch $@

.PHONY: clean
clean:
	rm -f flag.txt reindex.txt

distclean: clean
	rm -f index.yaml
