#!/bin/sh

sleeptime=30
logfile="/var/log/dnscache.file"
adglogfile="/etc/AdGuardHome/data/querylog.json"
dns_enable=$(uci get sfe.config.dns 2>/dev/null)
dnscache_enable=$(uci get sfe.config.dnscache_enable 2>/dev/null)

clean_log(){
logrow=$(grep -c "" ${logfile})
if [ $logrow -ge 500 ];then
    cat /dev/null > ${logfile}
    echo "$curtime Log条数超限，清空处理！" >> ${logfile}
fi

adglogrow=$(grep -c "" ${adglogfile})
if [ $adglogrow -ge 5000 ];then
    cat /dev/null > ${adglogfile}
    echo "$curtime adgLog条数超限，清空处理！" >> ${logfile}
fi

}

while [ $dns_enable -eq 1 ];
do
curtime=`date "+%H:%M:%S"`
echo "$curtime online! "
clean_log
if [ $dns_enable -eq 1 ]; then
	if [ $dnscache_enable = "3" ];  then
		if ! pidof AdGuardHome>/dev/null; then
			if [ ! -d "/var/etc/AdGuardHome/" ];  then
				mkdir -p /var/etc/AdGuardHome
				ln -s /etc/AdGuardHome/* /var/etc/AdGuardHome/
			fi
			AdGuardHome -c /var/etc/AdGuardHome/AdGuardHome.yaml -w /var/etc/AdGuardHome -h 0.0.0.0 -p 3000 >/dev/null 2>&1 &
			echo "$curtime 重启服务！" >> ${logfile}
		fi
	else
		if ! pidof dnscache>/dev/null; then
			if [ $dnscache_enable = "1" ];  then
			/usr/sbin/dnscache -c /var/etc/dnscache.conf -d
			elif [ $dnscache_enable = "2" ];  then
			dnscache -f /var/run/dnscache/dnscache.conf -d
			fi
			echo "$curtime 重启服务！" >> ${logfile}
		fi
	fi
fi

sleep ${sleeptime}
continue
done

