#!/vendor/bin/sh

modemlogsize=`getprop persist.asuslog.modem.size`
modemlogcount=`getprop persist.asuslog.modem.count`
modemlogpath=`getprop persist.asuslog.modem.path`
modemcfgpath=`getprop persist.asuslog.modem.diacfg`

#Add-Begin by terry_tao 2015/11/30
#fix not capture modem logs when reboot device due to /sdcard/ hasn't been created
sdcardpath="/sdcard/"
count=1000
while [ ! -d $sdcardpath ] && [ $count -gt 0 ]
do
  ((count--))
  usleep 200000
done
#Add-End by terry_tao 2015/11/30

if [ ! -n "$modemlogsize" ]; then
  modemlogsize='200'
fi

if [ ! -n "$modemlogcount" ]; then
  modemlogcount='3'
fi 

if [ ! -n "$modemlogpath" ]; then
  modemlogpath='/sdcard/Asuslog/Modem'
else
   if [ ! -d "$modemlogpath" ]; then
	 setprop persist.asuslog.modem.path /sdcard/Asuslog/Modem
 	 modemlogpath='/sdcard/Asuslog/Modem'
	 if [ ! -f "$modemlogpath" ]; then
		mkdir -p $modemlogpath
         else
		rm -r $modemlogpath
		mkdir -p $modemlogpath
	 fi
   fi
fi

if [ ! -n "$modemcfgpath" ]; then
  modemcfgpath='/vendor/bin/modem_and_audio.cfg'
  setprop persist.asuslog.modem.diacfg "/vendor/bin/modem_and_audio.cfg"
fi 

if [ "$modemcfgpath" = "/vendor/bin/Diag.cfg" ]; then
	/vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/modem_audio_gps -s $modemlogsize -n $modemlogcount -c
elif [ "$modemcfgpath" = "/vendor/bin/modem_and_audio.cfg" ]; then
        /vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/modem_audio -s $modemlogsize -n $modemlogcount -c
elif [ "$modemcfgpath" = "/vendor/bin/gps.cfg" ]; then
        /vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/gps -s $modemlogsize -n $modemlogcount -c
elif [ "$modemcfgpath" = "/vendor/bin/audio.cfg" ]; then
        /vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/audio -s $modemlogsize -n $modemlogcount -c
elif [ "$modemcfgpath" = "/vendor/bin/Compact_mode.cfg" ]; then
	/vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/compact -s $modemlogsize -n $modemlogcount -c
elif [ "$modemcfgpath" = "/vendor/bin/wifi_bt.cfg" ]; then
	/vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/wifi_bt -s $modemlogsize -n $modemlogcount -c
elif [ "$modemcfgpath" = "/vendor/bin/fm.cfg" ]; then
	/vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/fm -s $modemlogsize -n $modemlogcount -c
elif [ "$modemcfgpath" = "/vendor/bin/sns.cfg" ]; then
	/vendor/bin/diag_mdlog -f $modemcfgpath -o $modemlogpath/sns -s $modemlogsize -n $modemlogcount -c
fi

