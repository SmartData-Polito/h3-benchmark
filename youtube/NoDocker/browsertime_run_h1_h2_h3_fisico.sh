#!/bin/bash
network_param=$(echo $1 | tr ":" " ")
name=$2
http=$3
num_esp=$4
interface=$5
#interface="enx00243217c403"
video="false"
cookie="CONSENT=YES+yt.422910894.it+FX+214" #is an example!!
echo "Hai inserito: Esperimenti-$1 name-$2 http-$3 numero_esp-$4"

for t in ${network_param[@]}; do
    echo "#########BEFORE###########" >> http${http}_log_${name}.txt
    tc qdisc show >> http${http}_log_${name}.txt
    if [[ ${name} == "bw" ]]; then
        sudo ./network_emulator.sh ${interface}:${t}mbit:${t}mbit::
    elif [[ ${name} == "pl" ]]; then
        sudo ./network_emulator.sh ${interface}::::${t}%
    elif [[ ${name} == "RTT" ]]; then
        sudo ./network_emulator.sh ${interface}:::${t}ms:
    else
        echo "Hai inserito tipo errato"
    fi
    echo "#########AFTER###########" >> http${http}_log_${name}.txt
    tc qdisc show >> http${http}_log_${name}.txt
    echo "########END-AFTER########" >> http${http}_log_${name}.txt
    for esp in $(seq "$num_esp"); do
      if [[ ${http} == "3" ]]; then
          browsertime \
           --chrome.args enable-quic \
           --chrome.args ignore-urlfetcher-cert-requests \
           --chrome.args autoplay-policy=no-user-gesture-required --chrome.args no-first-run \
           --chrome.args quic-version=h3 \
           -n 1 \
           --video $video \
           --videoParams.createFilmstrip $video \
           --visualMetrics $video \
           --videoParams.convert $video \
           --viewPort="4096x2160" \
           --cookie $cookie \
           --cacheClearRaw true \
           --har har_http${http}_${name}_${t}_esp_${esp} \
           --resultDir results_http${http}_${name}_${t}_esp_${esp}\
           --pageCompleteCheckStartWait 540000 \
           https://www.youtube.com/embed/aqz-KE-bpKQ?autoplay=1 --tcpdump
      elif [[ ${http} == "1" ]]; then
          browsertime \
           --chrome.args disable-quic \
           --chrome.args ignore-urlfetcher-cert-requests \
           --chrome.args autoplay-policy=no-user-gesture-required --chrome.args no-first-run \
           --chrome.args disable-http2 \
           -n 1 \
           --video $video \
           --videoParams.createFilmstrip $video \
           --visualMetrics $video \
           --videoParams.convert $video \
           --viewPort="4096x2160" \
           --cookie $cookie \
           --cacheClearRaw true \
           --har har_http${http}_${name}_${t}_esp_${esp} \
           --resultDir results_http${http}_${name}_${t}_esp_${esp}\
           --pageCompleteCheckStartWait 540000 \
           https://www.youtube.com/embed/aqz-KE-bpKQ?autoplay=1 --tcpdump
      else
        echo "Hai inserito http errato"
        exit -1
      fi
    done
    sudo ./network_emulator.sh remove
done

