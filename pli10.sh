#!/bin/bash

#init

if ! command -v wine &> /dev/null
then
    apt-get install wine
fi

if [ ! -d "$HOME/.wine/drive_c/TDM-GCC-32" ]; 
then     
    wine ./tdm-gcc-10.3.0.exe

    if [ ! -d "$HOME/.wine/drive_c/TDM-GCC-32" ]; 
    then     
        echo "Please install manually TDM-GCC under current wine installation : wine/drive_c/TDM-GCC-32";
    fi
fi

#compile

echo | wine ./pli10.exe input.eap > ./output.txt
iconv -f cp1253 -t UTF-8 output.txt > output_new.txt
cat ./output_new.txt

#run

wine ./input.eap.exe
