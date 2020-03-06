-- Copyright (C) 2017 yushi studio <ywb94@qq.com>
-- Licensed to the public under the GNU General Public License v3.

local IPK_Version="3.0.9"
local m, s, o
local redir_run=0
local reudp_run=0
local sock5_run=0
local server_run=0
local kcptun_run=0
local tunnel_run=0
local udp2raw_run=0
local udpspeeder_run=0
local gfw_count=0
local ad_count=0
local ip_count=0
local ucic = luci.model.uci.cursor()
local shadowsocksr = "shadowsocksr"
-- html constants
font_blue = [[<font color="green">]]
font_off = [[</font>]]
bold_on  = [[<strong>]]
bold_off = [[</strong>]]

local fs = require "nixio.fs"
local sys = require "luci.sys"
local kcptun_version=translate("Unknown")
local kcp_file="/usr/bin/kcptun-client"
if not fs.access(kcp_file)  then
kcptun_version=translate("Not exist")
else
if not fs.access(kcp_file, "rwx", "rx", "rx") then
fs.chmod(kcp_file, 755)
end
kcptun_version=sys.exec(kcp_file .. " -v | awk '{printf $3}'")
if not kcptun_version or kcptun_version == "" then
kcptun_version = translate("Unknown")
end

end

if nixio.fs.access("/etc/dnsmasq.ssr/gfw_list.conf") then
gfw_count = tonumber(sys.exec("cat /etc/dnsmasq.ssr/gfw_list.conf | wc -l"))/2
end

if nixio.fs.access("/etc/dnsmasq.ssr/ad.conf") then
ad_count=tonumber(sys.exec("cat /etc/dnsmasq.ssr/ad.conf | wc -l"))
end

if nixio.fs.access("/etc/china_ssr.txt") then
ip_count = sys.exec("cat /etc/china_ssr.txt | wc -l")
end

function processlist()
	local data = {}
	local netf = {}
	local k
	local ps = luci.util.execi("/bin/busybox top -bn1 | egrep -v dnsmasq")
	local nets = luci.util.execi("netstat -netupl | egrep -v dnsmasq | awk '{print $1,$4,_,$6,$7}'")

	if not ps or not nets then
		return
	end

	for line in nets do
-- tcp        0      0 127.0.0.1:1234          0.0.0.0:*               LISTEN      5103/v2ray
-- udp        0      0 127.0.0.1:1234          0.0.0.0:*                           5147/v2ray
--		local proto, ip, port, nid = line:match("([^%s]+) +.* +([^ ]*):(%d+) +.* +(%d+)\/.*")
		local proto, ip, port, nid = line:match("([^%s]+) (.*):(%d+)[^%d]+(%d+)\/.*")
		local idx = tonumber(nid)
		if idx and ip then
			local newstr = "://" .. ip .. ":" .. port
			local isnew = (netf[idx] and netf[idx]['listen']) and netf[idx]['listen']:match(proto .. newstr)  or false
			netf[idx] = {
				['listen'] = ((netf[idx] and netf[idx]['listen']) and (not isnew) and (netf[idx]['listen'] .. "\n" .. proto) or proto) .. newstr,
			}
		end
	end
-- 5103     1 root     S     661m 543%   0% /usr/bin/v2ray/v2ray -config /var/etc/shadowsocksr.json
	for line in ps do
		local pid, ppid, user, stat, vsz, mem, cpu, cmd = line:match(
			"^ *(%d+) +(%d+) +(%S.-%S) +([RSDZTW][W ][<N ]) +(%d+.?) +(%d+%%) +(%d+%%) +(.+)"
		)
		if cmd then
		local idx = tonumber(pid)
		local bin, param, cfg = cmd:match("^.*\/([^ ]*) *([^ ]*) *\/var\/etc\/([^ ]*).*")
		if idx and cfg then
			local listen = "NONE"
			if netf[idx] and netf[idx]['listen'] then
				listen = netf[idx]['listen']
			end
			data[idx] = {
				['PID']     = pid,
				['COMMAND'] = bin,
				['LISTEN'] = listen,
				['CONFIG']   = cfg,
				['%MEM']    = mem,
				['%CPU']    = cpu,
			}
		end
		end
	end

	return data
end

function printstat(status, form, name)
	local tabs = {
		["Global Client"] = "shadowsocksr.json",
		["Game Mode UDP Relay"] = "shadowsocksr_u.json",
		["PDNSD"] = "pdnsd.conf",
		["DNS Forward"] = "shadowsocksr_d.json",
		["SOCKS5 Proxy"] = "shadowsocksr_s.json",
		["Global SSR Server"] = "shadowsocksr_0.json",
		
	}
	local stat = translate("Unknown")
	local sname = stat
	if tabs[name] and status then
	stat = translate("Not Running")
	for idx, cfg in pairs(status) do
		if status[idx]['CONFIG'] and status[idx]['CONFIG'] == tabs[name] then
			stat = font_blue .. bold_on .. translate("Running") .. bold_off .. " > " .. status[idx]['COMMAND'] .. " -c " .. status[idx]['CONFIG'] .. font_off
			sname = translate(status[idx]['COMMAND'])
			break
		end
	end
	end
	local section = form:field(DummyValue,name,translate(name) .. ": " .. sname)
	section.rawhtml  = true
	section.value = stat
	return section
