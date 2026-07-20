import 'package:flutter/material.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  int _severity = 3;
  String? _selected;

  final List<Map<String, String>> _symptoms = [
    {'emoji': '🤕', 'label': 'Back pain'},
    {'emoji': '🤢', 'label': 'Nausea'},
    {'emoji': '😴', 'label': 'Fatigue'},
    {'emoji': '🦵', 'label': 'Swelling'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Log a symptom',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What are you feeling today?', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'COMMON IN WEEK 24',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Symptom Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.5,
                children: _symptoms.map((s) {
                  final isSelected = _selected == s['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selected = s['label']),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.softTeal
                            : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teal
                              : AppColors.borderDefault,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            s['emoji']!,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            s['label']!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isSelected
                                  ? AppColors.teal
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Severity
              Text(
                'HOW SEVERE? (1 = MILD, 5 = SEVERE)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final n = i + 1;
                  final isSelected = _severity == n;
                  return GestureDetector(
                    onTap: () => setState(() => _severity = n),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.teal
                            : AppColors.cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teal
                              : AppColors.borderDefault,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$n',
                          style: AppTextStyles.body.copyWith(
                            color: isSelected
                                ? AppColors.textOnColor
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Symptom saved: $_selected'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    disabledBackgroundColor: AppColors.borderDefault,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text('Save symptom', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
