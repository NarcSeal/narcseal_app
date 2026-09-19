/// Enum representing the outcome of a drug test analysis.
enum TestResult {
  positive,
  negative,
  inconclusive;

  /// Display label in uppercase for UI rendering.
  String get displayLabel => name.toUpperCase();

  /// Whether this result is a drug-positive finding.
  bool get isDrugPositive => this == TestResult.positive;
}
