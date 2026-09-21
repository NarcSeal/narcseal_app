class TestKit {
  final String id;
  final String name;
  final int waitTimeSeconds;

  TestKit({
    required this.id,
    required this.name,
    required this.waitTimeSeconds,
  });

  factory TestKit.fromJson(Map<String, dynamic> json) {
    return TestKit(
      id: json['id'] as String,
      name: json['name'] as String,
      waitTimeSeconds: json['wait_time_seconds'] as int,
    );
  }
}
