#!/bin/bash

SRC_FILENAME=$1

SRC_TMP="/tmp/$$"

WINEPREFIX="$(pwd)/wine32"
PROJECT_DIR="$(pwd)"

SRC_BUFFER="$SRC_TMP/buffer.txt"

### # # ###

function prepare() {
    echo -e "\n[hou-compiler-linux] prepare..."

    # prepare : deps

    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install wine32

    # prepare : wine

    mkdir -p "$WINEPREFIX"

    if [ ! -d "$WINEPREFIX/drive_c" ]; then
        echo "Preparing 32-bit Wine prefix in $WINEPREFIX..."
        WINEARCH=win32 WINEPREFIX="$WINEPREFIX" winecfg
    fi

    # prepare : wine : TDM-GCC-32

    if [ ! -d "$WINEPREFIX/drive_c/TDM-GCC-32" ];
    then
        WINEPREFIX="$WINEPREFIX" wine tdm-gcc-10.3.0.exe

        if [ ! -d "$WINEPREFIX/drive_c/TDM-GCC-32" ];
        then
            echo "Please install manually TDM-GCC under current wine installation : wine/drive_c/TDM-GCC-32";
        fi
    fi

    # prepare : .prepared file

    touch .prepared
}

function init() {
    echo -e "\n[hou-compiler-linux] init..."

    ### # # ###

    mkdir -p "$SRC_TMP"

    touch $SRC_BUFFER
}

### # # ###

function transpose() {
    echo -e "\n[hou-compiler-linux] transpose..."

    ### # # ###

    iconv -f UTF-8 -t CP1253 ./${SRC_FILENAME}.utf8.eap > ./${SRC_FILENAME}.cp1253.eap
}

function compile() {
    echo -e "\n[hou-compiler-linux] compile..."

    ### # # ###

    echo | WINEPREFIX="$WINEPREFIX" wine cmd /c "chcp 1253 && pli10.exe ${SRC_FILENAME}.cp1253.eap" | iconv -f CP1253 -t UTF-8
}

function run() {
    echo -e "\n[hou-compiler-linux] run..."

    ### # # ###

    echo -n '' > $SRC_BUFFER

    ### # # ###

    WINEPREFIX="$WINEPREFIX" wine cmd /c "chcp 1253 >nul & ${SRC_FILENAME}.cp1253.eap.exe" | tee "$SRC_BUFFER" > /dev/null &

    WINE_PID=$!

    ### # # ###

    while true; do
        if [ -s $SRC_BUFFER ]; then
            cat $SRC_BUFFER | iconv -f CP1253 -t UTF-8

            echo -n '' > $SRC_BUFFER
        fi

        ### # # ###

        if ! ps -p $WINE_PID > /dev/null; then
            break
        fi

        ### # # ###

        sleep 0.5
    done
}

function clean() {
    echo -e "\n[hou-compiler-linux] clean..."

    ### # # ###

    rm -rf $SRC_TMP
}

### # # ###

function main() {
    # prepare
    if [ ! -e .prepared ]; then
        prepare
    fi

    # init
    init

    ### # # ###

    # transpose
    transpose

    # compile
    compile

    # run
    run

    # clean
    clean

    ### # # ###

    echo -e "\n[hou-compiler-linux] exit..."
}

main
