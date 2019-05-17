include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-openvpn-server
PKG_VERSION:=2.3
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=LuCI
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for OpenVPN Server
  DEPENDS:=+openvpn-openssl +openvpn-easy-rsa-whisky
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
	LuCI support for OpenVPN Server.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/po/zh-cn/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.zh-cn.lmo,$(notdir $(po)));)
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/openvpn) && rm -f /etc/uci-defaults/openvpn
	exit 0
}
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/*.lua $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/openvpn
	$(INSTALL_DATA) ./luasrc/view/openvpn/*.htm $(1)/usr/lib/lua/luci/view/openvpn/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openvpn-server.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./root/etc/config/openvpn $(1)/etc/config/openvpn
	$(INSTALL_DIR) $(1)/etc/easy-rsa
	$(INSTALL_DATA) ./root/etc/easy-rsa/vars $(1)/etc/easy-rsa/vars
	$(INSTALL_DIR) $(1)/etc/openvpn/server
	$(INSTALL_DATA) ./root/etc/openvpn/server/psw-file $(1)/etc/openvpn/server/psw-file
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/openvpn $(1)/etc/uci-defaults/openvpn
	$(INSTALL_BIN) ./root/etc/*.sh $(1)/etc/
	$(INSTALL_DATA) ./root/etc/ovpnadd.conf $(1)/etc/ovpnadd.conf
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./root/etc/hotplug.d/iface/99-vpn0 $(1)/etc/hotplug.d/iface/99-vpn0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
