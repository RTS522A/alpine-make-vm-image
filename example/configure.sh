#!/bin/sh

_step_counter=0
step() {
	_step_counter=$(( _step_counter + 1 ))
	printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2  # bold cyan
}


step 'Set up timezone'
setup-timezone -z Europe/Moscow

step 'Set up networking'
cat > /etc/network/interfaces <<-EOF
	iface lo inet loopback
	iface eth0 inet dhcp
	iface eth1 inet static
		address 192.168.1.1
		netmask 255.255.255.0
EOF
ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0
ln -s networking /etc/init.d/net.eth1

step 'Adjust rc.conf'
sed -Ei \
	-e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
	-e 's/^[# ](rc_logger)=.*/\1=YES/' \
	-e 's/^[# ](unicode)=.*/\1=YES/' \
	/etc/rc.conf

step 'Enable services'
rc-update add acpid default
rc-update add chronyd default
rc-update add crond default
rc-update add net.eth0 default
rc-update add net.eth1 default
rc-update add net.lo boot
rc-update add termencoding boot

step 'List /usr/local/bin'
ls -la /usr/local/bin
