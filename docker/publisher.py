from confluent_kafka import Producer, KafkaException, KafkaError
import sys, os, logging, time

from pprint import pformat, pprint

KAFKA_HOST = os.environ.get('KAFKA_HOST', "kafka")
KAFKA_TOPIC = os.environ.get('KAFKA_TOPIC', "test")


def produce(broker, topic):

    conf = {'bootstrap.servers': broker}

    # Create Producer instance
    p = Producer(**conf)

    sys.stderr.write('BROKER: %s\n' % broker)
    sys.stderr.write('TOPIC: %s\n' % topic)

    # Optional per-message delivery callback (triggered by poll() or flush())
    # when a message has been successfully delivered or permanently
    # failed delivery (after retries).
    def delivery_callback(err, msg):
        if err:
            sys.stderr.write('%% Message failed delivery: %s\n' % err)
        else:
            sys.stderr.write('%% Message delivered to %s [%d] @ %o\n' %
                             (msg.topic(), msg.partition(), msg.offset()))


    # Read lines from stdin, produce each line to Kafka
    for i in xrange(0,10000):
        try:
            # Produce line (without newline)
            p.produce(topic, str(i), callback=delivery_callback)

        except BufferError as e:
            sys.stderr.write('%% Local producer queue is full (%d messages awaiting delivery): try again\n' %
                             len(p))


        p.poll(0)

    # Wait until all messages have been delivered
    sys.stderr.write('%% Waiting for %d deliveries\n' % len(p))
    p.flush()


while True:
    produce(KAFKA_HOST, KAFKA_TOPIC)
    time.sleep(1)
