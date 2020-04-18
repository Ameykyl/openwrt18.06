-- Copyright (C) 2017 yushi studio <ywb94@qq.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocksr", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocksr") then
		return
	end
	entry({"admin", "Internet", "shadowsocksr"}, alias("admin", "Internet", "shadowsocksr", "client"),_("ShadowSocksR Plus+"), 10).dependent = true
	entry({"admin", "Internet", "shadowsocksr", "client"}, cbi("shadowsocksr/client"),_("SSR Client"), 10).leaf = true
	entry({"admin", "Internet", "shadowsocksr", "servers"}, cbi("shadowsocksr/servers"), _("Node List"), 11).leaf = true
                 entry({"admin", "Internet", "shadowsocksr", "servers"},arcombine(cbi("shadowsocksr/servers"), cbi("shadowsocksr/client-config")),_("Node List"), 11).leaf = true
                 entry({"admin", "Internet", "shadowsocksr", "subscription"},cbi("shadowsocksr/subscription"),_("Subscription"),30).leaf=true
	entry({"admin", "Internet", "shadowsocksr", "control"},cbi("shadowsocksr/control"), _("Access Control"), 40).leaf = true
                 entry({"admin", "Internet", "shadowsocksr", "servers-list"},arcombine(cbi("shadowsocksr/servers-list"), cbi("shadowsocksr/client-config")),_("Severs Nodes"), 45).leaf = true
	entry({"admin", "Internet", "shadowsocksr", "advanced"},cbi("shadowsocksr/advanced"),_("Advanced Settings"), 50).leaf = true
	entry({"admin", "Internet", "shadowsocksr", "server"},arcombine(cbi("shadowsocksr/server"), cbi("shadowsocksr/server-config")),_("SSR Server"), 60).leaf = true
	entry({"admin", "Internet", "shadowsocksr", "status"},form("shadowsocksr/status"),_("Status"), 70).leaf = true
	entry({"admin", "Internet", "shadowsocksr", "check"}, call("check_status"))
	entry({"admin", "Internet", "shadowsocksr", "refresh"}, call("refresh_data"))
	entry({"admin", "Internet", "shadowsocksr", "subscribe"}, call("subscribe"))
	entry({"admin", "Internet", "shadowsocksr", "checkport"}, call("check_port"))
                 entry({"admin", "Internet", "shadowsocksr", "checkports"}, call("check_ports"))
	entry({"admin", "Internet", "shadowsocksr", "logview"}, cbi("shadowsocksr/logview", {hideapplybtn=true, hidesavebtn=true, hideresetbtn=true}), _("Log") ,80).leaf=true
                 entry({"admin", "Internet", "shadowsocksr", "fileread"}, call("act_read"), nil).leaf=true
	entry({"admin", "Internet", "shadowsocksr","run"},call("act_status")).leaf=true
                 entry({"admin", "Internet", "shadowsocksr", "change"}, call("change_node"))
                 entry({"admin", "Internet", "shadowsocksr", "allserver"}, call("get_servers"))
                 entry({"admin", "Internet", "shadowsocksr", "subscribe"}, call("get_subscribe"))
	entry({"admin", "Internet", "shadowsocksr", "ping"}, call("act_ping")).leaf=true
end

function get_subscribe()

    local cjson = require "cjson"
    local e = {}
    local uci = luci.model.uci.cursor()
    local auto_update = luci.http.formvalue("auto_update")
    local auto_update_time = luci.http.formvalue("auto_update_time")
    local proxy = luci.http.formvalue("proxy")
    local subscribe_url = luci.http.formvalue("subscribe_url")
    if subscribe_url ~= "[]" then
        local cmd1 = 'uci set shadowsocksr.@server_subscribe[0].auto_update="' ..
                         auto_update .. '"'
        local cmd2 = 'uci set shadowsocksr.@server_subscribe[0].auto_update_time="' ..
                         auto_update_time .. '"'
        local cmd3 = 'uci set shadowsocksr.@server_subscribe[0].proxy="' .. proxy .. '"'
        luci.sys.call('uci delete shadowsocksr.@server_subscribe[0].subscribe_url ')
        luci.sys.call(cmd1)
        luci.sys.call(cmd2)
        luci.sys.call(cmd3)
        for k, v in ipairs(cjson.decode(subscribe_url)) do
            luci.sys.call(
                'uci add_list shadowsocksr.@server_subscribe[0].subscribe_url="' .. v ..
                    '"')
        end
        luci.sys.call('uci commit shadowsocksr')
        luci.sys.call(
              "nohup /usr/bin/lua /usr/share/shadowsocksr/subscribe.lua >/www/check_update.htm 2>/dev/null &")
        
        e.error = 0
    else
        e.error = 1
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json(e)