end

procs=processlist()


local icount=sys.exec("busybox ps -w | grep ssr-reudp |grep -v grep| wc -l")
if tonumber(icount)>0 then
reudp_run=1
else
icount=sys.exec("busybox ps -w | grep ssr-retcp |grep \"\\-u\"|grep -v grep| wc -l")
if tonumber(icount)>0 then
reudp_run=1
end
end

if luci.sys.call("busybox ps -w | grep ssr-retcp | grep -v grep >/dev/null") == 0 then
redir_run=1
end

if luci.sys.call("busybox ps -w | grep ssr-socks | grep -v grep >/dev/null") == 0 then
sock5_run=1
end

if luci.sys.call("pidof kcptun-client >/dev/null") == 0 then
kcptun_run=1
end

if luci.sys.call("pidof ssr-server >/dev/null") == 0 then
server_run=1
end

if luci.sys.call("busybox ps -w | grep ssr-tunnel |grep -v grep >/dev/null") == 0 then
tunnel_run=1
end

if luci.sys.call("pidof pdnsd >/dev/null") == 0 or (luci.sys.call("busybox ps -w | grep ssr-dns |grep -v grep >/dev/null") == 0 and luci.sys.call("pidof dns2socks >/dev/null") == 0)then
pdnsd_run=1
end

m = SimpleForm("Version")
m.reset = false
m.submit = false



s=m:field(DummyValue,"redir_run",translate("Global Client"))
s.rawhtml  = true
if redir_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end

s=m:field(DummyValue,"reudp_run",translate("Game Mode UDP Relay"))
s.rawhtml  = true
if reudp_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end

if ucic:get_first(shadowsocksr, 'global', 'pdnsd_enable', '0') ~= '0' then
s=m:field(DummyValue,"pdnsd_run",translate("DNS Anti-pollution"))
s.rawhtml  = true
if pdnsd_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end
end

if ucic:get_first(shadowsocksr, 'socks5_proxy', 'socks', '0') == '1' then
if nixio.fs.access("/usr/bin/microsocks") then
s=m:field(DummyValue,"sock5_run",translate("SOCKS5 Proxy Server"))
s.rawhtml  = true
if sock5_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end
end
end

if nixio.fs.access("/usr/bin/ssr-server") then
s=m:field(DummyValue,"server_run",translate("Global SSR Server"))
s.rawhtml  = true
if server_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end
end

if nixio.fs.access("/usr/bin/kcptun-client") then
s=m:field(DummyValue,"kcp_version",translate("KcpTun Version"))
s.rawhtml  = true
s.value =kcptun_version

s=m:field(DummyValue,"kcptun_run",translate("KcpTun"))
s.rawhtml  = true
if kcptun_run == 1 then
s.value =font_blue .. bold_on .. translate("Running") .. bold_off .. font_off
else
s.value = translate("Not Running")
end
end

s=m:field(DummyValue,"google",translate("Google Connectivity"))
s.value = translate("No Check")
s.template = "shadowsocksr/check"

s=m:field(DummyValue,"baidu",translate("Baidu Connectivity"))
s.value = translate("No Check")
s.template = "shadowsocksr/check"

s=m:field(DummyValue,"gfw_data",translate("GFW List Data"))
s.rawhtml  = true
s.template = "shadowsocksr/refresh"
s.value =tostring(math.ceil(gfw_count)) .. " " .. translate("Records")

s=m:field(DummyValue,"ip_data",translate("China IP Data"))
s.rawhtml  = true
s.template = "shadowsocksr/refresh"
s.value =ip_count .. " " .. translate("Records")

if ucic:get_first(shadowsocksr, 'global', 'adblock', '0') == '1' then
s=m:field(DummyValue,"ad_data",translate("Advertising Data"))
s.rawhtml  = true
s.template = "shadowsocksr/refresh"
s.value =ad_count .. " " .. translate("Records")
end

s=m:field(DummyValue,"check_port",translate("Check Server Port"))
s.template = "shadowsocksr/checkport"
s.value =translate("No Check")

t = m:section(Table, procs, translate("Running Details: ") .. "(/var/etc)")
t:option(DummyValue, "PID", translate("PID"))
t:option(DummyValue, "COMMAND", translate("CMD"))
t:option(DummyValue, "LISTEN", translate("LISTEN"))
t:option(DummyValue, "%CPU", translate("CPU"))
t:option(DummyValue, "%MEM", translate("MEM"))


return m
