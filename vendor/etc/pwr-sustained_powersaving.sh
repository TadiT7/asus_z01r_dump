#!/system/bin/sh
#This is sustained powersaving mode,restoring cpu to schedutil mode.

# configure governor settings for little cluster
echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# configure governor settings for big cluster
echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
