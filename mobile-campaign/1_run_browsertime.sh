#!/bin/bash

# Test a domain with:
# cat domains.txt  | xargs -I {} -- bash -c "echo {} ; sudo docker run  --rm ymuski/curl-http3 curl --http3 -m 10 https://{} -o /dev/null -S -L -v 2>&1 | grep HTTP/"
        
NUM=10
RATS="4g 3g"
QUALITIES="good medium bad"
DOMAINS=$( cat domains.txt )
IFACE_SHAPING=docker0
DOCKER_NET="bridge"
# Set the out dir, according to the campaign
OUTDIR="results_smartphone"
# Set this parameter to emulate a device

EMULATION_ARG="--chrome.mobileEmulation.deviceName 'iPhone 6'"
#EMULATION_ARG="--chrome.mobileEmulation.deviceName iPad"
#EMULATION_ARG=""

banner() {
    msg="# $* #"
    edge=$(echo "$msg" | sed 's/./#/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
}

mkdir -p $OUTDIR

for domain in $DOMAINS ; do
for rat in $RATS ; do
for quality in $QUALITIES ; do
for i in $( seq $NUM )  ; do

    # Setup vars
    banner "Website: ${domain}, RAT: ${rat}, Quality: ${quality}, Iteration: ${i}"
    mkdir -p $OUTDIR/$domain/$rat/$quality/$i
    
    pushd errant
    sudo ./errant -o universal -c universal -t $rat -q $quality -i $IFACE_SHAPING -l ../$OUTDIR/$domain/$rat/$quality/$i/errant-log.txt
    popd

    # HTTP 1
    eval sudo docker run --network=$DOCKER_NET --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:14.7.0 \
                    --video \
                    --visualMetrics \
                    -n 1 \
                    --useSameDir \
                    --har ../../../../results/$domain/$rat/$quality/$i/h1 \
                    --chrome.args="--disable-http2" \
                    --chrome.args="--disable-quic" \
                    ${EMULATION_ARG} \
                    https://$domain

    # HTTP 2
    eval sudo docker run --network=$DOCKER_NET  --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:14.7.0 \
                    --video \
                    --visualMetrics \
                    -n 1 \
                    --useSameDir \
                    --har ../../../../results/$domain/$rat/$quality/$i/h2 \
                    --chrome.args="--disable-quic"\
                    $EMULATION_ARG \
                    https://$domain

    
    # HTTP 3
    eval sudo docker run --network=$DOCKER_NET  --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:14.7.0 \
                    --video \
                    --visualMetrics \
                    -n 1 \
                    --useSameDir \
                    --har ../../../../results/$domain/$rat/$quality/$i/h3 \
                    --chrome.args="--quic-version=h3" \
        --chrome.args="--origin-to-force-quic-on=$( ./get_h3_origins.py $OUTDIR/$domain/$rat/$quality/$i/h2.har )" \
                    $EMULATION_ARG \
                    https://$domain

    pushd errant
    sudo ./errant -r
    popd
    
done
done
done
done
