import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/form_definition.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
import '../../shared/utils/id_gen.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/responsive_data_table.dart';
import '../../shared/widgets/search_and_filter_bar.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_badge.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.forms;

  bool _isLoading = true;
  bool _loadFailed = false;
  List<FormDefinition> _forms = [];
  Map<String, dynamic> _stats = {};
  FormStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    final statsRes = await _repo.stats();
    if (statsRes is Success<Map<String, dynamic>>) {
      _stats = statsRes.data;
    }

    await _fetchForms();
  }

  Future<void> _fetchForms() async {
    final res = await _repo.list(
      search: _searchController.text,
      status: _selectedStatus,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res is Success) {
        _forms = (res as Success).data.items;
      } else {
        _loadFailed = true;
      }
    });
  }

  String _statusLabel(AppLocalizations l10n, FormStatus status) {
    switch (status) {
      case FormStatus.published:
        return l10n.statusPublished;
      case FormStatus.draft:
        return l10n.statusDraft;
      case FormStatus.archived:
        return l10n.statusArchived;
    }
  }

  Widget _buildStatusBadge(AppLocalizations l10n, FormStatus status) {
    final label = _statusLabel(l10n, status);
    switch (status) {
      case FormStatus.published:
        return StatusBadge.success(label: label);
      case FormStatus.draft:
        return StatusBadge.warning(label: label);
      case FormStatus.archived:
        return StatusBadge.neutral(label: label);
    }
  }

  Future<void> _previewForm(FormDefinition form) async {
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => _FormPreviewDialog(form: form),
    );
    if (submitted == true && mounted) {
      AppFeedback.success(
        context,
        AppLocalizations.of(context)!.formSubmittedMessage,
      );
      _loadData();
    }
  }

  void _showAddEditDialog([FormDefinition? form]) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = form != null;
    final titleCtrl = TextEditingController(text: form?.title ?? '');
    final slugCtrl = TextEditingController(text: form?.slug ?? '');
    final descCtrl = TextEditingController(text: form?.description ?? '');
    FormStatus status = form?.status ?? FormStatus.published;
    String? titleError;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? l10n.editFormTitle : l10n.createFormAction,
              ),
              content: SizedBox(
                width: dialogContentWidth(context, 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: '${l10n.formTitleLabel} *',
                        errorText: titleError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        if (titleError != null) {
                          setDialogState(() => titleError = null);
                        }
                        if (!isEditing && slugCtrl.text.isEmpty) {
                          slugCtrl.text = val.toLowerCase().replaceAll(
                            RegExp(r'[^a-z0-9]+'),
                            '-',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: slugCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.formSlugLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FormStatus>(
                      initialValue: status,
                      decoration: InputDecoration(
                        labelText: l10n.formStatusLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: FormStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(_statusLabel(l10n, s)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => status = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.formDescriptionLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) {
                      setDialogState(() => titleError = l10n.formTitleRequired);
                      return;
                    }
                    final slug = slugCtrl.text.trim().isNotEmpty
                        ? slugCtrl.text.trim()
                        : titleCtrl.text.trim().toLowerCase().replaceAll(
                            RegExp(r'[^a-z0-9]+'),
                            '-',
                          );

                    final Result<FormDefinition> result;
                    if (isEditing) {
                      final updated = form.copyWith(
                        title: titleCtrl.text.trim(),
                        slug: slug,
                        description: descCtrl.text.trim(),
                        status: status,
                      );
                      result = await _repo.update(updated);
                    } else {
                      final newForm = FormDefinition(
                        id: IdGen.uuid(),
                        title: titleCtrl.text.trim(),
                        slug: slug,
                        description: descCtrl.text.trim(),
                        status: status,
                        submissionsCount: 0,
                        fields: [
                          AppFormField(
                            id: 'f1',
                            type: FieldType.text,
                            label: l10n.formNameField,
                            placeholder: l10n.formNamePlaceholder,
                            required: true,
                          ),
                          AppFormField(
                            id: 'f2',
                            type: FieldType.email,
                            label: l10n.formEmailField,
                            placeholder: l10n.formEmailPlaceholder,
                            required: true,
                          ),
                          AppFormField(
                            id: 'f3',
                            type: FieldType.textarea,
                            label: l10n.formMessageField,
                            placeholder: l10n.formMessagePlaceholder,
                            required: true,
                          ),
                        ],
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      result = await _repo.create(newForm);
                    }

                    if (!mounted) return;
                    if (result is Success) {
                      if (dialogCtx.mounted) {
                        Navigator.of(dialogCtx).pop();
                        AppFeedback.success(
                          dialogCtx,
                          isEditing ? l10n.formUpdated : l10n.formCreated,
                        );
                      }
                      _loadData();
                    } else if (dialogCtx.mounted) {
                      AppFeedback.error(dialogCtx, (result as Failure).error);
                    }
                  },
                  child: Text(isEditing ? l10n.actionSave : l10n.actionCreate),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteForm(FormDefinition form) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDialogTitle(form.title)),
        content: Text(l10n.deleteDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _repo.delete(form.id);
      if (!mounted) return;
      AppFeedback.fromResult(context, result, successMessage: l10n.formDeleted);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    if (_loadFailed) {
      return ErrorStateView(message: l10n.loadFailed, onRetry: _loadData);
    }

    final totalForms = _stats['totalForms']?.toString() ?? '—';
    final publishedForms = _stats['publishedForms']?.toString() ?? '—';
    final totalSubmissions = _stats['totalSubmissions']?.toString() ?? '—';

    return SingleChildScrollView(
      key: const Key('forms-page'),
      padding: AppSpacing.pagePadding(width),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.formsPageTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.formsPageSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(l10n.createFormAction),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = AppBreakpoints.isMobile(constraints.maxWidth);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isCompact ? 1 : 3,
                    mainAxisExtent: 130,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  children: [
                    StatCard(
                      label: l10n.totalForms,
                      value: totalForms,
                      icon: Icons.dynamic_form_outlined,
                    ),
                    StatCard(
                      label: l10n.activePublished,
                      value: publishedForms,
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: l10n.totalSubmissions,
                      value: totalSubmissions,
                      icon: Icons.mark_email_read_outlined,
                      iconColor: Colors.blue,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.searchFormsHint,
              onSearchChanged: (_) => _fetchForms(),
              filterWidgets: [
                DropdownButton<FormStatus?>(
                  value: _selectedStatus,
                  hint: Text(l10n.allStatuses),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.allStatuses),
                    ),
                    ...FormStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabel(l10n, s)),
                      ),
                    ),
                  ],
                  onChanged: (s) {
                    setState(() => _selectedStatus = s);
                    _fetchForms();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ResponsiveDataTable<FormDefinition>(
              items: _forms,
              isLoading: _isLoading,
              emptyTitle: l10n.noFormsTitle,
              emptyMessage: l10n.noFormsMessage,
              emptyActionLabel: l10n.createFormAction,
              onEmptyAction: () => _showAddEditDialog(),
              columns: [
                TableColumnDef(label: l10n.colTitle, flex: 3),
                TableColumnDef(label: l10n.colSlug, flex: 2),
                TableColumnDef(label: l10n.colFields, flex: 2),
                TableColumnDef(label: l10n.colSubmissions, flex: 2),
                TableColumnDef(label: l10n.colStatus, flex: 2),
                TableColumnDef(
                  label: l10n.colActions,
                  flex: 3,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, form, index) {
                return [
                  Text(
                    form.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '/forms/${form.slug}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(l10n.fieldsCount(form.fields.length)),
                  Text('${form.submissionsCount}'),
                  _buildStatusBadge(l10n, form.status),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        key: Key('preview-form-${form.id}'),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        onPressed: () => _previewForm(form),
                        tooltip: l10n.previewFormTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(form),
                        tooltip: l10n.actionEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deleteForm(form),
                        tooltip: l10n.actionDelete,
                      ),
                    ],
                  ),
                ];
              },
              mobileCardBuilder: (context, form, index) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              form.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusBadge(l10n, form.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/forms/${form.slug}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${l10n.fieldsCount(form.fields.length)} • '
                              '${l10n.submissionsCountLabel(form.submissionsCount)}',
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                key: Key('preview-form-${form.id}'),
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                ),
                                onPressed: () => _previewForm(form),
                                tooltip: l10n.previewFormTooltip,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAddEditDialog(form),
                                tooltip: l10n.actionEdit,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                color: theme.colorScheme.error,
                                onPressed: () => _deleteForm(form),
                                tooltip: l10n.actionDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Test/preview dialog that submits through the repository instead of
/// mutating the local submission count.
class _FormPreviewDialog extends StatefulWidget {
  const _FormPreviewDialog({required this.form});

  final FormDefinition form;

  @override
  State<_FormPreviewDialog> createState() => _FormPreviewDialogState();
}

class _FormPreviewDialogState extends State<_FormPreviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _selectValues = {};
  final Map<String, bool> _checkboxValues = {};
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    for (final field in widget.form.fields) {
      if (field.type == FieldType.select) {
        _selectValues[field.id] = null;
      } else if (field.type == FieldType.checkbox) {
        _checkboxValues[field.id] = false;
      } else {
        _controllers[field.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validate(AppLocalizations l10n, AppFormField field, String? value) {
    final trimmed = value?.trim() ?? '';
    if (field.required && trimmed.isEmpty) return l10n.fieldRequired;
    if (trimmed.isEmpty) return null;
    if (field.type == FieldType.email &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      return l10n.loginEmailInvalid;
    }
    if (field.type == FieldType.number && double.tryParse(trimmed) == null) {
      return l10n.fieldRequired;
    }
    return null;
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{};
    for (final field in widget.form.fields) {
      switch (field.type) {
        case FieldType.select:
          final value = _selectValues[field.id];
          if (value != null) payload[field.id] = value;
          break;
        case FieldType.checkbox:
          payload[field.id] = _checkboxValues[field.id] ?? false;
          break;
        default:
          final value = _controllers[field.id]?.text.trim() ?? '';
          if (value.isNotEmpty) payload[field.id] = value;
      }
    }
    return payload;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final result = await AppRepositories.instance.forms.submit(
      widget.form.id,
      _buildPayload(),
    );

    if (!mounted) return;
    if (result is Success) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _submitError = (result as Failure).error.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPublished = widget.form.status == FormStatus.published;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(widget.form.title)),
          const SizedBox(width: 12),
          _statusBadge(l10n, widget.form.status),
        ],
      ),
      content: SizedBox(
        width: dialogContentWidth(context, 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.form.description != null) ...[
                  Text(
                    widget.form.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Divider(height: 24),
                ],
                if (!isPublished) ...[
                  Text(
                    l10n.formUnpublishedHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ...widget.form.fields.map(_buildField),
                if (_submitError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _submitError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        FilledButton(
          onPressed: isPublished && !_isSubmitting ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.submitFormAction),
        ),
      ],
    );
  }

  Widget _buildField(AppFormField field) {
    final l10n = AppLocalizations.of(context)!;
    final label = '${field.label}${field.required ? ' *' : ''}';

    if (field.type == FieldType.select) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: _selectValues[field.id],
          decoration: InputDecoration(
            labelText: label,
            hintText: field.placeholder ?? l10n.selectOptionLabel,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: field.options.map((opt) {
            return DropdownMenuItem(value: opt, child: Text(opt));
          }).toList(),
          validator: (value) =>
              field.required && value == null ? l10n.fieldRequired : null,
          onChanged: (value) {
            setState(() => _selectValues[field.id] = value);
          },
        ),
      );
    }

    if (field.type == FieldType.checkbox) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FormField<bool>(
          initialValue: _checkboxValues[field.id] ?? false,
          validator: (value) =>
              field.required && value != true ? l10n.fieldRequired : null,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(field.placeholder ?? label),
                  value: _checkboxValues[field.id] ?? false,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() => _checkboxValues[field.id] = value ?? false);
                    state.didChange(value);
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _controllers[field.id],
        maxLines: field.type == FieldType.textarea ? 3 : 1,
        keyboardType: switch (field.type) {
          FieldType.email => TextInputType.emailAddress,
          FieldType.number => TextInputType.number,
          FieldType.phone => TextInputType.phone,
          _ => TextInputType.text,
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: field.placeholder,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (value) => _validate(l10n, field, value),
      ),
    );
  }
}

Widget _statusBadge(AppLocalizations l10n, FormStatus status) {
  final label = switch (status) {
    FormStatus.published => l10n.statusPublished,
    FormStatus.draft => l10n.statusDraft,
    FormStatus.archived => l10n.statusArchived,
  };
  return switch (status) {
    FormStatus.published => StatusBadge.success(label: label),
    FormStatus.draft => StatusBadge.warning(label: label),
    FormStatus.archived => StatusBadge.neutral(label: label),
  };
}
