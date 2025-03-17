# hou-compiler-linux

![Screenshot](doc/assets/img/header1.png)

## Purpose

Run Hellenic Open University's Software Engineering PLH10 compiler -finally- on Linux !

## Disclaimer

Please make sure to back up your scripts regularly and have access to a Windows machine in case this program doesn't work for you.

I take no responsibility for its use in your university or in any other way.

## Dependencies

This program requires the 32-bit version of Wine. If you check the script (pli10.sh), it actually attempts to install it by itself:

```
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine32
```

## How to Use

### 1. Create the program

Create a file -at the root of the project- named `<NAME>.utf8.eap` -  where `<NAME>` is the name you want your program to have.

For example : 
```
test1.utf8.eap
```

In this file, write your code and save it. 

The content must be in UTF-8 encoding (which is usually the default).

### 2. Encode, compile, run

At this point, please note that if this is your first time running this tool:
1. A Wine graphical window may open. Close it if you don't want to alter any options.
2. The TDM-GCC compiler installer will open. Follow the installation process.

Now, simply run `./pli10.sh <NAME>`. Without the `.utf8.eap` part.

For example :
```
./pli10.sh test1
```

**This will encode\*, compile and run the program.**

**Running is happening through a wrapper that handles encoding of input and output as well ! 
For optimal compatibility, don't procceed to run the produced executable your self.**

\* *By encoding, we mean converting from UTF-8 to CP1253 (Windows-1253), which is required by the legacy compiler.*

## Examples

You can find the following examples :
- `test1.utf8.eap` 
- `test2.utf8.eap`
- `test3.utf8.eap`

To run them : 

```
./pli10.sh test1
```
```
./pli10.sh test2
```
```
./pli10.sh test3
```

## Weak Points

~~Don't use Greek characters in either the output or the input of the program. Use Greeklish instead !~~

**Greek characters are now fully supported everywhere.**

## Developer Notes

There is a reason all files are thrown on the same place and it's because the compiler strugles generally to work with files out of it's directory.
