# docker-images
Repository for docker images
## kafka-cluster-ssl
Kafka cluster docker images with SSL enabled   
Usage
1. Run ```./create-certs.sh``` to generate the ssl trust store and keystore.
2. Run ```export KAFKA_SSL_SECRETS_DIR=$(pwd)/secrets```
2. Run ```docker-compose up -d``` to start the kafka cluster
2. Run ```docker-compose ps``` or ```docker-compose logs kafka-ssl-1``` to check the status
3. Run the following command to verify zk status: 
```Bash
for i in 22181 32181 42181; do
   docker run --net=host --rm confluentinc/cp-zookeeper:5.0.1 bash -c "echo stat | nc localhost $i | grep Mode"
done
```
3. Run ```bin/kafka-topics --zookeeper zookeeper-1:22181 --topic mytest2 --create --partitions 3 --replication-factor 3``` to create a topic
4. Run ```bin/kafka-console-consumer --bootstrap-server kafka-1:19094 --topic mytest2 --consumer.config /etc/kafka/secrets/host.consumer.ssl.config``` to start the console consumer
5. Run ```bin/kafka-console-producer --broker-list kafka-1:19094 --topic mytest2 --producer.config /etc/kafka/secrets/host.producer.ssl.config``` to start the console producer
