#!/bin/bash

N=5
OUTDIR=results

mkdir -p $OUTDIR
for domain in $( cat ../census/crawl_domains.txt ) ; do
#for domain in www.youtube.com ; do

    echo $domain
    mkdir -p results/$domain
    
    # HTTP 1
    sudo docker run --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:10.9.0 \
                                                                                --video \
                                                                                --visualMetrics \
                                                                                -n $N \
                                                                                --useSameDir \
                                                                                --har ../../../../results/$domain/h1 \
                                                                                --chrome.args="--disable-http2" \
                                                                                --chrome.args="--disable-quic" \
                                                                                https://$domain
    
    # HTTP 2
    sudo docker run --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:10.9.0 \
                                                                                --video \
                                                                                --visualMetrics \
                                                                                -n $N \
                                                                                --useSameDir \
                                                                                --har ../../../../results/$domain/h2 \
                                                                                --chrome.args="--disable-quic"\
                                                                                https://$domain
    
    
    # HTTP 3
    sudo docker run --rm -v "$(pwd)"/${OUTDIR}:/results sitespeedio/browsertime:10.9.0 \
                                                                                --video \
                                                                                --visualMetrics \
                                                                                -n $N \
                                                                                --useSameDir \
                                                                                --har ../../../../results/$domain/h3 \
                                                                                --chrome.args="--quic-version=h3-29" \
                                    --chrome.args="--origin-to-force-quic-on=$( ./get_h3_origins.py results/$domain/h2.har )" \
                                                                                https://$domain
                                                                                
    #sudo docker run --rm -v "$(pwd)":/browsertime sitespeedio/browsertime:10.9.0 \
    # --video --visualMetrics -n 1 --chrome.args="--quic-version=h3-29" \
    # --chrome.args="--origin-to-force-quic-on=fonts.googleapis.com:443,www.youtube.com:443,fonts.gstatic.com:443" https://www.youtube.com/
    
done






