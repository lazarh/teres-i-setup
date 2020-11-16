#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
DIR_GIT=~/Documents/git/teres-i-setup

echo -e "${RED}apt update ...${NC}"
sudo apt update

echo -e "${RED}apt install ...${NC}" 
sudo apt install man-db fdisk vim build-essential pkg-config cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config xcb-proto libxcb-xrm-dev libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev libxcb-composite0-dev unzip gpiod htop suckless-tools git mpd libx11-dev libxft-dev libxinerama-dev mpd mpc libmpdclient-dev xinit xserver-xorg x11-xserver-utils feh mesa-utils xcompmgr brightnessctl pcmanfm alsa-utils alsa-firmware-loaders alsa-base pulseaudio arc-theme hdparm xclip sqlite3 python3-pip -y

if [ ! -d $DIR_GIT ]; then
	mkdir -p $DIR_GIT;
fi

echo -e "${RED}compile dwm ...${NC}" 
cd $DIR_GIT/dwm
sudo make clean install

echo -e "${RED}compile st ...${NC}" 
cd $DIR_GIT/st
sudo make clean install

echo -e "${RED}compile dmenu ...${NC}" 
cd $DIR_GIT/dmenu
sudo make clean install

echo -e "${RED}compile slstatus ...${NC}" 
cd $DIR_GIT/slstatus
sudo make clean install

echo -e "${RED}compile tabbed ...${NC}" 
cd $DIR_GIT/tabbed
sudo make clean install

echo -e "${RED}add headphones on/off script${NC}"
# headphones on
cat > headphones_on << EOF
#!/bin/bash

echo 361 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio361/direction
echo 1 > /sys/class/gpio/gpio361/value
echo 361 > /sys/class/gpio/unexport
EOF

# headphones off
cat > headphones_off << EOF
#!/bin/bash

echo 361 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio361/direction
echo 0 > /sys/class/gpio/gpio361/value
echo 361 > /sys/class/gpio/unexport
EOF

chmod +x headphones*
sudo mv headphones* /usr/local/bin/.

echo -e "${RED}add backlight support${NC}"
# backlight
cat > 20-backlight.rules << EOF
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF
sudo mv 20-backlight.rules /etc/udev/rules.d/
user=$(whoami)
sudo usermod -aG video $user

echo -e "${RED}add dwm autostart${NC}"
# dwm autostart
if [ ! -d ~/.dwm/ ]; then
	mkdir -p ~/.dwm/;
fi

echo -e "${RED}add dwm autostart - autostart.sh ${NC}"
cat > ~/.dwm/autostart.sh << EOF
# headphones on
#sudo headphones_on

# slstatus
slstatus &

# wallpaparer
feh --bg-scale ~/Pictures/wallpapers/*.jpg -z

# keyboard layout
setxkbmap -model pc104 -layout us,bg -variant ,phonetic -option g
rp:win_space_toggle

# transparency
xcompmgr &
EOF

echo -e "${RED}add dwm autostart - autostart_blocking.sh${NC}"
touch ~/.dwm/autostart_blocking.sh
chmod +x ~/.dwm/*.sh

echo -e "${RED}add .xinitrc${NC}"
touch ~/.xinitrc
grep -qxF 'exec dwm' ~/.xinitrc || echo 'exec dwm' >> ~/.xinitrc

echo -e "${RED}add .bashrc_teres${NC}"
cat > ~/.bashrc_teres << 'EOF'
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi

toilet Teres I

temp=$( cat /sys/devices/virtual/thermal/thermal_zone0/temp )
temp=`expr $temp / 1000`
echo '          CPU Temperature:' $temp 'C'
uptime=$( uptime )
echo $uptime
EOF

grep -qxF '. $HOME/.bashrc_teres' ~/.bashrc || echo '. $HOME/.bashrc_teres' >> ~/.bashrc

#echo 'Xft.dpi: 82' >> ~/.Xresources
#echo 'exec dwm' >> ~/.xinitrc

echo -e "${RED}fix dpi & xorg.conf${NC}"
# dpi config
touch ~/.Xresources
grep -qxF 'Xft.dpi: 82' ~/.Xresources || echo 'Xft.dpi: 82' >> ~/.Xresources

echo > 20-video.conf << EOF
Section "Device"
        Identifier "Lima"
#       MatchDriver "sun4i-drm"
        Driver "modesetting"
        Option "PrimaryGPU" "true"
        Option "HWCursor" "false"
        Option "SwapbuffersWait" "true"
EndSection

Section "Monitor"
  Identifier  "eDP-1"
  Option      "DPMS" "false"
#  DisplaySize  533 300    # In millimeters
EndSection

Section "Screen"
        Identifier "Screen0"
        Device "Lima"
        Monitor "eDP-1"
EndSection

Section "ServerFlags"
  Option "AutoAddGPU" "off"
  Option "BlankTime" "0"
  Option "StandbyTime" "0"
  Option "SuspendTime" "0"
  Option "OffTime" "0"
EndSection
EOF
sudo mv 20-video.conf /usr/share/X11/xorg.conf.d/.

echo -e "${RED}set up gtk Arc-Dark theme${NC}"
mkdir ~/.config/gtk-3.0/ -p
cat > settings.ini << EOF
[Settings]
gtk-icon-theme-name = Arc-Dark
gtk-theme-name = Arc-Dark
gtk-font-name = DejaVu Sans 8
EOF

mv settings.ini ~/.config/gtk-3.0/.

echo -e "${RED}install wallpapers ...${NC}"
# wallpapares
if [ ! -d ~/Pictures/wallpapers ]; then
	git clone https://gist.github.com/85942af486eb79118467.git ~/Pictures/wallpapers
fi
