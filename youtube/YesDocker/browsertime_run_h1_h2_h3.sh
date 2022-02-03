#!/bin/bash
network_param=$(echo $1 | tr ":" " ")
name=$2
http=$3
num_esp=$4
interface="enx002467356b83"
video="true"
echo "Hai inserito: Esperimenti-$1 name-$2 http-$3 numero_esp-$4"

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
        echo "Non setto nulla"
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
           http://130.192.95.216:8090/controlbar.html --tcpdump
      elif [[ ${http} == "2" ]]; then
        sudo docker run --rm -v "$(pwd)":/sitespeed -w / sitespeedio/browsertime \
         --chrome.args ignore-urlfetcher-cert-requests \
         --chrome.args autoplay-policy=no-user-gesture-required --chrome.args no-first-run \
         --chrome.args ignore-certificate-errors-spki-list=5V2I9iQ0NrsorG7qXJzxuVGyFcla/L4HNMyrzgx7X0E= \
         -n 1 \
         --video $video \
         --videoParams.createFilmstrip $video \
         --visualMetrics $video \
         --videoParams.convert $video \
         --har har_http${http}_${name}_${t}_esp_${esp} \
         --resultDir /sitespeed/results_http${http}_${name}_${t}_esp_${esp}\
         --pageCompleteCheckStartWait 540000 \
         https://130.192.95.216:8091/controlbar.html --tcpdump
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
           --pageCompleteCheckStartWait 10000 \
           https://www.youtube.com/watch?v=aqz-KE-bpKQ --tcpdump
    else
        echo "Hai inserito http errato"
        exit -1
    fi
    n_chunk=`cat results_http${http}_${name}_${t}_esp_${esp}/har_http${http}_${name}_${t}_esp_${esp}.har | egrep -o "_[0-9]*.m4v" | sort | uniq | wc -l`
    echo "Esperimento ${name} - ${t}  numero - ${esp} - Chunk Visualizzati - ${n_chunk}  http - ${http}" | tee -a http${http}_log_${name}.txt
  done
  sudo ./network_emulator.sh remove
done

