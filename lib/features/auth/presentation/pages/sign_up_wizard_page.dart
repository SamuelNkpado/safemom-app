import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/clinic_option_tile.dart';
import '../widgets/wizard_progress.dart';

/// Screens 02-05 — the 4-step sign-up wizard.
///
/// Steps 1-2 collect everything [SignUpWithEmail] needs; the account is
/// created when the user finishes step 2. Steps 3-4 (clinic, partner) refine
/// the profile afterward. Field values are view state held here; account
/// creation goes through [AuthBloc].
class SignUpWizardPage extends StatefulWidget {
  const SignUpWizardPage({super.key});

  @override
  State<SignUpWizardPage> createState() => _SignUpWizardPageState();
}

class _SignUpWizardPageState extends State<SignUpWizardPage> {
  static const _totalSteps = 4;

  final _pageController = PageController();
  final _accountFormKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _partnerPhone = TextEditingController();

  int _step = 0; // 0-based
  DateTime? _dueDate;
  String? _clinicId;
  bool _awaitingSignup = false;

  // Temporary clinic list (matches the Figma). Replace with a GetClinics
  // use case once the backend exposes the clinics collection.
  static const _clinics = <({String id, String name, String subtitle})>[
    (id: 'kasarani', name: 'Kasarani Health Centre', subtitle: '1.2 km away · Open 24 hrs'),
    (id: 'stfrancis', name: 'St. Francis Hospital', subtitle: '2.4 km away · Open 24 hrs'),
    (id: 'mater', name: 'Mater Hospital', subtitle: '3.8 km away · Open 24 hrs'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _partnerPhone.dispose();
    super.dispose();
  }

  int? get _currentWeek {
    if (_dueDate == null) return null;
    final days = _dueDate!.difference(DateTime.now()).inDays;
    return (40 - (days / 7)).round().clamp(1, 42);
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onAccountContinue() {
    if (_accountFormKey.currentState!.validate()) {
      _goTo(1);
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 300)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submitSignup() {
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose your due date.')),
      );
      return;
    }
    _awaitingSignup = true;
    context.read<AuthBloc>().add(
          AuthSignUpSubmitted(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            phoneNumber: _phone.text.trim(),
            dueDate: _dueDate!,
          ),
        );
  }

  void _finish() {
    // TODO(onboarding): persist _clinicId and partner invite, then call
    // MarkOnboardingComplete once the preferences data layer is wired.
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.root, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (_awaitingSignup &&
                state.formStatus == AuthFormStatus.success) {
              _awaitingSignup = false;
              _goTo(2); // account created, continue to clinic selection
            } else if (state.formStatus == AuthFormStatus.failure &&
                state.errorMessage != null) {
              _awaitingSignup = false;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.pageTop,
            ),
            child: Column(
              children: [
                WizardProgress(
                  step: _step + 1,
                  total: _totalSteps,
                  onBack: _step == 0
                      ? () => Navigator.maybePop(context)
                      : () => _goTo(_step - 1),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _accountStep(),
                      _dueDateStep(),
                      _clinicStep(),
                      _partnerStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- STEP 1: ACCOUNT ----------

  Widget _accountStep() {
    return SingleChildScrollView(
      child: Form(
        key: _accountFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create your account', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Your name',
              hintText: 'Amina W.',
              controller: _name,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            // NOTE: the Figma omits email, but signUpWithEmail requires it.
            // Confirm with the team where email should be captured.
            AppTextField(
              label: 'Email',
              hintText: 'you@example.com',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Phone number',
              hintText: '+254 712 345 678',
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 9)
                  ? 'Enter a valid phone number'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Create password',
              hintText: 'At least 8 characters',
              controller: _password,
              obscureText: true,
              validator: (v) => (v == null || v.length < 8)
                  ? 'At least 8 characters'
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Continue', onPressed: _onAccountContinue),
          ],
        ),
      ),
    );
  }

  // ---------- STEP 2: DUE DATE ----------

  Widget _dueDateStep() {
    final week = _currentWeek;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('When is your baby due?', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          onTap: _pickDueDate,
          child: Row(
            children: [
              const Icon(LucideIcons.calendar, color: AppColors.teal),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _dueDate == null
                      ? 'Tap to choose your due date'
                      : _formatDate(_dueDate!),
                  style: AppTextStyles.body.copyWith(
                    color: _dueDate == null
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (week != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('You are at week $week', style: AppTextStyles.h3),
        ],
        const Spacer(),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => PrimaryButton(
            label: 'Sign Up',
            isLoading: state.isSubmitting,
            onPressed: _submitSignup,
          ),
        ),
      ],
    );
  }

  // ---------- STEP 3: CLINIC ----------

  Widget _clinicStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Your clinic', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Choose where you receive care',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.separated(
            itemCount: _clinics.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final c = _clinics[i];
              return ClinicOptionTile(
                name: c.name,
                subtitle: c.subtitle,
                selected: _clinicId == c.id,
                onTap: () => setState(() => _clinicId = c.id),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'Continue', onPressed: () => _goTo(3)),
      ],
    );
  }

  // ---------- STEP 4: PARTNER ----------

  Widget _partnerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.softTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: AppColors.coral, size: 40),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(child: Text('Invite Your Partner', style: AppTextStyles.h2)),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            'Share this journey with someone who supports you',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: "Partner's phone number",
          hintText: '+254 ...',
          controller: _partnerPhone,
          keyboardType: TextInputType.phone,
        ),
        const Spacer(),
        PrimaryButton(label: 'Send invite', onPressed: _finish),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _finish,
          child: Text(
            'Skip for now',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.teal),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
