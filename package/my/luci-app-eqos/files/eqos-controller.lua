module("luci.controller.eqos", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/eqos") then
		return
	end
	
	local page

	entry({"admin","QOS"}, firstchild(), "QOS", 87).dependent = false
	page = entry({"admin", "QOS", "eqos"}, cbi("eqos"), "EQoS")
	page.dependent = true
end
