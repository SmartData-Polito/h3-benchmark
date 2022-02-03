
Measuring HTTP/3 Performance
============================

This repository contains the source code that we have used to setup and run the experiments of the paper "*A First Look at HTTP/3 Adoption and Performance*". It contains the code to run the crawlers under different network conditions and replicate the measurement campaigns we have run for our paper.

## Dependencies

All our code has been run on high-end Linux servers equipped with Ubuntu 20.04. A few tools are needed to make the experiments run:
* Docker: to run containers. On Ubuntu, you can install using [this](https://docs.docker.com/engine/install/ubuntu/) guide.
* ERRANT: a data-driven emulator of Radio Access Networks, available [here](https://github.com/marty90/errant).
* Network Condition Emulator: a tool to easily install `tc-netem` policies, available [here](https://github.com/marty90/Network-Conditions-Emulator).

## Large Scale Census
With the large scale census, you can test all the 12 k HTTP/3-enabled websites that we have measured in the paper. The code is in the folder `browsing-campaign`. The scripts allow you to create the needed `tc-netem` policies and run the visits using the [BrowserTime](https://www.sitespeed.io/documentation/browsertime/) tool via Docker. The list of domains in the `census` directory.

## Mobile Experiments
In the mobile campaign, we tested a set of websites emulating mobile (tablet and smartphone) devices, with emulated mobile network conditions. We used a subset of 100 websites (25 per content provider), randomly chosen among the complete list of 12 k websites. The code is in the folder `mobile-campaign`, where the scripts allow you to visit the websites using BrowserTime via Docker and ERRANT to emulate the mobile network conditions.


## Youtube

In this folder are present the files for running the experiments with (limited):
* Bandwidth.
* RTT.
* Packet Loss.

with e without the use of docker.
In particular, browsertime application is used.
In order to use the system, configure the file run_every with the desired experiment.
The structure of the file is the following:
`./browsertime_run_h1_h2_h3.sh value1:value2..:value_n [bw/RTT/pl] [http-1/2/3] n_experiments name_interface`

It is important to configure in `./browsertime_run_h1_h2_h3.sh` a valid coockie session.

