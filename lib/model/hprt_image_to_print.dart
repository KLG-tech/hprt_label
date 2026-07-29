import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

class HPRTImageToPrint {
  final ByteData image;

  HPRTImageToPrint({
    required this.image,
  });

  Map<String, dynamic> toJson() => {
        "byteData": image,
      };
}
