#!/bin/bash
network_param=$(echo $1 | tr ":" " ")
name=$2
http=$3
num_esp=$4
interface=$5
video="false"

for t in ${network_param[@]}; do
    echo "#########BEFORE###########" >> http${http}_log_${name}.txt
    tc qdisc show >> http${http}_log_${name}.txt
    echo "########END-BEFORE########" >> http${http}_log_${name}.txt
    if [[ ${name} == "bw" ]]; then
        sudo ./network_emulator.sh ${interface}:${t}mbit:${t}mbit::
    elif [[ ${name} == "pl" ]]; then
        sudo ./network_emulator.sh ${interface}::::${t}%
    elif [[ ${name} == "RTT" ]]; then
    #    sudo ./network_emulator.sh ${interface}:::${t}ms:
    else
        echo "Hai inserito tipo errato"
    fi
    echo "#########AFTER###########" >> http${http}_log_${name}.txt
    tc qdisc show >> http${http}_log_${name}.txt
    echo "########END-AFTER########" >> http${http}_log_${name}.txt
    for esp in $(seq "$num_esp"); do
      if [[ ${http} == "1" ]]; then
          sudo docker run --rm -v "$(pwd)":/sitespeed -w / sitespeedio/browsertime \
           --chrome.args ignore-urlfetcher-cert-requests \
           --chrome.args autoplay-policy=no-user-gesture-required --chrome.args no-first-run \
           -n 1 \
           --video $video \
           --videoParams.createFilmstrip $video \
           --visualMetrics $video \
           --videoParams.convert $video \
           --har har_http${http}_${name}_${t}_esp_${esp} \
           --resultDir /sitespeed/results_http${http}_${name}_${t}_esp_${esp} \
           --pageCompleteCheckStartWait 540000 \
           https://www.youtube.com/watch?v=aqz-KE-bpKQ --tcpdump
           
      elif [[ ${http} == "3" ]]; then
          sudo docker run --rm -v "$(pwd)":/sitespeed -w / sitespeedio/browsertime \
           --chrome.args enable-quic \
           --chrome.args ignore-urlfetcher-cert-requests \
           --chrome.args autoplay-policy=no-user-gesture-required --chrome.args no-first-run \
           --chrome.args quic-version=h3 \
           -n 1 \
           --video $video \
           --videoParams.createFilmstrip $video \
           --visualMetrics $video \
           --videoParams.convert $video \
           --cookie CONSENT=YES+yt.422910894.it+FX+214 \
           --har har_http${http}_${name}_${t}_esp_${esp} \
           --cacheClearRaw true \
           --resultDir /sitespeed/results_http${http}_${name}_${t}_esp_${esp}\
           --pageCompleteCheckStartWait 540000 \
           https://www.youtube.com/watch?v=aqz-KE-bpKQ --tcpdump
    else
        echo "Hai inserito http errato"
        exit -1
    fi
  done
  sudo ./network_emulator.sh remove
done

