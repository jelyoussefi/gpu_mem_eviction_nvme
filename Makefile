#----------------------------------------------------------------------------------------------------------------------
# Flags
#----------------------------------------------------------------------------------------------------------------------
SHELL:=/bin/bash
CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
KERNEL_DIR = ${CURRENT_DIR}/intel-gpu-i915-backports


BASE_KERNEL_NAME=5.3.18-150300.59.81


#----------------------------------------------------------------------------------------------------------------------
# Targets
#----------------------------------------------------------------------------------------------------------------------
default: build 
.PHONY:  test

install_prerequisite:
	@$(call msg, Installing Prerequisite  ...)
	@sudo zypper install dkms make linux-glibc-devel lsb-release rpm-build	

install_kernel_sources:
	@$(call msg, Installing the Kernel source  ...)
	sudo zypper ref -s && \
	sudo zypper install -y kernel-default-${BASE_KERNEL_VERSION} kernel-syms-${BASE_KERNEL_VERSION}

	
build: 
	@$(call msg, Building the i915 driver  ...)
	@make -C ${KERNEL_DIR} make dkmsrpm-pkg
	

install: build
	@$(call msg, Installing the i915 driver   ...)
	@cd ${HOME}/rpmbuild/RPMS/x86_64 && \
		sudo rpm -ivh intel-dmabuf-dkms*.rpm intel-i915-dkms*.rpm
	@sudo rmmod  i915 || echo
	@sudo modprobe i915 enable_eviction=3 nvme_partition_path=/data/nvme_swap/

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

