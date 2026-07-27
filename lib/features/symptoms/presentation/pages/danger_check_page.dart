import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/usecases/run_danger_check.dart';

class DangerCheckPage extends StatefulWidget {
  const DangerCheckPage({super.key});

  @override
  State<DangerCheckPage> createState() => _DangerCheckPageState();
}

class _DangerCheckPageState extends State<DangerCheckPage> {
  final Set<String> _selectedIndicators = {};
  bool _isSubmitting = false;

  static const List<_DangerIndicator> _indicators = [
    _DangerIndicator(
      id: 'heavy_bleeding',
      icon: '🩸',
      title: 'Heavy bleeding',
      description: 'Soaking through pads or clots',
      riskLevel: 'high',
    ),
    _DangerIndicator(
      id: 'severe_pain',
      icon: '🤕',
      title: 'Severe abdominal pain',
      description: 'Sharp, persistent pain',
      riskLevel: 'high',
    ),
    _DangerIndicator(
      id: 'fever',
      icon: '🥶',
      title: 'Chills or fever',
      description: 'Temperature above 38.5°C',
      riskLevel: 'high',
    ),
    _DangerIndicator(
      id: 'dizziness',
      icon: '😵',
      title: 'Dizziness or fainting',
      description: 'Loss of consciousness',
      riskLevel: 'high',
    ),
    _DangerIndicator(
      id: 'swelling',
      icon: '🤍',
      title: 'Unusual swelling',
      description: 'Face, hands, or legs swelling',
      riskLevel: 'medium',
    ),
    _DangerIndicator(
      id: 'vision_changes',
      icon: '👁️',
      title: 'Vision changes',
      description: 'Blurred vision or flashing lights',
      riskLevel: 'medium',
    ),
    _DangerIndicator(
      id: 'difficulty_breathing',
      icon: '😤',
      title: 'Difficulty breathing',
      description: 'Shortness of breath at rest',
      riskLevel: 'high',
    ),
    _DangerIndicator(
      id: 'chest_pain',
      icon: '💔',
      title: 'Chest pain',
      description: 'Pressure or pain in chest',
      riskLevel: 'high',
    ),
  ];

  Future<void> _submitCheck() async {
    if (_selectedIndicators.isEmpty || _isSubmitting) {
      _showSnack('Please select at least one concern.', isError: true);
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated ||
        authState.user == null) {
      _showSnack('Please sign in to run a safety check.', isError: true);
      return;
    }

    final userId = authState.user!.userId;

    setState(() => _isSubmitting = true);

    try {
      final runDangerCheck = getIt<RunDangerCheck>();
      final checkId = DateTime.now().millisecondsSinceEpoch.toString();

      final answers = <String, String>{};
      for (final indicator in _indicators) {
        answers[indicator.id] = _selectedIndicators.contains(indicator.id)
            ? 'yes'
            : 'no';
      }

      await runDangerCheck(
        checkId: checkId,
        userId: userId,
        answers: answers,
        completedAt: DateTime.now(),
      );

      if (!mounted) return;

      final hasHighRisk =
          _selectedIndicators.any((id) {
            return _indicators
                .firstWhere((ind) => ind.id == id)
                .riskLevel ==
                'high';
          });

      _showResultDialog(hasHighRisk ? 'high' : 'medium');

      setState(() {
        _selectedIndicators.clear();
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        'Could not save check. Please try again. ($e)',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showResultDialog(String riskLevel) {
    final isHighRisk = riskLevel == 'high';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          isHighRisk ? '⚠️ Please seek care' : '✓ Noted',
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHighRisk
                  ? 'Your responses suggest you should contact a healthcare provider immediately.'
                  : 'We\'ve recorded your concerns. Monitor your symptoms and reach out if they worsen.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isHighRisk)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.softCoral,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.coral),
                ),
                child: Text(
                  'In an emergency, tap the SOS button in the app or call emergency services.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Got it',
              style: AppTextStyles.button.copyWith(
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.body.copyWith(
          color: AppColors.textOnColor,
        )),
        backgroundColor:
            isError ? AppColors.emergencyRed : AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text('Safety check', style: AppTextStyles.h2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you experiencing any of these?',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select all that apply so we can help you stay safe.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              ..._indicators.map((indicator) {
                final isSelected = _selectedIndicators.contains(indicator.id);
                final borderColor = isSelected
                    ? (indicator.riskLevel == 'high'
                        ? AppColors.emergencyRed
                        : AppColors.warningAmber)
                    : AppColors.borderDefault;
                final bgColor = isSelected
                    ? (indicator.riskLevel == 'high'
                        ? AppColors.softCoral
                        : AppColors.softTeal)
                    : AppColors.cardSurface;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIndicators.remove(indicator.id);
                        } else {
                          _selectedIndicators.add(indicator.id);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Text(
                            indicator.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  indicator.title,
                                  style: AppTextStyles.h3.copyWith(
                                    color: isSelected
                                        ? (indicator.riskLevel == 'high'
                                            ? AppColors.emergencyRed
                                            : AppColors.warningAmber)
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  indicator.description,
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedIndicators.add(indicator.id);
                                } else {
                                  _selectedIndicators.remove(indicator.id);
                                }
                              });
                            },
                            fillColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return indicator.riskLevel == 'high'
                                    ? AppColors.emergencyRed
                                    : AppColors.warningAmber;
                              }
                              return AppColors.borderDefault;
                            }),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: AppSpacing.xl),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.infoBlue),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.info,
                      color: AppColors.infoBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'This check does not replace medical advice. Always call a healthcare provider if you feel unwell.',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: 'Submit safety check',
                isLoading: _isSubmitting,
                onPressed:
                    _selectedIndicators.isEmpty ? null : _submitCheck,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerIndicator {
  final String id;
  final String icon;
  final String title;
  final String description;
  final String riskLevel;

  const _DangerIndicator({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.riskLevel,
  });
}