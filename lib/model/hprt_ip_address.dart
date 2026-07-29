class HPRTIpAddress {
  final String ipAddress;

  HPRTIpAddress({
    required this.ipAddress,
  });

  Map<String, dynamic> toJson() => {
        "ipAddress": ipAddress,
      };
}
