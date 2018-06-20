#!/system/bin/sh -x
#This is ultra mode

#enable CABC function
echo 3 > /proc/cabc_mode_switch

setprop persist.asus.power.mode ultra

#adjust cpu max frequency
echo 1766400 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1766400 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 1766400 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 1766400 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
echo 2803200 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo 2803200 > /sys/devices/system/cpu/cpu5/cpufreq/scaling_max_freq
echo 2803200 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq
echo 2803200 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq