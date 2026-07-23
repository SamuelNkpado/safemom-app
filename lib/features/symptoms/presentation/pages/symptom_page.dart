import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/symptom_log.dart';
import '../../domain/usecases/log_symptom.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  int _severity = 3;
  String? _selectedLabel;
  SymptomType? _selectedType;
  bool _isSaving = false;

  // Symptom options mapped to entity types so the save call is exact.
  final List<_SymptomOption> _symptoms = const [
    _SymptomOption('🤕', 'Back pain', SymptomType.backPain),
    _SymptomOption('🤢', 'Nausea', SymptomType.nausea),
    _SymptomOption('😴', 'Fatigue', SymptomType.fatigue),
    _SymptomOption('💧', 'Swelling', SymptomType.swelling),
    _SymptomOption('🤯', 'Headache', SymptomType.headache),
    _SymptomOption('⚡', 'Cramping', SymptomType.cramping),
  ];

  Future<void> _saveSymptom() async {
    if (_selectedType == null || _isSaving) return;

    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated ||
        authState.user == null) {
      _showSnack('Please sign in to log symptoms.', isError: true);
      return;
    }

    final userId = authState.user!.userId;

    setState(() => _isSaving = true);

    try {
      final logSymptom = getIt<LogSymptom>();
      final symptomId = DateTime.now().millisecondsSinceEpoch.toString();

      // Pregnancy week — for now use current week from user profile.
      // A future improvement is to compute from due date.
      const pregnancyWeek = 24;

      await logSymptom(
        symptomId: symptomId,
        userId: userId,
        symptomType: _selectedType!,
        severity: _severity,
        pregnancyWeek: pregnancyWeek,
        loggedAt: DateTime.now(),
      );

      if (!mounted) return;
      _showSnack(
        'Symptom saved to your record. Kaza moyo!',
        isError: false,
      );
      setState(() {
        _selectedLabel = null;
        _selectedType = null;
        _severity = 3;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        'Could not save. Please try again. ($e)',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body.copyWith(
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
        title: Text('Log a symptom', style: AppTextStyles.h2),
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
              Text('What are you feeling today?', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.lg),

              // Symptom grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.5,
                children: _symptoms.map((option) {
                  final isSelected = option.label == _selectedLabel;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedLabel = option.label;
                      _selectedType = option.type;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.softTeal
                            : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teal
                              : AppColors.borderDefault,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(option.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              option.label,
                              style: AppTextStyles.body.copyWith(
                                color: isSelected
                                    ? AppColors.teal
                                    : AppColors.textPrimary,
                              ),
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
              Text('How severe? (1 = mild, 5 = severe)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final level = i + 1;
                  final isSelected = _severity == level;
                  return GestureDetector(
                    onTap: () => setState(() => _severity = level),
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
                          '$level',
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

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                  _selectedType == null || _isSaving ? null : _saveSymptom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    disabledBackgroundColor: AppColors.borderDefault,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Save symptom',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textOnColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymptomOption {
  final String emoji;
  final String label;
  final SymptomType type;

  const _SymptomOption(this.emoji, this.label, this.type);
}