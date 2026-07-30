import 'dart:typed_data';

class HPRTImageToPrint {
  final ByteData image;

  HPRTImageToPrint({
    required this.image,
  });

  Map<String, dynamic> toJson() => {
        "byteData": image.buffer.asUint8List(image.offsetInBytes, image.lengthInBytes),
      };
}
