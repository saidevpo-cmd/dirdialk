import 'package:diali/data/mock/mock_form_repository.dart';
import 'package:diali/domain/models/app_error.dart';
import 'package:diali/domain/models/form_definition.dart';
import 'package:flutter_test/flutter_test.dart';

FormDefinition form({
  required String id,
  FormStatus status = FormStatus.published,
  int submissions = 0,
}) => FormDefinition(
  id: id,
  title: 'Contact',
  slug: 'contact-$id',
  status: status,
  submissionsCount: submissions,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  group('MockFormRepository.submit', () {
    test('increments only the target published form', () async {
      final repo = MockFormRepository(
        initialData: [
          form(id: 'a', submissions: 2),
          form(id: 'b', submissions: 7),
        ],
      );

      final result = await repo.submit('a', {'name': 'Ada'});

      expect(result, isA<Success<void>>());
      final a = (await repo.getById('a') as Success<FormDefinition>).data;
      final b = (await repo.getById('b') as Success<FormDefinition>).data;
      expect(a.submissionsCount, 3);
      expect(b.submissionsCount, 7);
    });

    test('rejects submissions to draft forms', () async {
      final repo = MockFormRepository(
        initialData: [form(id: 'draft', status: FormStatus.draft)],
      );

      final result = await repo.submit('draft', {'name': 'Ada'});

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error.code, AppError.validationCode);
      final draft =
          (await repo.getById('draft') as Success<FormDefinition>).data;
      expect(draft.submissionsCount, 0);
    });

    test('returns notFound for an unknown form', () async {
      final repo = MockFormRepository(initialData: []);

      final result = await repo.submit('missing', const {});

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, AppError.notFound);
    });
  });
}
