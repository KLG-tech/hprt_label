import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hprt_label_platform_interface.dart';

class MethodChannelHprtLabel extends HprtLabelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hprt_label');

  @override
  Future<String?> connectIp(Map<String, dynamic> param) async {
    final result = await methodChannel.invokeMethod<String>('connectIp', param) ?? "failed";
    return result;
  }

  @override
  Future<String?> printImage(Map<String, dynamic> param) async {
    final result = await methodChannel.invokeMethod<String>('printImage', param) ?? "failed";
    return result;
  }

  @override
  Future<String?> connectUsb() async {
    final result = await methodChannel.invokeMethod<String>('connectUsb') ?? "failed";
    return result;
  }

  @override
  Future<String?> requestUsbPermission() async {
    final result = await methodChannel.invokeMethod<String>('requestUsbPermission') ?? "failed";
    return result;
  }
}
