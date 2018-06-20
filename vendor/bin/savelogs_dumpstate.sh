#!/vendor/bin/sh

LOG_TAG="Bugreport"
LOG_NAME="${0}:"

loge ()
{
  /system/bin/log -t $LOG_TAG -p e "$LOG_NAME $@"
}

GENERAL_LOG=/data/media/0/ASUS/LogUploader/general/sdcard
BUGREPORT_PATH=/data/user_de/0/com.android.shell/files/bugreports
#mkdir -p $GENERAL_LOG
#dumpstate -q > $GENERAL_LOG/dumpstate.txt
#dumpstate -q -d -z -o $BUGREPORT_PATH/bugreport
CHECK_DUMPSTATE_PRO=`getprop debug.asus.savelogmtp.dumpstate`
loge "debug.asus.savelogmtp.dumpstate is .$CHECK_DUMPSTATE_PRO"
setprop debug.asus.savelogmtp.dumpstate 1

CHECK_DUMPSTATE_OK=`getprop init.svc.bugreport`
if [ ".$CHECK_DUMPSTATE_OK" == "." ]; then
	sleep 2
fi
#usually it takes 5 minutes
for i in $(seq 240); do		
	setprop debug.savelogmtp.testwait 1
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

setprop debug.savelogmtp.testwait 2

loge "copy bugreport to LogUploader folder"
if [ ! -e $GENERAL_LOG ]; then
	loge "LogUploader dir isn't exist, make dir..."
	mkdir -p $GENERAL_LOG
fi

chmod -R  666 $BUGREPORT_PATH/

for filename in $BUGREPORT_PATH/*; do
	name=${filename##*/}
    loge "copy $filename to $GENERAL_LOG"
    cp  $filename $GENERAL_LOG
    rm $filename
done

setprop debug.savelogmtp.testwait 3

setprop debug.asus.savelogmtp.dumpstate 0
loge "Generate bugreport  to LogUploader completed"
#chmod -R 777 $GENERAL_LOG/
#setprop persist.asus.savelogs.complete 1
#setprop persist.asus.savelogs.complete 0
