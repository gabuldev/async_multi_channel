import 'package:async_multi_channels/src/api_client.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class ChannelClient {
  static final instance = ChannelClient();

  final stream = BehaviorSubject<Map<String, dynamic>>();
  final channel = MethodChannel("api_client");

  void listen(void Function(ApiResponse response) onChange) {
    stream.listen((json) {
      onChange(ApiResponse.fromMap(json));
    });
  }

  ChannelClient() {
    channel.setMethodCallHandler((call) async {
      stream.sink.add(call.arguments);
      return true;
    });
  }
}
