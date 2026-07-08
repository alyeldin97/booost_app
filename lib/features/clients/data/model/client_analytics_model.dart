import 'package:equatable/equatable.dart';

class ClientAnalyticsModel extends Equatable {
  const ClientAnalyticsModel({
    required this.id,
    required this.clientId,
    required this.weekStart,
    this.totalSales,
    this.netSales,
    this.retentionRate,
    this.roas,
    this.cpc,
    this.ctr,
    this.adSpend,
  });

  final String id;
  final String clientId;
  final DateTime weekStart;
  final double? totalSales;
  final double? netSales;
  final double? retentionRate;
  final double? roas;
  final double? cpc;
  final double? ctr;
  final double? adSpend;

  factory ClientAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      ClientAnalyticsModel(
        id: json['id'] as String,
        clientId: json['client_id'] as String,
        weekStart: DateTime.parse(json['week_start'] as String),
        totalSales: (json['total_sales'] as num?)?.toDouble(),
        netSales: (json['net_sales'] as num?)?.toDouble(),
        retentionRate: (json['retention_rate'] as num?)?.toDouble(),
        roas: (json['roas'] as num?)?.toDouble(),
        cpc: (json['cpc'] as num?)?.toDouble(),
        ctr: (json['ctr'] as num?)?.toDouble(),
        adSpend: (json['ad_spend'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toInsertJson(String clientId) => {
        'client_id': clientId,
        'week_start':
            '${weekStart.year.toString().padLeft(4, '0')}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}',
        'total_sales': totalSales,
        'net_sales': netSales,
        'retention_rate': retentionRate,
        'roas': roas,
        'cpc': cpc,
        'ctr': ctr,
        'ad_spend': adSpend,
      };

  @override
  List<Object?> get props => [
        id,
        clientId,
        weekStart,
        totalSales,
        netSales,
        retentionRate,
        roas,
        cpc,
        ctr,
        adSpend,
      ];
}
