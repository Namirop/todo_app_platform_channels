import 'package:todoapp/features/lists/models/share_result.dart';

class ShareState {
  final bool isSharing;
  final bool hasShared;
  final ShareResult? shareResult;
  final String? error;

  const ShareState({
    this.isSharing = false,
    this.hasShared = false,
    this.shareResult,
    this.error,
  });

  ShareState copyWith({
    bool? isSharing,
    bool? hasShared,
    ShareResult? shareResult,
    String? error,
    bool clearResult = false,
  }) {
    return ShareState(
      isSharing: isSharing ?? this.isSharing,
      hasShared: hasShared ?? this.hasShared,
      shareResult: clearResult ? null : (shareResult ?? this.shareResult),
      error: clearResult ? null : (error ?? this.error),
    );
  }
}
