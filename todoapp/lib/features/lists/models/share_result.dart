class ShareResult {
  final int successCount;
  final List<ShareFailure> failures;

  ShareResult({required this.successCount, this.failures = const []});
}

class ShareFailure {
  final String name;
  final String error;

  ShareFailure({required this.name, required this.error});
}
