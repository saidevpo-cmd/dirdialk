import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/app_error.dart';

/// Maps infrastructure exceptions to the domain [AppError] and wraps results.
///
/// Every Supabase repository method routes through [guard] so the UI sees the
/// same `Result<T>` contract regardless of the data source.
Future<Result<T>> guard<T>(Future<T> Function() run) async {
  try {
    return Success(await run());
  } on AppError catch (e) {
    // Repository methods signal domain errors (e.g. notFound) by throwing an
    // [AppError]; it is already mapped, so pass it straight through.
    return Failure(e);
  } on PostgrestException catch (e) {
    return Failure(_fromPostgrest(e));
  } on AuthException catch (e) {
    return Failure(AppError(
      code: 'UNAUTHORIZED',
      message: e.message,
      statusCode: e.statusCode == null ? 401 : int.tryParse(e.statusCode!),
    ));
  } on StorageException catch (e) {
    return Failure(AppError(
      code: 'STORAGE_ERROR',
      message: e.message,
      statusCode: int.tryParse(e.statusCode ?? ''),
    ));
  } catch (e) {
    return Failure(AppError(
      code: 'NETWORK_ERROR',
      message: e.toString(),
    ));
  }
}

AppError _fromPostgrest(PostgrestException e) {
  switch (e.code) {
    case '23505': // unique_violation
      return const AppError(
        code: 'CONFLICT',
        message: 'A record with the same unique value already exists.',
        statusCode: 409,
      );
    case '23503': // foreign_key_violation
      return const AppError(
        code: 'VALIDATION',
        message: 'Related record is missing or still in use.',
        statusCode: 400,
      );
    case '23502': // not_null_violation
    case '23514': // check_violation
    case '22P02': // invalid_text_representation
      return const AppError(
        code: 'VALIDATION',
        message: 'A value violates a database rule.',
        statusCode: 400,
      );
    case '42501': // insufficient_privilege (RLS / grants)
      return const AppError(
        code: 'FORBIDDEN',
        message: 'You do not have permission to perform this action.',
        statusCode: 403,
      );
    case 'PGRST116': // no row / multiple rows returned for single()
      return AppError.notFound;
    case 'PGRST301': // JWT expired or invalid
      return AppError.unauthorized;
    default:
      break;
  }
  final status = _statusFromMessage(e.message);
  return AppError(
    code: status == 401
        ? 'UNAUTHORIZED'
        : status == 403
            ? 'FORBIDDEN'
            : 'SERVER_ERROR',
    message: e.message,
    statusCode: status,
  );
}

int _statusFromMessage(String message) {
  final m = RegExp(r'\b([45]\d{2})\b').firstMatch(message);
  if (m != null) {
    return int.parse(m.group(1)!);
  }
  final lower = message.toLowerCase();
  if (lower.contains('permission denied') ||
      lower.contains('row-level security')) {
    return 403;
  }
  if (lower.contains('jwt') || lower.contains('not authenticated')) {
    return 401;
  }
  return 400;
}
