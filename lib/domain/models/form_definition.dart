enum FormStatus { draft, published, archived }

enum FieldType { text, number, email, phone, select, checkbox, textarea, date }

class AppFormField {
  const AppFormField({
    required this.id,
    required this.type,
    required this.label,
    this.placeholder,
    this.required = false,
    this.options = const [],
  });

  final String id;
  final FieldType type;
  final String label;
  final String? placeholder;
  final bool required;
  final List<String> options;
}

class FormDefinition {
  const FormDefinition({
    required this.id,
    required this.title,
    this.description,
    required this.slug,
    this.status = FormStatus.draft,
    this.fields = const [],
    this.submissionsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String slug;
  final FormStatus status;
  final List<AppFormField> fields;
  final int submissionsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  FormDefinition copyWith({
    String? id,
    String? title,
    String? description,
    String? slug,
    FormStatus? status,
    List<AppFormField>? fields,
    int? submissionsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      FormDefinition(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        slug: slug ?? this.slug,
        status: status ?? this.status,
        fields: fields ?? this.fields,
        submissionsCount: submissionsCount ?? this.submissionsCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
