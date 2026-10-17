import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../data/app_repositories.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/customer.dart';
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

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _searchController = TextEditingController();
  final _repo = AppRepositories.instance.customers;

  bool _isLoading = true;
  String? _errorMessage;
  List<Customer> _customers = [];
  Map<String, dynamic> _stats = {};
  CustomerTier? _selectedTier;

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

    await _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final res = await _repo.list(
      search: _searchController.text,
      tier: _selectedTier,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res is Success) {
        _customers = (res as Success).data.items;
      } else {
        _errorMessage = (res as Failure).error.message;
      }
    });
  }

  String _tierLabel(AppLocalizations l10n, CustomerTier tier) =>
      tier == CustomerTier.vip ? l10n.statusVip : l10n.statusRegular;

  void _showAddEditDialog([Customer? customer]) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = customer != null;
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final emailCtrl = TextEditingController(text: customer?.email ?? '');
    final phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    final addressCtrl = TextEditingController(text: customer?.address ?? '');
    final cityCtrl = TextEditingController(text: customer?.city ?? '');
    final countryCtrl = TextEditingController(text: customer?.country ?? '');
    final notesCtrl = TextEditingController(text: customer?.notes ?? '');
    CustomerTier tier = customer?.tier ?? CustomerTier.regular;

    String? nameError;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? l10n.editCustomerTitle : l10n.actionAddCustomer,
              ),
              content: SizedBox(
                width: dialogContentWidth(context, 500),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.customerNameLabel,
                          errorText: nameError,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: l10n.emailLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: l10n.customerPhoneLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cityCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.customerCityLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: countryCtrl,
                              decoration: InputDecoration(
                                labelText: l10n.customerCountryLabel,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.customerAddressLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<CustomerTier>(
                        initialValue: tier,
                        decoration: InputDecoration(
                          labelText: l10n.customerTierLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: CustomerTier.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(_tierLabel(l10n, t)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => tier = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.customerNotesLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      setDialogState(() => nameError = l10n.fieldRequired);
                      return;
                    }
                    final Result<Object?> result;
                    if (isEditing) {
                      final updated = customer.copyWith(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        country: countryCtrl.text.trim(),
                        tier: tier,
                        notes: notesCtrl.text.trim(),
                      );
                      result = await _repo.update(updated);
                    } else {
                      final newCust = Customer(
                        id: IdGen.uuid(),
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        country: countryCtrl.text.trim(),
                        tier: tier,
                        notes: notesCtrl.text.trim(),
                        totalOrders: 0,
                        totalSpent: 0.0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      result = await _repo.create(newCust);
                    }

                    switch (result) {
                      case Success():
                        // Close only after a confirmed write so a failure
                        // never discards the user's input.
                        if (dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                        if (!mounted) return;
                        AppFeedback.success(
                          this.context,
                          isEditing
                              ? l10n.customerUpdated
                              : l10n.customerCreated,
                        );
                        _loadData();
                      case Failure(:final error):
                        AppFeedback.error(
                          dialogCtx.mounted ? dialogCtx : this.context,
                          error,
                        );
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
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDialogTitle(customer.name)),
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
      final result = await _repo.delete(customer.id);
      if (!mounted) return;
      AppFeedback.fromResult(
        context,
        result,
        successMessage: l10n.customerDeleted,
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadData,
      );
    }

    final totalCust = _stats['totalCustomers']?.toString() ?? '—';
    final vipCust = _stats['vipCustomers']?.toString() ?? '—';
    final totalSpent = _stats['totalSpentAll'] != null
        ? '\$${(_stats['totalSpentAll'] as double).toStringAsFixed(2)}'
        : '—';

    return SingleChildScrollView(
      key: const Key('customers-page'),
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
                      Text(l10n.navCustomers,
                          style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        l10n.customersSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.person_add_outlined, size: 20),
                  label: Text(l10n.actionAddCustomer),
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
                      label: l10n.statCustomers,
                      value: totalCust,
                      icon: Icons.people_outline,
                    ),
                    StatCard(
                      label: l10n.statVipClients,
                      value: vipCust,
                      icon: Icons.star_outline,
                      iconColor: Colors.amber,
                    ),
                    StatCard(
                      label: l10n.statLifetimeValue,
                      value: totalSpent,
                      icon: Icons.monetization_on_outlined,
                      iconColor: Colors.green,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search & Filter
            SearchAndFilterBar(
              searchController: _searchController,
              searchHint: l10n.searchCustomersHint,
              onSearchChanged: (_) => _fetchCustomers(),
              filterWidgets: [
                DropdownButton<CustomerTier?>(
                  value: _selectedTier,
                  hint: Text(l10n.allTiers),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.allTiers),
                    ),
                    ...CustomerTier.values.map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_tierLabel(l10n, t)),
                      ),
                    ),
                  ],
                  onChanged: (tier) {
                    setState(() => _selectedTier = tier);
                    _fetchCustomers();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Customer Table
            ResponsiveDataTable<Customer>(
              items: _customers,
              isLoading: _isLoading,
              emptyTitle: l10n.customersEmptyTitle,
              emptyMessage: l10n.customersEmptyMessage,
              emptyActionLabel: l10n.actionAddCustomer,
              onEmptyAction: () => _showAddEditDialog(),
              columns: [
                TableColumnDef(label: l10n.colCustomer, flex: 3),
                TableColumnDef(label: l10n.colContact, flex: 3),
                TableColumnDef(label: l10n.colLocation, flex: 2),
                TableColumnDef(label: l10n.colTier, flex: 2),
                TableColumnDef(label: l10n.colSpent, flex: 2),
                TableColumnDef(
                  label: l10n.colActions,
                  flex: 2,
                  alignment: Alignment.centerRight,
                ),
              ],
              rowBuilder: (context, customer, index) {
                return [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          customer.initials,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (customer.email != null)
                        Text(customer.email!, style: theme.textTheme.bodySmall),
                      if (customer.phone != null)
                        Text(
                          customer.phone!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    [customer.city, customer.country]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(', '),
                  ),
                  customer.tier == CustomerTier.vip
                      ? StatusBadge.warning(
                          label: l10n.statusVip, icon: Icons.star)
                      : StatusBadge.neutral(label: l10n.statusRegular),
                  Text(
                    '\$${customer.totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showAddEditDialog(customer),
                        tooltip: l10n.actionEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _deleteCustomer(customer),
                        tooltip: l10n.actionDelete,
                      ),
                    ],
                  ),
                ];
              },
              mobileCardBuilder: (context, customer, index) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(customer.initials),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (customer.email != null)
                                  Text(customer.email!,
                                      style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          customer.tier == CustomerTier.vip
                              ? StatusBadge.warning(
                                  label: l10n.statusVip, icon: Icons.star)
                              : StatusBadge.neutral(label: l10n.statusRegular),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${l10n.spentLabel}: \$${customer.totalSpent.toStringAsFixed(2)}',
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAddEditDialog(customer),
                                tooltip: l10n.actionEdit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: theme.colorScheme.error,
                                onPressed: () => _deleteCustomer(customer),
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
