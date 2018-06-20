#!/system/bin/sh
#This is superon mode.

# configure governor settings for little cluster
echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# configure governor settings for big cluster
echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

sleep 1

# "GPU performance mode"
echo 1 > /sys/class/kgsl/kgsl-3d0/bus_split
echo msm-adreno-tz > /sys/class/kgsl/kgsl-3d0/devfreq/governor
echo 0 > /sys/class/kgsl/kgsl-3d0/force_bus_on
sleep 1
echo 0 > /sys/class/kgsl/kgsl-3d0/force_rail_on
echo 0 > /sys/class/kgsl/kgsl-3d0/force_clk_on
sleep 1
echo 80 > /sys/class/kgsl/kgsl-3d0/idle_timer
sleep 1

# "clkscale_enable"
echo 1 > /sys/class/scsi_host/host0/../../../clkscale_enable
