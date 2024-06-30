class ErrorObject {
  late final int statusCode;
  late final String? message;

  ErrorObject({required this.statusCode, required this.message});

  @override
  String toString() {
    return 'ErrorObject(statusCode: $statusCode, message: $message)';
  }
}