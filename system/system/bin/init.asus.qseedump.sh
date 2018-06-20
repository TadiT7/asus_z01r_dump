#!/system/bin/sh
umask 0;
sync
qseelog_enable=`getprop persist.asuslog.qseelog.enable`


if [ ".$qseelog_enable" == ".1" ];then 
        SAVE_LOG_DATA="`date +%Y_%m_%d_%H_%M_%S`"
		cat /d/tzdbg/qsee_log >  /data/media/0/Asuslog/QSEE/$SAVE_LOG_DATA"qsee.txt"
fi
