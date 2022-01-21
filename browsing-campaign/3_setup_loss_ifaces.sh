#!/bin/bash



sudo docker network rm loss_1
sudo docker network create  --driver bridge \
                            --opt "com.docker.network.bridge.name"="docker_loss_1" loss_1
                            
sudo docker network rm loss_2
sudo docker network create  --driver bridge \
                            --opt "com.docker.network.bridge.name"="docker_loss_2" loss_2
                            
sudo docker network rm loss_5
sudo docker network create  --driver bridge \
                            --opt "com.docker.network.bridge.name"="docker_loss_5" loss_5         
                            
                            
sudo ./Network-Conditions-Emulator/network_emulator.sh docker_loss_1::::1% docker_loss_2::::2% docker_loss_5::::5%