#!/vendor/bin/sh

LOG_TAG="Bugreport"
LOG_NAME="${0}:"

#MODEM_LOG
MODEM_LOG=/data/media/0/ASUS/LogUploader/modem
#MODEM_LOG=/sdcard/ASUS/LogUploader/modem
#TCP_DUMP_LOG
TCP_DUMP_LOG=/data/media/0/ASUS/LogUploader/TCPdump
#TCP_DUMP_LOG=/sdcard/ASUS/LogUploader/TCPdump
#GENERAL_LOG
GENERAL_LOG=/data/media/0/ASUS/LogUploader/general/sdcard
#GENERAL_LOG=/sdcard/ASUS/LogUploader/general/sdcard
#BUGREPORT_PATH
BUGREPORT_PATH=/data/user_de/0/com.android.shell/files/bugreports

#Dumpsys folder
DUMPSYS_DIR=/data/media/0/ASUS/LogUploader/general/sdcard/Dumpsys

#BUSYBOX=busybox

savelogs_prop=`getprop persist.asus.savelogs`
is_tcpdump_status=`getprop init.svc.tcpdump-warp`

modem_prop=`getprop persist.asuslog.qxdmlog.enable`
tcpdump_prop=`getprop persist.asuslog.tcpdump.enable`
tagstartdump_prop=`getprop persist.asus.savelogmtp.tagstartdump`

CHECK_DUMPSTATE_PRO=`getprop debug.asus.savelogmtp.dumpstate`
CHECK_DUMPSTATE_OK=`getprop init.svc.bugreport`

loge ()
{
  /system/bin/log -t $LOG_TAG -p e "$LOG_NAME $@"
}

generate_bugreport ()
{
	echo "debug.asus.savelogmtp.dumpstate is .$CHECK_DUMPSTATE_PRO"
	setprop debug.asus.savelogmtp.dumpstate 1

	if [ ".$CHECK_DUMPSTATE_OK" == "." ]; then
		sleep 2
	fi
	
#usually it takes 5 minutes
	for i in $(seq 240); do		
		CHECK_DUMPSTATE_OK=`getprop init.svc.bugreport`
		echo "bugreport=$CHECK_DUMPSTATE_OK, waiting for it stopped..."
		if [ ".$CHECK_DUMPSTATE_OK" == ".stopped" ]; then
			break
		elif [ ".$CHECK_DUMPSTATE_OK" == "." ]; then
			break
		else	
			sleep 2
		fi
	done;

	echo "copy bugreport to LogUploader folder"
	if [ ! -e $GENERAL_LOG ]; then
		echo "LogUploader dir isn't exist, make dir..."
		mkdir -p $GENERAL_LOG
	fi
	
	chmod -R  666 $BUGREPORT_PATH/
	
	for filename in $BUGREPORT_PATH/*; do
		name=${filename##*/}
		echo "copy $filename to $GENERAL_LOG"
		cp  $filename $GENERAL_LOG
		rm $filename
	done
	
	setprop debug.asus.savelogmtp.dumpstate 0
	echo "Generating bugreport completed"
}

check_dumpsys_ok ()
{
	sleep 5
	setprop asus.savelogmtp.check_dump $tagstartdump_prop
	for i in $(seq 300); do		
		tagstartdump_prop=`getprop persist.asus.savelogmtp.tagstartdump`
		if [ ".$tagstartdump_prop" == ".1" ]; then
			sleep 2
			echo "Running"
		elif [ ".$tagstartdump_prop" == ".0" ]; then
			echo "Stopped"
			break
		else
			echo "Not execute"
			break;
		fi
	done;
	setprop persist.asus.savelogmtp.tagstartdump 0
}

