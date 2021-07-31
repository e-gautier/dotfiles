#!/usr/bin/env sh

set -e
set -v

# non-free repos
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# if install mode is laptop
if [[ $INSTALL_MODE = "laptop" ]] || ! [[ $INSTALL_MODE  ]]; then

  # Microsoft key
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

  # powershell
  curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

  # vscodium
  sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
  printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=gitlab.com_paulcarroty_vscodium_repo\nbaseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg" |sudo tee -a /etc/yum.repos.d/vscodium.repo

  # install vscode extensions
  awk '{system("codium --install-extension "$1)}' $VSC_EXTENSIONS

  # hybrid sleep at 5% battery
  BATTERYFILE=/etc/udev/rules.d/99-low-battery.rules
  sudo sh -c "echo 'SUBSYSTEM==\"power_supply\", ATTR{status}==\"Discharging\", ATTR{capacity}==\"[0-5]\", RUN+=\"/usr/bin/systemctl hybrid-sleep\"' > $BATTERYFILE"

  # logind power management
  sudo sed -i '/^#HandlePowerKey=.*$/ s/^#//' /etc/systemd/logind.conf
  sudo sed -i '/^#HandleSuspendKey=.*$/ s/^#//' /etc/systemd/logind.conf
  sudo sed -i '/^#HandleHibernateKey=.*$/ s/^#//' /etc/systemd/logind.conf
  sudo sed -i '/^#HandleLidSwitch=.*$/ s/^#//' /etc/systemd/logind.conf
  sudo sed -i '/^#HandleLidSwitchExternalPower=.*$/ s/^#//' /etc/systemd/logind.conf
  sudo sed -i '/^#HandleLidSwitchDocked=.*$/ s/^#//' /etc/systemd/logind.conf

  # resolved configuration
  sudo sed -i 's/^DNS=.*$/DNS=1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001/g' /etc/systemd/resolved.conf
  sudo sed -i '/^#FallbackDNS=.*$/ s/^#//' /etc/systemd/resolved.conf
  sudo ln -fs /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

# docker ce
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl disable --now docker containerd

# zfs
sudo dnf install https://zfsonlinux.org/fedora/zfs-release$(rpm -E %dist).noarch.rpm
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
sudo dnf swap -y zfs-fuse zfs

# auto-install security updates
sudo dnf install -y dnf-automatic
sudo sed -i -e 's/upgrade_type = default/upgrade_type = security/g' /etc/dnf/automatic.conf
sudo sed -i -e 's/apply_updates = no/apply_update = yes/g' /etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer

# binaries
awk '/--- '$INSTALL_MODE'/{n=1;next}/---/{n=0}{if(n) system("sudo dnf install -y "$0)}' binaries

if [[ $INSTALL_MODE = "laptop" ]] || ! [[ $INSTALL_MODE  ]]; then
  # install snaps
  if type -P snap; then
    awk '/--- '$INSTALL_MODE'/{n=1;next}/---/{n=0}{if(n) system("sudo snap install "$0)}' snaps
  fi

  # enable user services
  systemctl --user enable syncthing

  # enable powertop comsumption optimzation
  sudo -p "[sudo] password for %u in order to enable Powertop: " cp systemd/system/powertop.service /etc/systemd/system/
  sudo systemctl enable --now powertop.service

  # enable system services
  sudo systemctl enable --now systemd-timesyncd.service systemd-resolved.service

  # disable some unwanted services
  sudo systemctl disable --now rsyslog pmcd pmie pmlogger sshd atd sssd firewalld crond chronyd

  # add user in wireshark group in order to run wireshark unprivileged
  sudo -p "[sudo] password for %u in order to add $USER into wireshark group: " usermod -aG wireshark $USER
fi