end
-- 获取所有节点
function get_servers()
    local uci = luci.model.uci.cursor()
    local server_table = {}
    uci:foreach("shadowsocksr", "servers", function(s)
        s["name"] = s[".name"]
        table.insert(server_table,s)
    end)
    luci.http.prepare_content("application/json")
    luci.http.write_json(server_table)
end

-- 切换节点
function change_node()
                local e = {}
                local uci = luci.model.uci.cursor()
                local sid = luci.http.formvalue("set")
                local name = ""
                uci:foreach("shadowsocksr", "global", function(s) name = s[".name"] end)
                e.status = false
                e.sid = sid
                if sid ~= "" then
                uci:set("shadowsocksr", name, "global_server", sid)
                uci:commit("shadowsocksr")
                luci.sys.call("/etc/init.d/shadowsocksr restart")
                e.status = true
    end
                luci.http.prepare_content("application/json")
                luci.http.write_json(e)
end


-- 检测全局服务器状态
function act_status()
              math.randomseed(os.time())
              local e = {}
-- 全局服务器
                          e.global=luci.sys.call("ps -w | grep ssr-retcp | grep -v grep >/dev/null") == 0

  -- 检测Socks5
                          e.socks5 = luci.sys.call("busybox ps -w | grep ssr-local | grep -v grep >/dev/null") == 0	         
--检测chinadns状态
	          if tonumber(luci.sys.exec("ps -w | grep chinadns |grep -v grep| wc -l"))>0 then
		        e.chinadns= true
	          elseif tonumber(luci.sys.exec("ps -w | grep dnsparsing |grep -v grep| wc -l"))>0 then
	 	        e.chinadns= true
	          elseif tonumber(luci.sys.exec("ps -w | grep dnscrypt-proxy |grep -v grep| wc -l"))>0 then
		        e.chinadns= true
                           elseif tonumber(luci.sys.exec("ps -w | grep pdnsd |grep -v grep| wc -l"))>0 then
		        e.chinadns= true
	          elseif tonumber(luci.sys.exec("ps -w | grep dns2socks |grep -v grep| wc -l"))>0 then
		        e.chinadns= true

end
--检测服务端状态
	         if tonumber(luci.sys.exec("ps -w | grep ssr-server |grep -v grep| wc -l"))>0 then
	         e.server= true
end
                         if luci.sys.call("pidof ssr-server >/dev/null") == 0 then
                         e.ssr_server= true
end
 	        if luci.sys.call("pidof ss-server >/dev/null") == 0 then
                         e.ss_server= true
end
	        if luci.sys.call("ps -w | grep v2ray-server | grep -v grep >/dev/null") == 0 then
                         e.v2_server= true

end
   -- 检测国内通道
                       e.baidu = false
                       sret = luci.sys.call("/usr/bin/ssr-check www.baidu.com 80 3 1")
                       if sret == 0 then
                       e.baidu =  true
end

    -- 检测国外通道
                      e.google = false
                      sret = luci.sys.call("/usr/bin/ssr-check www.google.com 80 3 1")
                      if sret == 0 then
                      e.google =  true
end


-- 检测游戏模式状态
                    e.game = false
                    if tonumber(luci.sys.exec("ps -w | grep ssr-reudp |grep -v grep| wc -l"))>0 then
                    e.game= true
                    else
                    if tonumber(luci.sys.exec("ps -w | grep ssr-retcp |grep \"\\-u\"|grep -v grep| wc -l"))>0 then
                    e.game= true
    end
    end
                   luci.http.prepare_content("application/json")
                   luci.http.write_json(e)
end


