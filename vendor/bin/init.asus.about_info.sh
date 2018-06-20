#!/vendor/bin/sh
about_flag=`getprop persist.asuslog.aboutinfo`
cmdline_info=`cat /proc/cmdline`
emmc_health=`cat /proc/storage_primary_health`
boot_info=`cat /proc/bootinfo`
keybox=`getprop atd.keybox.ready`
touch_fw=`cat /sys/class/switch/touch/name`

if [ ".$about_flag" == ".1" ];then
	echo "Cmdline Info:" > /data/media/0/Asuslog/about_info
	echo "$cmdline_info" >> /data/media/0/Asuslog/about_info
	echo "\n" >> /data/media/0/Asuslog/about_info
	echo "Boot Info" >> /data/media/0/Asuslog/about_info
	echo "$boot_info" >> /data/media/0/Asuslog/about_info
	echo "\n" >> /data/media/0/Asuslog/about_info
	echo "EMMC Health:$emmc_health" >> /data/media/0/Asuslog/about_info
	if test "$keybox"; then
		echo "Keybox Status:TRUE" >> /data/media/0/Asuslog/about_info
	else
		echo "Keybox Status:FALSE" >> /data/media/0/Asuslog/about_info
	fi
	echo "Touch FW Version:" >> /data/media/0/Asuslog/about_info
	echo "$touch_fw" >> /data/media/0/Asuslog/about_info
	
	chmod -R 666  /data/media/0/Asuslog/about_info
elif [ ".$about_flag" == ".0" ];then
	rm -rf /data/media/0/Asuslog/about_info
else
	echo "ERROR!!"
fi
