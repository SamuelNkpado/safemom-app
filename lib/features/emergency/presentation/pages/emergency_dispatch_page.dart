import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/constants/app_spacing.dart';
import 'package:safemom/core/theme/app_text_styles.dart';
import 'package:safemom/core/widgets/safemom_bottom_nav.dart';

import '../../domain/entities/emergency_request.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';

class EmergencyDispatchPage extends StatefulWidget {
  final String userId;
  final String clinicId;
  final double latitude;
  final double longitude;

  const EmergencyDispatchPage({
    super.key,
    required this.userId,
    required this.clinicId,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<EmergencyDispatchPage> createState() => _EmergencyDispatchPageState();
}

class _EmergencyDispatchPageState extends State<EmergencyDispatchPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmergencyBloc>().add(SosTriggered(
          userId: widget.userId,
          clinicId: widget.clinicId,
          latitude: widget.latitude,
          longitude: widget.longitude,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<EmergencyBloc, EmergencyState>(
        listenWhen: (previous, current) => previous.sosStatus != current.sosStatus,
        listener: (context, state) {
          if (state.sosStatus == SosStatus.cancelled) Navigator.pop(context);
        },
        child: Scaffold(
          backgroundColor: AppColors.emergencyRed,
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<EmergencyBloc, EmergencyState>(
                    builder: (context, state) => _buildBody(context, state),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              SafeMomBottomNav(currentIndex: -1, onTabSelected: (_) {}, onSosPressed: () {}),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EmergencyState state) {
    switch (state.sosStatus) {
      case SosStatus.idle:
      case SosStatus.sending:
        return const _CenteredMessage(
          label: 'Sending your alert...',
          child: CircularProgressIndicator(color: Colors.white),
        );
      case SosStatus.error:
        return _CenteredMessage(
          icon: Icons.error_outline_rounded,
          label: state.sosError ?? 'Something went wrong.',
          action: TextButton(
            onPressed: () => context.read<EmergencyBloc>().add(SosTriggered(
                  userId: widget.userId,
                  clinicId: widget.clinicId,
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                )),
            child: const Text('Try again', style: TextStyle(color: Colors.white)),
          ),
        );
      case SosStatus.cancelling:
        return const _CenteredMessage(
          label: 'Cancelling request...',
          child: CircularProgressIndicator(color: Colors.white),
        );
      case SosStatus.cancelled:
        return const _CenteredMessage(
          icon: Icons.check_circle_outline_rounded,
          label: 'Request cancelled.',
        );
      case SosStatus.active:
        return _ActiveView(state: state, userId: widget.userId);
    }
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget? action;
  final Widget? child;

  const _CenteredMessage({this.icon, required this.label, this.action, this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child != null) child!,
            if (icon != null) Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
            if (action != null) ...[const SizedBox(height: AppSpacing.sm), action!],
          ],
        ),
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  final EmergencyState state;
  final String userId;
  const _ActiveView({required this.state, required this.userId});

  String _statusLabel(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.pending:
        return 'Finding help...';
      case EmergencyStatus.dispatched:
      case EmergencyStatus.enRoute:
        return 'Help is on the way';
      case EmergencyStatus.arrived:
        return 'Help has arrived';
      case EmergencyStatus.cancelled:
        return 'Request cancelled';
      case EmergencyStatus.failed:
        return 'Could not reach dispatch';
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = state.request;
    if (request == null) {
      return const _CenteredMessage(
        label: 'Loading...',
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    final isCancelling = state.sosStatus == SosStatus.cancelling;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Column(
        children: [
          Text(
            _statusLabel(request.status),
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.local_hospital_rounded, color: AppColors.emergencyRed, size: 40),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (request.etaMinutes != null)
            Text(
              'Estimated arrival  ·  ${request.etaMinutes} min',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold).copyWith(color: Colors.white),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (request.driverName != null) _DriverCard(request: request),
          const SizedBox(height: AppSpacing.md),
          _PartnerNotifiedCard(request: request),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.emergencyRed),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: isCancelling
                  ? null
                  : () => context.read<EmergencyBloc>().add(DispatchCancelRequested(userId)),
              child: isCancelling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emergencyRed),
                    )
                  : Text(
                      'Cancel request',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold).copyWith(color: AppColors.emergencyRed),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final EmergencyRequest request;
  const _DriverCard({required this.request});

  String get _initials {
    final name = request.driverName ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Future<void> _call(BuildContext context) async {
    final phone = request.driverPhone;
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the dialer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
            child: Text(_initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR DRIVER', style: AppTextStyles.caption),
                Text(request.driverName ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                if (request.vehiclePlate != null)
                  Text(request.vehiclePlate!, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (request.driverPhone != null)
            IconButton(
              onPressed: () => _call(context),
              icon: const Icon(Icons.call_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(backgroundColor: AppColors.teal, shape: const CircleBorder()),
            ),
        ],
      ),
    );
  }
}

class _PartnerNotifiedCard extends StatelessWidget {
  final EmergencyRequest request;
  const _PartnerNotifiedCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final notified = request.partnerNotifiedAt != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: const Color(0xFFE3F3E9), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(
            notified ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
            color: const Color(0xFF2E7D4F),
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              notified ? 'Your partner has been notified.' : 'Notifying your partner...',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
