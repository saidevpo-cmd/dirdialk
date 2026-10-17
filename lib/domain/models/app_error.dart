/// Sealed result type used by all repository methods.
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;
}

class AppError {
  const AppError({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  static const unauthorized =
      AppError(code: 'UNAUTHORIZED', message: 'Unauthorized', statusCode: 401);
  static const forbidden =
      AppError(code: 'FORBIDDEN', message: 'Forbidden', statusCode: 403);
  static const notFound =
      AppError(code: 'NOT_FOUND', message: 'Not found', statusCode: 404);
  static const networkError =
      AppError(code: 'NETWORK_ERROR', message: 'No internet connection');
  static const serverError =
      AppError(code: 'SERVER_ERROR', message: 'Server error', statusCode: 500);

  static const validationCode = 'VALIDATION';
  static const conflictCode = 'CONFLICT';

  /// Input failed a client- or server-side business rule.
  factory AppError.validation(String message) =>
      AppError(code: validationCode, message: message, statusCode: 422);

  /// The request conflicts with current state (e.g. not enough stock).
  factory AppError.conflict(String message) =>
      AppError(code: conflictCode, message: message, statusCode: 409);

  @override
  String toString() => 'AppError($code: $message)';
}
