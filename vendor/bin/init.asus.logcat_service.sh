#!/vendor/bin/sh

LOGCAT_COUNT=`getprop persist.asus.logcatcount`

if [ ".$LOGCAT_COUNT" == "." ];then
	/system/bin/logcat -b kernel -b main -b system -b crash -r 10000 -n 20 -v threadtime -f /data/logcat_log/logcat.txt
else
	echo "/system/bin/logcat -b kernel -b main -b system -b crash -r 10000 -n $LOGCAT_COUNT -v threadtime -f /data/logcat_log/logcat.txt"
	/system/bin/logcat -b kernel -b main -b system -b crash -r 10000 -n $LOGCAT_COUNT -v threadtime -f /data/logcat_log/logcat.txt
fi
