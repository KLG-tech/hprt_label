import 'hprt_label_platform_interface.dart';

class HprtLabel {
  Future<bool?> connectIp(Map<String, dynamic> param) {
    try {
      return HprtLabelPlatform.instance.connectIp(param);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> printImage(Map<String, dynamic> param) {
    try {
      return HprtLabelPlatform.instance.printImage(param);
    } catch (e) {
      rethrow;
    }
  }
}