function act_ping()
	local e = {}
	local domain = luci.http.formvalue("domain")
	local port = luci.http.formvalue("port")
	e.index = luci.http.formvalue("index")
	local iret = luci.sys.call(" ipset add ss_spec_wan_ac " .. domain .. " 2>/dev/null")
	local socket = nixio.socket("inet", "stream")
	socket:setopt("socket", "rcvtimeo", 3)
	socket:setopt("socket", "sndtimeo", 3)
	e.socket = socket:connect(domain, port)
	socket:close()
	e.ping = luci.sys.exec("ping -c 1 -W 1 %q 2>&1 | grep -o 'time=[0-9]*.[0-9]' | awk -F '=' '{print$2}'" % domain)
	if (e.ping == "") then
		e.ping = luci.sys.exec(string.format("echo -n $(tcpping -c 1 -i 1 -p %s %s 2>&1 | grep -o 'ttl=[0-9]* time=[0-9]*.[0-9]' | awk -F '=' '{print$3}') 2>/dev/null",port, domain))
  end
	if (iret == 0) then
		luci.sys.call(" ipset del ss_spec_wan_ac " .. domain)
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function check_status()
	local set = "/usr/bin/ssr-check www." .. luci.http.formvalue("set") .. ".com 80 3 1"
	sret = luci.sys.call(set)
	if sret == 0 then
		retstring ="0"
	else
		retstring ="1"
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ ret=retstring })
end

function refresh_data()
	local set = luci.http.formvalue("set")
	local uci = luci.model.uci.cursor()
	local icount = 0
	if set == "gfw_data" then
		refresh_cmd = "wget-ssl --no-check-certificate -O- " .. uci:get_first('shadowsocksr', 'global', 'gfwlist_url', 'https://cdn.jsdelivr.net/gh/gfwlist/gfwlist/gfwlist.txt') .. ' > /tmp/gfw.b64'
		sret = luci.sys.call(refresh_cmd .. " 2>/dev/null")
		if sret == 0 then
			luci.sys.call("/usr/bin/ssr-gfw")
			icount = luci.sys.exec("cat /tmp/gfwnew.txt | wc -l")
			if tonumber(icount) > 1000 then
				oldcount = luci.sys.exec("cat /etc/dnsmasq.ssr/gfw_list.conf | wc -l")
				if tonumber(icount) ~= tonumber(oldcount) then
					luci.sys.exec("cp -f /tmp/gfwnew.txt /etc/dnsmasq.ssr/gfw_list.conf")
					luci.sys.exec("cp -f /tmp/gfwnew.txt /tmp/dnsmasq.ssr/gfw_list.conf")
					luci.sys.call("/etc/init.d/dnsmasq restart")
					retstring = tostring(tonumber(icount)/2)
				else
					retstring = "0"
				end
			else
				retstring = "-1"
			end
			luci.sys.exec("rm -f /tmp/gfwnew.txt")
		else
			retstring = "-1"
		end
	end
	if set == "ip_data" then
		refresh_cmd = "wget-ssl --no-check-certificate -O- " .. uci:get_first('shadowsocksr', 'global', 'chnroute_url', 'https://ispip.clang.cn/all_cn.txt') .. ' > /tmp/china_ssr.txt'
		sret = luci.sys.call(refresh_cmd .. " 2>/dev/null")
		icount = luci.sys.exec("cat /tmp/china_ssr.txt | wc -l")
		if sret == 0 and tonumber(icount) > 1000 then
			oldcount = luci.sys.exec("cat /etc/china_ssr.txt | wc -l")
			if tonumber(icount) ~= tonumber(oldcount) then
				luci.sys.exec("cp -f /tmp/china_ssr.txt /etc/china_ssr.txt")
				luci.sys.exec("/etc/init.d/shadowsocksr restart &")
				retstring = tostring(tonumber(icount))
			else
				retstring = "0"
			end
		else
			retstring = "-1"
		end
		luci.sys.exec("rm -f /tmp/china_ssr.txt")
	end
	if set == "nfip_data" then
		refresh_cmd = "wget-ssl --no-check-certificate -O- ".. uci:get_first('shadowsocksr', 'global', 'nfip_url','https://raw.githubusercontent.com/QiuSimons/Netflix_IP/master/NF_only.txt') .." > /tmp/netflixip.list"
		sret = luci.sys.call(refresh_cmd .. " 2>/dev/null")
		icount = luci.sys.exec("cat /tmp/netflixip.list | wc -l")
		if sret == 0 and tonumber(icount) > 5 then
			oldcount = luci.sys.exec("cat /etc/config/netflixip.list | wc -l")
			if tonumber(icount) ~= tonumber(oldcount) then
				luci.sys.exec("cp -f /tmp/netflixip.list /etc/config/netflixip.list")
				luci.sys.exec("/etc/init.d/shadowsocksr restart &")
				retstring = tostring(tonumber(icount))
			else
				retstring = "0"
			end
		else
			retstring = "-1"
		end
		luci.sys.exec("rm -f /tmp/netflixip.list")
	end
	if set == "ad_data" then
		refresh_cmd = "wget-ssl --no-check-certificate -O- ".. uci:get_first('shadowsocksr', 'global', 'adblock_url','https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt') .." > /tmp/adnew.conf"
		sret = luci.sys.call(refresh_cmd .. " 2>/dev/null")
		if sret == 0 then
			luci.sys.call("/usr/bin/ssr-ad")
			icount = luci.sys.exec("cat /tmp/ad.conf | wc -l")
			if tonumber(icount) > 100 then
				if nixio.fs.access("/etc/dnsmasq.ssr/ad.conf") then
					oldcount = luci.sys.exec("cat /etc/dnsmasq.ssr/ad.conf | wc -l")
				else
					oldcount = "0"
				end
				if tonumber(icount) ~= tonumber(oldcount) then
					luci.sys.exec("cp -f /tmp/ad.conf /etc/dnsmasq.ssr/ad.conf")
					luci.sys.exec("cp -f /tmp/ad.conf /tmp/dnsmasq.ssr/ad.conf")
					luci.sys.call("/etc/init.d/dnsmasq restart")
					retstring = tostring(tonumber(icount))
				else
					retstring = "0"
				end
			else
				retstring = "-1"
			end
			luci.sys.exec("rm -f /tmp/ad.conf")
		else
			retstring = "-1"
		end
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret = retstring,retcount = icount})
end


