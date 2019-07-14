#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1
PKG_RELEASE:=2019.06.21

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=smartdns
	DEPENDS:=
	URL:=smartdns
endef

define Package/$(PKG_NAME)/description
smartdns
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/config/smartdns $(1)/etc/config/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DATA) ./files/init.d/* $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/smartdns
	$(INSTALL_DATA) ./files/smartdns/* $(1)/etc/smartdns/

ifeq ($(ARCH),mipsel)
	$(INSTALL_BIN) ./files/7620n/smartdns $(1)/usr/sbin/
endif
ifeq ($(ARCH),mips)
	$(INSTALL_BIN) ./files/ar71xx/smartdns $(1)/usr/sbin/
endif
ifeq ($(ARCH),i386)
	$(INSTALL_BIN) ./files/x86/smartdns $(1)/usr/sbin/
endif
ifeq ($(ARCH),x86_64)
	$(INSTALL_BIN) ./files/x86_64/smartdns $(1)/usr/sbin/
endif
ifeq ($(ARCH),arm)
	$(INSTALL_BIN) ./files/arm/smartdns $(1)/usr/sbin/
endif
ifeq ($(ARCH),aarch64)
	$(INSTALL_BIN) ./files/armv7/smartdns $(1)/usr/sbin/
endif
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
