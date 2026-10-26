ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_DIR := build

.PHONY: \
	all \
	build \
	clean \
	help

all: build

build: \
	01-intro.pdf

install: build
	mkdir -p "$(PREFIX)/presentations"
	cp "$(BUILD_DIR)/01-intro.pdf" "$(PREFIX)/presentations/01-intro.pdf"

clean:
	rm -rf $(BUILD_DIR)

help:
	@printf "all\tbuild all presentations and homeworks\n"
	@printf "build\tbuild all presentations and homeworks\n"
	@printf "clean\tremove build artifacts\n"
	@printf "help\tprint this message\n"
	@printf "install\tinstall all presentations and homeworks\n"
	@printf "01-intro.pdf\tbuild presentation 01-intro.pdf\n"

define generate_pdf
	TEXINPUTS='$(shell pwd)//:' \
	SOURCE_DATE_EPOCH='$(shell date +%s)' \
	latexmk \
		-lualatex \
		-jobname=$(subst .pdf,,$2) \
		$1
endef

*.pdf: \
	presentations/presentationtemplate.sty \
	presentations/images/binary-file.png \
	presentations/images/source_code.png \
	presentations/images/prosoft-logo.png \
	packages/terminal.sty \
	packages/mylisting.sty

01-intro.pdf: \
	presentations/01-intro/intro.tex \
	$(wildcard presentations/01-intro/*.c) \
	$(wildcard presentations/01-intro/*.h)
	$(call generate_pdf,$<,$@)
