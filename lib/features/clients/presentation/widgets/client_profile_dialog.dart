import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../data/model/client_analytics_model.dart';
import '../../data/model/client_model.dart';
import '../../data/repo/clients_repository.dart';

Future<void> showClientProfileDialog(BuildContext context, {required ClientModel client}) {
  return showDialog(
    context: context,
    // See create_content_item_dialog.dart for why this must be false:
    // the default root navigator sits outside the Workspace shell's
    // BlocProvider scope, breaking context.read<WorkspaceCubit>() here.
    useRootNavigator: false,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        child: _ClientProfileContent(client: client),
      ),
    ),
  );
}

class _ClientProfileContent extends StatefulWidget {
  const _ClientProfileContent({required this.client});
  final ClientModel client;

  @override
  State<_ClientProfileContent> createState() => _ClientProfileContentState();
}

class _ClientProfileContentState extends State<_ClientProfileContent> {
  late ClientModel _client = widget.client;
  late final _nameController = TextEditingController(text: _client.name);
  late final _notesController = TextEditingController(text: _client.notes ?? '');
  late final _personaController = TextEditingController(text: _client.persona ?? '');
  late final _feedbackController = TextEditingController(text: _client.feedback ?? '');

  List<ClientAnalyticsModel> _analytics = [];
  bool _loadingAnalytics = true;

  Color get _color => AppColors.clientColorFor(_client.id);

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _personaController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      final rows = await context.read<ClientsRepository>().getAnalytics(_client.id);
      if (mounted) setState(() { _analytics = rows; _loadingAnalytics = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingAnalytics = false);
    }
  }

  Future<void> _saveProfile() async {
    try {
      await context.read<ClientsRepository>().updateClient(_client.id, {
        'name': _nameController.text.trim(),
        'notes': _notesController.text,
        'persona': _personaController.text,
        'feedback': _feedbackController.text,
      });
      if (mounted) {
        setState(() => _client = _client.copyWith(
              name: _nameController.text.trim(),
              notes: _notesController.text,
              persona: _personaController.text,
              feedback: _feedbackController.text,
            ));
        await context.read<WorkspaceCubit>().load();
        if (mounted) AppToast.success(context, 'Client profile saved');
      }
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not save: $e');
    }
  }

  Future<void> _deleteClient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete client?'),
        content: Text(
            'This will remove ${_client.name} and cascade-delete their tasks and content items. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ClientsRepository>().deleteClient(_client.id);
      if (mounted) await context.read<WorkspaceCubit>().load();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not delete client: $e');
    }
  }

  Future<void> _addAnalyticsRow() async {
    final entry = await showDialog<ClientAnalyticsModel>(
      context: context,
      builder: (_) => _AnalyticsEntryDialog(clientId: _client.id, color: _color),
    );
    if (entry == null || !mounted) return;
    try {
      await context.read<ClientsRepository>().upsertAnalytics(entry);
      await _loadAnalytics();
      if (mounted) AppToast.success(context, 'Analytics saved');
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not save analytics: $e');
    }
  }

  Future<void> _deleteAnalyticsRow(ClientAnalyticsModel row) async {
    try {
      await context.read<ClientsRepository>().deleteAnalytics(row.id);
      await _loadAnalytics();
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not delete row: $e');
    }
  }

  ClientAnalyticsModel? get _latestWeek {
    if (_analytics.isEmpty) return null;
    final sorted = [..._analytics]..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_color, _color.withValues(alpha: 0.6)],
    );

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 22, 16, 22),
            decoration: BoxDecoration(gradient: gradient),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    _client.initials,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Client name',
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete client',
                  icon: const Icon(LucideIcons.trash2, color: Colors.white),
                  onPressed: _deleteClient,
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_latestWeek != null) ...[
                      _SectionHeader(
                          icon: LucideIcons.sparkles, title: 'Latest snapshot', color: _color),
                      const SizedBox(height: 12),
                      _StatGrid(week: _latestWeek!, color: _color),
                      const SizedBox(height: 28),
                    ],
                    _SectionHeader(
                        icon: LucideIcons.notebookPen, title: 'Notes', color: AppColors.info),
                    const SizedBox(height: 8),
                    _FancyField(
                      controller: _notesController,
                      hint: 'Internal notes about this client...',
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 20),
                    _SectionHeader(
                        icon: LucideIcons.userCircle2,
                        title: 'Shakhbata (persona)',
                        color: AppColors.accent),
                    const SizedBox(height: 8),
                    _FancyField(
                      controller: _personaController,
                      hint: 'Brand voice, personality, tone...',
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 20),
                    _SectionHeader(
                        icon: LucideIcons.messageSquareHeart,
                        title: 'Client feedback',
                        color: AppColors.warning),
                    const SizedBox(height: 8),
                    _FancyField(
                      controller: _feedbackController,
                      hint: 'Feedback received from the client...',
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _saveProfile,
                        style: FilledButton.styleFrom(backgroundColor: _color),
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Save profile'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        _SectionHeader(
                            icon: LucideIcons.barChart3,
                            title: 'Weekly analytics',
                            color: AppColors.success),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addAnalyticsRow,
                          icon: const Icon(LucideIcons.plus, size: 15),
                          label: const Text('Add week'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_loadingAnalytics)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_analytics.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text('No analytics recorded yet.',
                            style: AppTextStyles.caption),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                WidgetStatePropertyAll(_color.withValues(alpha: 0.08)),
                            headingTextStyle:
                                AppTextStyles.label.copyWith(color: _color),
                            dataTextStyle: AppTextStyles.body,
                            columns: const [
                              DataColumn(label: Text('Week of')),
                              DataColumn(label: Text('Total sales')),
                              DataColumn(label: Text('Net sales')),
                              DataColumn(label: Text('Retention')),
                              DataColumn(label: Text('ROAS')),
                              DataColumn(label: Text('CPC')),
                              DataColumn(label: Text('CTR')),
                              DataColumn(label: Text('Ad spend')),
                              DataColumn(label: Text('')),
                            ],
                            rows: _analytics
                                .map((a) => DataRow(cells: [
                                      DataCell(Text(
                                          '${a.weekStart.year}-${a.weekStart.month.toString().padLeft(2, '0')}-${a.weekStart.day.toString().padLeft(2, '0')}')),
                                      DataCell(Text(a.totalSales?.toStringAsFixed(2) ?? '—')),
                                      DataCell(Text(a.netSales?.toStringAsFixed(2) ?? '—')),
                                      DataCell(Text(a.retentionRate != null
                                          ? '${a.retentionRate!.toStringAsFixed(1)}%'
                                          : '—')),
                                      DataCell(Text(a.roas?.toStringAsFixed(2) ?? '—')),
                                      DataCell(Text(a.cpc?.toStringAsFixed(2) ?? '—')),
                                      DataCell(Text(
                                          a.ctr != null ? '${a.ctr!.toStringAsFixed(1)}%' : '—')),
                                      DataCell(Text(a.adSpend?.toStringAsFixed(2) ?? '—')),
                                      DataCell(IconButton(
                                        icon: const Icon(LucideIcons.trash2, size: 14),
                                        color: AppColors.danger,
                                        onPressed: () => _deleteAnalyticsRow(a),
                                      )),
                                    ]))
                                .toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title, required this.color});
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.subtitle),
      ],
    );
  }
}

