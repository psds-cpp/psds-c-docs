ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_DIR := build

.PHONY: \
	all \
	build \
	clean \
	help

all: build

build: \
	01-intro.pdf \
	02-c-vs-cpp.pdf

install: build
	mkdir -p "$(PREFIX)/presentations"
	cp "$(BUILD_DIR)/01-intro.pdf" "$(PREFIX)/presentations/01-intro.pdf"
	cp "$(BUILD_DIR)/02-c-vs-cpp.pdf" "$(PREFIX)/presentations/02-c-vs-cpp.pdf"

clean:
	rm -rf $(BUILD_DIR)

help:
	@printf "all\tbuild all presentations and homeworks\n"
	@printf "build\tbuild all presentations and homeworks\n"
	@printf "clean\tremove build artifacts\n"
	@printf "help\tprint this message\n"
	@printf "install\tinstall all presentations and homeworks\n"
	@printf "01-intro.pdf\tbuild presentation 01-intro.pdf\n"
	@printf "02-c-vs-cpp.pdf\tbuild presentation 02-c-vs-cpp.pdf\n"

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
	packages/mylisting.sty \
	packages/myitemize.sty

01-intro.pdf: \
	presentations/01-intro/intro.tex \
	$(wildcard presentations/01-intro/*.c) \
	$(wildcard presentations/01-intro/*.h)
	$(call generate_pdf,$<,$@)

02-c-vs-cpp.pdf: \
	presentations/02-c-vs-cpp/c-vs-cpp.tex \
	$(wildcard presentations/02-c-vs-cpp/*.c) \
	$(wildcard presentations/02-c-vs-cpp/*.cpp) \
	$(wildcard presentations/02-c-vs-cpp/*.h)
	$(call generate_pdf,$<,$@)
