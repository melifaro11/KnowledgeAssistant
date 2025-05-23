class SourceStatus {
  /// Source ID
  final String sourceId;

  /// Status: pending | running | indexed | failed
  final String status;

  /// Progress (0-100)
  final int progress;

  /// Status message
  final String? message;

  SourceStatus({
    required this.sourceId,
    required this.status,
    required this.progress,
    this.message,
  });

  factory SourceStatus.fromJson(Map<String, dynamic> json, String sourceId) {
    return SourceStatus(
      sourceId: sourceId,
      status: json['status'] as String,
      progress: json['progress'] as int,
      message: json['message'] as String?,
    );
  }
}
