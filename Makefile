# Build Redis as follows:
# - make               -- create non-SGX no-debug-log manifest
# - make SGX=1         -- create SGX no-debug-log manifest
# - make SGX=1 DEBUG=1 -- create SGX debug-log manifest
#
# Use `make clean` to remove Gramine-generated files

################################# CONSTANTS ###################################
# directory with arch-specific libraries the below path works for Debian/Ubuntu; 
# for CentOS/RHEL/Fedora, you should overwrite this default like this: `ARCH_LIBDIR=/lib64 make`

ARCH_LIBDIR ?= /lib/$(shell $(CC) -dumpmachine)						# directory dove dovrebbero essere le librerie usate dall'app 


ifeq ($(DEBUG),1)
GRAMINE_LOG_LEVEL = debug
else
GRAMINE_LOG_LEVEL = error
endif

.PHONY: all
all: Slicer.manifest
ifeq ($(SGX),1)
all: Slicer.manifest.sgx Slicer.sig 
endif

############################## EXECUTABLE ###############################
# Slicer executable already installed in other location

################################ MANIFEST ###############################
Slicer.manifest: Slicer.manifest.template
	gramine-manifest \
		-Dlog_level=$(GRAMINE_LOG_LEVEL) \
		-Darch_libdir=$(ARCH_LIBDIR) \
		$< > $@

# Manifest for Gramine-SGX requires special "gramine-sgx-sign" procedure. This
# procedure measures all trusted files, adds the measurement to the
# resulting manifest.sgx file (among other, less important SGX options)

# Make on Ubuntu <= 20.04 doesn't support "Rules with Grouped Targets" (`&:`),
# see the helloworld example for details on this workaround.
Slicer.sig Slicer.manifest.sgx: sgx_outputs
	@:

.INTERMEDIATE: sgx_outputs
sgx_outputs: Slicer.manifest $(SRCDIR)/src/Slicer
	gramine-sgx-sign \
		--manifest Slicer.manifest \
		--output Slicer.manifest.sgx



########################### COPIES OF EXECUTABLES #############################
# Copy the executable in our working directory, so copy all the Slicer dirs.
# It is only required the first time or when modifications are made to the content of the root Slicer directories.
Slicer: /home/fitnesslab/Desktop/Slicer
	cp -r $< $@

Slicer-SuperBuild-Debug: /home/fitnesslab/Desktop/Slicer-SuperBuild-Debug
	cp -r $< $@

############################## RUNNING TESTS ##################################
ifeq ($(SGX),)
GRAMINE = gramine-direct
else
GRAMINE = gramine-sgx
endif
################################## CLEANUP ####################################

.PHONY: clean
clean:
	$(RM) -rf *.token *.sig *.manifest.sgx *.manifest Slicer *.rdb

