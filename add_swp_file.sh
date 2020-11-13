#!/bin/bash
echo 'fallocate -l 1G /swapfile'
fallocate -l 1G /swapfile
echo 'chmod 600 /swapfile'
chmod 600 /swapfile
echo 'mkswap /swapfile'
mkswap /swapfile
echo 'swapon /swapfile'
mkswap /swapfile
echo 'add to fstab'
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
swapon --show
