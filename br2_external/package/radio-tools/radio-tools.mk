################################################################################
#
# radio-tools
#
################################################################################

RADIO_TOOLS_VERSION = 1.0
RADIO_TOOLS_SITE = $(BR2_EXTERNAL_RASPIPLAY_PATH)/package/radio-tools/src
RADIO_TOOLS_SITE_METHOD = local

define RADIO_TOOLS_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-o $(@D)/radio-pcm-half $(@D)/radio-pcm-half.c
endef

define RADIO_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/radio-pcm-half \
		$(TARGET_DIR)/usr/bin/radio-pcm-half
endef

$(eval $(generic-package))
