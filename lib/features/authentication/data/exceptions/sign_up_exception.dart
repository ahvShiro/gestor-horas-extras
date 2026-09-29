class SignUpException implements Exception {
  final String message;
  final int? statusCode;

  const SignUpException(this.message, {this.statusCode});

  @override
  String toString() => 'SignUpException: [$statusCode] $message';
}
