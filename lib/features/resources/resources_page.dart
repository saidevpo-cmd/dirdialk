import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/resource.dart';
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

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.resources;

  bool _isLoading = true;
  bool _loadFailed = false;
  List<Resource> _all = [];
  List<Resource> _resources = [];
  ResourceType? _selectedType;
  String? _selectedCategory;
  bool? _selectedPublished;

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

    final res = await _repo.list(limit: 200);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res case Success(:final data)) {
        _all = data.items;
        _applyFilters();
      } else {
        _loadFailed = true;
      }
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    _resources = _all.where((r) {
      if (_selectedType != null && r.type != _selectedType) return false;
      if (_selectedCategory != null && r.category != _selectedCategory) {
        return false;
      }
      if (_selectedPublished != null && r.isPublished != _selectedPublished) {
        return false;
      }
      if (query.isNotEmpty) {
        final haystack = [
          r.name,
          r.description ?? '',
          r.category ?? '',
          r.contact ?? '',
          r.location ?? '',
          r.url ?? '',
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  List<String> get _categories {
    final set = <String>{};
    for (final r in _all) {
      final c = r.category?.trim();
      if (c != null && c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return Icons.description_outlined;
      case ResourceType.spreadsheet:
        return Icons.table_chart_outlined;
      case ResourceType.image:
        return Icons.image_outlined;
      case ResourceType.folder:
        return Icons.folder_outlined;
      case ResourceType.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  void _showLink(Resource resource) {
    final l10n = AppLocalizations.of(context)!;
    if (!resource.hasLink) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(resource.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.category != null)
              Text('${l10n.colCategory}: ${resource.category}'),
            if (resource.contact != null) ...[
              const SizedBox(height: 4),
              Text('${l10n.entryContactLabel}: ${resource.contact}'),
            ],
            if (resource.location != null) ...[
              const SizedBox(height: 4),
              Text('${l10n.entryLocationLabel}: ${resource.location}'),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.websiteLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            SelectableText(resource.url!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEditDialog([Resource? resource]) async {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = resource != null;
    final nameCtrl = TextEditingController(text: resource?.name ?? '');
    final categoryCtrl = TextEditingController(text: resource?.category ?? '');
    final descCtrl = TextEditingController(text: resource?.description ?? '');
    final urlCtrl = TextEditingController(text: resource?.url ?? '');
    final contactCtrl = TextEditingController(text: resource?.contact ?? '');
    final locationCtrl = TextEditingController(text: resource?.location ?? '');
    ResourceType type = resource?.type ?? ResourceType.document;
    bool isPublished = resource?.isPublished ?? false;
    String? errorText;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? l10n.editEntryTitle : l10n.addEntryAction,
              ),
              content: SizedBox(
                width: dialogContentWidth(context, 520),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (errorText != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(dialogCtx)
                                .colorScheme
                                .errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            errorText!,
                            style: TextStyle(
                              color: Theme.of(dialogCtx)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: '${l10n.entryNameLabel} *',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: categoryCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.colCategory,
                                hintText: l10n.entryNameHint,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<ResourceType>(
                              initialValue: type,
                              decoration: InputDecoration(
                                labelText: l10n.entryTypeLabel,
                                border: const OutlineInputBorder(),
                              ),
                              items: ResourceType.values.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setDialogState(() => type = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.descriptionLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: urlCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.entryWebsiteLabel,
                          hintText: 'https://...',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: contactCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.entryContactLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: locationCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.entryLocationLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.publishedInDirectory),
                        value: isPublished,
                        onChanged: (v) => setDialogState(() => isPublished = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      setDialogState(() => errorText = l10n.entryNameRequired);
                      return;
                    }

                    final url = urlCtrl.text.trim();
                    final category = categoryCtrl.text.trim();
                    final description = descCtrl.text.trim();
                    final contact = contactCtrl.text.trim();
                    final location = locationCtrl.text.trim();

                    final Result<Resource> result;
                    if (isEditing) {
                      result = await _repo.update(
                        resource.copyWith(
                          name: name,
                          category: category,
                          description: description,
                          url: url,
                          contact: contact,
                          location: location,
                          type: type,
                          isPublished: isPublished,
                        ),
                      );
                    } else {
                      result = await _repo.create(
                        Resource(
                          id: IdGen.uuid(),
                          name: name,
                          category: category.isEmpty ? null : category,
                          description: description.isEmpty ? null : description,
                          url: url.isEmpty ? null : url,
                          contact: contact.isEmpty ? null : contact,
                          location: location.isEmpty ? null : location,
                          type: type,
                          isPublished: isPublished,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                    }

                    if (result case Failure<Resource>(:final error)
                        when dialogCtx.mounted) {
                      setDialogState(() => errorText = error.message);
                      return;
                    }

                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop(true);
                    }
                  },
                  child: Text(
                    isEditing ? l10n.actionSave : l10n.addEntryAction,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      AppFeedback.success(context, l10n.saved);
      _loadData();
    }
  }

  Future<void> _deleteResource(Resource resource) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDialogTitle(resource.name)),
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
      final result = await _repo.delete(resource.id);
      if (!mounted) return;
      AppFeedback.fromResult(
        context,
        result,
        successMessage: l10n.recordDeleted,
      );
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

    final totalEntries = _all.length.toString();
    final publishedCount = _all.where((r) => r.isPublished).length.toString();
    final categoriesCount = _categories.length.toString();
    final withContact = _all
        .where((r) => (r.contact?.trim().isNotEmpty ?? false))
        .length
        .toString();

    return SingleChildScrollView(
      key: const Key('resources-page'),
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
                        l10n.directoryTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.directorySubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add_business_outlined, size: 20),
                  label: Text(l10n.addEntryAction),
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
                    crossAxisCount: isCompact ? 2 : 4,
                    mainAxisExtent: 130,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  children: [
                    StatCard(
                      label: l10n.totalEntries,
                      value: totalEntries,
                      icon: Icons.storefront_outlined,
                    ),
                    StatCard(
                      label: l10n.statusPublished,
                      value: publishedCount,
                      icon: Icons.public,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: l10n.categoriesLabel,
                      value: categoriesCount,
                      icon: Icons.category_outlined,
                      iconColor: Colors.blue,
                    ),
                    StatCard(
                      label: l10n.withContactLabel,
                      value: withContact,
                      icon: Icons.contact_phone_outlined,
                      iconColor: Colors.purple,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.searchDirectoryHint,
              onSearchChanged: (_) => setState(_applyFilters),
              filterWidgets: [
                DropdownButton<String?>(
                  value: _selectedCategory,
                  hint: Text(l10n.categoriesLabel),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.categoriesLabel),
                    ),
                    ..._categories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (c) {
                    setState(() {
                      _selectedCategory = c;
                      _applyFilters();
                    });
                  },
                ),
                DropdownButton<bool?>(
                  value: _selectedPublished,
                  hint: Text(l10n.allStatuses),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.allStatuses),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text(l10n.statusPublished),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text(l10n.statusHidden),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedPublished = v;
                      _applyFilters();
                    });
                  },
                ),
                DropdownButton<ResourceType?>(
                  value: _selectedType,
                  hint: Text(l10n.allTypes),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.allTypes)),
                    ...ResourceType.values.map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (t) {
                    setState(() {
                      _selectedType = t;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ResponsiveDataTable<Resource>(
              items: _resources,
              isLoading: _isLoading,
              emptyTitle: l10n.noDirectoryTitle,
              emptyMessage: l10n.noDirectoryMessage,
              emptyActionLabel: l10n.addEntryAction,
              onEmptyAction: () => _showAddEditDialog(),
              columns: [
                TableColumnDef(label: l10n.colName, flex: 4),
                TableColumnDef(label: l10n.colCategory, flex: 2),
                TableColumnDef(label: l10n.colContact, flex: 3),
                TableColumnDef(label: l10n.colStatus, flex: 2),
                TableColumnDef(
                  label: l10n.colActions,
                  flex: 3,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, res, index) {
                return [
                  Row(
                    children: [
                      Icon(
                        _getResourceIcon(res.type),
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              res.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (res.location != null &&
                                res.location!.isNotEmpty)
                              Text(
                                res.location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  res.category != null && res.category!.isNotEmpty
                      ? StatusBadge.info(label: res.category!)
                      : const Text('—'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        res.contact ?? '—',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (res.url != null && res.url!.isNotEmpty)
                        Text(
                          res.url!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  res.isPublished
                      ? StatusBadge.success(label: l10n.statusPublished)
                      : StatusBadge.warning(label: l10n.statusHidden),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (res.hasLink)
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () => _showLink(res),
                          tooltip: l10n.viewLinkTooltip,
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(res),
                        tooltip: l10n.actionEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deleteResource(res),
                        tooltip: l10n.actionDelete,
                      ),
                    ],
                  ),
                ];
              },
              mobileCardBuilder: (context, res, index) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getResourceIcon(res.type),
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              res.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          res.isPublished
                              ? StatusBadge.success(label: l10n.statusPublished)
                              : StatusBadge.warning(label: l10n.statusHidden),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (res.category != null)
                        Text(res.category!, style: theme.textTheme.bodySmall),
                      if (res.contact != null)
                        Text(
                          '${l10n.colContact}: ${res.contact}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (res.location != null)
                        Text(
                          '${l10n.colLocation}: ${res.location}',
                          style: theme.textTheme.bodySmall,
                        ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (res.hasLink)
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 18),
                              onPressed: () => _showLink(res),
                              tooltip: l10n.viewLinkTooltip,
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showAddEditDialog(res),
                            tooltip: l10n.actionEdit,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: theme.colorScheme.error,
                            onPressed: () => _deleteResource(res),
                            tooltip: l10n.actionDelete,
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
