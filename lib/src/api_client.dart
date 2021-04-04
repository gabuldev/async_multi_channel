import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';

import 'package:async_multi_channels/src/channel_client.dart';

String get uuid => DateTime.now().toIso8601String();

abstract class RequestBase {
  String get id;
  Completer<ApiResponse> get completer;
  RequestBase head(Map<String, dynamic> data);
  RequestBase body(Map<String, dynamic> data);
}

class ApiResquest implements RequestBase {
  String _id;
  final String path;
  Completer<ApiResponse> _completer = Completer<ApiResponse>();
  // ignore: unused_field
  Map<String, dynamic> _head;
  // ignore: unused_field
  Map<String, dynamic> _body;
  ApiResquest(this.path) {
    _id = uuid;
  }
  @override
  body(Map<String, dynamic> data) {
    _body = data;
    return this;
  }

  @override
  head(Map<String, dynamic> data) {
    _head = data;
    return this;
  }

  @override
  String get id => _id;

  @override
  // TODO: implement complete
  Completer<ApiResponse> get completer => _completer;
}

class ApiResponse {
  final String id;
  final Map<String, dynamic> body;
  ApiResponse({
    @required this.id,
    @required this.body,
  });

  ApiResponse copyWith({
    String id,
    Map<String, dynamic> body,
  }) {
    return ApiResponse(
      id: id ?? this.id,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'body': body,
    };
  }

  factory ApiResponse.fromMap(Map<String, dynamic> map) {
    return ApiResponse(
      id: map['id'],
      body: Map<String, dynamic>.from(map['body']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiResponse.fromJson(String source) =>
      ApiResponse.fromMap(json.decode(source));

  @override
  String toString() => 'ApiResponse(id: $id, body: $body)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiResponse &&
        other.id == id &&
        mapEquals(other.body, body);
  }

  @override
  int get hashCode => id.hashCode ^ body.hashCode;
}

class ApiClient {
  final _requests = Map<String, RequestBase>();

  ApiClient(ChannelClient channel) {
    channel.listen((response) {
      if (_requests.containsKey(response.id)) {
        _requests[response].completer.complete(response);
      }
    });
  }

  Future<ApiResponse> post(String path,
      {Map<String, dynamic> body, Map<String, dynamic> head}) {
    final _request = ApiResquest(path).body(body).head(head);
    _requests.addAll({_request.id: _request});
    return _request.completer.future;
  }
}
