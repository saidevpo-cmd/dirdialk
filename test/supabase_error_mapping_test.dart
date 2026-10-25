import 'package:diali/core/supabase/supabase_result.dart';
import 'package:diali/domain/models/app_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

PostgrestException _pg(String? code, String message) =>
    PostgrestException(message: message, code: code);

void main() {
  group('guard success', () {
    test('wraps a value in Success', () async {
      final result = await guard<int>(() async => 42);
      expect(result, isA<Success<int>>());
      expect((result as Success<int>).data, 42);
    });

    test('passes a thrown AppError straight through', () async {
      final result = await guard<int>(() async => throw AppError.notFound);
      expect(result, isA<Failure<int>>());
      final error = (result as Failure<int>).error;
      expect(error.code, 'NOT_FOUND');
      expect(error.statusCode, 404);
    });
  });

  group('PostgREST mapping', () {
    Future<AppError> map(PostgrestException e) async {
      final result = await guard<int>(() async => throw e);
      return (result as Failure<int>).error;
    }

    test('unique violation -> CONFLICT 409', () async {
      final error = await map(_pg('23505', 'duplicate key value'));
      expect(error.code, 'CONFLICT');
      expect(error.statusCode, 409);
    });

    test('foreign key violation -> VALIDATION 400', () async {
      final error = await map(_pg('23503', 'violates foreign key constraint'));
      expect(error.code, 'VALIDATION');
      expect(error.statusCode, 400);
    });

    test('check / not-null / invalid input -> VALIDATION 400', () async {
      for (final code in ['23514', '23502', '22P02']) {
        final error = await map(_pg(code, 'bad value'));
        expect(error.code, 'VALIDATION', reason: code);
        expect(error.statusCode, 400, reason: code);
      }
    });

    test('P0001 (plpgsql RAISE from an RPC) -> VALIDATION 400', () async {
      final error = await map(
        _pg('P0001', 'a valid phone number is required'),
      );
      expect(error.code, 'VALIDATION');
      expect(error.statusCode, 400);
      // The server message is surfaced so a validation error is actionable.
      expect(error.message, 'a valid phone number is required');
    });

    test('insufficient privilege (RLS) -> FORBIDDEN 403', () async {
      final error = await map(_pg('42501', 'permission denied for table'));
      expect(error.code, 'FORBIDDEN');
      expect(error.statusCode, 403);
    });

    test('PGRST116 -> NOT_FOUND 404', () async {
      final error = await map(_pg('PGRST116', 'JSON object requested'));
      expect(error.code, 'NOT_FOUND');
      expect(error.statusCode, 404);
    });

    test('PGRST301 -> UNAUTHORIZED 401', () async {
      final error = await map(_pg('PGRST301', 'JWT expired'));
      expect(error.code, 'UNAUTHORIZED');
      expect(error.statusCode, 401);
    });

    test('RLS text without an error code -> FORBIDDEN 403', () async {
      final error = await map(
        _pg(null, 'new row violates row-level security policy'),
      );
      expect(error.code, 'FORBIDDEN');
      expect(error.statusCode, 403);
    });

    test('unknown error code falls back to SERVER_ERROR', () async {
      final error = await map(_pg('XX000', 'internal error'));
      expect(error.code, 'SERVER_ERROR');
      expect(error.statusCode, 400);
    });
  });

  group('auth and storage mapping', () {
    test('AuthException -> UNAUTHORIZED', () async {
      final result = await guard<int>(
        () async => throw const AuthException('bad', statusCode: '401'),
      );
      final error = (result as Failure<int>).error;
      expect(error.code, 'UNAUTHORIZED');
      expect(error.statusCode, 401);
    });

    test('StorageException -> STORAGE_ERROR', () async {
      final result = await guard<int>(
        () async => throw const StorageException('too big', statusCode: '413'),
      );
      final error = (result as Failure<int>).error;
      expect(error.code, 'STORAGE_ERROR');
      expect(error.statusCode, 413);
    });

    test('unexpected exception -> NETWORK_ERROR', () async {
      final result = await guard<int>(() async => throw StateError('boom'));
      final error = (result as Failure<int>).error;
      expect(error.code, 'NETWORK_ERROR');
    });
  });
}
