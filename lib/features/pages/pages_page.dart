import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/page_content.dart';
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

class PagesPage extends StatefulWidget {
  const PagesPage({super.key});

  @override
  State<PagesPage> createState() => _PagesPageState();
}

class _PagesPageState extends State<PagesPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.pages;

  bool _isLoading = true;
  bool _loadFailed = false;
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
      _loadFailed = false;
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
        _loadFailed = true;
      }
    });
  }

  String _statusLabel(AppLocalizations l10n, PageStatus status) {
    switch (status) {
      case PageStatus.published:
        return l10n.statusPublished;
      case PageStatus.draft:
        return l10n.statusDraft;
    }
  }

  Widget _buildStatusBadge(AppLocalizations l10n, PageStatus status) {
    final label = _statusLabel(l10n, status);
    switch (status) {
      case PageStatus.published:
        return StatusBadge.success(label: label);
      case PageStatus.draft:
        return StatusBadge.warning(label: label);
    }
  }

  void _previewPage(PageContent page) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(page.title)),
              const SizedBox(width: 12),
              _buildStatusBadge(l10n, page.status),
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
                    '${l10n.colSlug}: /pages/${page.slug}',
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
                      '${l10n.metaLabel}: ${page.metaDesc!}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Text(
                    page.content ?? l10n.noContentYet,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.actionClose),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddEditDialog([PageContent? page]) async {
    final l10n = AppLocalizations.of(context)!;
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

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? l10n.editPageTitle : l10n.createPageAction,
              ),
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
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: '${l10n.pageTitleLabel} *',
                          border: const OutlineInputBorder(),
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
                              decoration: InputDecoration(
                                labelText: '${l10n.urlSlugLabel} *',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<PageStatus>(
                              initialValue: status,
                              decoration: InputDecoration(
                                labelText: l10n.colStatus,
                                border: const OutlineInputBorder(),
                              ),
                              items: PageStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(_statusLabel(l10n, s)),
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
                        decoration: InputDecoration(
                          labelText: l10n.shortExcerptLabel,
                          hintText: l10n.excerptHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.coverImageUrlLabel,
                          hintText: 'https://...',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentCtrl,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: '${l10n.pageBodyLabel} *',
                          hintText: l10n.pageBodyHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: metaTitleCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.seoMetaTitleLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: metaDescCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.seoMetaDescriptionLabel,
                                border: const OutlineInputBorder(),
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
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text(l10n.actionCancel),
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
                      validation = l10n.pageTitleRequired;
                    } else if (content.isEmpty) {
                      validation = l10n.pageContentRequired;
                    } else if (slug.isEmpty) {
                      validation = l10n.pageSlugRequired;
                    } else {
                      final duplicate = _pages.any(
                        (p) => p.slug == slug && p.id != page?.id,
                      );
                      if (duplicate) {
                        validation = l10n.pageSlugInUse(slug);
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
                          id: IdGen.uuid(),
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
                      Navigator.of(dialogCtx).pop(true);
                    }
                  },
                  child: Text(
                    isEditing ? l10n.actionSaveChanges : l10n.actionCreate,
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

  Future<void> _deletePage(PageContent page) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDialogTitle(page.title)),
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
      final result = await _repo.delete(page.id);
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pagesPageTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.pagesPageSubtitle,
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
                  label: Text(l10n.createPageAction),
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
                      label: l10n.totalPages,
                      value: totalPages,
                      icon: Icons.article_outlined,
                    ),
                    StatCard(
                      label: l10n.statusPublished,
                      value: publishedPages,
                      icon: Icons.public,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      label: l10n.draftsLabel,
                      value: draftPages,
                      icon: Icons.edit_note,
                      iconColor: Colors.amber,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.searchPagesHint,
              onSearchChanged: (_) => _fetchPages(),
              filterWidgets: [
                DropdownButton<PageStatus?>(
                  value: _selectedStatus,
                  hint: Text(l10n.allStatuses),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.allStatuses),
                    ),
                    ...PageStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabel(l10n, s)),
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
            ResponsiveDataTable<PageContent>(
              items: _pages,
              isLoading: _isLoading,
              emptyTitle: l10n.noPagesTitle,
              emptyMessage: l10n.noPagesMessage,
              emptyActionLabel: l10n.createPageAction,
              onEmptyAction: () => _showAddEditDialog(),
              columns: [
                TableColumnDef(label: l10n.colTitle, flex: 3),
                TableColumnDef(label: l10n.colSlug, flex: 2),
                TableColumnDef(label: l10n.colSeoTitle, flex: 2),
                TableColumnDef(label: l10n.colStatus, flex: 2),
                TableColumnDef(
                  label: l10n.colActions,
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
                      Text(
                        page.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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
                  Text(
                    '/pages/${page.slug}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(page.metaTitle ?? '—', style: theme.textTheme.bodySmall),
                  _buildStatusBadge(l10n, page.status),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        onPressed: () => _previewPage(page),
                        tooltip: l10n.readPreviewTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(page),
                        tooltip: l10n.actionEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deletePage(page),
                        tooltip: l10n.actionDelete,
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
                          Flexible(
                            child: Text(
                              page.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusBadge(l10n, page.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/pages/${page.slug}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
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
                          _buildStatusBadge(l10n, page.status),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                ),
                                onPressed: () => _previewPage(page),
                                tooltip: l10n.readPreviewTooltip,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAddEditDialog(page),
                                tooltip: l10n.actionEdit,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                color: theme.colorScheme.error,
                                onPressed: () => _deletePage(page),
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
