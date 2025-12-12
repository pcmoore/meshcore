# Simple makefile to build specific targets
#

TARGETS ?= \
	RAK_4631_repeater \
	RAK_4631_companion_radio_ble \
	RAK_WisMesh_Tag_companion_radio_ble \
	Heltec_t114_companion_radio_ble \
	Station_G2_repeater

.PHONY: help
help:
	@echo "MeshCore make targets:"
	@echo "  clean:    clean platformio build directory"
	@echo "  targets:  build firmware targets specified in the makefile"

.PHONY: check_deps
check_deps:
	@if [ -z "$$FIRMWARE_VERSION" ]; then \
		echo ">>> error: set FIRMWARE_VERSION to \"vX.Y.Z\""; \
		exit 1; \
	fi
	@if [ ! -d ./BUILDS ]; then \
		mkdir ./BUILDS || exit 1; \
	fi

$(TARGETS): check_deps
	@echo ">>> building $@"
	@./build.sh build-firmware $@
	@git="`git rev-parse --short HEAD 2>/dev/null`"; \
	[ -n "$$git" ] && git="-$$git"; \
	for i in ./.pio/build/$@/firmware.*; do \
		ext=`echo $$i | sed 's/\(.*\)\.\([a-zA-Z0-9]\)/\2/'`; \
		build_dest=./BUILDS/$@_$$FIRMWARE_VERSION$$git.$$ext; \
		cp -f $$i $$build_dest; \
		chmod 0444 $$build_dest; \
		ls --color=never $$build_dest; \
	done

.PHONY: all
targets: check_deps $(TARGETS)

.PHONY: clean
clean:
	@echo ">>> cleaning platformio build directories"
	@rm -rf .pio
