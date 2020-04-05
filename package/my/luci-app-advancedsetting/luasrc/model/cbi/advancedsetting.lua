#-- Copyright (C) 2018 dz <dingzhong110@gmail.com>
local e=require"nixio.fs"
local t=require"luci.sys"
m=Map("advancedsetting",translate("Advanced Setting"),translate("Direct editing of built-in Script Documents for various services, unless you know what you are doing, do not easily modify these configuration documents"))
s=m:section(TypedSection,"advancedsetting")
s.anonymous=true
if nixio.fs.access("/etc/dnsmasq.conf")then
s:tab("config1",translate("dnsmasq"),translate("This page is the document content for configuring /etc/dnsmasq.conf. Restart takes effect after application is saved"))
conf=s:taboption("config1",Value,"editconf1",nil,translate("Each line of the opening numeric symbol (#) or semicolon (;) is considered a comment; delete (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
function conf.cfgvalue(t,t)
return e.readfile("/etc/dnsmasq.conf")or""
end
function conf.write(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dnsmasq.conf",t)
if(luci.sys.call("cmp -s /tmp/dnsmasq.conf /etc/dnsmasq.conf")==1)then
e.writefile("/etc/dnsmasq.conf",t)
luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
end
e.remove("/tmp/dnsmasq.conf")
end
end
end
if nixio.fs.access("/etc/config/network")then
s:tab("config2",translate("network"),translate("This page is the document content for configuring /etc/config/network. Restart takes effect after application is saved"))
conf=s:taboption("config2",Value,"editconf2",nil,translate("Each line of the opening numeric symbol (#) or semicolon (;) is considered a comment; delete (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
function conf.cfgvalue(t,t)
return e.readfile("/etc/config/network")or""
end
function conf.write(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/netwok",t)
if(luci.sys.call("cmp -s /tmp/network /etc/config/network")==1)then
e.writefile("/etc/config/network",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/network")
end
end
end
if nixio.fs.access("/etc/hosts")then
s:tab("config3",translate("hosts"),translate("This page is the document content for configuring /etc/hosts. Restart takes effect after application is saved"))
conf=s:taboption("config3",Value,"editconf3",nil,translate("Each line of the opening numeric symbol (#) or semicolon (;) is considered a comment; delete (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
function conf.cfgvalue(t,t)
return e.readfile("/etc/hosts")or""
end
function conf.write(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/etc/hosts",t)
if(luci.sys.call("cmp -s /tmp/etc/hosts /etc/hosts")==1)then
e.writefile("/etc/hosts",t)
luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
end
e.remove("/tmp/etc/hosts")
end
end
end
if nixio.fs.access("/etc/config/dhcp")then
s:tab("dhcpconf",translate("dhcp"),translate("本页是配置/etc/config/DHCP的文档内容。应用保存后自动重启生效"))
conf=s:taboption("dhcpconf",Value,"dhcpconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/dhcp")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dhcp",t)
if(luci.sys.call("cmp -s /tmp/dhcp /etc/config/dhcp")==1)then
e.writefile("/etc/config/dhcp",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/dhcp")
end
end
end
if nixio.fs.access("/etc/config/firewall")then
s:tab("firewallconf",translate("firewall"),translate("本页是配置/etc/config/firewall的文档内容。应用保存后自动重启生效"))
conf=s:taboption("firewallconf",Value,"firewallconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/firewall")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/firewall",t)
if(luci.sys.call("cmp -s /tmp/firewall /etc/config/firewall")==1)then
e.writefile("/etc/config/firewall",t)
luci.sys.call("/etc/init.d/firewall restart >/dev/null")
end
e.remove("/tmp/firewall")
end
end
end
if nixio.fs.access("/etc/pcap-dnsproxy/Config.conf")then
s:tab("pcapconf",translate("配置pcap-dnsproxy"),translate("本页是配置/etc/pcap-dnsproxy/Config.conf的文档内容。应用保存后自动重启生效"))
conf=s:taboption("pcapconf",Value,"pcapconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/pcap-dnsproxy/Config.conf")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/Config.conf",t)
if(luci.sys.call("cmp -s /tmp/Config.conf /etc/pcap-dnsproxy/Config.conf")==1)then
e.writefile("/etc/pcap-dnsproxy/Config.conf",t)
luci.sys.call("/etc/init.d/pcap-dnsproxy restart >/dev/null")
end
e.remove("/tmp/Config.conf")
end
end
end
if nixio.fs.access("/etc/wifidog.conf")then
s:tab("wifidogconf",translate("配置wifidog"),translate("本页是配置/etc/wifidog.conf的文档内容。应用保存后自动重启生效"))
conf=s:taboption("wifidogconf",Value,"wifidogconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/wifidog.conf")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/wifidog.conf",t)
if(luci.sys.call("cmp -s /tmp/wifidog.conf /etc/wifidog.conf")==1)then
e.writefile("/etc/wifidog.conf",t)
end
e.remove("/tmp/wifidog.conf")
end
end
end
if nixio.fs.access("/bin/nuc")then
s:tab("mode",translate("模式切换"),translate("<br />可以在这里切换NUC和正常模式，重置你的网络设置。<br /><font color=\"Red\"><strong>点击后会立即重启设备，没有确认过程，请谨慎操作！</strong></font><br/>"))
o=s:taboption("mode",Button,"nucmode",translate("切换为NUC模式"),"<strong><font color=\"green\">本模式适合于单网口主机，如NUC、单网口电脑，需要配合VLAN交换机使用！<br />设置教程：</font><a style=\"color: #ff0000;\" href=\"https://koolshare.cn/thread-166161-1-1.html\">跳转链接到Koolshare论坛教程贴</a></strong>")
o.inputtitle=translate("NUC模式")
o.inputstyle="reload"
o.write=function()
luci.sys.call("/bin/nuc")
end
o=s:taboption("mode",Button,"normalmode",translate("切换成正常模式"),"<strong><font color=\"green\">本模式适合于有两个网口或以上的设备使用，如多网口软路由或者虚拟了两个以上网口的虚拟机使用！</font></strong>")
o.inputtitle=translate("正常模式")
o.inputstyle="reload"
o.write=function()
luci.sys.call("/bin/normalmode")
end
end

return m