#!/bin/bash

SRC_FILENAME=$1

PATH_TMP_DIR="/tmp/$$"
PATH_BUFFER="$PATH_TMP_DIR/buffer.txt"

WINEPREFIX="$(pwd)/wine32"

### # # ###

function help_wine_32() {
    if command -v apt &>/dev/null; then
        echo -e "\n[hou-compiler-linux] detected. To install wine32:";
        echo "sudo dpkg --add-architecture i386";
        echo "sudo apt update";
        echo "sudo apt install wine32";
    elif command -v dnf &>/dev/null; then
        echo "Fedora detected. To install wine 32-bit support:";
        echo "sudo dnf install wine";
        echo "sudo dnf install wine.i686";
    elif command -v yum &>/dev/null; then
        echo "RHEL/CentOS detected. To install wine 32-bit support:";
        echo "sudo yum install wine";
        echo "sudo yum install wine.i686";
    elif command -v pacman &>/dev/null; then
        echo "Arch Linux detected. To install wine 32-bit support:";
        echo "sudo pacman -S wine";
        echo "sudo pacman -S lib32-mesa lib32-libpulse";
    elif command -v zypper &>/dev/null; then
        echo "openSUSE detected. To install wine 32-bit support:";
        echo "sudo zypper install wine";
        echo "sudo zypper install wine-32bit";
    elif command -v apk &>/dev/null; then
        echo "Alpine Linux detected. Wine installation is complex due to musl libc and lack of standard multi-lib.";
        echo "Refer to: https://wiki.alpinelinux.org/wiki/Wine";
    elif command -v eopkg &>/dev/null; then
        echo "Solus detected. To install wine:";
        echo "sudo eopkg install wine";
    elif command -v xbps-install &>/dev/null; then
        echo "Void Linux detected. Multi-lib support must be enabled:";
        echo "Refer to: https://docs.voidlinux.org/usage/multilib/";
    elif command -v nix-env &>/dev/null; then
        echo "NixOS detected. Installing Wine may require enabling multi-lib and using nixpkgs:";
        echo "nix-env -iA nixpkgs.wineWowPackages.stable";
    elif command -v brew &>/dev/null; then
        echo "Homebrew detected. On macOS/Linuxbrew:";
        echo "brew install --cask wine-stable";
        echo "(Note: 32-bit apps not supported on modern macOS.)";
    elif command -v pkg &>/dev/null; then
        echo "FreeBSD detected. Install Wine with:";
        echo "sudo pkg install wine";
    else
        echo "Unknown package manager. Please install Wine 32-bit support manually.";
    fi
}

### # # ###

function prepare_wine_32() {
    mkdir -p "$WINEPREFIX";

    if [ ! -d "$WINEPREFIX/drive_c" ]; then
        echo -e "\n[hou-compiler-linux] Error: Preparing 32-bit Wine prefix in $WINEPREFIX...";

        WINEARCH=win32 WINEPREFIX="$WINEPREFIX" wineboot;
        if [ $? -ne 0 ]; then
            echo -e "\n[hou-compiler-linux] Error: Preperation of 32-bit Wine failed.";

            help_wine32;

            exit 1;
        fi
    fi
}

function prepare_tdm_gcc_32() {
    if [ ! -d "$WINEPREFIX/drive_c/TDM-GCC-32" ]; then
        WINEPREFIX="$WINEPREFIX" wine tdm-gcc-10.3.0.exe;
        if [ $? -ne 0 ]; then
            echo -e "\n[hou-compiler-linux] Error: Failed to run TDM-GCC installer.";

            exit 1;
        fi
        if [ ! -d "$WINEPREFIX/drive_c/TDM-GCC-32" ]; then
            echo -e "\n[hou-compiler-linux] Error: TDM-GCC does not appear to be installed under $WINEPREFIX/drive_c/TDM-GCC-32";
            echo -e "\n[hou-compiler-linux] Please install manually: WINEPREFIX=\"$WINEPREFIX\" wine tdm-gcc-10.3.0.exe";

            exit 1;
        fi
    fi
}

function prepare() {
    echo -e "\n[hou-compiler-linux] prepare...";

    ### # # ###

    # prepare : wine
    prepare_wine_32;

    # prepare : wine : TDM-GCC-32
    prepare_tdm_gcc_32();

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

    echo | WINEPREFIX="$WINEPREFIX" wine cmd /c "chcp 1253 && pli10.exe ${SRC_FILENAME}.cp1253.eap" | iconv -f CP1253 -t UTF-8;
}

function run() {
    echo -e "\n[hou-compiler-linux] run...";

    ### # # ###

    echo -n '' > $PATH_BUFFER;

    ### # # ###

    WINEPREFIX="$WINEPREFIX" wine cmd /c "chcp 1253 >nul & ${SRC_FILENAME}.cp1253.eap.exe" | tee "$PATH_BUFFER" > /dev/null &

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
