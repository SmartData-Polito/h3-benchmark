#!/bin/bash

if [ $# -ne 3 ]; then
    echo "usage: $0 bw file outdir"
    exit 1
fi

N=5

BW=$1
FILE=$2
OUTDIR=$3


mkdir -p $OUTDIR

for domain in $( cat $FILE ) ; do
#for domain in www.youtube.com ; do

    echo $domain
    if [ -d "$OUTDIR/$domain" ]; then
        echo "Domain $domain already visited. Skipping..."
        continue
    fi
    
    mkdir -p $OUTDIR/$domain
    
    # HTTP 1
    sudo docker run --network=bw_$BW --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:10.9.0 \
                                                                                --video \
                                                                                --visualMetrics \
                                                                                -n $N \
                                                                                --useSameDir \
                                                                                --har ../../../../results/$domain/h1 \
                                                                                --chrome.args="--disable-http2" \
                                                                                --chrome.args="--disable-quic" \
                                                                                --timeouts.pageLoad 60000 \
                                                                                --timeouts.pageCompleteCheck 60000 \
                                                                                https://$domain
    
    # HTTP 2
    sudo docker run --network=bw_$BW  --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:10.9.0 \
                                                                                --video \
                                                                                --visualMetrics \
                                                                                -n $N \
                                                                                --useSameDir \
                                                                                --har ../../../../results/$domain/h2 \
                                                                                --chrome.args="--disable-quic"\
                                                                                --timeouts.pageLoad 60000 \
                                                                                --timeouts.pageCompleteCheck 60000 \
                                                                                https://$domain
    
    
    # HTTP 3
    sudo docker run --network=bw_$BW  --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:10.9.0 \
                                                                                --video \
                                                                                --visualMetrics \
                                                                                -n $N \
                                                                                --useSameDir \
                                                                                --har ../../../../results/$domain/h3 \
                                                                                --chrome.args="--quic-version=h3-29" \
                                    --chrome.args="--origin-to-force-quic-on=$( ./get_h3_origins.py $OUTDIR/$domain/h2.har )" \
                                                                                --timeouts.pageLoad 60000 \
                                                                                --timeouts.pageCompleteCheck 60000 \
                                                                                https://$domain
                                                                                

done






