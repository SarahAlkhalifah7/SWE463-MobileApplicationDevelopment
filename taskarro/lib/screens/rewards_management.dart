import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/parent.dart';
import '../models/reward.dart';
import '../services/reward_storage.dart';
import '../services/star_service.dart';

class RewardsManagementScreen extends StatefulWidget {
  const RewardsManagementScreen({super.key, required this.parent});

  final ParentAccount parent;

  @override
  State<RewardsManagementScreen> createState() =>
      _RewardsManagementScreenState();
}

class _RewardsManagementScreenState extends State<RewardsManagementScreen> {
  static const Color purple = Color(0xFF7563E8);
  static const Color darkText = Color(0xFF29283A);
  static const Color border = Color(0xFFE8E3F5);
  static const Color lightPurple = Color(0xFFF2EFFF);
  static const Color lightYellow = Color(0xFFFFF4D6);

  // The child whose rewards are shown (null if the parent has no children)
  Child? _selectedChild;

  List<Reward> _rewards = [];
  int _availableStars = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.parent.children.isNotEmpty) {
      _selectedChild = widget.parent.children.first;
    }

    _loadRewards();
  }

  // Load the selected child's rewards and stars from storage
  Future<void> _loadRewards() async {
    if (_selectedChild == null) {
      setState(() => _isLoading = false);
      return;
    }

    final childId = _selectedChild!.accessCode;
    final rewards = await RewardStorage.getRewardsForChild(childId);
    final stars = await StarService.getAvailableStars(childId);

    if (!mounted) return;

    setState(() {
      _rewards = _sortRewards(rewards);
      _availableStars = stars;
      _isLoading = false;
    });
  }

  // Rewards not given yet first (cheapest first), given rewards at the end
  List<Reward> _sortRewards(List<Reward> rewards) {
    rewards.sort((a, b) {
      if (a.isRedeemed != b.isRedeemed) {
        return a.isRedeemed ? 1 : -1;
      }
      return a.requiredStars.compareTo(b.requiredStars);
    });

    return rewards;
  }

  void _selectChild(Child child) {
    setState(() {
      _selectedChild = child;
      _isLoading = true;
    });

    _loadRewards();
  }

  // Will open the Add Reward form (next step)
  void _openAddReward() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Reward form is coming next!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9F0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rewards',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedChild == null)
                  _buildNoChildren()
                else if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _buildChildSelector(),
                  const SizedBox(height: 16),
                  _buildStarsCard(),
                  const SizedBox(height: 24),
                  _buildRewardsTitle(),
                  const SizedBox(height: 12),
                  if (_rewards.isEmpty)
                    _buildEmptyState()
                  else
                    ..._rewards.map(
                      (reward) => _RewardCard(
                        reward: reward,
                        availableStars: _availableStars,
                      ),
                    ),
                  const SizedBox(height: 8),
                  _buildAddButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card showing "Rewards for Sara" with a Switch menu
  Widget _buildChildSelector() {
    final child = _selectedChild!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: lightPurple,
              shape: BoxShape.circle,
            ),
            child: Text(child.avatar, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rewards for',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (widget.parent.children.length > 1)
            PopupMenuButton<Child>(
              onSelected: _selectChild,
              itemBuilder: (context) => widget.parent.children
                  .map(
                    (c) => PopupMenuItem<Child>(
                      value: c,
                      child: Text('${c.avatar}  ${c.name}'),
                    ),
                  )
                  .toList(),
              child: const Row(
                children: [
                  Text(
                    'Switch',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: purple),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Yellow card: "⭐ 180 stars — Available for Sara's rewards"
  Widget _buildStarsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightYellow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_availableStars stars',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              Text(
                "Available for ${_selectedChild!.name}'s rewards",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Rewards',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '${_rewards.length} ${_rewards.length == 1 ? 'reward' : 'rewards'}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openAddReward,
        icon: const Icon(Icons.add),
        label: const Text('Add Reward'),
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // Shown when the selected child has no rewards yet
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 14),
          const Text(
            'No rewards yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add a reward for ${_selectedChild!.name} to work towards, '
            'like ice cream or a movie night!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Shown when the parent has not added any children
  Widget _buildNoChildren() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Text('👶', style: TextStyle(fontSize: 48)),
          SizedBox(height: 14),
          Text(
            'Add a child first',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Go to Home and add a child, then you can create rewards for them.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// One reward in the list
class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.reward, required this.availableStars});

  final Reward reward;
  final int availableStars;

  @override
  Widget build(BuildContext context) {
    final isAvailable = reward.isAvailable(availableStars);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E3F5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(reward.icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29283A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '⭐ ${reward.requiredStars} stars required',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),

                // Progress bar towards this reward
                if (!reward.isRedeemed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: reward.progress(availableStars),
                      minHeight: 6,
                      backgroundColor: const Color(0xFFEDEAF5),
                      color: isAvailable
                          ? const Color(0xFF2E9E5B)
                          : const Color(0xFF7563E8),
                    ),
                  ),
                const SizedBox(height: 8),
                _buildStatus(isAvailable),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // "Given ✓", "Ready to redeem" or "20 more stars needed"
  Widget _buildStatus(bool isAvailable) {
    String text;
    Color color;
    Color background;

    if (reward.isRedeemed) {
      text = '✓ Given';
      color = Colors.grey[700]!;
      background = const Color(0xFFF0F0F0);
    } else if (isAvailable) {
      text = '✓ Ready to redeem';
      color = const Color(0xFF2E9E5B);
      background = const Color(0xFFE6F6EC);
    } else {
      text = '${reward.starsNeeded(availableStars)} more stars needed';
      color = const Color(0xFFB7791F);
      background = const Color(0xFFFFF4D6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
