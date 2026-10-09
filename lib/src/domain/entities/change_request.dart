class ChangeRequest {
  final String id;
  final String reason;
  final DateTime deadlineUtc;
  final DateTime createdAt;

  const ChangeRequest({
    required this.id,
    required this.reason,
    required this.deadlineUtc,
    required this.createdAt,
  });
}