#!/vendor/bin/sh

#K function
Calibration_function(){
		`climax -b -dsysfs -l /vendor/etc/firmware/ZS620KL/stereo.cnt --resetMtpEx > /data/misc/amp/cal_s_speaker0_log.txt 2>&1`
		`climax -b -dsysfs -l /vendor/etc/firmware/ZS620KL/stereo.cnt --calshow >> /data/misc/amp/cal_s_speaker0_log.txt 2>&1`
		`climax -b -dsysfs -l /vendor/etc/firmware/ZS620KL/stereo.cnt --calibrate=once >> /data/misc/amp/cal_s_speaker0_log.txt 2>&1`
}
#defalut value
`setprop tfa9874.rcv.calibration FAIL`
`setprop tfa9874.spk.calibration FAIL`
`setprop persist.asus.ampcalibration false`

if [ -e "/sdcard/Asuslog/NXP" ]
then
   rm  /sdcard/Asuslog/NXP/*
else
   mkdir -p /sdcard/Asuslog/NXP
fi

export Temp_data_rec=""
export Temp_data_spk=""
flag=0

#Strat Calibration
	Calibration_function
	Temp_data_rec=`climax -d /dev/i2c-2 --slave=0x34 -r 0xf0`
	Temp_data_spk=`climax -d /dev/i2c-2 --slave=0x35 -r 0xf0`
#checkt MTP state
if [[ ${Temp_data_rec:14:6} = 0x0003 && ${Temp_data_spk:14:6} = 0x0003 ]]
then
	flag=1
else
	flag=0
fi
#echo "MTP state: ${Temp_data_rec} ${Temp_data_spk}"
echo "MTP state: ${Temp_data_rec} ${Temp_data_spk}" > /data/misc/amp/cal_mtpex_data_tmp.txt

#check calibration value
Temp_data_rec=`climax -d /dev/i2c-2 --slave=0x34 -r 0xf5`
Temp_data_rec=${Temp_data_rec:14:6}
let Temp_data_rec=Temp_data_rec
echo "[0x34] 0xf5 : ${Temp_data_rec}" > /data/misc/amp/cal_self_receiver0_data_tmp.txt

Temp_data_spk=`climax -d /dev/i2c-2 --slave=0x35 -r 0xf5`
Temp_data_spk=${Temp_data_spk:14:6}
let Temp_data_spk=Temp_data_spk
echo "[0x35] 0xf5 : ${Temp_data_spk}" > /data/misc/amp/cal_self_speaker0_data_tmp.txt

rec_min=25200
rec_max=30800
spk_min=6300
spk_max=7700

echo "6300 7700 25200 30800" > /data/misc/amp/SPK_REC_calibration_value_range

if [[ $Temp_data_rec -lt $rec_min || $Temp_data_rec -gt $rec_max || $Temp_data_spk -lt $spk_min || $Temp_data_spk -gt $spk_max || flag -eq 0 ]]
then
	#echo "false"
	`setprop persist.asus.ampcalibration false`
	`setprop tfa9874.rcv.calibration FAIL`
	`setprop tfa9874.spk.calibration FAIL`
else
	#echo  "true"
	`setprop persist.asus.ampcalibration true`
	`setprop tfa9874.rcv.calibration PASS`
	`setprop tfa9874.spk.calibration PASS`
fi
#copy log to /sdcard/Asuslog/
cp  /data/misc/amp/* /sdcard/Asuslog/NXP

#until [[ ${Temp_data_rec:14:6} = 0x0003 && ${Temp_data_spk:14:6} = 0x0003 || count -eq 3 ]]
#do
	#statements
#	Calibration_function
#	Temp_data_rec=`climax -d /dev/i2c-2 --slave=0x34 -r 0xf0`
#	Temp_data_spk=`climax -d /dev/i2c-2 --slave=0x35 -r 0xf0`
#	let count=`expr $count + 1`
#	echo "$Temp_data_rec $Temp_data_spk $count"

#done