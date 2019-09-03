#-- Copyright (C) 2018 dz <dingzhong110@gmail.com>

module("luci.controller.cupsd", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cupsd") then
		return
	end

	local page

	page = entry({"admin", "services", "cupsd"}, cbi("cupsd"), _("cupsd"), 60)
	page.dependent = true
end
