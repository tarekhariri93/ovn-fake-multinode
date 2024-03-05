#!/bin/bash -xe

RUNC_CMD=${RUNC_CMD:-podman}

# Simple configuration sanity checks
$RUNC_CMD exec -it ovn-central-az1-1 ovn-nbctl show > nb_show
$RUNC_CMD exec -it ovn-central-az1-1 ovn-sbctl show > sb_show

if [ "$CREATE_FAKE_VMS" = "yes" ]; then
    grep "(public1)" nb_show
    grep "(sw01)" nb_show
    grep "(sw11)" nb_show
    grep "(lr1)" nb_show
fi

grep "Chassis ovn-gw-1" sb_show
grep "Chassis ovn-chassis-1" sb_show
grep "Chassis ovn-chassis-2" sb_show


# Some pings between the containers
$RUNC_CMD exec -it ovn-chassis-1 ping -c 1 -w 1 170.168.0.2
$RUNC_CMD exec -it ovn-chassis-1 ping -c 1 -w 1 170.168.0.3
$RUNC_CMD exec -it ovn-chassis-1 ping -c 1 -w 1 170.168.0.5

$RUNC_CMD exec -it ovn-chassis-2 ping -c 1 -w 1 170.168.0.2
$RUNC_CMD exec -it ovn-chassis-2 ping -c 1 -w 1 170.168.0.3
$RUNC_CMD exec -it ovn-chassis-2 ping -c 1 -w 1 170.168.0.4

$RUNC_CMD exec -it ovn-gw-1 ping -c 1 -w 1 170.168.0.2
$RUNC_CMD exec -it ovn-gw-1 ping -c 1 -w 1 170.168.0.4
$RUNC_CMD exec -it ovn-gw-1 ping -c 1 -w 1 170.168.0.5


if [ "$CREATE_FAKE_VMS" = "yes" ]; then
    # Check expected routes from nested namespaces

    $RUNC_CMD exec -it ovn-chassis-1 ip netns

    # sw01p1 : dual stack
    $RUNC_CMD exec -it ovn-chassis-1 ip netns exec sw01p1 ip -4 route > sw01p1_route
    $RUNC_CMD exec -it ovn-chassis-1 ip netns exec sw01p1 ip -6 route >> sw01p1_route
    cat sw01p1_route
    grep "11.0.0.0/24 dev sw01p1" sw01p1_route
    grep "default via 11.0.0.1 dev sw01p1" sw01p1_route
    grep "1001::/64 dev sw01p1" sw01p1_route
    grep "default via 1001::a dev sw01p1" sw01p1_route

    echo 'happy happy, joy joy'
fi
