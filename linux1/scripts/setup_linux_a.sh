#!/bin/sh
# Linux A (Server) — kulakov_server
# Docker version: сеть уже настроена compose, только маршрут + Flask

# Маршрут для ответных пакетов к клиенту (через шлюз linux_b)
ip route add 192.168.8.0/24 via 192.168.13.1 2>/dev/null || true

# Установка Python и Flask из пакетов Alpine (без pip, надёжнее)
apk add --no-cache python3 py3-flask > /dev/null 2>&1

# Копируем приложение
mkdir -p /home/kulakov_1/server
cp /app/app.py /home/kulakov_1/server/

echo "================================================"
echo " kulakov_server готов. Flask стартует на :5000"
echo "================================================"
python3 /home/kulakov_1/server/app.py
