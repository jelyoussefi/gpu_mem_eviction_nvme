#----------------------------------------------------------------------------------------------------------------------
# Flags
#----------------------------------------------------------------------------------------------------------------------
SHELL:=/bin/bash
CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
KERNEL_DIR = ${CURRENT_DIR}/intel-gpu-i915-backports
export TERM=xterm


#----------------------------------------------------------------------------------------------------------------------
# Targets
#----------------------------------------------------------------------------------------------------------------------
default: build 
.PHONY:  


build: 
	@$(call msg, Building the i915 driver  ...)
	@make -C ${KERNEL_DIR} i915dkmsdeb-pkg 
	

install: build
	@$(call msg, Installing the i915 driver   ...)
	@sudo dpkg -i ${CURRENT_DIR}/intel-i915-dkms_*_all.deb || echo 	
	@sudo rmmod  i915 > /dev/null 2>@1 || echo
	@sudo modprobe i915

test:
	@$(call msg, Running gpu memory eviction test   ...)
	
clean:
	@$(call msg, Cleaning   ...)
	@rm -rf intel-i915-dkms*

#----------------------------------------------------------------------------------------------------------------------
# helper functions
#----------------------------------------------------------------------------------------------------------------------
define msg
	tput setaf 2 && \
	for i in $(shell seq 1 120 ); do echo -n "-"; done; echo  "" && \
	echo "         "$1 && \
	for i in $(shell seq 1 120 ); do echo -n "-"; done; echo "" && \
	tput sgr0
endef

