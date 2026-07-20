import 'package:flutter/material.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';

class DangerCheckerPage extends StatefulWidget {
  const DangerCheckerPage({super.key});

  @override
  State<DangerCheckerPage> createState() => _DangerCheckerPageState();
}

class _DangerCheckerPageState extends State<DangerCheckerPage> {
  int _current = 0;
  String? _selected;
  bool _showWarning = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Is the pain constant or coming and going?',
      'answers': [
        {
          'label': 'Constant and severe',
          'detail': 'Has not stopped for an hour',
          'warn': true,
        },
        {
          'label': 'Coming and going',
          'detail': 'Like waves, with breaks between',
          'warn': false,
        },
        {
          'label': 'Mild discomfort',
          'detail': 'Not painful, just noticeable',
          'warn': false,
        },
      ],
    },
    {
      'question': 'Do you have any bleeding?',
      'answers': [
        {
          'label': 'Yes, heavy bleeding',
          'detail': 'Soaking more than one pad per hour',
          'warn': true,
        },
        {
          'label': 'Light spotting',
          'detail': 'Small amount, light pink or brown',
          'warn': false,
        },
        {'label': 'No bleeding', 'detail': 'No blood at all', 'warn': false},
      ],
    },
    {
      'question': 'How is your baby moving?',
      'answers': [
        {
          'label': 'Not moving at all',
          'detail': 'No movement in the last few hours',
          'warn': true,
        },
        {
          'label': 'Moving less than usual',
          'detail': 'Fewer kicks than normal',
          'warn': false,
        },
        {'label': 'Moving normally', 'detail': 'Same as usual', 'warn': false},
      ],
    },
    {
      'question': 'Do you have a headache or vision changes?',
      'answers': [
        {
          'label': 'Severe headache with blurred vision',
          'detail': 'Sudden and very painful',
          'warn': true,
        },
        {
          'label': 'Mild headache',
          'detail': 'Not too bad, manageable',
          'warn': false,
        },
        {'label': 'No headache', 'detail': 'Feeling fine', 'warn': false},
      ],
    },
  ];

  void _pick(String label, bool warn) {
    setState(() {
      _selected = label;
      _showWarning = warn;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _showWarning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_current];
    final answers = q['answers'] as List<Map<String, dynamic>>;

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
          'Check a symptom',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              Text(
                'Question ${_current + 1} of ${_questions.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(
                value: (_current + 1) / _questions.length,
                backgroundColor: AppColors.borderDefault,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                borderRadius: BorderRadius.circular(4),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Question
              Text(q['question'] as String, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Take your time. There are no wrong answers.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Answers
              ...answers.map((a) {
                final isSelected = _selected == a['label'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => _pick(a['label'] as String, a['warn'] as bool),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
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
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColors.teal
                                : AppColors.borderDefault,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a['label'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.teal
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  a['detail'] as String,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Warning banner
              if (_showWarning) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.softCoral,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.coral),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.coral,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Based on your answers',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Text('🚨', style: TextStyle(fontSize: 18)),
                    label: Text('Get help now', style: AppTextStyles.button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergencyRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ],

              // Next button
              if (!_showWarning && _selected != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      _current < _questions.length - 1
                          ? 'Next question'
                          : 'Done',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
