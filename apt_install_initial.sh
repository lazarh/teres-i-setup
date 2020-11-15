#!/bin/bash

DIR_GIT=~/Documents/git/teres-i-setup

sudo apt update
sudo apt install man-db fdisk vim build-essential pkg-config cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config xcb-proto libxcb-xrm-dev libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev libxcb-composite0-dev unzip gpiod htop suckless-tools git mpd libx11-dev libxft-dev libxinerama-dev mpd mpc libmpdclient-dev xinit xserver-xorg x11-xserver-utils feh mesa-utils xcompmgr brightnessctl pcmanfm alsa-utils alsa-firmware-loaders alsa-base pulseaudio arc-theme -y

if [ ! -d $DIR_GIT ]; then
	mkdir -p $DIR_GIT;
fi

cd $DIR_GIT/dwm
sudo make clean install

cd $DIR_GIT/st
sudo make clean install

cd $DIR_GIT/dmenu
sudo make clean install

cd $DIR_GIT/slstatus
sudo make clean install

cd $DIR_GIT/tabbed
sudo make clean install

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

# backlight
cat > 20-backlight.rules << EOF
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF
sudo mv 20-backlight.rules /etc/udev/rules.d/
user=$(whoami)
sudo usermod -aG video $user

# dwm autostart
if [ ! -d ~/.dwm/ ]; then
	  mkdir -p ~/.dwm/;
fi

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

touch ~/.dwm/autostart_blocking.sh
chmod +x ~/.dwm/*.sh

#echo 'Xft.dpi: 82' >> ~/.Xresources
#echo 'exec dwm' >> ~/.xinitrc

# dpi config
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

mkdir .config/gtk-3.0/ -p
cat > settings.ini << EOF
[Settings]
gtk-icon-theme-name = Arc-Dark
gtk-theme-name = Arc-Dark
gtk-font-name = DejaVu Sans 8
EOF

grep -qxF 'exec dwm' ~/.xinitrc || echo 'exec dwm' >> ~/.xinitrc

grep -qxF 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi' ~/.bashrc || echo 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi' >> ~/.bashrc

# wallpapares
if [ ! -d ~/Pictures/wallpapers ]; then
	git clone https://gist.github.com/85942af486eb79118467.git ~/Pictures/wallpapers
fi
