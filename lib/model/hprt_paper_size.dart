import 'dart:ui';

class HPRTPaperSize {
  final Size size;

  HPRTPaperSize({
    required this.size,
  });

  Map<String, dynamic> toJson() => {'width': size.width, 'height': size.height};
}


class HPRTCoordinate {
  final Size size;

  HPRTCoordinate({
    required this.size,
  });

  Map<String, dynamic> toJson() => {'x': size.width, 'y': size.height};
}