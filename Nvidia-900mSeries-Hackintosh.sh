#!/bin/bash
# instructions： 
# 	cd the temporary folder where you download/put the script
# 	chmod +x Nvidia-900mSeries-Hackintosh.sh
# 	./Nvidia-900mSeries-Hackintosh.sh
# Maintained by: XinyuWufei for primarily Clevo laptop's display （nvidia 900m series graphic card）

portname=("A" "B" "C" "D" "E" "F" "G" "H")
portnumber=6
# internalDisplay=3
echo "Please remove any (third-party's)efi string in config ; clean the cache and reboot beofre the first time to use!!!\n"
echo "generating orginal device-properties.xml/hex..."
eval "ioreg -lw0 -p IODeviceTree -n efi -r -x | grep device-properties | sed 's/.*<//;s/>.*//;' > orginal.hex && ./gfxutil -s -n -i hex -o xml orginal.hex orginal.xml"
if [ -f "orginal.xml.bak" ]
then
	cp orginal.xml.bak orginal.xml
	eval "sed -i.bak '1,4d' orginal.xml"
else
	eval "sed -i.bak '1,4d' orginal.xml"
fi
echo " "
echo "Please verify your intenal Display Port number showed as below:"
eval "ioreg -lw0 | grep IODisplayPrefsKey"
read -p "Please enter the default intenal Display Port number(normally edp is on port 3):" internalDisplay

rm device-properties.xml 

echo '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">
<dict>\n<key>PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)</key>\n<dict>' >> device-properties.xml

read -p "Please enter the VRAM in decimal:" vram
printf -v vram '0x0%08x\n' $vram 

# read -p "Please enter the vbios revision:" vbios


for ((i = 0; i<$portnumber; i++))
do
	if [ $i = $internalDisplay ]
	then
    	echo "<key>@$i,AAPL,boot-display</key>
		<string>01000000 </string>
		<key>@$i,NVDA,UnderscanMin</key>
		<string>0x00000052</string>
		<key>@$i,backlight-control</key>
		<string>01000000 </string>
		<key>@$i,built-in</key>
		<string>01000000 </string>
		<key>@$i,compatible</key>
		<string>NVDA,NVMac</string>
		<key>@$i,connector-type</key>
		<data>
		AAgAAA==
		</data>
		<key>@$i,device_type</key>
		<string>display</string>
		<key>@$i,name</key>
		<string>NVDA,Display-${portname[$i]}</string>
		<key>@$i,pwm-info</key>
		<data>
		ARQAZKhhAAAeAgAALAAAAAAEAAA=
		</data>
		<key>@$i,use-backlight-blanking</key>
		<data>
		AQAAAA==
		</data>" >> device-properties.xml
	else
    	echo "<key>@$i,NVDA,UnderscanMin</key>
		<string>0x00000052</string>
		<key>@$i,compatible</key>
		<string>NVDA,NVMac</string>
		<key>@$i,connector-type</key>
		<data>
		AAgAAA==
		</data>
		<key>@$i,device_type</key>
		<string>display</string>
		<key>@$i,name</key>
		<string>NVDA,Display-${portname[$i]}</string>" >> device-properties.xml
	fi
done
echo '  <key>AAPL,HasLid</key>
		<data>
		AQAAAA==
		</data>
		<key>AAPL,HasPanel</key>
		<data>
		AQAAAA==
		</data>
		<key>AAPL,backlight-control</key>
		<data>
		AQAAAA==
		</data>
		<key>VRAM,totalsize</key>
		<string>$vram</string>
		<key>device_type</key>
		<string>NVDA,Parent</string>
		<key>hda-gfx</key>
		<string>onboard-1</string>
		</dict>' >> device-properties.xml

# <key>rom-revision</key>
# <string>VBIOS $vbios</string>

eval "cat orginal.xml  >> device-properties.xml"
./gfxutil -i xml -o hex "device-properties.xml" "device-properties.hex"
cat device-properties.hex
echo "\nDone!
before to use efi string,be sure to check no redundant propeities/items in file 'device-properties.xml'!"