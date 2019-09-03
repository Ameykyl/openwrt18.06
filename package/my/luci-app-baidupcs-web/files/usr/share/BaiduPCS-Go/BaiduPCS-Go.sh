#!/bin/sh
logfile="/tmp/BaiduPCS-Go.log"
dir="/usr/share/BaiduPCS-Go/"
new_version=$(curl -s "https://github.com/liuzhuoling2011/baidupcs-web/tags/"| grep "/liuzhuoling2011/baidupcs-web/releases/tag/"| head -n 1| awk -F "/tag/" '{print $2}'| sed 's/\">//')
echo "$new_version" > ${dir}new_version
if [ $? -eq 0 ];then
	edition=$(uci get baidupcs-web.config.edition 2>/dev/null)
	if [ "$edition" = "auto_detected" ];then
		new_version=$(cat ${dir}new_version|sed -n '1p')
	else
		new_version=$edition
	fi
	echo "$(date "+%Y-%m-%d %H:%M:%S") BaiduPCS-Go下载启动，验证版本..." >> ${logfile}
	echo "$(date "+%Y-%m-%d %H:%M:%S") 检测到BaiduPCS-Go版本为$new_version..." >> ${logfile}

		UpdateApp() {
			for a in $(opkg print-architecture | awk '{print $2}'); do
				case "$a" in
					all|noarch)
						;;
					aarch64_armv8-a|aarch64)
						ARCH="linux-amd64"
						;;
					arm_arm1176jzf-s_vfp|arm_arm926ej-s|arm_cortex-a15_neon-vfpv4|arm_cortex-a5|arm_cortex-a53_neon-vfpv4|arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|arm_cortex-a9_neon|arm_cortex-a9_vfpv3|arm_fa526|arm_mpcore|arm_mpcore_vfp|arm_xscale|armeb_xscale)
						ARCH="linux-arm"
						;;
					i386_pentium|i386_pentium4)
						ARCH="linux-86"
						;;
					mipsel_24kc|mipsel_24kec_dsp|mipsel_74kc|mipsel_mips32|mipsel_1004kc_dsp)
						ARCH="linux-mipsle"
						;;
					x86_64)
						ARCH="linux-amd64"
						;;
					*)
						exit 0
						;;
				esac
			done
		}

		download_binary(){
			echo "$(date "+%Y-%m-%d %H:%M:%S") 开始下载BaiduPCS-Go可执行文件..." >> ${logfile}
			rm -rf $bin_dir/Baidu*.zip
			bin_dir="/tmp"
			UpdateApp
			cd $bin_dir
			down_url=https://github.com/liuzhuoling2011/baidupcs-web/releases/download/"$new_version"/BaiduPCS-Go-"$new_version"-"$ARCH".zip

			local a=0
			while [ ! -f $bin_dir/BaiduPCS-Go-"$new_version"-"$ARCH".zip ]; do
				[ $a = 6 ] && exit
				curl -OL --connect-timeout 20 --retry 5 --location --insecure $down_url
				sleep 2
				let "a = a + 1"
			done
	
			if [ -f $bin_dir/BaiduPCS-Go-"$new_version"-"$ARCH".zip ]; then
				echo "$(date "+%Y-%m-%d %H:%M:%S") 成功下载BaiduPCS-Go可执行文件" >> ${logfile}
				killall -q -9 BaiduPCS-Go

				unzip -o BaiduPCS-Go-"$new_version"-"$ARCH".zip -d $bin_dir/
				if [ -f /usr/bin/BaiduPCS-Go ]; then
					rm -rf /usr/bin/BaiduPCS-Go
				fi
				mv $bin_dir/BaiduPCS-Go-"$new_version"-"$ARCH"/BaiduPCS-Go /usr/bin/
				rm -rf $bin_dir/BaiduPCS-Go-"$new_version"-"$ARCH"
				rm -rf $bin_dir/BaiduPCS-Go-"$new_version"-"$ARCH".zip
				if [ -f "/usr/bin/BaiduPCS-Go" ]; then
					chmod +x /usr/bin/BaiduPCS-Go
					/etc/init.d/baidupcs-web restart
				fi
			else
				echo "$(date "+%Y-%m-%d %H:%M:%S") 下载BaiduPCS-Go可执行文件失败，请重试！" >> ${logfile}
			fi


		}

		download_binary
		rm -rf ${dir}new_version
fi