class _FancyField extends StatelessWidget {
  const _FancyField({required this.controller, required this.hint, required this.color});
  final TextEditingController controller;
  final String hint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.week, required this.color});
  final ClientAnalyticsModel week;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String, IconData)>[
      ('Total sales', week.totalSales != null ? '\$${week.totalSales!.toStringAsFixed(0)}' : '—',
          LucideIcons.dollarSign),
      ('Net sales', week.netSales != null ? '\$${week.netSales!.toStringAsFixed(0)}' : '—',
          LucideIcons.wallet),
      ('Retention',
          week.retentionRate != null ? '${week.retentionRate!.toStringAsFixed(0)}%' : '—',
          LucideIcons.repeat),
      ('ROAS', week.roas != null ? week.roas!.toStringAsFixed(2) : '—', LucideIcons.target),
      ('CPC', week.cpc != null ? '\$${week.cpc!.toStringAsFixed(2)}' : '—',
          LucideIcons.mousePointerClick),
      ('CTR', week.ctr != null ? '${week.ctr!.toStringAsFixed(1)}%' : '—',
          LucideIcons.trendingUp),
      ('Ad spend', week.adSpend != null ? '\$${week.adSpend!.toStringAsFixed(0)}' : '—',
          LucideIcons.megaphone),
    ];
    final palette = [
      color,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      const Color(0xFF9333EA),
      const Color(0xFFDB2777),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < stats.length; i++)
          Container(
            width: 140,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette[i % palette.length].withValues(alpha: 0.14),
                  palette[i % palette.length].withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette[i % palette.length].withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(stats[i].$3, size: 16, color: palette[i % palette.length]),
                const SizedBox(height: 8),
                Text(stats[i].$2,
                    style: AppTextStyles.h3.copyWith(color: palette[i % palette.length])),
                const SizedBox(height: 2),
                Text(stats[i].$1, style: AppTextStyles.caption),
              ],
            ),
          ),
      ],
    );
  }
}

class _AnalyticsEntryDialog extends StatefulWidget {
  const _AnalyticsEntryDialog({required this.clientId, required this.color});
  final String clientId;
  final Color color;

  @override
  State<_AnalyticsEntryDialog> createState() => _AnalyticsEntryDialogState();
}

class _AnalyticsEntryDialogState extends State<_AnalyticsEntryDialog> {
  DateTime _weekStart = DateTime.now();
  final _totalSales = TextEditingController();
  final _netSales = TextEditingController();
  final _retention = TextEditingController();
  final _roas = TextEditingController();
  final _cpc = TextEditingController();
  final _ctr = TextEditingController();
  final _adSpend = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(LucideIcons.barChart3, color: widget.color, size: 20),
          const SizedBox(width: 8),
          const Text('Add weekly analytics'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  'Week of ${_weekStart.year}-${_weekStart.month.toString().padLeft(2, '0')}-${_weekStart.day.toString().padLeft(2, '0')}'),
              trailing: Icon(LucideIcons.calendar, size: 16, color: widget.color),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _weekStart,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _weekStart = picked);
              },
            ),
            _numField('Total sales', _totalSales),
            _numField('Net sales', _netSales),
            _numField('Retention rate (%)', _retention),
            _numField('ROAS', _roas),
            _numField('CPC', _cpc),
            _numField('CTR (%)', _ctr),
            _numField('Ad spend', _adSpend),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: widget.color),
          onPressed: () {
            Navigator.pop(
              context,
              ClientAnalyticsModel(
                id: '',
                clientId: widget.clientId,
                weekStart: _weekStart,
                totalSales: double.tryParse(_totalSales.text),
                netSales: double.tryParse(_netSales.text),
                retentionRate: double.tryParse(_retention.text),
                roas: double.tryParse(_roas.text),
                cpc: double.tryParse(_cpc.text),
                ctr: double.tryParse(_ctr.text),
                adSpend: double.tryParse(_adSpend.text),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _numField(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );
}