function check_ports()
    local set = ""
    local retstring = "<br /><br />"
    local s
    local server_name = ""
    local shadowsocksr = "shadowsocksr"
    local uci = luci.model.uci.cursor()
    local iret = 1

    uci:foreach(
        shadowsocksr,
        "servers",
        function(s)
            if s.alias then
                server_name = s.alias
            elseif s.server and s.server_port then
                server_name = "%s:%s" % {s.server, s.server_port}
            end
            iret = luci.sys.call(" ipset add ss_spec_wan_ac " .. s.server .. " 2>/dev/null")
            socket = nixio.socket("inet", "stream")
            socket:setopt("socket", "rcvtimeo", 3)
            socket:setopt("socket", "sndtimeo", 3)
            ret = socket:connect(s.server, s.server_port)
            if tostring(ret) == "true" then
                socket:close()
                retstring = retstring .. "<font color='green'>[" .. server_name .. "] OK.</font><br />"
            else
                retstring = retstring .. "<font color='red'>[" .. server_name .. "] Error.</font><br />"
            end
            if iret == 0 then
                luci.sys.call(" ipset del ss_spec_wan_ac " .. s.server)
            end
        end
    )

    luci.http.prepare_content("application/json")
    luci.http.write_json({ret = retstring})
end


-- 检测单个节点状态并返回连接速度
function check_port()

    local e = {}
    -- e.index=luci.http.formvalue("host")
    local t1 = luci.sys.exec(
                   "ping -c 1 -W 1 %q 2>&1 | grep -o 'time=[0-9]*.[0-9]' | awk -F '=' '{print$2}'" %
                       luci.http.formvalue("host"))
    luci.http.prepare_content("application/json")
    luci.http.write_json({ret = 1, used = t1})

end

function act_read(lfile)
	local NXFS = require "nixio.fs"
	local HTTP = require "luci.http"
	local lfile = HTTP.formvalue("lfile")
	local ldata={}
	ldata[#ldata+1] = NXFS.readfile(lfile) or "_nofile_"
	if ldata[1] == "" then
		ldata[1] = "_nodata_"
	end
	HTTP.prepare_content("application/json")
	HTTP.write_json(ldata)
end

