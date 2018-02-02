# kafka-k8s-training

This repository has several components:

* [Docker](docker) files for the creation of docker images for Kafka broker and consumers
* [Makefile](Makefile) which automates the creation of the docker images
* [helm charts](charts) used in the deployment of docker images for the publisher and consumer to Kubernetes
* [Kubernetes YAML files](kafka) used to deploy Zookeeper and Kafka to Kubernetes
