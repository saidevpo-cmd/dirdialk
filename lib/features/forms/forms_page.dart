import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/form_definition.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
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
  String? _errorMessage;
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
      _errorMessage = null;
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
        _errorMessage = 'Failed to load forms';
      }
    });
  }

  Widget _buildStatusBadge(FormStatus status) {
    switch (status) {
      case FormStatus.published:
        return StatusBadge.success(label: 'Published');
      case FormStatus.draft:
        return StatusBadge.warning(label: 'Draft');
      case FormStatus.archived:
        return StatusBadge.neutral(label: 'Archived');
    }
  }

  void _previewForm(FormDefinition form) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(form.title),
              _buildStatusBadge(form.status),
            ],
          ),
          content: SizedBox(
            width: dialogContentWidth(ctx, 500),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (form.description != null) ...[
                    Text(
                      form.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                  ...form.fields.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${f.label} ${f.required ? '*' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          if (f.type == FieldType.select)
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: f.placeholder ?? 'Select option',
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: f.options.map((opt) {
                                return DropdownMenuItem(
                                  value: opt,
                                  child: Text(opt),
                                );
                              }).toList(),
                              onChanged: (_) {},
                            )
                          else if (f.type == FieldType.checkbox)
                            CheckboxListTile(
                              title: Text(f.placeholder ?? f.label),
                              value: false,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (_) {},
                            )
                          else
                            TextField(
                              maxLines: f.type == FieldType.textarea ? 3 : 1,
                              keyboardType: f.type == FieldType.email
                                  ? TextInputType.emailAddress
                                  : (f.type == FieldType.number
                                      ? TextInputType.number
                                      : TextInputType.text),
                              decoration: InputDecoration(
                                hintText: f.placeholder,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                // Simulate form submission
                final updated = form.copyWith(
                  submissionsCount: form.submissionsCount + 1,
                );
                final result = await _repo.update(updated);
                if (!mounted) return;
                if (result is Success) {
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  AppFeedback.success(context, 'Form submitted successfully!');
                  _loadData();
                } else {
                  AppFeedback.error(context, (result as Failure).error);
                }
              },
              child: const Text('Submit Form'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditDialog([FormDefinition? form]) {
    final isEditing = form != null;
    final titleCtrl = TextEditingController(text: form?.title ?? '');
    final slugCtrl = TextEditingController(text: form?.slug ?? '');
    final descCtrl = TextEditingController(text: form?.description ?? '');
    FormStatus status = form?.status ?? FormStatus.published;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Form' : 'Create Custom Form'),
              content: SizedBox(
                width: dialogContentWidth(context, 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Form Title *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        if (!isEditing && slugCtrl.text.isEmpty) {
                          slugCtrl.text = val
                              .toLowerCase()
                              .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: slugCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Slug URL (e.g. contact-us) *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FormStatus>(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: 'Form Status',
                        border: OutlineInputBorder(),
                      ),
                      items: FormStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase()),
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
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final slug = slugCtrl.text.trim().isNotEmpty
                        ? slugCtrl.text.trim()
                        : titleCtrl.text.trim().toLowerCase().replaceAll(' ', '-');

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
                        id: 'form_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        slug: slug,
                        description: descCtrl.text.trim(),
                        status: status,
                        submissionsCount: 0,
                        fields: const [
                          AppFormField(
                            id: 'f1',
                            type: FieldType.text,
                            label: 'Full Name',
                            placeholder: 'Your name',
                            required: true,
                          ),
                          AppFormField(
                            id: 'f2',
                            type: FieldType.email,
                            label: 'Email Address',
                            placeholder: 'you@company.com',
                            required: true,
                          ),
                          AppFormField(
                            id: 'f3',
                            type: FieldType.textarea,
                            label: 'Message / Inquiry',
                            placeholder: 'How can we help you?',
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
                          isEditing ? 'Form updated.' : 'Form created.',
                        );
                      }
                      _loadData();
                    } else if (dialogCtx.mounted) {
                      AppFeedback.error(dialogCtx, (result as Failure).error);
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Create Form'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteForm(FormDefinition form) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Form'),
        content: Text('Are you sure you want to delete "${form.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _repo.delete(form.id);
      if (!mounted) return;
      AppFeedback.fromResult(
        context,
        result,
        successMessage: 'Form deleted.',
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadData,
      );
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
            // Page Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Forms Builder', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Design lead capture forms, questionnaires, and survey funnels',
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
                  label: const Text('Create Form'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stat Cards
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
                      label: 'Total Forms',
                      value: totalForms,
                      icon: Icons.dynamic_form_outlined,
                    ),
                    StatCard(
                      label: 'Active & Published',
                      value: publishedForms,
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: 'Total Submissions',
                      value: totalSubmissions,
                      icon: Icons.mark_email_read_outlined,
                      iconColor: Colors.blue,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search & Filter
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: 'Search forms by title or slug...',
              onSearchChanged: (_) => _fetchForms(),
              filterWidgets: [
                DropdownButton<FormStatus?>(
                  value: _selectedStatus,
                  hint: const Text('All Statuses'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...FormStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
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

            // Forms Table
            ResponsiveDataTable<FormDefinition>(
              items: _forms,
              isLoading: _isLoading,
              emptyTitle: 'No forms created yet',
              emptyMessage: 'Create a new form to collect customer submissions',
              emptyActionLabel: 'Create Form',
              onEmptyAction: () => _showAddEditDialog(),
              columns: const [
                TableColumnDef(label: 'FORM TITLE', flex: 3),
                TableColumnDef(label: 'SLUG URL', flex: 2),
                TableColumnDef(label: 'FIELDS', flex: 2),
                TableColumnDef(label: 'SUBMISSIONS', flex: 2),
                TableColumnDef(label: 'STATUS', flex: 2),
                TableColumnDef(
                  label: 'ACTIONS',
                  flex: 3,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, form, index) {
                return [
                  Text(form.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('/forms/${form.slug}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      )),
                  Text('${form.fields.length} fields'),
                  Text('${form.submissionsCount}'),
                  _buildStatusBadge(form.status),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        onPressed: () => _previewForm(form),
                        tooltip: 'Preview / Test Form',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(form),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deleteForm(form),
                        tooltip: 'Delete',
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
                          Text(form.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusBadge(form.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('/forms/${form.slug}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          )),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${form.fields.length} fields • ${form.submissionsCount} submissions'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 18),
                                onPressed: () => _previewForm(form),
                                tooltip: 'Preview / Test Form',
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAddEditDialog(form),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: theme.colorScheme.error,
                                onPressed: () => _deleteForm(form),
                                tooltip: 'Delete',
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
