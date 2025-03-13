#!/bin/bash

SRC_FILENAME=$1

WINEPREFIX="$(pwd)/wine32"
PROJECT_DIR="$(pwd)"

# init

function init() {

    # init : deps

    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install wine32

    # init : wine

    mkdir -p "$WINEPREFIX"

    if [ ! -d "$WINEPREFIX/drive_c" ]; then
        echo "Initializing 32-bit Wine prefix in $WINEPREFIX..."
        WINEARCH=win32 WINEPREFIX="$WINEPREFIX" winecfg
    fi

    # init : wine : TDM-GCC-32

    if [ ! -d "$WINEPREFIX/drive_c/TDM-GCC-32" ]; 
    then     
        WINEPREFIX="$WINEPREFIX" wine tdm-gcc-10.3.0.exe

        if [ ! -d "$WINEPREFIX/drive_c/TDM-GCC-32" ]; 
        then     
            echo "Please install manually TDM-GCC under current wine installation : wine/drive_c/TDM-GCC-32";
        fi
    fi

    # init : .inited file

    touch .inited
}

if [ ! -e .inited ]; then
    init
fi

# encode
iconv -f UTF-8 -t cp1253 ./${SRC_FILENAME}.utf8.eap > ./${SRC_FILENAME}.cp1253.eap

# compile
#
# the reversed pipe to echo is used to print the compiler's output through iconv
echo | WINEPREFIX="$WINEPREFIX" wine cmd /c "pli10.exe ${SRC_FILENAME}.cp1253.eap" | iconv -f cp1253 -t UTF-8

# run
WINEPREFIX="$WINEPREFIX" wine cmd /c "${SRC_FILENAME}.cp1253.eap.exe"
