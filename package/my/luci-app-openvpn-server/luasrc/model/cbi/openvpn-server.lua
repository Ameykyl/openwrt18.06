
mp = Map("openvpn", "OpenVPN Server",translate("An easy config OpenVPN Server Web-UI"))

mp:section(SimpleSection).template  = "openvpn/openvpn_status"

s = mp:section(TypedSection, "openvpn")
s.anonymous = true
s.addremove = false

s:tab("basic",  translate("Base Setting"))

o = s:taboption("basic", Flag, "enabled", translate("Enable"))

local pid = luci.util.exec("/usr/bin/pgrep openvpn")

if pid ~= "" then
	restart = s:taboption("basic", Button, "_restart", translate("Restart") ,translate("Restart OpenVPN service."))
	restart.inputstyle = "apply"
	function restart.write(self, section)
		luci.util.exec("/etc/init.d/openvpn restart 2>&1")
	end
end

ddns = s:taboption("basic", Value, "ddns", translate("Address"))
ddns.description = translate("DDNS address or IP of the WAN port")
ddns.datatype = "host"
ddns.default = "exmple.com"
ddns.rmempty = false
ddns.password = true

port = s:taboption("basic", Value, "port", translate("Port"))
port.datatype = "range(1,65535)"
port.rmempty = false

proto = s:taboption("basic",ListValue,"proto", translate("proto"))
proto.rmempty = false
proto:value("tcp", translate("TCP"))
proto:value("udp", translate("UDP"))

localnet = s:taboption("basic", Value, "server", translate("Client Network"))
localnet.datatype = "string"
localnet.description = translate("VPN Client Network IP with subnet")

max_clients = s:taboption("basic",Value,"max_clients", translate("Max-clients"))
max_clients.datatype = "range(1,255)"
max_clients.description = translate("Set maximum number of connections.")

remote_cert_tls = s:taboption("basic", ListValue, "remote_cert_tls", translate("Remote-cert-tls"))
remote_cert_tls.description = translate("Check remote certificate to prevent man-in-the-middle attacks.<br / >Recommended to enable.")
remote_cert_tls:value("", translate("Disable"))
remote_cert_tls:value("client", translate("Enable"))

tls_auth = s:taboption("basic", ListValue, "tls_auth", translate("TLS-Auth"))
tls_auth.description = translate("Add an additional layer of HMAC authentication on top of the TLS control channel.Recommended to enable.")
tls_auth:value("", translate("Disable"))
tls_auth:value("/etc/openvpn/ta.key 0", translate("Enable"))

duplicate_cn = s:taboption("basic",Flag,"duplicate_cn", translate("Duplicate-cn"))
duplicate_cn.description = translate("Allow multiple clients with the same name or the same client certificate to connect to the server at the same time.")

auth_user_pass_verify = s:taboption("basic",ListValue,"auth_user_pass_verify", translate("Auth-user-pass-verify"))
auth_user_pass_verify.description = translate("Enable username/password for authentication.")
auth_user_pass_verify:value("", translate("Disable"))
auth_user_pass_verify:value("/etc/checkpsw.sh via-env", translate("Enable"))

script_security = s:taboption("basic",ListValue,"script_security", translate("Script-security level"))
script_security.description = translate("If username/password are used for authentication,please change to level 3.")
script_security:value("",translate("Disable"))
script_security:value("1",translate("1-Only call built-in executables such as ifconfig, ip, route, or netsh."))
script_security:value("2",translate("2-Allow calling of built-in executables and user-defined scripts."))
script_security:value("3",translate("3-Allow passwords to be passed to scripts via environmental variables."))

username_as_common_name = s:taboption("basic",Flag,"username_as_common_name", translate("Username-as-common-name"))
username_as_common_name.description = translate("For enable username/password verification,use the authenticated username as the common name, rather than the common name from the client cert.")
username_as_common_name:depends("auth_user_pass_verify", "/etc/openvpn/server/checkpsw.sh via-env")

