#!/system/bin/sh


umask 0;
sync
tcpdump_enable=`getprop persist.asuslog.tcpdump.enable`
SAVE_LOG_DATA="`date +%Y_%m_%d_%H_%M_%S`"
/system/xbin/tcpdump  -i any -p -s 0 -W 2 -C 100 -w /data/media/0/Asuslog/TcpDump/$SAVE_LOG_DATA"tcpdump.pcap"
