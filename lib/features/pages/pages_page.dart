import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/page_content.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/utils/dialog_sizing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/responsive_data_table.dart';
import '../../shared/widgets/search_and_filter_bar.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_badge.dart';

class PagesPage extends StatefulWidget {
  const PagesPage({super.key});

  @override
  State<PagesPage> createState() => _PagesPageState();
}

class _PagesPageState extends State<PagesPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.pages;

  bool _isLoading = true;
  String? _errorMessage;
  List<PageContent> _pages = [];
  Map<String, dynamic> _stats = {};
  PageStatus? _selectedStatus;

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

    await _fetchPages();
  }

  Future<void> _fetchPages() async {
    final res = await _repo.list(
      search: _searchController.text,
      status: _selectedStatus,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res is Success) {
        _pages = (res as Success).data.items;
      } else {
        _errorMessage = 'Failed to load pages';
      }
    });
  }

  Widget _buildStatusBadge(PageStatus status) {
    switch (status) {
      case PageStatus.published:
        return StatusBadge.success(label: 'Published');
      case PageStatus.draft:
        return StatusBadge.warning(label: 'Draft');
    }
  }

  void _previewPage(PageContent page) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(page.title),
              _buildStatusBadge(page.status),
            ],
          ),
          content: SizedBox(
            width: dialogContentWidth(ctx, 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (page.imageUrl != null && page.imageUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        page.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 180,
                          alignment: Alignment.center,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    'Slug: /pages/${page.slug}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (page.excerpt != null && page.excerpt!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      page.excerpt!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (page.metaDesc != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Meta: ${page.metaDesc!}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Text(
                    page.content ?? 'No content added yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditDialog([PageContent? page]) {
    final isEditing = page != null;
    final titleCtrl = TextEditingController(text: page?.title ?? '');
    final slugCtrl = TextEditingController(text: page?.slug ?? '');
    final excerptCtrl = TextEditingController(text: page?.excerpt ?? '');
    final imageCtrl = TextEditingController(text: page?.imageUrl ?? '');
    final contentCtrl = TextEditingController(text: page?.content ?? '');
    final metaTitleCtrl = TextEditingController(text: page?.metaTitle ?? '');
    final metaDescCtrl = TextEditingController(text: page?.metaDesc ?? '');
    PageStatus status = page?.status ?? PageStatus.published;
    String? errorText;

    String slugify(String value) => value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Page' : 'Create CMS Page'),
              content: SizedBox(
                width: dialogContentWidth(context, 550),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (errorText != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(dialogCtx).colorScheme.errorContainer,
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
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Page Title *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          if (!isEditing && slugCtrl.text.isEmpty) {
                            slugCtrl.text = slugify(val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: slugCtrl,
                              decoration: const InputDecoration(
                                labelText: 'URL Slug *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<PageStatus>(
                              initialValue: status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: PageStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setDialogState(() => status = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: excerptCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Short Excerpt',
                          hintText: 'A one or two sentence summary shown in lists...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cover Image URL',
                          hintText: 'https://...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentCtrl,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Page Body Content *',
                          hintText: 'Write text, markdown, or article content...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: metaTitleCtrl,
                              decoration: const InputDecoration(
                                labelText: 'SEO Meta Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: metaDescCtrl,
                              decoration: const InputDecoration(
                                labelText: 'SEO Meta Description',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
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
                    final title = titleCtrl.text.trim();
                    final content = contentCtrl.text.trim();
                    final slug = slugify(
                      slugCtrl.text.trim().isNotEmpty
                          ? slugCtrl.text.trim()
                          : title,
                    );

                    String? validation;
                    if (title.isEmpty) {
                      validation = 'Page title is required.';
                    } else if (content.isEmpty) {
                      validation = 'Page body content is required.';
                    } else if (slug.isEmpty) {
                      validation = 'A valid URL slug is required.';
                    } else {
                      final duplicate = _pages.any(
                        (p) => p.slug == slug && p.id != page?.id,
                      );
                      if (duplicate) {
                        validation = 'The slug "/pages/$slug" is already in use.';
                      }
                    }

                    if (validation != null) {
                      setDialogState(() => errorText = validation);
                      return;
                    }

                    final excerpt = excerptCtrl.text.trim();
                    final imageUrl = imageCtrl.text.trim();
                    final metaTitle = metaTitleCtrl.text.trim();
                    final metaDesc = metaDescCtrl.text.trim();

                    final Result<PageContent> result;
                    if (isEditing) {
                      result = await _repo.update(
                        page.copyWith(
                          title: title,
                          slug: slug,
                          excerpt: excerpt,
                          imageUrl: imageUrl,
                          content: content,
                          status: status,
                          metaTitle: metaTitle,
                          metaDesc: metaDesc,
                        ),
                      );
                    } else {
                      result = await _repo.create(
                        PageContent(
                          id: 'page_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          slug: slug,
                          excerpt: excerpt,
                          imageUrl: imageUrl,
                          content: content,
                          status: status,
                          metaTitle: metaTitle,
                          metaDesc: metaDesc,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                    }

                    if (result case Failure<PageContent>(:final error)
                        when dialogCtx.mounted) {
                      setDialogState(() => errorText = error.message);
                      return;
                    }

                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                    }
                    _loadData();
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Create Page'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletePage(PageContent page) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Page'),
        content: Text('Are you sure you want to delete "${page.title}"?'),
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
      final result = await _repo.delete(page.id);
      if (!mounted) return;
      AppFeedback.fromResult(
        context,
        result,
        successMessage: 'Page deleted.',
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

    final totalPages = _stats['totalPages']?.toString() ?? '—';
    final publishedPages = _stats['publishedPages']?.toString() ?? '—';
    final draftPages = _stats['draftPages']?.toString() ?? '—';

    return SingleChildScrollView(
      key: const Key('pages-page'),
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
                      Text('CMS Pages', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Manage public policy pages, company terms, and blog content',
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
                  label: const Text('Create Page'),
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
                      label: 'Total Pages',
                      value: totalPages,
                      icon: Icons.article_outlined,
                    ),
                    StatCard(
                      label: 'Published',
                      value: publishedPages,
                      icon: Icons.public,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: 'Drafts',
                      value: draftPages,
                      icon: Icons.edit_note,
                      iconColor: Colors.amber,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search & Filter
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: 'Search pages by title or content...',
              onSearchChanged: (_) => _fetchPages(),
              filterWidgets: [
                DropdownButton<PageStatus?>(
                  value: _selectedStatus,
                  hint: const Text('All Statuses'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...PageStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (s) {
                    setState(() => _selectedStatus = s);
                    _fetchPages();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Pages Table
            ResponsiveDataTable<PageContent>(
              items: _pages,
              isLoading: _isLoading,
              emptyTitle: 'No CMS pages found',
              emptyMessage: 'Create a new page to publish content to your storefront',
              emptyActionLabel: 'Create Page',
              onEmptyAction: () => _showAddEditDialog(),
              columns: const [
                TableColumnDef(label: 'PAGE TITLE', flex: 3),
                TableColumnDef(label: 'SLUG URL', flex: 2),
                TableColumnDef(label: 'SEO TITLE', flex: 2),
                TableColumnDef(label: 'STATUS', flex: 2),
                TableColumnDef(
                  label: 'ACTIONS',
                  flex: 3,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, page, index) {
                return [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(page.title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (page.excerpt != null && page.excerpt!.isNotEmpty)
                        Text(
                          page.excerpt!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  Text('/pages/${page.slug}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      )),
                  Text(page.metaTitle ?? '—',
                      style: theme.textTheme.bodySmall),
                  _buildStatusBadge(page.status),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        onPressed: () => _previewPage(page),
                        tooltip: 'Read / Preview Page',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(page),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deletePage(page),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ];
              },
              mobileCardBuilder: (context, page, index) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(page.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusBadge(page.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('/pages/${page.slug}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          )),
                      if (page.excerpt != null && page.excerpt!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          page.excerpt!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(page.status),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 18),
                                onPressed: () => _previewPage(page),
                                tooltip: 'Read / Preview Page',
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAddEditDialog(page),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: theme.colorScheme.error,
                                onPressed: () => _deletePage(page),
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
