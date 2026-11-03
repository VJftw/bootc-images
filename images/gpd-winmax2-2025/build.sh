#!/bin/bash

# gpd-winmax2-2025: GPD Win Max 2 (2025) handheld
# Based on bazzite-deck, which ships InputPlumber (controller/gyro) and PowerStation (TDP),
# and a kernel with the gpd-fan hwmon driver.

set -ouex pipefail

# Disable the direct boot into Steam Big Picture (gamescope session).
# bazzite-autologin rewrites the SDDM autologin user on every boot, so mask it;
# system_files/etc/sddm.conf.d/zzz-no-autologin.conf clears any existing config.
systemctl mask bazzite-autologin.service

# Default to a 15W TDP at boot (PowerStation doesn't persist TDP itself)
systemctl enable gpd-default-tdp.service

# bazzite-deck ships SDDM with no theme installed (hence the bare default greeter) and no
# "Login Screen" page in System Settings. Add the Breeze theme (kde_settings.conf selects
# 01-breeze-fedora) and the SDDM KCM to configure it.
dnf5 install -y sddm-breeze sddm-kcm

# Valve's desktop defaults (immutable [$i] entries in /etc/xdg/kdeglobals) disable screen
# locking, so Meta+L does nothing, and hide the SDDM settings page installed above.
sed -i -e '/^action\/lock_screen=false$/d' -e '/^kcm_sddm\.desktop=false$/d' /etc/xdg/kdeglobals

### Laptop defaults
# This device is mostly used as a clamshell laptop, so replace the handheld defaults from
# bazzite-deck. These are /etc/xdg system defaults; per-user settings still override them.

# Lock when resuming from suspend (e.g. after opening the lid)
sed -i 's/^LockOnResume=.*/LockOnResume=true/' /etc/xdg/kscreenlockerrc

# Less aggressive idle timers on battery: dim after 4m, screen off after 5m, suspend after 15m
# (idleTime is in milliseconds for DimDisplay/SuspendSession and seconds for DPMSControl)
sed -i \
  -e '/^\[Battery\]\[DimDisplay\]$/,/^$/ s/^idleTime=.*/idleTime=240000/' \
  -e '/^\[Battery\]\[DPMSControl\]$/,/^$/ s/^idleTime=.*/idleTime=300/' \
  -e '/^\[Battery\]\[SuspendSession\]$/,/^$/ s/^idleTime=.*/idleTime=900000/' \
  /etc/xdg/powermanagementprofilesrc

# Don't start Steam with every desktop login
rm -f /etc/xdg/autostart/steam.desktop

# Physical keyboard: don't pop up the on-screen keyboard over text fields
sed -i 's/^VirtualKeyboardEnabled=.*/VirtualKeyboardEnabled=false/' /etc/xdg/kwinrc

# Plain Breeze instead of Valve's Vapor look and feel
sed -i 's/^LookAndFeelPackage=.*/LookAndFeelPackage=org.kde.breeze.desktop/' /etc/xdg/kdeglobals
