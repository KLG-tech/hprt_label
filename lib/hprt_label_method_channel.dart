import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hprt_label/model/hprt_image_to_print.dart';
import 'package:hprt_label/model/hprt_ip_address.dart';
import 'package:hprt_label/model/hprt_paper_size.dart';

import 'hprt_label_platform_interface.dart';

class MethodChannelHprtLabel extends HprtLabelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hprt_label');

  @override
  Future<bool?> connectIp(HPRTIpAddress param) async {
    final result = await methodChannel.invokeMethod<bool>('connectIp', param.toJson()) ?? false;
    return result;
  }

  @override
  Future<bool?> printImage(HPRTImageToPrint param) async {
    final result = await methodChannel.invokeMethod<bool>('printImage', param.toJson()) ?? false;
    return result;
  }

  @override
  Future<bool?> connectUsb() async {
    final result = await methodChannel.invokeMethod<bool>('connectUsb') ?? false;
    return result;
  }

  @override
  Future<bool?> requestUsbPermission() async {
    final result = await methodChannel.invokeMethod<bool>('requestUsbPermission') ?? false;
    return result;
  }

  @override
  Future<bool?> setPaperSize(HPRTPaperSize size) async {
    final result = await methodChannel.invokeMethod<bool>("setPaperSize", size.toJson()) ?? false;
    return result;
  }

  @override
  Future<bool?> setCoordinate(HPRTCoordinate size) async {
    final result = await methodChannel.invokeMethod<bool>("setCoordinate", size.toJson()) ?? false;
    return result;
  }

  @override
  Future<bool?> disconnect() async {
    final result = await methodChannel.invokeMethod<bool>("disconnect") ?? false;
    return result;
  }
}
