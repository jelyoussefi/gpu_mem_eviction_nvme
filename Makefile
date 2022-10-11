#----------------------------------------------------------------------------------------------------------------------
# Flags
#----------------------------------------------------------------------------------------------------------------------
SHELL:=/bin/bash
CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
KERNEL_DIR = ${CURRENT_DIR}/intel-gpu-i915-backports


BASE_KERNEL_NAME=5.14.0-1051


#----------------------------------------------------------------------------------------------------------------------
# Targets
#----------------------------------------------------------------------------------------------------------------------
default: build 
.PHONY:  test

install_prerequisite:
	@$(call msg, Installing Prerequisite  ...)
	@sudo apt install -y dkms make debhelper devscripts build-essential flex bison gawk	

install_kernel_sources:
	@$(call msg, Installing the Kernel source  ...)
	sudo apt install -y linux-headers-${BASE_KERNEL_NAME}-oem linux-image-unsigned-${BASE_KERNEL_NAME}-oem
	
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
	@make -C ${CURRENT_DIR}/test

monitor:
        @$(call msg, Monitoring the system and gpu memories   ...)
        @make -C ${CURRENT_DIR}/gpu_system_memory_monitoring


	
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