save_general_log () {
	setprop persist.asus.savelogmtp.tagstartdump 1
	setprop asus.savelogmtp.forupload 1
	setprop debug.asus.savelogmtp.savedumpsyslogs 1
	############################################################################################
	# save cmdline
	cat /proc/cmdline > $GENERAL_LOG/cmdline.txt
	echo "cat /proc/cmdline > $GENERAL_LOG/cmdline.txt"	
	############################################################################################
	# save mount table
	cat /proc/mounts > $GENERAL_LOG/mounts.txt
	echo "cat /proc/mounts > $GENERAL_LOG/mounts.txt"
	############################################################################################
	getenforce > $GENERAL_LOG/getenforce.txt
	echo "getenforce > $GENERAL_LOG/getenforce.txt"
	############################################################################################
	# save property
	getprop > $GENERAL_LOG/getprop.txt
	echo "getprop > $GENERAL_LOG/getprop.txt"
	############################################################################################
	# save network info
	cat /proc/net/route > $GENERAL_LOG/route.txt
	echo "cat /proc/net/route > $GENERAL_LOG/route.txt"
	ifconfig -a > $GENERAL_LOG/ifconfig.txt
	echo "ifconfig -a > $GENERAL_LOG/ifconfig.txt"
	############################################################################################
	# save software version
	echo "AP_VER: `getprop ro.build.display.id`" > $GENERAL_LOG/version.txt
	echo "CP_VER: `getprop gsm.version.baseband`" >> $GENERAL_LOG/version.txt
	echo "BT_VER: `getprop bt.version.driver`" >> $GENERAL_LOG/version.txt
	echo "WIFI_VER: `getprop wifi.version.driver`" >> $GENERAL_LOG/version.txt
	echo "GPS_VER: `getprop gps.version.driver`" >> $GENERAL_LOG/version.txt
	echo "BUILD_DATE: `getprop ro.build.date`" >> $GENERAL_LOG/version.txt
	############################################################################################
	# save load kernel modules
	lsmod > $GENERAL_LOG/lsmod.txt
	echo "lsmod > $GENERAL_LOG/lsmod.txt"
	############################################################################################
	# save process now
	ps >  $GENERAL_LOG/ps.txt
	echo "ps > $SAVE_LOG_PATH/ps.txt"
	ps -t -p > $GENERAL_LOG/ps_thread.txt
	echo "ps > $SAVE_LOG_PATH/ps_thread.txt"
	############################################################################################
	# save kernel message
	dmesg > $GENERAL_LOG/dmesg.txt
	echo "dmesg > $GENERAL_LOG/dmesg.txt"
	############################################################################################
	# copy data/log to data/media
	#$BUSYBOX ls -R -l /data/log/ > $GENERAL_LOG/ls_data_log.txt
	#mkdir $GENERAL_LOG/log
	#$BUSYBOX cp /data/log/* $GENERAL_LOG/log/
	#echo "$BUSYBOX cp /data/log $GENERAL_LOG"
	############################################################################################
	# copy data/tombstones to data/media
	ls -R -l /data/tombstones/ > $GENERAL_LOG/ls_data_tombstones.txt
	mkdir $GENERAL_LOG/tombstones
	cp -r /data/tombstones/* $GENERAL_LOG/tombstones/
	echo "cp /data/tombstones $GENERAL_LOG"	
	############################################################################################
	# copy Debug Ion information to data/media
	mkdir $GENERAL_LOG/ION_Debug
	cp /d/ion/* $GENERAL_LOG/ION_Debug/
	############################################################################################
	# copy data/logcat_log to data/media
	#busybox ls -R -l /data/logcat_log/ > $GENERAL_LOG/ls_data_logcat_log.txt
	#$BUSYBOX cp -r /data/logcat_log/ $GENERAL_LOG
	#echo "$BUSYBOX cp -r /data/logcat_log $GENERAL_LOG"
	mkdir $GENERAL_LOG/logcat_log
	# logcat & radio
	ls -R -l /data/logcat_log/ > $GENERAL_LOG/logcat_log/ls_data_logcat_log.txt
	cp -r /data/logcat_log/ $GENERAL_LOG/logcat_log
	############################################################################################
	# copy /vendor/asdf/ASUSEvtlog.txt to ASDF
	cp -r /sdcard/asus_log/ASUSEvtlog.txt $GENERAL_LOG #backward compatible
	cp -r /sdcard/asus_log/ASUSEvtlog_old.txt $GENERAL_LOG #backward compatible
	cp -r /vendor/asdf/ASUSEvtlog.txt $GENERAL_LOG
	cp -r /vendor/asdf/ASUSEvtlog_old.txt $GENERAL_LOG
	cp -rf /vendor/asdf $GENERAL_LOG
	cp -r /vendor/asdf/ASDF $GENERAL_LOG
	rm /vendor/asdf/ASUSEvtlog*.txt
	rm -r /vendor/asdf/ASDF/ASDF.*
	echo "cp -r /vendor/asdf/ASUSEvtlog.txt $GENERAL_LOG"
	############################################################################################
	# copy /data/misc/wifi/wpa_supplicant.conf
	# copy /data/misc/wifi/hostapd.conf
	# copy /data/misc/wifi/p2p_supplicant.conf
	#ls -R -l /data/misc/wifi/ > $GENERAL_LOG/ls_wifi_asus_log.txt
	#cp -r /data/misc/wifi/wpa_supplicant.conf $GENERAL_LOG
	#echo "cp -r /data/misc/wifi/wpa_supplicant.conf $GENERAL_LOG"
	#cp -r /data/misc/wifi/hostapd.conf $GENERAL_LOG
	#echo "cp -r /data/misc/wifi/hostapd.conf $GENERAL_LOG"
	#cp -r /data/misc/wifi/p2p_supplicant.conf $GENERAL_LOG
	#echo "cp -r /data/misc/wifi/p2p_supplicant.conf $GENERAL_LOG"
	############################################################################################
	# mv /data/anr to data/media
	ls -R -l /data/anr > $GENERAL_LOG/ls_data_anr.txt
	mkdir $GENERAL_LOG/anr
	cp /data/anr/* $GENERAL_LOG/anr/
	echo "cp /data/anr $GENERAL_LOG"
	############################################################################################
	# save system information
	mkdir $DUMPSYS_DIR
	# 	for x in SurfaceFlinger activity input_method alarm power battery batterystats audio cpuinfo meminfo power wifi diskstats; do
	# 	dumpsys $x > $DUMPSYS_DIR/$x.txt
	# 	echo "dumpsys $x > $DUMPSYS_DIR/$x.txt"
	# done
	# 	dumpsys window -a > $DUMPSYS_DIR/window.txt
	############################################################################################
	# [BugReporter]Save ps.txt to Dumpsys folder
	ps -t -p -P > $GENERAL_LOG/ps.txt
	############################################################################################
	date > $GENERAL_LOG/date.txt
	echo "date > $GENERAL_LOG/date.txt"
	############################################################################################	
	# save debug report
	#dumpstate > $GENERAL_LOG/dumpstate.txt
	#echo "dumpstate > $GENERAL_LOG/dumpstate.txt"
	############################################################################################
    micropTest=`cat /sys/class/switch/pfs_pad_ec/state`
	if [ "${micropTest}" = "1" ]; then
	    date > $GENERAL_LOG/microp_dump.txt
	    cat /d/gpio >> $GENERAL_LOG/microp_dump.txt                   
        echo "cat /d/gpio > $GENERAL_LOG/microp_dump.txt"  
        cat /d/microp >> $GENERAL_LOG/microp_dump.txt
        echo "cat /d/microp > $GENERAL_LOG/microp_dump.txt"
	fi
	############################################################################################
	df > $GENERAL_LOG/df.txt
	echo "df > $GENERAL_LOG/df.txt"
	
	check_dumpsys_ok
#generate bugreport and move it to Logupload folder	
#	generate_bugreport
}

save_modem_log () {
#	mv /data/media/0/diag_logs/QXDM_logs $MODEM_LOG 
#	echo "mv /data/media/diag_logs/QXDM_logs $MODEM_LOG"
	if [ ".$modem_prop" == ".2" ]; then
		mv /data/media/0/Asuslog/Modem/ $MODEM_LOG
		echo "mv /data/media/0/Asuslog/Modem $MODEM_LOG"
	elif [ ".$modem_prop" == ".1" ]; then
		setprop persist.asuslog.qxdmlog.enable 2
		mv /data/media/0/Asuslog/Modem/ $MODEM_LOG
		echo "mv /data/media/0/Asuslog/Modem $MODEM_LOG"
		mkdir /data/media/0/Asuslog/Modem
		setprop persist.asuslog.qxdmlog.enable 1
	fi
}

save_tcpdump_log () {
#	if [ -d "/data/logcat_log" ]; then
#		if [ ".$is_tcpdump_status" == ".running" ]; then
#			stop tcpdump-warp
#			mv /data/logcat_log/capture.pcap0 /data/logcat_log/capture.pcap0-1
#			start tcpdump-warp
#			for fname in /data/logcat_log/capture.pcap*
#			do
#				if [ -e $fname ]; then
#					if [ ".$fname" != "./data/logcat_log/capture.pcap0" ]; then
#						mv $fname $TCP_DUMP_LOG
#					fi
#				fi
#			done
#		else
#			mv /data/logcat_log/capture.pcap* $TCP_DUMP_LOG
#		fi
#	fi
############################################################################################
if [ ".$tcpdump_prop" == ".0" ]; then
	mv /data/media/0/Asuslog/TcpDump/ $TCP_DUMP_LOG
	echo "mv /data/media/0/Asuslog/TcpDump $TCP_DUMP_LOG"
elif [ ".$tcpdump_prop" == ".1" ]; then
	setprop persist.asuslog.tcpdump.enable 0
	mv /data/media/0/Asuslog/TcpDump/ $TCP_DUMP_LOG
	echo "mv /data/media/0/Asuslog/TcpDump $TCP_DUMP_LOG"
	setprop persist.asuslog.tcpdump.enable 1
fi
}

remove_folder () {
	# remove folder
	if [ -e $GENERAL_LOG ]; then
		rm -r $GENERAL_LOG
	fi
	
	if [ -e $MODEM_LOG ]; then
		rm -r $MODEM_LOG
	fi
	
	if [ -e $TCP_DUMP_LOG ]; then
		rm -r $TCP_DUMP_LOG
	fi
}

create_folder () {
	# create folder
	mkdir -p $GENERAL_LOG
	echo "mkdir -p $GENERAL_LOG"
	
	mkdir -p $MODEM_LOG
	echo "mkdir -p $MODEM_LOG"
	
	mkdir -p $TCP_DUMP_LOG
	echo "mkdir -p $TCP_DUMP_LOG"
}

if [ ".$savelogs_prop" == ".0" ]; then
	remove_folder
	# Ack BugReporter
    setprop persist.asus.broadcast com.asus.removelogs.completed
	
elif [ ".$savelogs_prop" == ".1" ]; then
	# check mount file
	umask 0;
	sync
	############################################################################################
	# remove folder
	#remove_folder

	# create folder
	create_folder
	
	# save_general_log
	save_general_log
	
	############################################################################################
	# sync data to disk 
	# 1015 sdcard_rw
	chmod -R 777 $GENERAL_LOG
	sync

	setprop persist.asus.broadcast com.asus.savelogs.completed
 
	echo "Done"
elif [ ".$savelogs_prop" == ".2" ]; then
	# check mount file
	umask 0;
	sync
	############################################################################################
	# remove folder
	#remove_folder

	# create folder
	create_folder
	
	# save_modem_log
	save_modem_log
	
	############################################################################################
	# sync data to disk 
	# 1015 sdcard_rw
	chmod -R 777 $MODEM_LOG
	sync

	setprop persist.asus.broadcast com.asus.savelogs.completed
 
	echo "Done"
elif [ ".$savelogs_prop" == ".3" ]; then
	# check mount file
	umask 0;
	sync
	############################################################################################
	# remove folder
	#remove_folder

	# create folder
	create_folder
	
	# save_tcpdump_log
	save_tcpdump_log
	
	############################################################################################
	# sync data to disk 
	# 1015 sdcard_rw
	chmod -R 777 $TCP_DUMP_LOG
	sync

	setprop persist.asus.broadcast com.asus.savelogs.completed
 
	echo "Done"
elif [ ".$savelogs_prop" == ".4" ]; then
	# check mount file
	umask 0;
	sync
	setprop asus.savelogmtp.testd savelogs_propf
	############################################################################################
	# remove folder
	remove_folder

	# create folder
	create_folder
	
	# save_general_log
	save_general_log
	
	# save_modem_log
	save_modem_log
	
	# save_tcpdump_log
	save_tcpdump_log
	
	############################################################################################
	# sync data to disk 
	# 1015 sdcard_rw
	chmod -R 777 $GENERAL_LOG
	chmod -R 777 $MODEM_LOG
	chmod -R 777 $TCP_DUMP_LOG

#	setprop persist.asus.savelogs.dumpstate 0
#	setprop persist.asus.savelogs.dumpstate 1
	setprop persist.asus.uts com.asus.savelogs.completed
    setprop persist.asus.broadcast com.asus.savelogs.completed	
fi
