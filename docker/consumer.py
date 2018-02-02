from confluent_kafka import Consumer, KafkaException, KafkaError, TopicPartition
import sys, os, logging, time

from pprint import pformat, pprint

KAFKA_HOST = os.environ.get('KAFKA_HOST', "kafka")
KAFKA_TOPIC = os.environ.get('KAFKA_TOPIC', "test")


def print_assignment(consumer, partitions):
    logging.info('kafka assignment: %s', pformat(partitions))


def fetch_metrics(brokers, topic):
    conf = {'bootstrap.servers': brokers, 'group.id': topic, 'session.timeout.ms': 6000,
            'default.topic.config': {'auto.offset.reset': 'smallest'}}

    client = Consumer(**conf)
    client.subscribe([topic])

    while True:
        msg = client.poll(timeout=1.0)

        if msg is None:
            continue

        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                # End of partition event
                logging.debug('%s [%d] reached end at offset %d' %
                              (msg.topic(), msg.partition(), msg.offset()))
                break
            elif msg.error():
                raise logging.error(msg.error())
        else:
            logging.debug('%s [%d] at offset %d with key %s:' %
                          (msg.topic(), msg.partition(), msg.offset(),
                           str(msg.key())))

        print(msg.value())


while True:
    fetch_metrics(KAFKA_HOST, KAFKA_TOPIC)
    time.sleep(1)
