import 'package:async_multi_channels/src/api_client.dart';
import 'package:async_multi_channels/src/channel_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ApiClient client;
  ChannelClient channelClient;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    channelClient = ChannelClient();
    client = ApiClient(channelClient);
  });

  test("Test", () async {
    channelClient.channel
        .setMockMethodCallHandler((call) => Future.value(MethodCall("update", {
              "id": "123456",
              "body": {"a": "test", "b": "test"}
            })));
    channelClient.channel.invokeMethod("update");
    final response = await client.post("/users");
  });
}
