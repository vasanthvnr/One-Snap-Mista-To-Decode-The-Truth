import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String category;
  final String imageUri;
  final Map<String, dynamic> results;

  const ResultScreen({
    super.key,
    required this.category,
    required this.imageUri,
    required this.results,
  });

  String _calculateOverallSafety(List ingredients) {
    bool hasBad = false;
    bool hasModerate = false;
    bool hasConflict = false;

    for (var ing in ingredients) {
      final eval = (ing['evaluation'] ?? '').toString().toLowerCase();
      if (eval == 'bad') hasBad = true;
      if (eval == 'moderate') hasModerate = true;
      if (ing['notSuitable'] == true) hasConflict = true;
    }

    if (hasBad || hasConflict) return 'bad';
    if (hasModerate) return 'moderate';
    return 'good';
  }

  Map<String, dynamic> _getSafetyInfo(String level) {
    switch (level.toLowerCase()) {
      case 'good':
        return {
          'label': 'Safe Product',
          'description': 'All ingredients are considered safe.',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'moderate':
        return {
          'label': 'Moderate Risk',
          'description':
              'Some ingredients may cause mild irritation or issues.',
          'color': Colors.orange,
          'icon': Icons.warning_amber,
        };
      case 'bad':
        return {
          'label': 'Unsafe Product',
          'description':
              'Some ingredients are unsafe or not suitable for your health issues.',
          'color': Colors.red,
          'icon': Icons.dangerous,
        };
      default:
        return {
          'label': 'Unknown Risk',
          'description': 'Could not determine safety level.',
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }

  Color _getIngredientColor(String safety, bool notSuitable) {
    if (notSuitable) return Colors.red; // Highlight conflict
    switch (safety.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'bad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = results['ingredients'] ?? [];
    final String overallSafety = _calculateOverallSafety(ingredients);
    final safetyInfo = _getSafetyInfo(overallSafety);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: safetyInfo['color'],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Display
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(imageUri,
                      height: 220, width: double.infinity, fit: BoxFit.cover)
                  : Image.file(File(imageUri),
                      height: 220, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // Overall Safety Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: safetyInfo['color'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(safetyInfo['icon'], color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      safetyInfo['label'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              safetyInfo['description'],
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),
            const Text(
              'Detected Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Ingredient List Display with health issues comparison
            ...ingredients.map<Widget>((ing) {
              final String name = ing['ingredient'] ?? 'Unknown';
              final String safety = ing['evaluation'] ?? 'Unknown';
              final bool notSuitable = ing['notSuitable'] ?? false;
              final String reason = ing['reason'] ?? '';
              final color = _getIngredientColor(safety, notSuitable);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis, 
                        ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            safety.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (notSuitable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'NOT FOR YOU',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    if (notSuitable && reason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.red,
                          ),
                        ),
                      )
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 10),
            const Divider(),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This result is for informational purposes only. Safety may vary by individual.',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
