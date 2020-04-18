include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-ssr-plus
PKG_VERSION:=176
PKG_RELEASE:=8-20200418

PKG_CONFIG_DEPENDS:= CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2ray \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_Trojan \
  CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_ipt2socks \
  CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_microsocks \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_Kcptun \
  CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_dns2socks \
  CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_redsocks2 \
  CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_dnscrypt_proxy \
  CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_simple-obfs\
  CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_v2ray-plugin \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Server \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Socks

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/config
config PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks
	bool "Include Shadowsocks New Version"
	default y 
	
config PACKAGE_$(PKG_NAME)_INCLUDE_V2ray
	bool "Include V2ray"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_Trojan
	bool "Include Trojan"
	default y 

config PACKAGE_$(PKG_NAME)_INCLUDE_ipt2socks
	bool "Include ipt2socks"
	default y 

config PACKAGE_$(PKG_NAME)_INCLUDE_microsocks
	bool "Include microsocks"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_Kcptun
	bool "Include Kcptun"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_dns2socks
	bool "Include dns2socks"
	default y 

config PACKAGE_$(PKG_NAME)_INCLUDE_redsocks2
	bool "Include redsocks2"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_dnscrypt_proxy
                 bool "Include dnscrypt-proxy-full"
                 default y

config PACKAGE_$(PKG_NAME)_INCLUDE_simple-obfs
	bool "Include simple-obfsl"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_v2ray-plugin
	bool "Include v2ray-plugin"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Server
	bool "Include ShadowsocksR Server"
	default y 
	
config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Socks
	bool "Include ShadowsocksR Socks and Tunnel"
	default y 
endef

define Package/luci-app-ssr-plus
 	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=A New SS/SSR/V2Ray/Trojan/Socks5  LuCI interface
	PKGARCH:=all
	DEPENDS:=+shadowsocksr-libev-alt +ipset +ip-full +iptables-mod-tproxy +dnsmasq-full +tcpping +coreutils +coreutils-base64 +bash +pdnsd-alt +wget +luasocket +jshn +lua   +curl \
            +PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks:shadowsocks-libev-ss-redir \
            +PACKAGE_$(PKG_NAME)_INCLUDE_V2ray:v2ray \
            +PACKAGE_$(PKG_NAME)_INCLUDE_Trojan:trojan \
            +PACKAGE_$(PKG_NAME)_INCLUDE_ipt2socks:ipt2socks \
            +PACKAGE_$(PKG_NAME)_INCLUDE_microsocks:microsocks \
            +PACKAGE_$(PKG_NAME)_INCLUDE_Kcptun:kcptun-client \
            +PACKAGE_$(PKG_NAME)_INCLUDE_dns2socks:dns2socks \
            +PACKAGE_$(PKG_NAME)_INCLUDE_redsocks2:redsocks2 \
            +PACKAGE_$(PKG_NAME)_INCLUDE_dnscrypt_proxy:dnscrypt-proxy-full \
            +PACKAGE_$(PKG_NAME)_INCLUDE_simple-obfs:simple-obfs \
            +PACKAGE_$(PKG_NAME)_INCLUDE_v2ray-plugin:v2ray-plugin \
            +PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Server:shadowsocksr-libev-server \
            +PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR_Socks:shadowsocksr-libev-ssr-local
endef

define Build/Prepare
endef

define Build/Compile
endef



define Package/luci-app-ssr-plus/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/ssr-plus.po $(1)/usr/lib/lua/luci/i18n/ssr-plus.zh-cn.lmo
endef

define Package/luci-app-ssr-plus/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-ssr-plus ) && rm -f /etc/uci-defaults/luci-ssr-plus
	rm -f /tmp/luci-indexcache
	chmod 755 /etc/init.d/shadowsocksr >/dev/null 2>&1
	/etc/init.d/vssr enable >/dev/null 2>&1
fi
exit 0
endef

define Package/luci-app-ssr-plus/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
     /etc/init.d/shadowsocksr disable
     /etc/init.d/shadowsocksr stop
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-ssr-plus))


