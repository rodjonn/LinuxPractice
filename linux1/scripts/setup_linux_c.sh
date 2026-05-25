#!/bin/sh
# Linux C (Client) — kulakov_client
# Docker version: добавляем маршрут к серверу и шлём curl-запросы

# Маршрут к подсети сервера через шлюз linux_b
ip route add 192.168.13.0/24 via 192.168.8.1

# Установка curl
apk add --no-cache curl > /dev/null 2>&1

SERVER="192.168.13.10:5000"

# Ждём пока сервер поднимется (до 60 секунд)
echo "Ожидаем kulakov_server..."
for i in $(seq 1 30); do
    if curl -sf --connect-timeout 2 "http://${SERVER}/get" > /dev/null 2>&1; then
        echo "Сервер доступен!"
        break
    fi
    printf "Попытка %d/30...\n" "$i"
    sleep 2
done

echo ""
echo "================================================"
echo " kulakov_client — отправляем запросы"
echo "================================================"

echo ""
echo "--- GET http://${SERVER}/get ---"
curl -s -X GET "http://${SERVER}/get"

echo ""
echo "--- POST http://${SERVER}/post ---"
curl -s -X POST "http://${SERVER}/post" \
     -H "Content-Type: application/json" \
     -d '{"student": "kulakov"}'

echo ""
echo "--- PUT http://${SERVER}/put ---"
curl -s -X PUT "http://${SERVER}/put" \
     -H "Content-Type: application/json" \
     -d '{"update": "kulakov_data"}'

echo ""
echo "================================================"
echo " Все три запроса отправлены успешно."
echo "================================================"
tail -f /dev/null
