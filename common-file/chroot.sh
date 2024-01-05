#!/bin/bash

install_package() {
    apt update
    dpkg -i /tmp/*.deb
    apt install -y coreutils network-manager modemmanager bc bsdmainutils gawk
    apt --fix-broken install -y
    apt install -y libqmi-utils
    DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
    apt install -y dnsmasq-base
}

remove_package() {
    dpkg -l | grep -E "meson|linux-image" |awk '{print $2}'|xargs dpkg -P
}

set_language() {
    locale-gen en_US en_US.UTF-8
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    fc-cache -fv
}

common_set() {
    rm /usr/sbin/openstick-startup-diagnose.sh
    rm /usr/lib/systemd/system/openstick-startup-diagnose.service
    rm /usr/lib/systemd/system/openstick-startup-diagnose.timer
    rm /usr/sbin/openstick-button-monitor.sh
    rm /usr/lib/systemd/system/openstick-button-monitor.service
    rm /usr/sbin/openstick-sim-changer.sh
    rm /usr/lib/systemd/system/openstick-sim-changer.service
    cp /tmp/mobian-setup-usb-network /usr/sbin/
    cp /tmp/mobian-setup-usb-network.service /usr/lib/systemd/system/mobian-setup-usb-network.service
    cp /tmp/gpioled /usr/sbin/
    cp /tmp/gpioled.service /usr/lib/systemd/system/gpioled.service
    cp /tmp/openstick-expanddisk-startup.sh /usr/sbin/
    cp /tmp/rules.v4 /etc/iptables/
    touch /etc/fstab
    echo "LABEL=aarch64 / btrfs defaults,noatime,compress=zstd,commit=30 0 0" > /etc/fstab
    sed -i '13 i\nmcli c u USB' /etc/rc.local
    sed -i 1s/-e// /etc/rc.local
    sed -i s/forking/idle/g /usr/lib/systemd/system/rc-local.service
    sed -i s/'Odroid N2'/MSM8916/g /etc/armbian-release
    sed -i s/'# ZRAM_PERCENTAGE=50'/ZRAM_PERCENTAGE=300/g /etc/default/armbian-zram-config
    sed -i s/'# MEM_LIMIT_PERCENTAGE=50'/MEM_LIMIT_PERCENTAGE=300/g /etc/default/armbian-zram-config
    rm /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    systemctl mask ModemManager.service
}

clean_file() {
    rm -rf /boot
    mkdir /boot
}

enable_motd() {
    chmod +x /etc/update-motd.d/*
}

clean_apt_lists() {
    rm -rf /var/lib/apt/lists
    apt clean all
}

remove_package
clean_file
install_package
update-alternatives --set iptables /usr/sbin/iptables-legacy
set_language
common_set
enable_motd
clean_apt_lists
exit
