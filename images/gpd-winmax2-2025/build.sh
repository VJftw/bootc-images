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
