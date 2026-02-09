import 'package:todoapp/features/lists/models/share_result.dart';

class ShareState {
  final bool isSharing;
  final ShareResult? shareResult;
  final String? error;

  const ShareState({this.isSharing = false, this.shareResult, this.error});

  ShareState copyWith({
    bool? isSharing,
    ShareResult? shareResult,
    String? error,
    bool clearResult = false,
  }) {
    return ShareState(
      isSharing: isSharing ?? this.isSharing,
      shareResult: clearResult ? null : (shareResult ?? this.shareResult),
      error: clearResult ? null : (error ?? this.error),
    );
  }
}