verify_client_cert = s:taboption("basic",ListValue,"verify_client_cert", translate("Verify-Client-Cert None"))
verify_client_cert.description = translate("Don’t require client certificate, client will authenticate using username/password only.<br / >Checking remote certificate will fail after enabling.")
verify_client_cert:depends("auth_user_pass_verify", "/etc/openvpn/server/checkpsw.sh via-env")
verify_client_cert:value("", translate("Disable"))
verify_client_cert:value("none", translate("Enable"))

list = s:taboption("basic", DynamicList, "push")
list.title = translate("Client Push Settings")
list.datatype = "string"
list.description = translate("Set route 192.168.0.0 255.255.255.0 and dhcp-option DNS 192.168.0.1 base on your router")

function Download()
	local t,e
	t=nixio.open("/tmp/my.ovpn","r")
	luci.http.header('Content-Disposition','attachment; filename="my.ovpn"')
	luci.http.prepare_content("application/octet-stream")
	while true do
		e=t:read(nixio.const.buffersize)
		if(not e)or(#e==0)then
			break
		else
			luci.http.write(e)
		end
	end
	t:close()
	luci.http.close()
end

local o
o = s:taboption("basic", Button,"certificate",translate("OpenVPN Client config file"))
o.inputtitle = translate("Download .ovpn file")
o.description = translate("If you are using IOS client, please download this .ovpn file and send it via Telegram or Email to your IOS device.<br / >After modifying the configuration, you need to download the .ovpn file again.<br / >Re-download the .ovpn file after generating the certificate.")
o.inputstyle = "reload"
o.write = function()
  luci.sys.call("sh /etc/genovpn.sh 2>&1 >/dev/null")
	Download()
end

gen = s:taboption("basic", Button,"gencert",translate("Generate certificate"))
gen.description = translate("<font color=\"red\">Generate certificate before running for the first time.<br / >After modifying the certificate option, you need to regenerate the certificate to take effect.<br / >The certificate may take a long time to generate.<br / >After the certificate is generated, the VPN service needs to be restarted to take effect.</font>")
gen.inputstyle = "apply"
function gen.write(self, section)
  luci.util.exec("/etc/openvpncert.sh")
end

s:tab("code",  translate("Client configuration"))
local conf = "/etc/ovpnadd.conf"
local NXFS = require "nixio.fs"
o = s:taboption("code", TextValue, "conf")
o.description = translate("The code added to .ovpn file.")
o.rows = 13
o.wrap = "off"
o.cfgvalue = function(self, section)
	return NXFS.readfile(conf) or ""
end
o.write = function(self, section, value)
	NXFS.writefile(conf, value:gsub("\r\n", "\n"))
end

s:tab("passwordfile",  translate("Username and Password"))
local pass = "/etc/openvpn/server/psw-file"
local NXFS = require "nixio.fs"
o = s:taboption("passwordfile", TextValue, "pass")
o.description = translate("One line is a set of username passwords,username password is separated by a space.")
o.rows = 13
o.wrap = "off"
o.cfgvalue = function(self, section)
	return NXFS.readfile(pass) or ""
end
o.write = function(self, section, value)
	NXFS.writefile(pass, value:gsub("\r\n", "\n"))
end

s:tab("varsfile",  translate("Certificate option"))
local varsfile = "/etc/easy-rsa/vars"
local NXFS = require "nixio.fs"
o = s:taboption("varsfile", TextValue, "varsfile")
o.description = translate("Edit certificate generation options,keep the default for normal users.<br / >Do not modify the set_var EASYRSA_PKI, otherwise the certificate will not be generated normally.")
o.rows = 13
o.wrap = "off"
o.cfgvalue = function(self, section)
	return NXFS.readfile(varsfile) or ""
end
o.write = function(self, section, value)
	NXFS.writefile(varsfile, value:gsub("\r\n", "\n"))
end

return mp
