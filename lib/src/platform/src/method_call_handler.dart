import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// @nodoc
/// Handles method calls invoked from platform side to dart side
class AblyMethodCallHandler {
  /// @nodoc
  /// creates instance with method channel and forwards calls respective
  /// instance methods: [onAuthCallback], [onRealtimeAuthCallback], etc
  AblyMethodCallHandler(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.authCallback:
          return onAuthCallback(call.arguments as AblyMessage);
        case PlatformMethod.realtimeAuthCallback:
          return onRealtimeAuthCallback(call.arguments as AblyMessage?);
        default:
          throw PlatformException(
              code: 'Received invalid method channel call from Platform side',
              message: 'No such method ${call.method}');
      }
    });
  }

  /// @nodoc
  /// handles auth callback for rest instances
  Future<Object> onAuthCallback(AblyMessage<dynamic> message) async {
    final tokenParams = message.message as TokenParams;
    final rest = restInstances[message.handle];
    if (rest == null) {
      throw AblyException(
        message: "AblyMethodCallHandler#onAuthCallback's "
            'rest handle is ${message.handle}, and rest is $rest',
      );
    }
    return rest.options.authCallback!(tokenParams);
  }

  /// @nodoc
  /// handles auth callback for realtime instances
  Future<Object?> onRealtimeAuthCallback(AblyMessage<dynamic>? message) async {
    final tokenParams = message!.message as TokenParams;
    final realtime = realtimeInstances[message.handle];
    if (realtime == null) {
      throw AblyException(
        message: "AblyMethodCallHandler#onRealtimeAuthCallback's "
            'realtime handle is ${message.handle}, and realtime is $realtime',
      );
    }
    return realtime.options.authCallback!(tokenParams);
  }

}
