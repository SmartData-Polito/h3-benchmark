#!/bin/bash



sudo docker network rm bw_5
sudo docker network create  --driver bridge \
                            --opt "com.docker.network.bridge.name"="docker_bw_5" bw_5
                            
sudo docker network rm bw_2
sudo docker network create  --driver bridge \
                            --opt "com.docker.network.bridge.name"="docker_bw_2" bw_2
                            
sudo docker network rm bw_1
sudo docker network create  --driver bridge \
                            --opt "com.docker.network.bridge.name"="docker_bw_1" bw_1       
                            
                            
sudo ./Network-Conditions-Emulator/network_emulator.sh docker_bw_5:5mbit:5mbit:: docker_bw_2:2mbit:2mbit:: docker_bw_1:1mbit:1mbit::