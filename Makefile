###############################################################################
#  Makefile – lint → package → repo index
###############################################################################
SHELL     := /bin/bash
REPOURL   := https://dzooli.github.io/helmcharts/

# ── chart-lista: csak KÖNYVTÁRAK a src/ alatt ────────────────────────────────
CHART_DIRS := $(patsubst %/,%,$(wildcard src/*/))   # → src/dask-arm64 src/xyz …
CHARTS     := $(notdir $(CHART_DIRS))               # → dask-arm64 xyz …

# ── célfájlok ────────────────────────────────────────────────────────────────
LINT_FLAGS := $(addprefix build/,$(addsuffix .lint,$(CHARTS)))
TGZ_FILES  := $(addprefix packages/,$(addsuffix .tgz,$(CHARTS)))

# ── fő cél ───────────────────────────────────────────────────────────────────
all: $(TGZ_FILES) index.yaml

###############################################################################
# 1) LINT – build/<chart>.lint  (flag a build/ mappában)
###############################################################################
build/%.lint: src/%/Chart.yaml | build
	@echo "🔍 helm lint src/$*"
	@helm lint src/$*
	@touch $@

lint: $(LINT_FLAGS)                   # manuális: make lint

build:
	@mkdir -p build

###############################################################################
# 2) PACKAGE – packages/<chart>.tgz  (verzió-független név)
###############################################################################
packages/%.tgz: build/%.lint | packages
	@echo "📦 helm package src/$*"
	@helm package src/$* --destination packages
	@latest=$$(ls -1t packages/*.tgz | head -1); mv $$latest $@

packages:
	@mkdir -p packages

###############################################################################
# 3) REPO INDEX  – index.yaml
###############################################################################
index.yaml: $(TGZ_FILES)
	@echo "🔄 helm repo index ..."
	@helm repo index . --url $(REPOURL) --merge $@

###############################################################################
# 4) CLEAN
###############################################################################
.PHONY: lint clean distclean
clean:
	rm -rf build packages
distclean: clean
	rm -f index.yaml

