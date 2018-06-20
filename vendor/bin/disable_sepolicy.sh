#!/vendor/bin/sh
sepolicy_flag=`getprop persist.asus.sepolicy`

if [ ".$sepolicy_flag" == ".0" ];then
	setenforce 0
else
	setenforce 1
fi
