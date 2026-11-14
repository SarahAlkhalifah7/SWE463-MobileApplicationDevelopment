import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reward.dart';

class RewardStorage {
  static const String _rewardsKey = 'rewards';

  // Create a unique id for a new reward (based on the current time)
  static String generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  // Get all saved rewards (for all children)
  static Future<List<Reward>> getRewards() async {
    final prefs = await SharedPreferences.getInstance();

    final rewardsData = prefs.getStringList(_rewardsKey) ?? [];

    return rewardsData.map((rewardString) {
      final Map<String, dynamic> data = jsonDecode(rewardString);

      return Reward.fromJson(data);
    }).toList();
  }

  // Get the rewards of one child only
  static Future<List<Reward>> getRewardsForChild(String childId) async {
    final rewards = await getRewards();

    return rewards.where((reward) => reward.childId == childId).toList();
  }

  // The reward the child is working towards:
  // the cheapest reward that has not been given yet (null if none)
  static Future<Reward?> getNextReward(String childId) async {
    final rewards = await getRewardsForChild(childId);

    final activeRewards = rewards.where((reward) => !reward.isRedeemed).toList()
      ..sort((a, b) => a.requiredStars.compareTo(b.requiredStars));

    return activeRewards.isEmpty ? null : activeRewards.first;
  }

  // Save all rewards
  static Future<void> _saveRewards(List<Reward> rewards) async {
    final prefs = await SharedPreferences.getInstance();

    final rewardsData = rewards
        .map((reward) => jsonEncode(reward.toJson()))
        .toList();

    await prefs.setStringList(_rewardsKey, rewardsData);
  }

  // Add a new reward
  static Future<void> addReward(Reward reward) async {
    final rewards = await getRewards();

    rewards.add(reward);

    await _saveRewards(rewards);
  }

  // Replace an existing reward (found by id) with the updated version
  static Future<void> updateReward(Reward updatedReward) async {
    final rewards = await getRewards();

    final index = rewards.indexWhere((reward) => reward.id == updatedReward.id);

    if (index != -1) {
      rewards[index] = updatedReward;

      await _saveRewards(rewards);
    }
  }

  // Delete one reward
  static Future<void> deleteReward(String rewardId) async {
    final rewards = await getRewards();

    rewards.removeWhere((reward) => reward.id == rewardId);

    await _saveRewards(rewards);
  }

  // Delete all rewards of a child (used when the child is removed)
  static Future<void> deleteRewardsForChild(String childId) async {
    final rewards = await getRewards();

    rewards.removeWhere((reward) => reward.childId == childId);

    await _saveRewards(rewards);
  }
}
