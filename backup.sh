#!/data/data/com.termux/files/usr/bin/bash

# pretty print function
function print_info() {
    echo -e "\e[1;32m[*]\e[0m $1"
}

# pretty error print function
function print_error() {
    echo -e "\e[1;31m[*]\e[0m $1"
}

function throw() {
  print_error "$1"
  exit 1
}

print_info "Please grant termux storage permission on next screen..."
termux-setup-storage

print_info "!! Make sure you installed termux from fdroid"
print_info " and not PlayStore. !!"

print_info "Please confirm whether you have installed termux from fdroid or not."
print_info "Enter 'y' for yes and 'n' for no."
read -n 1 confirmation
echo -ne "\b"
if [ "$confirmation" == "y" ]; then
    print_info "Continuing"
else
    print_info "Don't worry, we will download termux fdroid apk for you."
    print_info "One moment please"
    curl https://f-droid.org/repo/com.termux_117.apk \
        -so /sdcard/Download/com.termux_117.apk || throw "Failed to download termux APK, please try again or download it manually from https://f-droid.org/repo/com.termux_117.apk"
    print_info "APK downloaded and is located at internal storage/Download/com.termux_117.apk"
    print_info "Please install the APK and run this script again."
    exit 0
fi

print_info "Installing required packages"
pkg update -y &>/dev/null || err=1
yes | pkg upgrade &>/dev/null || err=1
pkg update -y &>/dev/null || err=1
pkg install tsu zip -y &>/dev/null || err=1
if [ "$err" == "1" ]; then
    throw "Failed to install packages, check your internet connection and try again."
fi

testfile=/cache/test.$RANDOM
print_info "Checking for root access"
sudo touch $testfile || throw "Root access not granted. Please grant root access and run this script again."
sudo rm -f $testfile

print_info "Making directory"
tmpdir="tmpdir-$RANDOM"
mkdir /sdcard/$tmpdir

print_info "Extracting partitions"
partitions="
nvram
nvcfg
nvdata
persist
protect1
protect2
proinfo
"
for part in $partitions; do
  sudo dd if="/dev/block/by-name/$part" of="/sdcard/$tmpdir/$part.img" &>/dev/null
done

print_info "Packing partitions to save space"
filename="IMEI_backup_$(date +%Y-%m-%d@%H-%M-%S).zip"
# shellcheck disable=SC2164
cd /sdcard
zip -qr $filename $tmpdir

print_info "Cleanup"
rm -rf $tmpdir

print_info "Done. File is located in internal storage with filename:"
print_info "$filename"
