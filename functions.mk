include $(JML_TOP)/gmsl/gmsl

dollars=$$

SHELL := /bin/bash

ifeq ($(TERM),xterm)

ESC :=

COLOR_GREEN :=$(ESC)[32m
COLOR_RED :=$(ESC)[31m
COLOR_RESET := $(ESC)[0m

endif

# Command to hash the name of a command.
hash_command = $(wordlist 1,1,$(shell echo $(strip $(1)) | md5sum))

# arg 1: names
define include_sub_makes
$$(foreach name,$(1),$$(eval $$(call include_sub_make,$$(name))))
endef

# arg 1: name
# arg 2: dir (optional, is the same as $(1) if not given)
# arg 3: makefile (optional, is $(2)/$(1).mk if not given)
define include_sub_make
$(if $(trace3),$$(warning called include_sub_make "$(1)" "$(2)" "$(3)" CWD=$(CWD)))
DIRNAME:=$(if $(2),$(2),$(1))
MAKEFILE:=$(if $(3),$(3),$(1).mk)
$$(call push,DIRS,$$(call peek,DIRS)$$(if $$(call peek,DIRS),/,)$$(DIRNAME))
CWD:=$$(call peek,DIRS)
$$(call push,MKPATH,$(1))
CURRENT:=$$(subst _testing,,$(1))
#CURRENT_TEST_TARGETS:=$$(if $$(findstring,xtestingx,$(1)),$$(CURRENT_TEST_TARGETS),$$(CURRENT_TEST_TARGETS $(1)_test))
include $$(if $$(CWD),$$(CWD)/,)/$$(MAKEFILE)
$$(CWD_NAME)_SRC :=	$(SRC)/$$(CWD)
$$(CWD_NAME)_OBJ :=	$(OBJ)/$$(CWD)
#$$(warning stack contains $(__gmsl_stack_DIRS))
CWD:=$$(call pop,DIRS)
CURRENT:=$$(call pop,MKPATH)
CURRENT_TEST_TARGETS := 
endef

# add a c++ source file
# $(1): filename of source file
# $(2): basename of the filename
# $(3): directory under which the source lives; default $(SRC)
# $(4): extra compiler options

define add_c++_source

$$(eval tmpDIR := $$(if $(3),$(3),$(SRC)))

$(if $(trace),$$(warning called add_c++_source "$(1)" "$(2)" "$(3)" "$(4)"))
BUILD_$(CWD)/$(2).lo_COMMAND:=$$(CXX) $$(CXXFLAGS) -o $(OBJ)/$(CWD)/$(2).lo -c $$(tmpDIR)/$(CWD)/$(1) -MP -MMD -MF $(OBJ)/$(CWD)/$(2).d -MQ $(OBJ)/$(CWD)/$(2).lo $$(OPTIONS_$(CWD)/$(1)) $(4) $(if $(findstring $(strip $(1)),$(DEBUG_FILES)),$(warning compiling $(1) for debug)$$(CXXDEBUGFLAGS))
$(if $(trace),$$(warning BUILD_$(CWD)/$(2).lo_COMMAND := "$$(BUILD_$(CWD)/$(2).lo_COMMAND)"))

BUILD_$(CWD)/$(2).lo_HASH := $$(call hash_command,$$(BUILD_$(CWD)/$(2).lo_COMMAND))
BUILD_$(CWD)/$(2).lo_OBJ  := $$(OBJ)/$(CWD)/$(2).$$(BUILD_$(CWD)/$(2).lo_HASH).lo

BUILD_$(CWD)/$(2).lo_COMMAND2 := $$(subst $(OBJ)/$(CWD)/$(2).lo,$$(BUILD_$(CWD)/$(2).lo_OBJ),$$(BUILD_$(CWD)/$(2).lo_COMMAND))

$(OBJ)/$(CWD)/$(2).d:
$$(BUILD_$(CWD)/$(2).lo_OBJ):	$$(tmpDIR)/$(CWD)/$(1) $(OBJ)/$(CWD)/.dir_exists
	$$(if $(verbose_build),@echo $$(BUILD_$(CWD)/$(2).lo_COMMAND2),@echo "[C++] $(CWD)/$(1)")
	@$$(BUILD_$(CWD)/$(2).lo_COMMAND2) || (echo "FAILED += $$@" >> .target.mk && false)
	@if [ -f $(2).d ] ; then mv $(2).d $(OBJ)/$(CWD)/$(2).d; fi

-include $(OBJ)/$(CWD)/$(2).d
endef

# add a c source file
# $(1): filename of source file
# $(2): basename of the filename
# $(3): directory under which the source lives; default $(SRC)
# $(4): extra compiler options

define add_c_source

$$(eval tmpDIR := $$(if $(3),$(3),$(SRC)))

$(if $(trace),$$(warning called add_c_source "$(1)" "$(2)" "$(3)" "$(4)"))
BUILD_$(CWD)/$(2).lo_COMMAND:=$$(CC) $$(CFLAGS) -o $(OBJ)/$(CWD)/$(2).lo -c $$(tmpDIR)/$(CWD)/$(1) -MP -MMD -MF $(OBJ)/$(CWD)/$(2).d -MQ $(OBJ)/$(CWD)/$(2).lo $$(OPTIONS_$(CWD)/$(1)) $(4) $(if $(findstring $(strip $(1)),$(DEBUG_FILES)),$(warning compiling $(1) for debug)$$(CDEBUGFLAGS))
$(if $(trace),$$(warning BUILD_$(CWD)/$(2).lo_COMMAND := "$$(BUILD_$(CWD)/$(2).lo_COMMAND)"))

BUILD_$(CWD)/$(2).lo_HASH := $$(call hash_command,$$(BUILD_$(CWD)/$(2).lo_COMMAND))
BUILD_$(CWD)/$(2).lo_OBJ  := $$(OBJ)/$(CWD)/$(2).$$(BUILD_$(CWD)/$(2).lo_HASH).lo

BUILD_$(CWD)/$(2).lo_COMMAND2 := $$(subst $(OBJ)/$(CWD)/$(2).lo,$$(BUILD_$(CWD)/$(2).lo_OBJ),$$(BUILD_$(CWD)/$(2).lo_COMMAND))

$(OBJ)/$(CWD)/$(2).d:
$$(BUILD_$(CWD)/$(2).lo_OBJ):	$$(tmpDIR)/$(CWD)/$(1) $(OBJ)/$(CWD)/.dir_exists
	$$(if $(verbose_build),@echo $$(BUILD_$(CWD)/$(2).lo_COMMAND2),@echo "[C] $(CWD)/$(1)")
	@$$(BUILD_$(CWD)/$(2).lo_COMMAND2) || (echo "FAILED += $$@" >> .target.mk && false)
	@if [ -f $(2).d ] ; then mv $(2).d $(OBJ)/$(CWD)/$(2).d; fi

-include $(OBJ)/$(CWD)/$(2).d
endef

# add a fortran source file
define add_fortran_source
$(if $(trace),$$(warning called add_fortran_source "$(1)" "$(2)"))
BUILD_$(CWD)/$(2).lo_COMMAND:=$(FC) $(FFLAGS) -o $(OBJ)/$(CWD)/$(2).lo -c $(SRC)/$(CWD)/$(1)
$(if $(trace),$$(warning BUILD_$(CWD)/$(2).lo_COMMAND := "$$(BUILD_$(CWD)/$(2).lo_COMMAND)"))

BUILD_$(CWD)/$(2).lo_HASH := $$(call hash_command,$$(BUILD_$(CWD)/$(2).lo_COMMAND))
BUILD_$(CWD)/$(2).lo_OBJ  := $$(OBJ)/$(CWD)/$(2).$$(BUILD_$(CWD)/$(2).lo_HASH).lo

BUILD_$(CWD)/$(2).lo_COMMAND2 := $$(subst $(OBJ)/$(CWD)/$(2).lo,$$(BUILD_$(CWD)/$(2).lo_OBJ),$$(BUILD_$(CWD)/$(2).lo_COMMAND))


$(OBJ)/$(CWD)/$(2).d:
$$(BUILD_$(CWD)/$(2).lo_OBJ):	$(SRC)/$(CWD)/$(1) $(OBJ)/$(CWD)/.dir_exists
	$$(if $(verbose_build),@echo $$(BUILD_$(CWD)/$(2).lo_COMMAND2),@echo "[FORTRAN] $(CWD)/$(1)")
	@$$(BUILD_$(CWD)/$(2).lo_COMMAND2) || (echo "FAILED += $$@" >> .target.mk && false)

endef

define add_cuda_source
$(if $(trace),$$(warning called add_cuda_source "$(1)" "$(2)"))
$(OBJ)/$(CWD)/$(2).d: $(SRC)/$(CWD)/$(1) $(OBJ)/$(CWD)/.dir_exists
	($(NVCC) $(NVCCFLAGS) -D__CUDACC__ -M $$< | awk 'NR == 1 { print "$$(BUILD_$(CWD)/$(2).lo_OBJ)", "$$@", ":", $$$$3, "\\"; next; } /usr/ { next; } /\/ \\$$$$/ { next; } { files[$$$$1] = 1; print; } END { print("\n"); for (file in files) { printf("%s: \n\n", file); } }') > $$@~
	mv $$@~ $$@

BUILD_$(CWD)/$(2).lo_COMMAND:=$(NVCC) $(NVCCFLAGS) -c -o $(OBJ)/$(CWD)/$(2).lo --verbose $(SRC)/$(CWD)/$(1)
$(if $(trace),$$(warning BUILD_$(CWD)/$(2).lo_COMMAND := "$$(BUILD_$(CWD)/$(2).lo_COMMAND)"))

BUILD_$(CWD)/$(2).lo_HASH := $$(call hash_command,$$(BUILD_$(CWD)/$(2).lo_COMMAND))
BUILD_$(CWD)/$(2).lo_OBJ  := $$(OBJ)/$(CWD)/$(2).$$(BUILD_$(CWD)/$(2).lo_HASH).lo

BUILD_$(CWD)/$(2).lo_COMMAND2 := $$(subst $(OBJ)/$(CWD)/$(2).lo,$$(BUILD_$(CWD)/$(2).lo_OBJ),$$(BUILD_$(CWD)/$(2).lo_COMMAND))


$$(BUILD_$(CWD)/$(2).lo_OBJ):	$(SRC)/$(CWD)/$(1) $(OBJ)/$(CWD)/.dir_exists
	$$(if $(verbose_build),@echo $$(BUILD_$(CWD)/$(2).lo_COMMAND2),@echo "[CUDA] $(CWD)/$(1)")
	@$$(BUILD_$(CWD)/$(2).lo_COMMAND2) || (echo "FAILED += $$@" >> .target.mk && false)


-include $(OBJ)/$(CWD)/$(2).d
endef

# Set up the map to map an extension to the name of a function to call
$(call set,EXT_FUNCTIONS,.cc,add_c++_source)
$(call set,EXT_FUNCTIONS,.c,add_c_source)
$(call set,EXT_FUNCTIONS,.f,add_fortran_source)
$(call set,EXT_FUNCTIONS,.cu,add_cuda_source)
$(call set,EXT_FUNCTIONS,.i,add_swig_source)

# add a single source file
# $(1): filename
# $(2): suffix of the filename
define add_source
$$(if $(trace),$$(warning called add_source "$(1)" "$(2)"))
$$(if $$(ADDED_SOURCE_$(CWD)_$(1)),,\
    $$(if $$(call defined,EXT_FUNCTIONS,$(2)),\
	$$(eval $$(call $$(call get,EXT_FUNCTIONS,$(2)),$(1),$$(basename $(1))))\
	    $$(eval ADDED_SOURCE_$(CWD)_$(1):=$(true)),\
	$$(error Extension "$(2)" is not known adding source file $(1))))
endef


# add a list of source files
# $(1): list of filenames
define add_sources
$$(if $(trace),$$(warning called add_sources "$(1)"))
$$(foreach file,$$(strip $(1)),$$(eval $$(call add_source,$$(file),$$(suffix $$(file)))))
endef

# set compile options for a single source file
# $(1): filename
# $(2): compile option
define set_single_compile_option
OPTIONS_$(CWD)/$(1) += $(2)
#$$(warning setting OPTIONS_$(CWD)/$(1) += $(2))
endef

# set compile options for a given list of source files
# $(1): list of filenames
# $(2): compile option
define set_compile_option
$$(foreach file,$(1),$$(eval $$(call set_single_compile_option,$$(file),$(2))))
endef

# add a library
# $(1): name of the library
# $(2): source files to include in the library
# $(3): libraries to link with
# $(4): output name; default lib$(1)
# $(5): output extension; default .so
# $(6): build name; default SO

define library
$$(if $(trace),$$(warning called library "$(1)" "$(2)" "$(3)"))
$$(eval $$(call add_sources,$(2)))

$$(eval tmpLIBNAME := $(if $(4),$(4),lib$(1)))
$$(eval so := $(if $(5),$(5),.so))

LIB_$(1)_BUILD_NAME := $(if $(6),$(6),[SO])

OBJFILES_$(1):=$$(foreach file,$(addsuffix .lo,$(basename $(2:%=$(CWD)/%))),$$(BUILD_$$(file)_OBJ))

LINK_$(1)_COMMAND:=$$(CXX) $$(CXXFLAGS) $$(CXXLIBRARYFLAGS) -o $(BIN)/$$(tmpLIBNAME)$$(so) $$(OBJFILES_$(1)) $$(foreach lib,$(3), -l$$(lib))

LINK_$(1)_HASH := $$(call hash_command,$$(LINK_$(1)_COMMAND))
LIB_$(1)_SO   := $(BIN)/$$(tmpLIBNAME).$$(LINK_$(1)_HASH)$$(so)

LIB_$(1)_CURRENT_VERSION := $$(shell cat $(BIN)/$$(tmpLIBNAME)$$(so).version 2>/dev/null)

# We need the library so names to stay the same, so we copy the correct one
# into our version
$(BIN)/$$(tmpLIBNAME)$$(so): $$(LIB_$(1)_SO) $$(if $$(findstring $$(LINK_$(1)_HASH),$$(LIB_$(1)_CURRENT_VERSION)),,redo)
	$$(if $$(findstring,redo,$$^),$$(warning $(1) version mismatch (relink required): current $$(LIB_$(1)_CURRENT_VERSION) required: $$(LINK_$(1)_HASH)))
	@cp $$< $$@
	@echo $$(LINK_$(1)_HASH) > $$@.version

redo:
.PHONY: redo

LINK_$(1)_COMMAND2 := $$(subst $(BIN)/$$(tmpLIBNAME)$$(so),$$(LIB_$(1)_SO),$$(LINK_$(1)_COMMAND))

LIB_$(1)_FILENAME := $$(tmpLIBNAME)$$(so)

$$(LIB_$(1)_SO):	$(BIN)/.dir_exists $$(OBJFILES_$(1)) $$(foreach lib,$(3),$$(LIB_$$(lib)_DEPS))
	$$(if $(verbose_build),@echo $$(LINK_$(1)_COMMAND2),@echo $$(LIB_$(1)_BUILD_NAME) $$(LIB_$(1)_FILENAME))
	@$$(LINK_$(1)_COMMAND2) || (echo "FAILED += $$@" >> .target.mk && false)

LIB_$(1)_DEPS := $(BIN)/$$(tmpLIBNAME)$$(so)

libraries: $(BIN)/$$(tmpLIBNAME)$$(so)

endef


# add a program
# $(1): name of the program
# $(2): libraries to link with
# $(3): name of files to include in the program.  If not included or empty,
#       $(1).cc assumed
# $(4): list of targets to add this program to
define program
$$(if $(trace4),$$(warning called program "$(1)" "$(2)" "$(3)"))

$(1)_PROGFILES:=$$(if $(3),$(3),$(1:%=%.cc))

$$(eval $$(call add_sources,$$($(1)_PROGFILES)))

#$$(warning $(1)_PROGFILES = $$($(1)_PROGFILES))

$(1)_OBJFILES:=$$(foreach file,$$(addsuffix .lo,$$(basename $$($(1)_PROGFILES:%=$(CWD)/%))),$$(BUILD_$$(file)_OBJ))

#$$(warning $(1)_OBJFILES = $$($(1)_OBJFILES))
#$$(warning $(1)_PROGFILES = "$$($(1)_PROGFILES)")

LINK_$(1)_COMMAND:=$$(CXX) $$(CXXFLAGS) $$(CXXEXEFLAGS) -o $(BIN)/$(1) -lexception_hook -ldl $$(foreach lib,$(2), -l$$(lib)) $$($(1)_OBJFILES) $$(CXXEXEPOSTFLAGS)


$(BIN)/$(1):	$(BIN)/.dir_exists $$($(1)_OBJFILES) $$(foreach lib,$(2),$$(LIB_$$(lib)_DEPS)) $$(if $$(HAS_EXCEPTION_HOOK),$$(BIN)/libexception_hook.so)
	$$(if $(verbose_build),@echo $$(LINK_$(1)_COMMAND),@echo "[BIN] $(1)")
	@$$(LINK_$(1)_COMMAND)

$$(foreach target,$(4) programs,$$(eval $$(target): $(BIN)/$(1)))

$(1): $(BIN)/$(1)
.PHONY:	$(1)

run_$(1): $(BIN)/$(1)
	$(BIN)/$(1) $($(1)_ARGS)

endef

# Options to go before a testing command for a test
# $(1): the options
TEST_PRE_OPTIONS_ = $(w arning TEST_PRE_OPTIONS $(1))$(if $(findstring timed,$(1)),/usr/bin/time )$(if $(findstring valgrind,$(1)),$(VALGRIND) $(VALGRINDFLAGS) )

TEST_PRE_OPTIONS = $(w arning TEST_PRE_OPTIONS $(1) returned $(c all TEST_PRE_OPTIONS_,$(1)))$(call TEST_PRE_OPTIONS_,$(1))

# Build the command for a test
# $(1): the name of the test
# $(2): the command to run
# $(3): the test options
BUILD_TEST_COMMAND = rm -f $(TESTS)/$(1).{passed,failed} && ((set -o pipefail && $(call TEST_PRE_OPTIONS,$(3))$(2) > $(TESTS)/$(1).running 2>&1 && mv $(TESTS)/$(1).running $(TESTS)/$(1).passed) || (mv $(TESTS)/$(1).running $(TESTS)/$(1).failed && echo "           $(1) FAILED" && cat $(TESTS)/$(1).failed && false))


# add a test case
# $(1) name of the test
# $(2) libraries to link with
# $(3) test style.  boost = boost test framework, and options: manual, valgrind
# $(4) testing targets to add it to

define test
$$(if $(trace),$$(warning called test "$(1)" "$(2)" "$(3)"))

$$(if $(3),,$$(error test $(1) needs to define a test style))

$$(eval $$(call add_sources,$(1).cc))

$(1)_OBJFILES:=$$(BUILD_$(CWD)/$(1).lo_OBJ)

LINK_$(1)_COMMAND:=$$(CXX) $$(CXXFLAGS) $$(CXXEXEFLAGS) -o $(TESTS)/$(1) -lexception_hook -ldl $$(foreach lib,$(2), -l$$(lib)) $$($(1)_OBJFILES) $(if $(findstring boost,$(3)), -lboost_unit_test_framework-mt)

$(TESTS)/$(1):	$(TESTS)/.dir_exists  $$($(1)_OBJFILES) $$(foreach lib,$(2),$$(LIB_$$(lib)_DEPS)) $$(if $$(HAS_EXCEPTION_HOOK),$$(BIN)/libexception_hook.so)
	$$(if $(verbose_build),@echo $$(LINK_$(1)_COMMAND),@echo "[BIN] $(1)")
	@$$(LINK_$(1)_COMMAND)

tests:	$(TESTS)/$(1)
$$(CURRENT)_tests: $(TESTS)/$(1)

TEST_$(1)_COMMAND := rm -f $(TESTS)/$(1).{passed,failed} && ((set -o pipefail && $(call TEST_PRE_OPTIONS,$(3))$(TESTS)/$(1) $(TESTS)/$(1) > $(TESTS)/$(1).running 2>&1 && mv $(TESTS)/$(1).running $(TESTS)/$(1).passed) || (mv $(TESTS)/$(1).running $(TESTS)/$(1).failed && echo "           $(COLOR_RED)$(1) FAILED$(COLOR_RESET)" && cat $(TESTS)/$(1).failed && echo "           $(COLOR_RED)$(1) FAILED$(COLOR_RESET)" && false))

$(TESTS)/$(1).passed:	$(TESTS)/$(1)
	$$(if $(verbose_build),@echo '$$(TEST_$(1)_COMMAND)',@echo "[TESTCASE] $(1)")
	@$$(TEST_$(1)_COMMAND)
	$$(if $(verbose_build),@echo '$$(TEST_$(1)_COMMAND)',@echo "           $(COLOR_GREEN)$(1) passed$(COLOR_RESET)")

$(1):	$(TESTS)/$(1)
	$(call TEST_PRE_OPTIONS,$(3))$(TESTS)/$(1)

.PHONY: $(1)

#$$(warning $(1) $$(CURRENT))

$(if $(findstring manual,$(3)),,test $(CURRENT_TEST_TARGETS) $$(CURRENT)_test) $(4):	$(TESTS)/$(1).passed

endef


compile: programs libraries tests