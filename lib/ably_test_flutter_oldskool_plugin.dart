import 'dart:async';

import 'package:flutter/services.dart';

class AblyTestFlutterOldskoolPlugin {
  static const MethodChannel _channel =
      const MethodChannel('ably_test_flutter_oldskool_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
