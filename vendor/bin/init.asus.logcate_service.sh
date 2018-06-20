#!/vendor/bin/sh

LOGCATE_COUNT=`getprop persist.asus.logcatcount`

if [ ".$LOGCATE_COUNT" == "." ];then
	/system/bin/logcat -r 10000 -b events -n 20 -v threadtime -f /data/logcat_log/logcat-events.txt
else
	/system/bin/logcat -r 10000 -b events -n $LOGCATE_COUNT -v threadtime -f /data/logcat_log/logcat-events.txt
fi
