import 'mock_test_structure.dart';

/// Thrown by `MockTestAssembler.assemble` when a required Teil exposes zero
/// Tests in its source data model, so a complete Attempt cannot be built.
///
/// Carries the offending [section] and [teilNumber] for diagnostics. The
/// user-facing message is generic and localized at the presentation layer; this
/// exception's [message] is intended for logging and debugging only.
///
/// _Requirements: 12.1, 12.2_
class MockAssemblyException implements Exception {
  /// The Section whose Teil could not be assembled.
  final MockSection section;

  /// The `teilNumber` of the offending Teil within [section].
  final int teilNumber;

  const MockAssemblyException({
    required this.section,
    required this.teilNumber,
  });

  /// Diagnostic message (not shown to the user).
  String get message =>
      'Cannot assemble Mock Test: ${section.name} Teil $teilNumber has no '
      'available Test in its source data.';

  @override
  String toString() => 'MockAssemblyException(${section.name}, '
      'teilNumber: $teilNumber): $message';
}
