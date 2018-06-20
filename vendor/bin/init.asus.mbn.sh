#!/vendor/bin/sh
APDP_MBN=/sdcard/qpst_mbn/apdp.mbn
MSADP_MBN=/sdcard/qpst_mbn/msadp.mbn
asus_qpstmbn_prop='persist.asuslog.qpst.enable'
asus_qpstmbn=`getprop $asus_qpstmbn_prop`

if [ ".$asus_qpstmbn" == ".1" ]; then
	if [ -e $APDP_MBN ]; then
		#echo "dd if=$APDP_MBN of=/dev/block/bootdevice/by-name/apdp" > /proc/asusevtlog
		dd if=$APDP_MBN of=/dev/block/bootdevice/by-name/apdp
	fi
	if [ -e $MSADP_MBN ]; then
		#echo "dd if=$MSADP_MBN of=/dev/block/bootdevice/by-name/msadp" > /proc/asusevtlog
		dd if=$MSADP_MBN of=/dev/block/bootdevice/by-name/msadp
	fi
elif [ ".$asus_qpstmbn" == ".0" ]; then
	#echo "clean mbn" > /proc/asusevtlog
	dd if=/dev/zero of=/dev/block/bootdevice/by-name/apdp
	dd if=/dev/zero of=/dev/block/bootdevice/by-name/msadp
fi
#echo 1500 > /sys/class/timed_output/vibrator/enable
