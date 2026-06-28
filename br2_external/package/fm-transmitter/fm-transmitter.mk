################################################################################
#
# fm-transmitter
#
################################################################################

FM_TRANSMITTER_VERSION = 322500ed9cbe6252a640e566a68596215b9a3ba5
FM_TRANSMITTER_SITE = $(call github,markondej,fm_transmitter,$(FM_TRANSMITTER_VERSION))
FM_TRANSMITTER_LICENSE = GPL-3.0

define FM_TRANSMITTER_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall -O3 -march=armv6 -mtune=arm1176jzf-s -mfloat-abi=hard -mfpu=vfp"
endef

define FM_TRANSMITTER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/fm_transmitter $(TARGET_DIR)/usr/bin/fm_transmitter
endef

$(eval $(generic-package))
