#-- Copyright (C) 2018 dz <dingzhong110@gmail.com>

local sys = require("luci.sys")
local util = require("luci.util")
local fs = require("nixio.fs")

local trport = 631
local button = ""

if luci.sys.call("pidof cupsd >/dev/null") == 0 then
	m = Map("cupsd", translate("cupsd"), "%s - %s" %{translate("cupsd"), translate("<strong><font color=\"green\">Running</font></strong>")})
	button = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\" " .. translate("Open Web Interface") .. " \" onclick=\"window.open('http://'+window.location.hostname+':" .. trport .. "')\"/>"
else
	m = Map("cupsd", translate("cupsd"), "%s - %s" %{translate("cupsd"), translate("<strong><font color=\"red\">Not Running</font></strong>")})
end

-- Basic
s = m:section(TypedSection, "cupsd", translate("Settings"), translate("General Settings") .. button)
s.anonymous = true

---- Eanble
enable = s:option(Flag, "enabled", translate("Enable"), translate("Enable or disable cupsd server"))
enable.default = 0
enable.rmempty = false

return m
