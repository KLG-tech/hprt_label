import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hprt_label_method_channel.dart';

abstract class HprtLabelPlatform extends PlatformInterface {
  /// Constructs a HprtLabelPlatform.
  HprtLabelPlatform() : super(token: _token);

  static final Object _token = Object();

  static HprtLabelPlatform _instance = MethodChannelHprtLabel();

  /// The default instance of [HprtLabelPlatform] to use.
  ///
  /// Defaults to [MethodChannelHprtLabel].
  static HprtLabelPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HprtLabelPlatform] when
  /// they register themselves.
  static set instance(HprtLabelPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> connectIp(Map<String, dynamic> param) {
    throw UnimplementedError('connectIp(param) has not been implemented.');
  }

  Future<String?> printImage(Map<String, dynamic> param) {
    throw UnimplementedError('printImage(param) has not been implemented.');
  }

  Future<String?> connectUsb() {
    throw UnimplementedError('connectUsb has not been implemented.');
  }

  Future<String?> requestUsbPermission() {
    throw UnimplementedError('requestUsbPermission has not been implemented.');
  }
}
