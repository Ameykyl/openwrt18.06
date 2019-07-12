define Package/docker-binary-common/default
  SECTION:=base
  CATEGORY:=Container
  TITLE:=Docker Daemon (binary)
  URL:=https://docs.docker.com/install/
  DEPENDS:=+ca-certificates +kmod-veth +ip-full
endef

define Package/docker-binary-common/description
	Docker daemon (pre-compiled static binary)
endef

define Package/docker-common/conffiles
	/etc/docker/daemon.json
	/etc/config/docker
endef

define Package/docker-common/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/runc $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ctr $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/docker $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dockerd $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/containerd-shim $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/docker-init $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/containerd $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/docker-proxy $(1)/usr/sbin
endef

define Package/docker-binary-common/install
	$(call Package/docker-common/install,$(1))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ../docker/files/dockerd.init $(1)/etc/init.d/docker
	$(INSTALL_DIR) $(1)/etc/config
	$(CP)	../docker/files/dockerd.config $(1)/etc/config/docker
endef
