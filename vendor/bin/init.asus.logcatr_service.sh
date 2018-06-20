#!/vendor/bin/sh

LOGCATR_COUNT=`getprop persist.asus.logcatcount`

if [ ".$LOGCATR_COUNT" == "." ];then
	/system/bin/logcat -r 10000 -b radio -n 20 -v time -f /data/logcat_log/logcat-radio.txt
else
	/system/bin/logcat -r 10000 -b radio -n $LOGCATR_COUNT -v time -f /data/logcat_log/logcat-radio.txt
fi
