import 'package:flutter_test/flutter_test.dart';
import 'package:hprt_label/hprt_label.dart';
import 'package:hprt_label/hprt_label_platform_interface.dart';
import 'package:hprt_label/hprt_label_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHprtLabelPlatform
    with MockPlatformInterfaceMixin
    implements HprtLabelPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HprtLabelPlatform initialPlatform = HprtLabelPlatform.instance;

  test('$MethodChannelHprtLabel is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHprtLabel>());
  });

  test('getPlatformVersion', () async {
    HprtLabel hprtLabelPlugin = HprtLabel();
    MockHprtLabelPlatform fakePlatform = MockHprtLabelPlatform();
    HprtLabelPlatform.instance = fakePlatform;

    expect(await hprtLabelPlugin.getPlatformVersion(), '42');
  });
}
