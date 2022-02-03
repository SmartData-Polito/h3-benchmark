#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    NET="-p 8090:8090 -p 8091:8091 -p 8090:8090/udp -p 8091:8091/udp"
    cat $PWD/nginx.conf | sed s/localhost/host.docker.internal/g > /tmp/nginx.conf
elif [ "$(uname)" == "Linux"  ]; then
    NET='--network=host' 
    cp $PWD/nginx.conf /tmp/nginx.conf
fi

sudo docker run --rm --name nginx   -v $PWD/nginx.conf:/etc/nginx/nginx.conf \
                                    -v $PWD/video_dash/:/etc/nginx/html/ \
                                    -v $PWD/cert/certificate.key:/etc/nginx/certificate.key \
                                    -v $PWD/cert/certificate.pem:/etc/nginx/certificate.pem \
                                    $NET \
                                    ymuski/nginx-quic

