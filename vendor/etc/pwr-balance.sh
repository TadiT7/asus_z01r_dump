#!/system/bin/sh -x
#This is balance mode

#enable CABC function
echo 3 > /proc/cabc_mode_switch

setprop persist.asus.power.mode balance 
