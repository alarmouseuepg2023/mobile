// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

int getUserId() {
  Random rand = Random();
  return rand.nextInt(1000000);
}

final userId = getUserId();

class MQTTClientManager extends ChangeNotifier {
  MqttServerClient? client;

  void initializeClient() {
    client = MqttServerClient.withPort(dotenv.env['MQTT_HOST'] ?? '', '$userId',
        int.parse(dotenv.env['MQTT_PORT'] ?? '1883'));

    client!.keepAlivePeriod = 60;
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;
    client!.onUnsubscribed = onUnsubscribed;
    client!.pongCallback = pong;
    //client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs(dotenv.env['MQTT_USER'], dotenv.env['MQTT_PASSWORD'])
        .withClientIdentifier('$userId');
    client!.connectionMessage = connMessage;
  }

  Future<int> connect() async {
    assert(client != null);
    try {
      await client!.connect();
    } on NoConnectionException catch (e) {
      print('MQTTClient::Client exception - $e');
      client!.disconnect();
    } on SocketException catch (e) {
      print('MQTTClient::Socket exception - $e');
      client!.disconnect();
    }

    return 0;
  }

  void disconnect() {
    client!.disconnect();
  }

  void subscribe(String topic) {
    client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  void unsubscribe(String topic) {
    client!.unsubscribe(topic);
  }

  void onConnected() {
    print('MQTT CONNECTED');
  }

  void onDisconnected() {
    print('MQTTClient::Disconnected');
  }

  void onSubscribed(String topic) {
    print('MQTTClient::Subscribed to topic: $topic');
  }

  void onUnsubscribed(String? topic) {
    print('MQTTClient::Unsubscribed from topic: $topic');
  }

  void pong() {
    print('MQTTClient::Ping response received');
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client!.updates;
  }
}

final mqttProvider = ChangeNotifierProvider((ref) {
  return MQTTClientManager();
});
