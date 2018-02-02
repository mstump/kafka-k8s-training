# kafka-k8s-training

This repository has several components:

* [Docker](docker) files for the creation of docker images for Kafka broker and consumers
* [Makefile](Makefile) which automates the creation of the docker images
* [helm charts](charts) used in the deployment of docker images for the publisher and consumer to Kubernetes
* [Kubernetes YAML files](kafka) used to deploy Zookeeper and Kafka to Kubernetes

## Useful links

* [helm](https://github.com/kubernetes/helm) to create templates for k8s YAML files
* [ark](https://github.com/heptio/ark/) for backup restore in kubernetes
* [authenticator](https://github.com/heptio/authenticator) for setting up auth to AWS IAM users
* [dex](https://github.com/coreos/dex) for auth to LDAP
* [kops](https://github.com/kubernetes/kops) for provisioning k8s on AWS

## Building and deploying components to k8s

### Install Zookeeper and Kafka
```
kubectl create -f kafka/zookeeper/*.yml
kubectl create -f kafka/kafka.yml
```

### Docker

Build docker images
```
make build
```

Push the docker images to the repositor(ies) defined at the top of the Makefile
```
make push
```

Run the Kafka consumer docker image
```
make kafka-consumer_run
```

Run the Kafka publisher docker image
```
make kafka-publisher_run
```

Access the shell of the Kafka publisher docker image
```
make kafka-publisher_shell
```

Access the shell of the Kafka consumer docker image
```
make kafka-consumer_shell
```

### Install Helm charts for the producer and the consumer

Install [helm](https://github.com/kubernetes/helm) on your local machine. Then install helm on your k8s cluster by running.

```
helm init
helm version
```

Install each of the helm charts.

```
helm install -n publisher charts/publisher
helm install -n consumer charts/consumer
```

Wait for the pods to become ready

```
kubectl get po -w
```

Tail the logs for the publisher deployment
```
kubectl logs -f deployment/publisher-publisher
```
