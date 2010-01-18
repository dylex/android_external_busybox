LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

# piggy-back on the normal makefile
# ideally these things would be moved outside the source directory
#
gen := $(LOCAL_PATH)/include/autoconf.h $(LOCAL_PATH)/include/bbconfigopts.h $(LOCAL_PATH)/include/applet_tables.h
LOCAL_GENERATED_SOURCES += $(gen)
$(gen):
	make -C $(LOCAL_PATH) prepare

links := $(LOCAL_PATH)/busybox.links
LOCAL_GENERATED_SOURCES += $(links)
$(links):
	make -C $(LOCAL_PATH) busybox.links

LOCAL_SRC_FILES := $(shell make -s -C $(LOCAL_PATH) show-sources) \
	../clearsilver/util/regex/regex.c \
	libbb/android.c

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/include $(LOCAL_PATH)/libbb \
	external/clearsilver \
	external/clearsilver/util/regex

LOCAL_CFLAGS := \
	-Werror=implicit \
	-DNDEBUG \
	-include include/autoconf.h \
	-D'BB_VER="$(strip $(shell make -s -C $(LOCAL_PATH) kernelversion))"' -DBB_BT=AUTOCONF_TIMESTAMP

LOCAL_MODULE := busybox
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)

include $(BUILD_EXECUTABLE)

SYMLINKS := $(addprefix $(TARGET_OUT_OPTIONAL_EXECUTABLES)/,$(notdir $(shell cat $(LOCAL_PATH)/busybox.links)))
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
