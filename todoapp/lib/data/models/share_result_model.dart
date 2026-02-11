import 'package:todoapp/features/lists/models/share_result.dart';

class ShareResultModel {
  final int successCount;
  final List<ShareFailureModel> failures;

  ShareResultModel({required this.successCount, this.failures = const []});

  factory ShareResultModel.fromJson(Map<String, dynamic> json) {
    return ShareResultModel(
      successCount: json['successCount'] as int,
      failures: (json['failures'] as List?)
              ?.map(
                (f) => ShareFailureModel.fromJson(f as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  ShareResult toEntity() {
    return ShareResult(
      successCount: successCount,
      failures: failures.map((f) => f.toEntity()).toList(),
    );
  }
}

class ShareFailureModel {
  final String name;
  final String error;

  ShareFailureModel({required this.name, required this.error});

  factory ShareFailureModel.fromJson(Map<String, dynamic> json) {
    return ShareFailureModel(
      name: json['name'] as String,
      error: json['error'] as String,
    );
  }

  ShareFailure toEntity() {
    return ShareFailure(name: name, error: error);
  }
}
