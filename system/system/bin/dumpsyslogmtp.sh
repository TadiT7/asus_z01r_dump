#!/system/bin/sh

LOG_TAG="Bugreport"
LOG_NAME="${0}:"

SAVE_LOG_PATH=`getprop asus.savelogmtp.folder`
savelog_upload=`getprop asus.savelogmtp.forupload`

CHECK_DUMPSTATE_PRO=`getprop debug.asus.savelogmtp.dumpstate`
CHECK_DUMPSTATE_OK=`getprop init.svc.bugreport`

GENERAL_LOG=/data/media/0/ASUS/LogUploader/general/sdcard
BUGREPORT_PATH=/data/user_de/0/com.android.shell/files/bugreports

loge ()
{
  /system/bin/log -t $LOG_TAG -p e "$LOG_NAME $@"
}

generate_bugreport ()
{
	loge "debug.asus.savelogmtp.dumpstate is .$CHECK_DUMPSTATE_PRO"
	setprop debug.asus.savelogmtp.dumpstate 1

	if [ ".$CHECK_DUMPSTATE_OK" == "." ]; then
		sleep 2
	fi
	
#usually it takes 5 minutes
	for i in $(seq 240); do		
		CHECK_DUMPSTATE_OK=`getprop init.svc.bugreport`
		loge "bugreport=$CHECK_DUMPSTATE_OK, waiting for it stopped..."
		if [ ".$CHECK_DUMPSTATE_OK" == ".stopped" ]; then
			break
		elif [ ".$CHECK_DUMPSTATE_OK" == "." ]; then
			break
		else	
			sleep 2
		fi
	done;
	
	setprop debug.asus.savelogmtp.dumpstate 0
	
	loge "copy bugreport to LogUploader folder"
	if [ ! -e $GENERAL_LOG ]; then
		loge "LogUploader dir isn't exist, make dir..."
		mkdir -p $GENERAL_LOG
	fi
	
	chmod -R  777 $BUGREPORT_PATH/
	
	for filename in $BUGREPORT_PATH/*; do
		name=${filename##*/}
		loge "copy $filename to $GENERAL_LOG"
		cp  $filename $GENERAL_LOG
		rm $filename
	done
	
	loge "Generating bugreport completed"
}

if [ ".$savelog_upload" == ".1" ]; then
	generate_bugreport
	setprop asus.savelogmtp.forupload 0
	setprop debug.asus.savelogmtp.savedumpsyslogs 0
	exit 1
elif [ ".$SAVE_LOG_PATH" == "." ]; then
	generate_bugreport
	setprop debug.asus.savelogmtp.savedumpsyslogs 0
	exit 1
fi

DUMP_LOG_PATH=$SAVE_LOG_PATH"/Dumpsys"
mkdir  $DUMP_LOG_PATH

for x in SurfaceFlinger window activity input_method alarm power battery batterystats audio cpuinfo meminfo power wifi diskstats; do
	dumpsys $x > $DUMP_LOG_PATH/$x.txt
	loge "dumpsys $x > $SAVE_LOG_PATH/$x.txt"
done

dumpsys window -a > $DUMP_LOG_PATH/window.txt
	# save debug report
dumpsys > $DUMP_LOG_PATH/dumpsys.txt

chmod -R 777 $SAVE_LOG_PATH/

setprop debug.asus.savelogmtp.savedumpsyslogs 0
