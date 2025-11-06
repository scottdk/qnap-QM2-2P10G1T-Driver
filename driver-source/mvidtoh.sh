#!/bin/bash

# Version 0.2, 2017/11/05
# Support for AQR105 FW conversion added

# Version 0.1, 2017/10/15
# Initial release

if [ $# -ne 3 ]; then
	echo "Usage: mvidtoh.sh <HDR file> <PHY NAME> <H file>"
	exit 1
fi

HDR_FILE=$1
PHY_NAME=$2
H_FILE=$3

if [ ! -e $HDR_FILE ]; then
	echo "mvidtoh: HDR file $HDR_FILE not found"
	exit 1
fi

if [ $PHY_NAME != "MV88X3120" ] && [ $PHY_NAME != "MV88X3310" ] && [ $PHY_NAME != "MV88E2010" ] && [ $PHY_NAME != "AQR105" ]; then
	echo "mvidtoh: PHY $PHY_NAME not supported. Expecting one of AQR105, MV88X3120, MV88X3310 or MV88E2010"
	exit 1
fi

## Determine file length in bytes without xxd
if command -v stat >/dev/null 2>&1; then
	len=$(stat -c%s "$HDR_FILE" 2>/dev/null || stat -f%z "$HDR_FILE")
else
	len=$(wc -c < "$HDR_FILE")
fi

/bin/rm -f $H_FILE
echo "" > $H_FILE
echo "#ifndef _${PHY_NAME}_PHY_H" >> $H_FILE
echo "#define _${PHY_NAME}_PHY_H" >> $H_FILE
echo "" >> $H_FILE

if [ $PHY_NAME == "AQR105" ]; then
	echo "unsigned int ${PHY_NAME}_phy_firmware_len = ${len};" >> $H_FILE
	echo "static u8 ${PHY_NAME}_phy_firmware[] __initdata = {" >> $H_FILE
	echo "/* $HDR_FILE */" >> $H_FILE
	if command -v xxd >/dev/null 2>&1; then
		xxd -i -c 8 "$HDR_FILE" | grep -v "unsigned" >> "$H_FILE"
	else
		# Fallback to hexdump: 8 bytes per line
		hexdump -v -e '8/1 " 0x%02X," "\n"' "$HDR_FILE" >> "$H_FILE"
	fi
	echo "};" >> $H_FILE
	echo "#endif" >> $H_FILE
else
	echo "static u16 ${PHY_NAME}_phy_initdata[] __initdata = {" >> $H_FILE
	echo "/* $HDR_FILE */" >> $H_FILE
	if command -v xxd >/dev/null 2>&1; then
		# xxd produces bytes like: 0x12, 0x34  -> merge pairs into 0x1234
		xxd -i -c 2 "$HDR_FILE" | sed 's/, 0x//' | grep -v "unsigned" >> "$H_FILE"
	elif command -v od >/dev/null 2>&1; then
		# Fallback using od: emit bytes, merge into 16-bit big-endian words
		od -An -tx1 -v "$HDR_FILE" \
		  | tr -s ' ' \
		  | tr ' ' '\n' \
		  | awk 'BEGIN{ORS=""} {if($1!="") bytes[++n]=toupper($1)} END{for(i=1;i<=n;i+=2){if(i<n) printf "0x%s%s,\n", bytes[i], bytes[i+1];}}' \
		  >> "$H_FILE"
	else
		# Last resort: busybox hexdump compatibility - print bytes then pair in awk
		hexdump -v -e '1/1 "%02X "' "$HDR_FILE" \
		  | awk 'BEGIN{ORS=""} {for(i=1;i<=NF;i+=2){if($(i+1)!="") printf "0x%s%s,\n", toupper($i), toupper($(i+1));}}' \
		  >> "$H_FILE"
	fi
	echo "};" >> $H_FILE
	echo "unsigned int ${PHY_NAME}_phy_initdata_len = ${len};" >> $H_FILE
	echo "#endif" >> $H_FILE
fi

exit 0
