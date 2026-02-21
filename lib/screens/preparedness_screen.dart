import 'package:flutter/material.dart';
import 'package:pantryready/constants/app_constants.dart';
import 'package:pantryready/models/pantry_item.dart';
import 'package:pantryready/models/user_preferences.dart';

enum _ReadinessStatus { onTarget, low, critical }

class _CategoryScore {
  final SystemCategory category;
  final double avgDaysOfSupply;
  final int trackedCount;
  final _ReadinessStatus status;

  const _CategoryScore({
    required this.category,
    required this.avgDaysOfSupply,
    required this.trackedCount,
    required this.status,
  });
}

class PreparednessScreen extends StatelessWidget {
  final List<PantryItem> pantryItems;
  final UserPreferences userPreferences;
  final VoidCallback onGoToSettings;

  const PreparednessScreen({
    super.key,
    required this.pantryItems,
    required this.userPreferences,
    required this.onGoToSettings,
  });

  List<PantryItem> get _trackedItems =>
      pantryItems
          .where(
            (item) =>
                item.dailyConsumptionRate != null &&
                item.dailyConsumptionRate! > 0,
          )
          .toList();

  List<PantryItem> get _untrackedItems =>
      pantryItems
          .where(
            (item) =>
                item.dailyConsumptionRate == null ||
                item.dailyConsumptionRate! <= 0,
          )
          .toList();

  int get _itemsMeetingTarget {
    final target = userPreferences.targetDaysOfSupply;
    final familySize = userPreferences.familySize;
    return _trackedItems.where((item) {
      final days =
          item.availableQuantity / (item.dailyConsumptionRate! * familySize);
      return days >= target;
    }).length;
  }

  List<_CategoryScore> _buildCategoryScores() {
    final target = userPreferences.targetDaysOfSupply;
    final familySize = userPreferences.familySize;

    final Map<SystemCategory, List<PantryItem>> byCategory = {};
    for (final item in _trackedItems) {
      byCategory.putIfAbsent(item.systemCategory, () => []).add(item);
    }

    final scores = <_CategoryScore>[];
    for (final entry in byCategory.entries) {
      double totalDays = 0.0;
      for (final item in entry.value) {
        totalDays +=
            item.availableQuantity / (item.dailyConsumptionRate! * familySize);
      }
      final avg = totalDays / entry.value.length;

      final _ReadinessStatus status;
      if (avg >= target) {
        status = _ReadinessStatus.onTarget;
      } else if (avg >= target * 0.5) {
        status = _ReadinessStatus.low;
      } else {
        status = _ReadinessStatus.critical;
      }

      scores.add(
        _CategoryScore(
          category: entry.key,
          avgDaysOfSupply: avg,
          trackedCount: entry.value.length,
          status: status,
        ),
      );
    }

    // Sort: critical first, then low, then on target
    scores.sort((a, b) => a.status.index.compareTo(b.status.index));
    return scores;
  }

  @override
  Widget build(BuildContext context) {
    final tracked = _trackedItems;
    final untracked = _untrackedItems;
    final meetingTarget = _itemsMeetingTarget;
    final totalTracked = tracked.length;
    final scorePercent =
        totalTracked > 0 ? (meetingTarget / totalTracked) : 0.0;
    final categoryScores = _buildCategoryScores();

    return Scaffold(
      body: SafeArea(
        child:
            pantryItems.isEmpty
                ? _buildEmptyState()
                : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildOverallScoreCard(
                      context,
                      scorePercent,
                      meetingTarget,
                      totalTracked,
                    ),
                    const SizedBox(height: 16),
                    if (categoryScores.isNotEmpty) ...[
                      _buildSectionHeader('Category Breakdown'),
                      const SizedBox(height: 8),
                      ...categoryScores.map(
                        (score) => _buildCategoryCard(score),
                      ),
                    ],
                    if (untracked.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildUntrackedSection(untracked),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 64,
            color: AppConstants.textSecondaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'No items to score',
            style: TextStyle(
              fontSize: 18,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items to your pantry to see your readiness score',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(
    BuildContext context,
    double scorePercent,
    int meetingTarget,
    int totalTracked,
  ) {
    final scoreColor =
        scorePercent >= 0.8
            ? AppConstants.successColor
            : scorePercent >= 0.5
            ? AppConstants.warningColor
            : AppConstants.errorColor;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onGoToSettings,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: scorePercent,
                            strokeWidth: 10,
                            backgroundColor: scoreColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scoreColor,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(scorePercent * 100).round()}%',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                            Text(
                              'Ready',
                              style: TextStyle(fontSize: 11, color: scoreColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Readiness',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$meetingTarget of $totalTracked items meet the ${userPreferences.targetDaysOfSupply}-day target',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Family of ${userPreferences.familySize}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.tune,
                              size: 14,
                              color: AppConstants.primaryColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to adjust target',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppConstants.textSecondaryColor,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryScore score) {
    final categoryColor =
        AppConstants.categoryColors[score.category] ??
        AppConstants.primaryColor;
    final target = userPreferences.targetDaysOfSupply.toDouble();
    final barValue = (score.avgDaysOfSupply / target).clamp(0.0, 1.0);

    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;
    switch (score.status) {
      case _ReadinessStatus.onTarget:
        statusColor = AppConstants.successColor;
        statusLabel = 'On Target';
        statusIcon = Icons.check_circle_outline;
      case _ReadinessStatus.low:
        statusColor = AppConstants.warningColor;
        statusLabel = 'Low';
        statusIcon = Icons.warning_amber_outlined;
      case _ReadinessStatus.critical:
        statusColor = AppConstants.errorColor;
        statusLabel = 'Critical';
        statusIcon = Icons.cancel_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: categoryColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          score.category.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            score.category.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppConstants.textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 13, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: barValue,
                        backgroundColor: AppConstants.surfaceColor,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${score.avgDaysOfSupply.toStringAsFixed(0)} days avg',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        const Text(
                          '  •  ',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'target: ${userPreferences.targetDaysOfSupply} days',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${score.trackedCount} item${score.trackedCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUntrackedSection(List<PantryItem> items) {
    return Card(
      elevation: 1,
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(
            Icons.help_outline,
            color: AppConstants.textSecondaryColor,
          ),
          title: Text(
            '${items.length} untracked item${items.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppConstants.textColor,
            ),
          ),
          subtitle: const Text(
            'Set a daily consumption rate to include in scoring',
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          children:
              items
                  .map(
                    (item) => ListTile(
                      dense: true,
                      leading: Text(
                        item.systemCategory.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      title: Text(item.name),
                      subtitle:
                          item.brand != null
                              ? Text(
                                item.brand!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.textSecondaryColor,
                                ),
                              )
                              : null,
                      trailing: const Text(
                        'No rate set',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
