#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=BaiduPCS-Go
PKG_VERSION:=3.7.0
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=LuCI Support for BaiduPCS-Web.
	URL:=https://github.com/liuzhuoling2011/baidupcs-web
endef

define Package/$(PKG_NAME)/description
LuCI Support for BaiduPCS-Web.
endef

ifeq ($(ARCH),x86_64)
	PKG_ARCH_BaiduPCS-Go:=linux-amd64
endif
ifeq ($(ARCH),i386)
	PKG_ARCH_BaiduPCS-Go:=linux-86
endif
ifeq ($(ARCH),mipsel)
	PKG_ARCH_BaiduPCS-Go:=linux-mipsle
endif
ifeq ($(ARCH),arm)
	PKG_ARCH_BaiduPCS-Go:=linux-arm
endif
ifeq ($(ARCH),aarch64)
	PKG_ARCH_BaiduPCS-Go:=linux-amd64
endif

define Build/Prepare
	[ ! -f $(PKG_BUILD_DIR)/BaiduPCS-Go-$(PKG_VERSION)-$(PKG_ARCH_BaiduPCS-Go).zip ] && wget https://github.com/liuzhuoling2011/baidupcs-web/releases/download/$(PKG_VERSION)/BaiduPCS-Go-$(PKG_VERSION)-$(PKG_ARCH_BaiduPCS-Go).zip -O $(PKG_BUILD_DIR)/BaiduPCS-Go-$(PKG_VERSION)-$(PKG_ARCH_BaiduPCS-Go).zip
	unzip -o $(PKG_BUILD_DIR)/BaiduPCS-Go-$(PKG_VERSION)-$(PKG_ARCH_BaiduPCS-Go).zip -d $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	chmod +x $(PKG_BUILD_DIR)/BaiduPCS-Go-$(PKG_VERSION)-$(PKG_ARCH_BaiduPCS-Go)/BaiduPCS-Go
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) -r $(PKG_BUILD_DIR)/BaiduPCS-Go-$(PKG_VERSION)-$(PKG_ARCH_BaiduPCS-Go)/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
