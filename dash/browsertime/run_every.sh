#!/bin/bash
./browsertime_run_h1_h2_h3.sh 1:2:5 bw 1 10 eth0 #http1
./browsertime_run_h1_h2_h3.sh 1:2:5 bw 2 10 eth0 #http2
./browsertime_run_h1_h2_h3.sh 1:2:5 bw 3 10 eth0 #Experiment http3 bandwidth 1-2-5Mbit
