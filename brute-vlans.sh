for vlan in {2..4094}; do
    echo "--- Trying VLAN $vlan ---"
    sudo ip link add link eth1 name eth1.$vlan type vlan id $vlan 2>/dev/null
    sudo ip link set eth1.$vlan up
    sudo ip addr add 10.230.5.200/24 dev eth1.$vlan 2>/dev/null
    # Отправляем один ARP-запрос с таймаутом 1 секунда
    if sudo arping -c 1 -w 1 -I eth1.$vlan 10.230.5.1 &>/dev/null; then
        echo "SUCCESS: VLAN $vlan responding!"
        break
    fi
    sudo ip link del eth1.$vlan 2>/dev/null
done
