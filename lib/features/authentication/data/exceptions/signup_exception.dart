class SignupException implements Exception {
  final String message;
  final int? statusCode;

  const SignupException(this.message, {this.statusCode});

  @override
  String toString() => 'SignupException: [$statusCode] $message';
}
