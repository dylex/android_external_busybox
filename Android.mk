LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

SUBMAKE := make -s -C $(LOCAL_PATH) CC=$(CC)
KERNEL_MODULES_DIR?=/system/modules/lib/modules

LOCAL_SRC_FILES := $(shell $(SUBMAKE) show-sources) \
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
	-D'BB_VER="$(strip $(shell $(SUBMAKE) kernelversion))"' -DBB_BT=AUTOCONF_TIMESTAMP

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
include $(CLEAR_VARS)
LOCAL_SRC_FILES := ../clearsilver/util/regex/regex.c
LOCAL_MODULE := libclearsilverregex
LOCAL_C_INCLUDES := \
	external/clearsilver \
	external/clearsilver/util/regex

include $(BUILD_STATIC_LIBRARY)


# Build a static busybox for the recovery image
include $(CLEAR_VARS)

KERNEL_MODULES_DIR?=/system/modules/lib/modules

LOCAL_SRC_FILES := $(shell $(SUBMAKE) show-sources) \
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
	-include sys/cdefs.h \
	-include stdio.h \
	-D'CONFIG_DEFAULT_MODULES_DIR="$(KERNEL_MODULES_DIR)"' \
	-D'BB_VER="$(strip $(shell $(SUBMAKE) kernelversion))"' -DBB_BT=AUTOCONF_TIMESTAMP

LOCAL_CFLAGS += \
  -Dgetmntent=busybox_getmntent \
  -Dgetmntent_r=busybox_getmntent_r

LOCAL_MODULE := libbusybox
LOCAL_STATIC_LIBRARIES += libclearsilverregex libcutils libc libm 
LOCAL_CFLAGS += -Dmain=busybox_driver
include $(BUILD_STATIC_LIBRARY)
