/// Data model representing a narcotics officer using the NarcSeal app.
class Officer {
  final String badgeId;
  final String fullName;
  final String username;
  final String rank;
  final String role;
  final String stationCode;
  final String district;
  final String state;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isActive;
  final DateTime? lastLogin;

  const Officer({
    required this.badgeId,
    required this.fullName,
    required this.username,
    required this.rank,
    this.role = 'field_officer',
    required this.stationCode,
    required this.district,
    required this.state,
    this.phoneNumber,
    this.photoUrl,
    this.isActive = true,
    this.lastLogin,
  });

  /// Short display name (e.g., "Insp. Sharma")
  String get shortTitle {
    final rankPrefix = switch (rank) {
      'inspector' => 'Insp.',
      'sub_inspector' => 'SI',
      'head_constable' => 'HC',
      'constable' => 'Const.',
      'dsp' => 'DSP',
      'sp' => 'SP',
      'dig' => 'DIG',
      'ig' => 'IG',
      _ => '',
    };
    final lastName = fullName.split(' ').last;
    return '$rankPrefix $lastName';
  }
}
