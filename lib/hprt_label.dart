import 'package:hprt_label/model/hprt_image_to_print.dart';
import 'package:hprt_label/model/hprt_ip_address.dart';
import 'package:hprt_label/model/hprt_paper_size.dart';

import 'hprt_label_platform_interface.dart';

class HprtLabel {
  Future<bool?> connectIp(HPRTIpAddress param) {
    try {
      return HprtLabelPlatform.instance.connectIp(param);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> printImage(HPRTImageToPrint param) async {
    try {
      return HprtLabelPlatform.instance.printImage(param);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> connectUsb() async {
    try {
      return HprtLabelPlatform.instance.connectUsb();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> requestUsbPermission() async {
    try {
      return HprtLabelPlatform.instance.requestUsbPermission();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> setPaperSize(HPRTPaperSize size) async {
    try {
      return HprtLabelPlatform.instance.setPaperSize(size);
    } catch (e) {
      rethrow;
    }
  }
}
