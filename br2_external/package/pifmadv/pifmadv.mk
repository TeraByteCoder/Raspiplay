################################################################################
#
# pifmadv
#
################################################################################

PIFMADV_VERSION = 878860c6d69899a1c3414b8953c46befc6bcc110
PIFMADV_SITE = $(call github,miegl,PiFmAdv,$(PIFMADV_VERSION))
PIFMADV_LICENSE = GPL-3.0
PIFMADV_LICENSE_FILES = LICENSE.md
PIFMADV_DEPENDENCIES = libsndfile libsoxr

define PIFMADV_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/src app \
		CC="$(TARGET_CC)" \
		TARGET=pi1 \
		CFLAGS="$(TARGET_CFLAGS) -Wall -Wno-multichar -std=gnu99 -c -O2 -march=armv6 -mtune=arm1176jzf-s -mfloat-abi=hard -mfpu=vfp -ffast-math -DRASPI=1" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define PIFMADV_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/pi_fm_adv $(TARGET_DIR)/usr/bin/pifmadv
endef

$(eval $(generic-package))
