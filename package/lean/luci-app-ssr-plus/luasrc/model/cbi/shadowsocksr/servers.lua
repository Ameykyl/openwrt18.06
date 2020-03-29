-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocksr = "shadowsocksr"

local uci = luci.model.uci.cursor()
local server_count = 0
uci:foreach("shadowsocksr", "servers", function(s)
  server_count = server_count + 1
end)

local fs  = require "nixio.fs"
local sys = require "luci.sys"

local ucic = luci.model.uci.cursor()

m = Map(shadowsocksr,  translate("Node List"))
m:section(SimpleSection).template  = "shadowsocksr/status2"


-- [[ Servers Manage ]]--
s = m:section(TypedSection, "servers")
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.sortable = true
s.description = string.format(translate("Server Count") ..  ": %d", server_count)
s.extedit = luci.dispatcher.build_url("admin/vpn/shadowsocksr/servers/%s")
function s.create(...)
	local sid = TypedSection.create(...)
	if sid then
		luci.http.redirect(s.extedit % sid)
	return
	end
end

o = s:option(DummyValue, "type", translate("Type"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or ""
end

o = s:option(DummyValue, "alias", translate("Alias"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or translate("None")
end

o = s:option(DummyValue, "server_port", translate("Server Port"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "N/A"
end

o = s:option(DummyValue, "server_port", translate("Socket Connected"))
o.template="shadowsocksr/socket"
o.width="10%"

o = s:option(DummyValue, "server", translate("Ping Latency"))
o.template="shadowsocksr/ping"
o.width="10%"


node = s:option(Button,"apply_node",translate("Apply"))
node.inputstyle = "apply"
node.write = function(self, section)
  ucic:set("shadowsocksr", '@global[0]', 'global_server', section)
  ucic:save("shadowsocksr") 
  ucic:commit("shadowsocksr")
  luci.sys.exec("/etc/init.d/shadowsocksr restart")
  luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "shadowsocksr", "client"))
end

o = s:option(Flag, "switch_enable", translate("Auto Switch"))
o.rmempty = false
function o.cfgvalue(...)
	return Value.cfgvalue(...) or 1
end

m:append(Template("shadowsocksr/server_list"))

return m