class InterviewSummary {
  final String role;
  final int overallScore;
  final String feedback;
  final List<String> strengths;
  final List<String> improvements;

  InterviewSummary({
    required this.role,
    required this.overallScore,
    required this.feedback,
    required this.strengths,
    required this.improvements,
});

  factory InterviewSummary.fromJson(Map<String, dynamic> json) {
    return InterviewSummary(
        role: json['role'] ?? '',
        overallScore: json['overallScore'] ?? 0,
        feedback: json['feedback'] ?? '',
        strengths: List<String>.from(json['strengths'] ?? []),
        improvements: List<String>.from(json['improvements'] ?? []),
    );
  }
}