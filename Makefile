# Build configuration
BUILD ?= build
MOM_MEMORY ?=

# Dependencies
DEPS ?= MOM6/ac/deps

# Autoconf configuration
CODEBASE ?= MOM6
MAKEFILE_IN ?= $(CODEBASE)/ac/Makefile.in
CONFIGURE_AC ?= $(CODEBASE)/ac/configure.ac
M4DIR ?= $(CODEBASE)/ac/m4
MAKEDEP ?= $(CODEBASE)/ac/makedep


# Autoconf setup
CONFIG_FLAGS := --config-cache
CONFIG_FLAGS += --srcdir=$(abspath $(CODEBASE))/ac
ifdef MOM_MEMORY
  CONFIG_FLAGS += MOM_MEMORY=$(abspath $(MOM_MEMORY))
endif

# `export` disables autoconf defaults; this restores them
CFLAGS ?= -g -O2
FCFLAGS ?= -g -O2

# NOTE: This is being passed to FMS, I don't think we want this
FCFLAGS += -I$(abspath $(DEPS)/fms/build)
LDFLAGS += -L$(abspath $(DEPS)/lib)

# Pass autoconf environment variables to submakes
export CPPFLAGS
export CC
export MPICC
export CFLAGS
export FC
export MPIFC
export FCFLAGS
export LDFLAGS
export LIBS
export PYTHON


# Makefile setup

# Verify that BUILD is not set to the current directory
# (which would clobber this Makefile)
MAKEPATH = $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ifeq ($(MAKEPATH), $(realpath $(BUILD)))
  $(error BUILD cannot be set to the current directory)
endif

# Disable builtin rules and variables
MAKEFLAGS += -rR

#----

.PHONY: all
all: $(BUILD)/MOM6

# NOTE: If libFMS has changed, then we completely rebuild MOM6
$(BUILD)/MOM6: FORCE $(BUILD)/Makefile $(DEPS)/lib/libFMS.a
	if test $(DEPS)/lib/libFMS.a -nt $@ ; then \
	  $(MAKE) -C $(BUILD) clean ; \
	fi
	$(MAKE) -C $(BUILD) MOM6

$(BUILD)/Makefile: $(BUILD)/config.status $(BUILD)/Makefile.in
	cd $(BUILD) && ./config.status

$(BUILD)/config.status: $(BUILD)/configure $(DEPS)/lib/libFMS.a
	cd $(BUILD) && \
	PATH="${PATH}:$(dir $(abspath $(MAKEDEP)))" \
	./configure -n $(CONFIG_FLAGS)

$(BUILD)/Makefile.in: $(MAKEFILE_IN) | $(BUILD)
	cp $(MAKEFILE_IN) $(BUILD)/Makefile.in

$(BUILD)/configure: $(BUILD)/configure.ac $(BUILD)/m4
	autoreconf $(BUILD)

$(BUILD)/configure.ac: $(CONFIGURE_AC) | $(BUILD)
	cp $(CONFIGURE_AC) $(BUILD)/configure.ac

$(BUILD)/m4: $(M4DIR) | $(BUILD)
	cp -r $(M4DIR) $(BUILD)

$(BUILD):
	mkdir -p $@


#----
# Dependencies

$(DEPS)/lib/libFMS.a: FORCE
	$(MAKE) -C $(DEPS) -j

FORCE:


#----
# Cleanup

.PHONY: clean
clean:
	rm -rf $(BUILD)
	$(MAKE) -C $(DEPS) clean

.PHONY: clean.runs
clean.runs: $(foreach e,$(EXPTS),clean.$(e))
