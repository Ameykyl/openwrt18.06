#!/bin/sh
logfile="/tmp/ssrplus.log"
dir="/usr/share/v2ray/"
v2ray_path=$(uci get shadowsocksr.@server_subscribe[0].v2ray_path 2>/dev/null)
[ ! -d "$dir" ] && mkdir -p $dir
[ ! -d "$v2ray_path" ] && mkdir -p $v2ray_path
v2ray_new_version=$(curl -s "https://github.com/v2ray/v2ray-core/tags"| grep "/v2ray/v2ray-core/releases/tag/"| head -n 1| awk -F "/tag/v" '{print $2}'| sed 's/\">//')
echo "$v2ray_new_version" > ${dir}v2ray_new_version
if [ $? -eq 0 ];then
	edition=$(uci get shadowsocksr.@server_subscribe[0].edition 2>/dev/null)
	if [ "$edition" = "auto_detected" ];then
		v2ray_new_version=$(cat ${dir}v2ray_new_version|sed -n '1p')
	else
		v2ray_new_version=$edition
	fi
	echo "$(date "+%Y-%m-%d %H:%M:%S") v2ray手动更新启动，验证版本..." >> ${logfile}
	echo "$(date "+%Y-%m-%d %H:%M:%S") 检测到v2ray版本为$v2ray_new_version..." >> ${logfile}

		UpdateApp() {
			for a in $(opkg print-architecture | awk '{print $2}'); do
				case "$a" in
					all|noarch)
						;;
					aarch64_armv8-a|arm_arm1176jzf-s_vfp|arm_arm926ej-s|arm_cortex-a15_neon-vfpv4|arm_cortex-a5|arm_cortex-a53_neon-vfpv4|arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|arm_cortex-a9_neon|arm_cortex-a9_vfpv3|arm_fa526|arm_mpcore|arm_mpcore_vfp|arm_xscale|armeb_xscale)
						ARCH="arm"
						;;
					i386_pentium|i386_pentium4)
						ARCH="32"
						;;
					ar71xx|mips_24kc|mips_mips32|mips64_octeon)
						ARCH="mips"
						;;
					mipsel_24kc|mipsel_24kec_dsp|mipsel_74kc|mipsel_mips32|mipsel_1004kc_dsp)
						ARCH="mipsle"
						;;
					x86_64)
						ARCH="64"
						;;
					*)
						exit 0
						;;
				esac
			done
		}

		download_binary(){
			available=$(df $v2ray_path -k | sed -n 2p | awk '{print $4}')
			if [ $available -ge 16384 ]; then
				echo "$(date "+%Y-%m-%d %H:%M:%S") 开始下载v2ray二进制文件......" >> ${logfile}
				bin_dir="/tmp"
				rm -rf $bin_dir/v2ray*.zip
				echo "$(date "+%Y-%m-%d %H:%M:%S") 当前下载目录为$bin_dir" >> ${logfile}
				UpdateApp
				cd $bin_dir
				down_url=https://github.com/v2ray/v2ray-core/releases/download/v"$v2ray_new_version"/v2ray-linux-"$ARCH".zip
				echo "$(date "+%Y-%m-%d %H:%M:%S") 正在下载v2ray可执行文件......" >> ${logfile}
				local a=0
				while [ ! -f $bin_dir/v2ray-linux-"$ARCH"*.zip ]; do
					[ $a = 6 ] && exit
					curl -OL --progress-bar --connect-timeout 20 --retry 5 --location --insecure $down_url
					sleep 2
					let "a = a + 1"
				done
	
				if [ -e $bin_dir/v2ray-linux-"$ARCH"*.zip ]; then
					echo "$(date "+%Y-%m-%d %H:%M:%S") 成功下载v2ray可执行文件" >> ${logfile}
					echo "$(date "+%Y-%m-%d %H:%M:%S") 当前安装目录为$v2ray_path..." >> ${logfile}
					echo "$(date "+%Y-%m-%d %H:%M:%S") 正在安装v2ray可执行文件" >> ${logfile}
					killall -q -9 v2ray
					[ -e $v2ray_path/v2ray ] && rm -rf $v2ray_path/*
					unzip -o v2ray-linux-"$ARCH"*.zip -d $bin_dir/v2ray-v"$v2ray_new_version"-linux-"$ARCH"/ > /dev/null 2>&1
					mv $bin_dir/v2ray-v"$v2ray_new_version"-linux-"$ARCH"/v2ray $v2ray_path
					mv $bin_dir/v2ray-v"$v2ray_new_version"-linux-"$ARCH"/v2ctl $v2ray_path
					mv $bin_dir/v2ray-v"$v2ray_new_version"-linux-"$ARCH"/geoip.dat $v2ray_path
					mv $bin_dir/v2ray-v"$v2ray_new_version"-linux-"$ARCH"/geosite.dat $v2ray_path
					rm -rf $bin_dir/v2ray-v"$v2ray_new_version"-linux-"$ARCH"
					rm -rf $bin_dir/v2ray*.zip
					if [ -e "$v2ray_path/v2ray" ]; then
						chmod +x $v2ray_path/v2ray
						chmod +x $v2ray_path/v2ctl
						echo "$(date "+%Y-%m-%d %H:%M:%S") 成功安装v2ray，正在重启进程" >> ${logfile}
						/etc/init.d/shadowsocksr restart
					fi
				else
					echo "$(date "+%Y-%m-%d %H:%M:%S") 下载v2ray二进制文件失败，请重试！" >> ${logfile}
				fi
			else
				echo "$(date "+%Y-%m-%d %H:%M:%S") 当前安装目录为$v2ray_path,安装路径剩余空间不足请修改路径！" >> ${logfile}
			fi

		}
		
		download_binary
		echo "" > ${dir}v2ray_version
		echo "$v2ray_new_version" > ${dir}v2ray_version
		rm -rf ${dir}v2ray_new_version
fi
