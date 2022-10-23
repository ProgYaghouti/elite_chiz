#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

#Root
[[ $(id -u) != 0 ]] && echo -e "\n Oops... please run ${yellow}~(^_^) ${none} as ${red}root ${none} user \n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
# i[36]86)
# v2ray_bit="32"
# caddy_arch="386"
# ;;
'amd64' | x86_64)
v2ray_bit="64"
caddy_arch="amd64"
;;
# *armv6*)
# v2ray_bit="arm32-v6"
# caddy_arch="arm6"
# ;;
# *armv7*)
# v2ray_bit="arm32-v7a"
# caddy_arch="arm7"
# ;;
*aarch64* | *armv8*)
v2ray_bit="arm64-v8a"
caddy_arch="arm64"
;;
*)
echo -e "
Haha...this ${red}spicy chicken script${none} doesn't support your system. ${yellow}(-_-) ${none}

Note: Only supports Ubuntu 16+ / Debian 8+ / CentOS 7+ systems
" && exit 1
;;
esac

# Stupid detection method
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

if [[ $(command -v yum) ]]; then

cmd="yum"

fi

else

echo -e "
Haha...this ${red}spicy chicken script${none} doesn't support your system. ${yellow}(-_-) ${none}

Note: Only supports Ubuntu 16+ / Debian 8+ / CentOS 7+ systems
" && exit 1

fi

uuid=$(cat /proc/sys/kernel/random/uuid)
old_id="e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
v2ray_server_config="/etc/v2ray/config.json"
v2ray_client_config="/etc/v2ray/233blog_v2ray_config.json"
backup="/etc/v2ray/233blog_v2ray_backup.conf"
_v2ray_sh="/usr/local/sbin/v2ray"
systemd=true
# _test=true

transport=(
TCP
TCP_HTTP
WebSocket
"WebSocket + TLS"
HTTP/2
mKCP
mKCP_utp
mKCP_srtp
mKCP_wechat-video
mKCP_dtls
mKCP_wireguard
QUIC
QUIC_utp
QUIC_srtp
QUIC_wechat-video
QUIC_dtls
QUIC_wireguard
TCP_dynamicPort
TCP_HTTP_dynamicPort
WebSocket_dynamicPort
mKCP_dynamicPort
mKCP_utp_dynamicPort
mKCP_srtp_dynamicPort
mKCP_wechat-video_dynamicPort
mKCP_dtls_dynamicPort
mKCP_wireguard_dynamicPort
QUIC_dynamicPort
QUIC_utp_dynamicPort
QUIC_srtp_dynamicPort
QUIC_wechat-video_dynamicPort
QUIC_dtls_dynamicPort
QUIC_wireguard_dynamicPort
VLESS_WebSocket_TLS
)

ciphers=(
aes-128-gcm
aes-256-gcm
chacha20-ietf-poly1305
)

_load() {
local _dir="/etc/v2ray/233boy/v2ray/src/"
. "${_dir}$@"
}
_sys_timezone() {
IS_OPENVZ=
if hostnamectl status | grep -q openvz; then
IS_OPENVZ=1
fi

echo
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
echo "Your host has been set to Asia/Shanghai time zone and automatically synced with systemd-timesyncd."
echo

if [[ $IS_OPENVZ ]]; then
echo
echo -e "Your host environment is ${yellow}Openvz${none} , it is recommended to use the ${yellow}v2ray mkcp${none} series of protocols."
echo -e "Note: ${yellow}Openvz${none} system time cannot be synchronized by in-vm program control."
echo -e "If the host time differs from the actual host by ${yellow} by more than 90 seconds ${none}, v2ray will not be able to communicate normally. Please send a ticket to contact the vps host for adjustment."
fi
}

_sys_time() {
echo -e "\nHost time: ${yellow}"
timedatectl status | sed -n '1p;4p'
echo -e "${none}"
[[ $IS_OPENV ]] && pause
}
v2ray_config() {
# clear
echo
while :; do
echo -e "Please select "$yellow"V2Ray"$none" transport protocol [${magenta}1-${#transport[*]}$none]"
echo
for ((i = 1; i <= ${#transport[*]}; i++)); do
Stream="${transport[$i - 1]}"
if [[ "$i" -le 9 ]]; then
# echo
echo -e "$yellow $i.$none${Stream}"
else
# echo
echo -e "$yellow $i.$none${Stream}"
fi
done
echo
echo "Note 1: The dynamic port is enabled if it contains [dynamicPort].."
echo "Note 2: [utp | srtp | wechat-video | dtls | wireguard] disguised as [BT download | video call | WeChat video call | DTLS 1.2 packet | WireGuard packet]"
echo
read -p "$(echo -e "(default protocol: ${cyan}TCP$none)"):" v2ray_transport
[ -z "$v2ray_transport" ] && v2ray_transport=1
case $v2ray_transport in
[1-9] | [1-2][0-9] | 3[0-3])
echo
echo
echo -e "$yellow V2Ray transport protocol = $cyan${transport[$v2ray_transport - 1]}$none"
echo "------------------------------------------------ ----------------"
echo
break
;;
*)
error
;;
esac
done
v2ray_port_config
}
v2ray_port_config() {
case $v2ray_transport in
4 | 5 | 33)
tls_config
;;
*)
local random=$(shuf -i20001-65535 -n1)
while :; do
echo -e "Please enter "$yellow"V2Ray"$none" port ["$magenta"1-65535"$none"]"
read -p "$(echo -e "(default port: ${cyan}${random}$none):")" v2ray_port
[ -z "$v2ray_port" ] && v2ray_port=$random
case $v2ray_port in
[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0 -9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9 ] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
echo
echo
echo -e "$yellow V2Ray port = $cyan$v2ray_port$none"
echo "------------------------------------------------ ----------------"
echo
break
;;
*)
error
;;
esac
done
if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
v2ray_dynamic_port_start
fi
;;
esac
}

v2ray_dynamic_port_start() {

while :; do
echo -e "Please enter "$yellow" V2Ray dynamic port start "$none" range ["$magenta"1-65535"$none"]"
read -p "$(echo -e "(default start port: ${cyan}10000$none):")" v2ray_dynamic_port_start_input
[ -z $v2ray_dynamic_port_start_input ] && v2ray_dynamic_port_start_input=10000
case $v2ray_dynamic_port_start_input in
$v2ray_port)
echo
echo " cannot be used with V2
