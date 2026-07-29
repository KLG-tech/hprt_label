import 'dart:ui';

class HPRTPaperSize {
  final Size size;

  HPRTPaperSize({
    required this.size,
  });

  Map<String, dynamic> toJson() => {'width': size.width, 'height': size.height};
}
