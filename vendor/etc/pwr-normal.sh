#!/system/bin/sh -x
#This is normal mode

#disable CABC function
echo 0 > /proc/cabc_mode_switch

setprop persist.asus.power.mode normal
