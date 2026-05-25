#!/bin/sh
# Linux B (Gateway) — kulakov_gateway
# Docker version: включаем форвардинг + iptables только на порт 5000

# Включить IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Установка инструментов
apk add --no-cache iptables tcpdump > /dev/null 2>&1

# Определяем интерфейсы по IP автоматически
ETH_SERVER=$(ip -4 addr | awk '/192\.168\.13\./{print $NF}')
ETH_CLIENT=$(ip -4 addr | awk '/192\.168\.8\./{print $NF}')

echo "================================================"
echo " kulakov_gateway"
echo " servernet: $ETH_SERVER — 192.168.13.1"
echo " clientnet: $ETH_CLIENT — 192.168.8.1"
echo "================================================"

# Сбросить существующие правила FORWARD
iptables -F FORWARD

# Разрешить новые TCP-соединения только на порт 5000 (клиент -> сервер)
iptables -A FORWARD -i $ETH_CLIENT -o $ETH_SERVER \
         -p tcp --syn --dport 5000 -m conntrack --ctstate NEW -j ACCEPT

# Разрешить уже установленные соединения в обе стороны
iptables -A FORWARD -i $ETH_CLIENT -o $ETH_SERVER \
         -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $ETH_SERVER -o $ETH_CLIENT \
         -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Всё остальное — заблокировать
iptables -P FORWARD DROP

echo "Правила iptables применены (разрешён только порт 5000):"
iptables -L FORWARD -v --line-numbers

# tcpdump в фоне — смотрим трафик на порту 5000
tcpdump -i $ETH_SERVER port 5000 -l -n &

echo "tcpdump запущен на $ETH_SERVER. Шлюз работает."
tail -f /dev/null
