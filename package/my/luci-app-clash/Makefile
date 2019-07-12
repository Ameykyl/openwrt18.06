# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for clash
LUCI_DEPENDS:=+clash +pdnsd-alt +bash +coreutils-nohup +wget
PKG_VERSION:=0.22.0
PKG_RELEASE:=0

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
