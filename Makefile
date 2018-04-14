LIBDIR := lib
USE_XSLT := true

.PHONY: latest
latest:: txt html

include tools/redefinitions.mk
include $(LIBDIR)/main.mk
include tools/core.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b master https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
