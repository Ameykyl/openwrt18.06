local m,s,o
local SYS  = require "luci.sys"
local trport = 3333
local button = ""
local version = "4.14.131"

if luci.sys.call("pidof AdGuardHome >/dev/null") == 0 then
	button = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\" " .. translate("Open Web Interface") .. " \" onclick=\"window.open('http://'+window.location.hostname+':" .. trport .. "')\"/>"
end

m = Map("flowoffload")
m.title	= translate("Turbo ACC Acceleration Settings")
m.description = translate("Opensource Linux Flow Offload driver (Fast Path or HWNAT)")
m:append(Template("flow/status"))

s = m:section(TypedSection, "flow")
s.addremove = false
s.anonymous = true

flow = s:option(Flag, "flow_offloading", translate("Enable"))
flow.default = 0
flow.rmempty = false
flow.description = translate("Enable software flow offloading for connections. (decrease cpu load / increase routing throughput)")

hw = s:option(Flag, "flow_offloading_hw", translate("HWNAT"))
hw.default = 0
hw.rmempty = true
hw.description = translate("Enable Hardware NAT (depends on hw capability like MTK 762x)")
hw:depends("flow_offloading", 1)

bbr = s:option(ListValue, "bbr", translate("TCP Congestion Control Algorithm"))
bbr:value("default", translate("default"))
bbr:value("bbr", translate("BBR"))
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_bbr_mod.ko") then
bbr:value("tcp_bbr_mod", translate("BBR_mod"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_bbr_bbrplus.ko") then
bbr:value("tcp_bbr_bbrplus", translate("bbr_bbrplus"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_bbr_tsunami.ko") then
bbr:value("tcp_bbr_tsunami", translate("bbr_tsunami"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_bbr_nanqinlang.ko") then
bbr:value("nanqinlang", translate("bbr_nanqinlang"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_bic.ko") then
bbr:value("bic", translate("bic"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_highspeed.ko") then
bbr:value("highspeed", translate("hstcp"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_htcp.ko") then
bbr:value("htcp", translate("htcp"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_hybla.ko") then
bbr:value("hybla", translate("hybla"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_illinois.ko") then
bbr:value("illinois", translate("illinois"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_lp.ko") then
bbr:value("lp", translate("lp"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_scalable.ko") then
bbr:value("scalable", translate("scalable"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_veno.ko") then
bbr:value("vegas", translate("veno"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_vegas.ko") then
bbr:value("vegas", translate("vegas"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_westwood.ko") then
bbr:value("westwood", translate("westwood"))
end
if nixio.fs.access("/lib/modules/" .. version .. "/tcp_yeah.ko") then
bbr:value("yeah", translate("yeah"))
end
bbr.default = "cubic"
bbr.rmempty = false
bbr.description = translate("Bottleneck Bandwidth and Round-trip propagation time (BBR)")

o = s:option(Flag, "free_memory", translate("Automatic Free Memory"))
o.default = 0
o.rmempty = false

aaaa = s:option(Flag, "filter_aaaa", translate("Filter AAAA"))
aaaa.default = 0
aaaa.rmempty = false
aaaa.description = translate("Dnsmasq rejects IPv6 parsing and optimizes domestic complex dual-stack network")

dns = s:option(Flag, "dns", translate("DNS Acceleration"))
dns.default = 0
dns.rmempty = false
dns.description = translate("Enable DNS Cache Acceleration and anti ISP DNS pollution")

o = s:option(ListValue, "dnscache_enable", translate("Resolve Dns Mode"), translate("AdGuardHome After setting up, shut down DNS acceleration normally and save configuration file") .. button)
o:value("1", translate("Use Pdnsd query and cache"))
if nixio.fs.access("/usr/bin/dnsforwarder") then
o:value("2", translate("Use dnsforwarder query and cache"))
end
if nixio.fs.access("/usr/bin/AdGuardHome") then
o:value("3", translate("Use AdGuardHome query and cache"))
end
o.default = 1
o:depends("dns", 1)

o = s:option(Flag, "mem_mode", translate("Memory mode operation"))
o.default = 0
o.rmempty = false
o:depends("dnscache_enable", 3)

o = s:option(Value, "dns_server", translate("Upsteam DNS Server"))
o.default = "114.114.114.114,114.114.115.115,223.5.5.5,223.6.6.6,180.76.76.76,119.29.29.29,119.28.28.28,1.2.4.8,210.2.4.8"
o.description = translate("Muitiple DNS server can saperate with ','")
o:depends("dnscache_enable", 1)
o:depends("dnscache_enable", 2)

o = s:option(Value, "ipv6dns_server", translate("Upsteam IPV6 DNS Server"))
o.default = "2001:4860:4860::8888,2001:4860:4860::8844,2001:2001::1111,2001:2001::1001,2400:da00::6666,240C::6666,240C::6644"
o.description = translate("Muitiple IPV6 DNS server can saperate with ','")
o:depends("dnscache_enable", 2)


return m
