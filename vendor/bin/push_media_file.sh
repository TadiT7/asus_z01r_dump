#!/vendor/bin/sh
LOG_TAG="PushMediaFiles"
logi ()
{
	/vendor/bin/log -t $LOG_TAG -p i "$@"
}

firstboot=`getprop persist.asus.media_copied`
dcim_folder="/sdcard/DCIM"
music_folder="/sdcard/Music"
pictureFile="/sdcard/DCIM/m_10.jpg"
musicFile="/sdcard/Music/m_JonasBlue-ByYourSide-feat-RAYE.mp3"
mv_file() {

#add loop to wait system mount /sdcard/DCIM
a=1
while [ ! -d "$dcim_folder" ]
do
	logi "DCIM folder not found, sleep 2 second."
	sleep 2
	if [ $a -eq 10 ]  
   then  
       break  
   fi  
   echo "a=$a"  
   a=$[$a+1]  
done

	logi "Found $dcim_folder, keep going."

#add loop to wait system mount /sdcard/Music
while [ ! -d "$music_folder" ]
do
	logi "Music folder not found, sleep 2 second."
	sleep 2
done

	logi "Found $music_folder, keep going."

    mkdir -p /sdcard/DCIM
    mkdir -p /sdcard/Movies
    mkdir -p /sdcard/Music
    if [ ! -f "$pictureFile" ]; then
		cp -r /vendor/etc/MediaFiles/asus_prebuild_media/DCIM/* /sdcard/DCIM/
	else
		echo "picture already exsit , keep going."
	fi
	
	if [ ! -f "$musicFile" ]; then
		cp -r /vendor/etc/MediaFiles/asus_prebuild_media/Music/* /sdcard/Music/
	else
		echo "musicFile already exsit , keep going."
	fi

    cp -r /vendor/etc/MediaFiles/asus_prebuild_media/Movies/* /sdcard/Movies/
	setprop persist.asus.media_copied 1
}

if [ "$firstboot" != "1" ]; then
    mv_file
fi
