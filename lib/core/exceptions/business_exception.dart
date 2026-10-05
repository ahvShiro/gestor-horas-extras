class BusinessException implements Exception {
  final String message;
  final int? statusCode;

  const BusinessException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}
