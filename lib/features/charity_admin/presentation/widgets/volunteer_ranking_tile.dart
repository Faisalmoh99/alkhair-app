import 'package:alkhair_app/core/theme/app_colors.dart';
import 'package:alkhair_app/features/charity_admin/domain/entities/volunteer_ranking.dart';
import 'package:flutter/material.dart';

/// One row in Screen 11's volunteer-performance leaderboard (Fig 5.11,
/// FR12) — name, delivered count, and a badge on the top volunteer.
class VolunteerRankingTile extends StatelessWidget {
  const VolunteerRankingTile({required this.rank, required this.ranking, super.key});

  final int rank;
  final VolunteerRanking ranking;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('$rank')),
      title: Text(ranking.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ranking.isLeader)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.emoji_events, color: AppColors.gold),
            ),
          Text('${ranking.deliveredCount}'),
        ],
      ),
    );
  }
}
