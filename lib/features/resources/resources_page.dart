import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/resource.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
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
  String? _errorMessage;
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
      _errorMessage = null;
    });

    final res = await _repo.list(limit: 200);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res case Success(:final data)) {
        _all = data.items;
        _applyFilters();
      } else {
        _errorMessage = 'Failed to load directory';
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
      if (_selectedPublished != null &&
          r.isPublished != _selectedPublished) {
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
        return Icons.storefront_outlined;
      case ResourceType.spreadsheet:
        return Icons.point_of_sale_outlined;
      case ResourceType.image:
        return Icons.handshake_outlined;
      case ResourceType.folder:
        return Icons.category_outlined;
      case ResourceType.other:
        return Icons.location_on_outlined;
    }
  }

  void _showLink(Resource resource) {
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
              Text('Category: ${resource.category}'),
            if (resource.contact != null) ...[
              const SizedBox(height: 4),
              Text('Contact: ${resource.contact}'),
            ],
            if (resource.location != null) ...[
              const SizedBox(height: 4),
              Text('Location: ${resource.location}'),
            ],
            const SizedBox(height: 12),
            const Text('Website', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            SelectableText(resource.url!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog([Resource? resource]) {
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

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Directory Entry' : 'Add Directory Entry',
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
                        decoration: const InputDecoration(
                          labelText: 'Business / Entry Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: categoryCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                hintText: 'e.g. Restaurant, Supplier',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<ResourceType>(
                              initialValue: type,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: urlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Website URL',
                          hintText: 'https://...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: contactCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Contact (phone / email)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: locationCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Location / Address',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Published in directory'),
                        value: isPublished,
                        onChanged: (v) =>
                            setDialogState(() => isPublished = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      setDialogState(
                        () => errorText = 'Entry name is required.',
                      );
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
                          id: 'res_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          category: category.isEmpty ? null : category,
                          description:
                              description.isEmpty ? null : description,
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
                      Navigator.of(dialogCtx).pop();
                    }
                    _loadData();
                  },
                  child: Text(isEditing ? 'Save' : 'Add Entry'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteResource(Resource resource) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Remove "${resource.name}" from the directory?'),
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
      final result = await _repo.delete(resource.id);
      if (!mounted) return;
      AppFeedback.fromResult(
        context,
        result,
        successMessage: 'Entry removed from the directory.',
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
                      Text('Business Directory',
                          style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Curate local partners, suppliers, and locations with contact details',
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
                  label: const Text('Add Entry'),
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
                      label: 'Total Entries',
                      value: totalEntries,
                      icon: Icons.storefront_outlined,
                    ),
                    StatCard(
                      label: 'Published',
                      value: publishedCount,
                      icon: Icons.public,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: 'Categories',
                      value: categoriesCount,
                      icon: Icons.category_outlined,
                      iconColor: Colors.blue,
                    ),
                    StatCard(
                      label: 'With Contact',
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
              searchHint: 'Search directory by name, category, or contact...',
              onSearchChanged: (_) => setState(_applyFilters),
              filterWidgets: [
                DropdownButton<String?>(
                  value: _selectedCategory,
                  hint: const Text('All Categories'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
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
                  hint: const Text('All Statuses'),
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: true, child: Text('Published')),
                    DropdownMenuItem(value: false, child: Text('Hidden')),
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
                  hint: const Text('All Types'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
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
              emptyTitle: 'No directory entries found',
              emptyMessage:
                  'Add a partner, supplier, or location to build your directory',
              emptyActionLabel: 'Add Entry',
              onEmptyAction: () => _showAddEditDialog(),
              columns: const [
                TableColumnDef(label: 'NAME', flex: 4),
                TableColumnDef(label: 'CATEGORY', flex: 2),
                TableColumnDef(label: 'CONTACT', flex: 3),
                TableColumnDef(label: 'STATUS', flex: 2),
                TableColumnDef(
                  label: 'ACTIONS',
                  flex: 3,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, res, index) {
                return [
                  Row(
                    children: [
                      Icon(_getResourceIcon(res.type),
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(res.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
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
                      Text(res.contact ?? '—',
                          style: theme.textTheme.bodySmall),
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
                      ? StatusBadge.success(label: 'Published')
                      : StatusBadge.warning(label: 'Hidden'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (res.hasLink)
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () => _showLink(res),
                          tooltip: 'View Link',
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(res),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deleteResource(res),
                        tooltip: 'Delete',
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
                          Icon(_getResourceIcon(res.type),
                              size: 24, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(res.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          res.isPublished
                              ? StatusBadge.success(label: 'Published')
                              : StatusBadge.warning(label: 'Hidden'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (res.category != null)
                        Text(res.category!,
                            style: theme.textTheme.bodySmall),
                      if (res.contact != null)
                        Text('Contact: ${res.contact}',
                            style: theme.textTheme.bodySmall),
                      if (res.location != null)
                        Text('Location: ${res.location}',
                            style: theme.textTheme.bodySmall),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (res.hasLink)
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 18),
                              onPressed: () => _showLink(res),
                              tooltip: 'View Link',
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showAddEditDialog(res),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: theme.colorScheme.error,
                            onPressed: () => _deleteResource(res),
                            tooltip: 'Delete',
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
