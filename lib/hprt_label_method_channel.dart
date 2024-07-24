import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hprt_label_platform_interface.dart';

class MethodChannelHprtLabel extends HprtLabelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hprt_label');

  @override
  Future<bool?> connectIp(Map<String, dynamic> param) async {
    final result = await methodChannel.invokeMethod<bool>('connectIp', param) ?? false;
    return result;
  }

  @override
  Future<String?> printImage(Map<String, dynamic> param) async {
    final result = await methodChannel.invokeMethod<String>('printImage', param) ?? "failed";
    return result;
  }
}
