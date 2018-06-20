#!/system/bin/sh

umask 0;
sync
tzlog_enable=`getprop persist.asuslog.tzlog.enable`


if [ ".$tzlog_enable" == ".1" ];then 
        SAVE_LOG_DATA="`date +%Y_%m_%d_%H_%M_%S`"
		cat /d/tzdbg/log >  /data/media/0/Asuslog/TZ/$SAVE_LOG_DATA"tz.txt"
fi
