import 'package:flutter/material.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../logic/calendar_event.dart';

class CalendarItemTile extends StatelessWidget {
  const CalendarItemTile({super.key, required this.event, this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: event.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border(left: BorderSide(color: event.color, width: 3)),
          ),
          child: Row(
            children: [
              Icon(
                event.isTask ? Icons.check_circle_outline : Icons.campaign_outlined,
                size: 13,
                color: event.color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.title,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormatters.time(event.date),
                style: AppTextStyles.label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
