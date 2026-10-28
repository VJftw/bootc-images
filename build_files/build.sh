#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
# Shared files first, then the variant's files (so a variant can override)
cp -avf "/ctx/common/system_files"/. /
cp -avf "/ctx/variant/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

### Default sched_ext scheduler

# bazzite-deck already ships /etc/scx_loader/config.toml (scx_lavd); plain bazzite only has
# commented defaults under /usr/share, so create one. Keep existing per-scheduler flags.
mkdir -p /etc/scx_loader
if [[ -f /etc/scx_loader/config.toml ]]; then
  sed -i -E 's/^#?\s*default_sched\s*=.*/default_sched = "scx_lavd"/' /etc/scx_loader/config.toml
else
  printf 'default_sched = "scx_lavd"\ndefault_mode = "Auto"\n' > /etc/scx_loader/config.toml
fi
grep -q '^default_sched = "scx_lavd"' /etc/scx_loader/config.toml

### Image signature verification

# Trust this repo's cosign key for ghcr.io/vjftw so `ostree-image-signed:` rebases verify
jq '.transports.docker["ghcr.io/vjftw"] = [{
  "type": "sigstoreSigned",
  "keyPath": "/etc/pki/containers/vjftw.pub",
  "signedIdentity": {"type": "matchRepository"}
}]' /etc/containers/policy.json > /tmp/policy.json
install -m644 /tmp/policy.json /etc/containers/policy.json
rm /tmp/policy.json

### Variant-specific customisations

bash -ouex pipefail /ctx/variant/build.sh
