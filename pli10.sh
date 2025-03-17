#!/bin/bash

WINEPREFIX_LOCAL="$(pwd)/wine"

SRC_FILENAME=$1

PATH_TMP_DIR="/tmp/$$"
PATH_BUFFER="$PATH_TMP_DIR/buffer.txt"

PATH_TDM_GCC_32_SRC="$(pwd)/TDM-GCC-32-WINE-32"
PATH_TDM_GCC_32_WINE_DEST="$WINEPREFIX_LOCAL/drive_c/TDM-GCC-32" # don't get mistaken and append $(pwd) here

### # # ###

function help_wine_install_32() {
    if command -v apt &>/dev/null; then
        echo -e "\n[hou-compiler-linux]: Please install Wine (32-bit) by running: ";
        echo -e "[hou-compiler-linux]: sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install wine32";
    else
        echo -e "\n[hou-compiler-linux]: Please install Wine (32-bit).";
    fi
}

### # # ###

function prepare_wine() {
    mkdir -p "$WINEPREFIX_LOCAL";

    if [ ! -d "$WINEPREFIX_LOCAL/drive_c" ]; then
        echo -e "\n[hou-compiler-linux] Preparing Wine (32-bit) prefix in $WINEPREFIX_LOCAL...";

        WINEARCH=win32 WINEPREFIX="$WINEPREFIX_LOCAL" wineboot;
        if [ $? -ne 0 ]; then
            echo -e "\n[hou-compiler-linux] Error: Preperation of Wine (32-bit) failed.";

            ### # # ###

            rm -rf $WINEPREFIX_LOCAL

            ### # # ###

            help_wine_install_32;

            exit 1;
        fi
    fi
}

function prepare_tdm_gcc() {
    if [ ! -d "$WINEPREFIX_LOCAL/drive_c/TDM-GCC-32" ]; then
        cp -r $PATH_TDM_GCC_32_SRC $PATH_TDM_GCC_32_WINE_DEST
    fi
}

function prepare() {
    echo -e "\n[hou-compiler-linux] prepare...";

    ### # # ###

    # prepare : wine
    prepare_wine;

    # prepare : wine : TDM-GCC-32
    prepare_tdm_gcc;

    ### # # ###

    touch .prepared
}

function init() {
    echo -e "\n[hou-compiler-linux] init...";

    ### # # ###

    mkdir -p "$PATH_TMP_DIR";

    touch $PATH_BUFFER;
}

### # # ###

function transpose() {
    echo -e "\n[hou-compiler-linux] transpose...";

    ### # # ###

    iconv -f UTF-8 -t CP1253 ./${SRC_FILENAME}.utf8.eap > ./${SRC_FILENAME}.cp1253.eap;
}

function compile() {
    echo -e "\n[hou-compiler-linux] compile...";

    ### # # ###

    echo | WINEPREFIX="$WINEPREFIX_LOCAL" wine cmd /c "chcp 1253 && pli10.exe ${SRC_FILENAME}.cp1253.eap" | iconv -f CP1253 -t UTF-8;
}

function run() {
    echo -e "\n[hou-compiler-linux] run...";

    ### # # ###

    echo -n '' > $PATH_BUFFER;

    ### # # ###

    WINEPREFIX="$WINEPREFIX_LOCAL" wine cmd /c "chcp 1253 >nul & ${SRC_FILENAME}.cp1253.eap.exe" | tee "$PATH_BUFFER" > /dev/null &

    WINE_PID=$!;

    while true; do
        if [ -s $PATH_BUFFER ]; then
            cat $PATH_BUFFER | iconv -f CP1253 -t UTF-8;

            echo -n '' > $PATH_BUFFER;
        fi

        ### # # ###

        if ! ps -p $WINE_PID > /dev/null; then
            break;
        fi

        ### # # ###

        sleep 0.5;
    done
}

function clean() {
    echo -e "\n[hou-compiler-linux] clean...";

    ### # # ###

    rm -rf $PATH_TMP_DIR;
}

### # # ###

function main() {
    # prepare
    if [ ! -e .prepared ]; then
        prepare;
    fi

    # init
    init;

    ### # # ###

    # transpose
    transpose;

    # compile
    compile;

    # run
    run;

    # clean
    clean;

    ### # # ###

    echo -e "\n[hou-compiler-linux] exit...";
}

main;
