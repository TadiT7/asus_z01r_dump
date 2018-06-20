#!/vendor/bin/sh

startlog_flag=`getprop persist.asus.startlog`
version_type=`getprop ro.build.type`
check_factory_version=`getprop ro.asus.factory`
is_sb=`grep -c SB=Y /proc/cmdline`
#echo 49152 > /proc/sys/vm/min_free_kbytes
action_log='/dev/console'

if test "$version_type" = "userdebug"; then
	if test "$check_factory_version" = "1"; then
#		start mpdecision
	echo "[ASUS]in factory version" > $action_log
	fi
echo "[ASUS]in userdebug" > $action_log
fi 

if test -e /data/everbootup; then
	echo "[ASUS]/data/everbootup exit" > $action_log
else
	echo "[ASUS] /data/everbootup not exit" > $action_log
	setprop persist.asus.ramdump 1
	setprop persist.asus.autosavelogmtp 0
fi

if  test "$version_type" = "eng"; then
	setprop persist.asus.startlog 1
	setprop persist.asus.kernelmessage 7
elif test "$version_type" = "userdebug"; then
		if test "$check_factory_version" = "1"; then
			if test "$is_sb" = "1"; then
				setprop persist.asus.kernelmessage 0
			else
				setprop persist.asus.kernelmessage 7
			fi
			setprop persist.asus.enable_navbar 1
		else
			setprop persist.asus.kernelmessage 7	
		fi
	setprop persist.asus.startlog 1
	setprop persist.sys.downloadmode.enable 1
	
fi

startlog_flag=`getprop persist.asus.startlog`

if test  -e  /data/logcat_log; then
	case "$startlog_flag" in
	"1")
#		setprop persist.asus.asusklog 1
#		setprop sys.config.klog 1
		setprop persist.asus.kernelmessage 7	
		start logcatdump
		start logcatdump-radio
		start logcatdump-events
		;;
	"0")
#		setprop persist.asus.asusklog 0
#		setprop sys.config.klog 0
		setprop persist.asus.kernelmessage 0
		stop logcatdump
		stop logcatdump-radio
		stop logcatdump-events
		;;
	"")
		stop logcatdump
		stop logcatdump-radio
		stop logcatdump-events
		;;
	esac
fi

