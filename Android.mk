busybox_local_path := $(call my-dir)
LOCAL_PATH := $(busybox_local_path)
include $(CLEAR_VARS)

KERNEL_MODULES_DIR?=/system/modules/lib/modules

LOCAL_SRC_FILES := $(shell make -s -C $(LOCAL_PATH) show-sources) \
	../clearsilver/util/regex/regex.c \
	libbb/android.c

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/include $(LOCAL_PATH)/libbb \
	external/clearsilver \
	external/clearsilver/util/regex \
	bionic/libc/private \
	libc/kernel/common

LOCAL_CFLAGS := \
	-std=gnu99 \
	-Werror=implicit \
	-DNDEBUG \
	-DANDROID_CHANGES \
	-include include/autoconf.h \
	-D'CONFIG_DEFAULT_MODULES_DIR="$(KERNEL_MODULES_DIR)"' \
	-D'BB_VER="$(strip $(shell make -s -C $(LOCAL_PATH) kernelversion))"' -DBB_BT=AUTOCONF_TIMESTAMP

LOCAL_MODULE := busybox
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)

include $(BUILD_EXECUTABLE)

BUSYBOX_LINKS := $(shell cat $(LOCAL_PATH)/busybox.links)
# nc is provided by external/netcat
exclude := nc
SYMLINKS := $(addprefix $(TARGET_OUT_OPTIONAL_EXECUTABLES)/,$(filter-out $(exclude),$(notdir $(BUSYBOX_LINKS))))
$(SYMLINKS): BUSYBOX_BINARY := $(LOCAL_MODULE)
$(SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Symlink: $@ -> $(BUSYBOX_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(BUSYBOX_BINARY) $@

ALL_DEFAULT_INSTALLED_MODULES += $(SYMLINKS)

# We need this so that the installed files could be picked up based on the
# local module name
ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(SYMLINKS)



# Make a static library for clearsilver's regex. This prevent multiple
# symbol definition error.
LOCAL_PATH := $(busybox_local_path)
include $(CLEAR_VARS)
LOCAL_SRC_FILES := ../clearsilver/util/regex/regex.c
LOCAL_MODULE := libclearsilverregex
LOCAL_C_INCLUDES := \
	external/clearsilver \
	external/clearsilver/util/regex

include $(BUILD_STATIC_LIBRARY)

# Build a static busybox for the recovery image
LOCAL_PATH := $(busybox_local_path)
include $(CLEAR_VARS)

KERNEL_MODULES_DIR?=/system/modules/lib/modules

LOCAL_SRC_FILES := $(shell make -s -C $(LOCAL_PATH) show-sources) \
	libbb/android.c

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/include $(LOCAL_PATH)/libbb \
	external/clearsilver \
	external/clearsilver/util/regex \
	bionic/libc/private \
	libc/kernel/common

LOCAL_CFLAGS := \
	-std=gnu99 \
	-Werror=implicit \
	-DNDEBUG \
	-DANDROID_CHANGES \
	-include include/autoconf.h \
	-D'CONFIG_DEFAULT_MODULES_DIR="$(KERNEL_MODULES_DIR)"' \
	-D'BB_VER="$(strip $(shell make -s -C $(LOCAL_PATH) kernelversion))"' -DBB_BT=AUTOCONF_TIMESTAMP

LOCAL_MODULE := recoverybusybox
LOCAL_MODULE_STEM := busybox
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_STATIC_LIBRARIES += libc libm libclearsilverregex

include $(BUILD_EXECUTABLE)

links := $(shell cat $(LOCAL_PATH)/busybox.links)
recovery_busybox_root := $(call intermediates-dir-for,EXECUTABLES,recoverybusybox)/recovery/root
exclude :=
SYMLINKS := $(addprefix $(recovery_busybox_intermediates)/sbin/,$(filter-out $(exclude),$(notdir $(links))))
$(SYMLINKS): BUSYBOX_BINARY := $(LOCAL_MODULE_STEM)
$(SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Symlink: $@ -> $(BUSYBOX_BINARY)"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(BUSYBOX_BINARY) $@

SHLINK := $(recovery_busybox_root)/system/bin/sh
$(SHLINK): BUSYBOX_BINARY := ../../sbin/$(LOCAL_MODULE_STEM)
$(SHLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Symlink: $@ -> $(BUSYBOX_BINARY)"
	mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf $(BUSYBOX_BINARY) $@

#ALL_DEFAULT_INSTALLED_MODULES += $(SYMLINKS) $(SHLINK)
$(LOCAL_MODULE): $(SYMLINKS)

# We need this so that the installed files could be picked up based on the
# local module name
#ALL_MODULES.$(LOCAL_MODULE).INSTALLED := \
    $(ALL_MODULES.$(LOCAL_MODULE).INSTALLED) $(SYMLINKS) $(SHLINK)
