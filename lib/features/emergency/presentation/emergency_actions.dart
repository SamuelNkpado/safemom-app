import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safemom/core/constants/app_colors.dart';
import 'package:safemom/core/theme/app_text_styles.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_bloc.dart';

import 'pages/emergency_dispatch_page.dart';

Future<void> launchEmergencySos(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Send SOS alert?', style: AppTextStyles.h3),
      content: Text(
        'This immediately notifies your emergency contacts and nearest '
        'clinic with your location. Only confirm if you need urgent help.',
        style: AppTextStyles.body,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Send Alert',
            style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final user = context.read<AuthBloc>().state.user;
  if (user == null) return;

  if (user.selectedClinicId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add a clinic in your profile before requesting emergency help.')),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
  );

  final position = await _getCurrentPosition();

  if (context.mounted) Navigator.pop(context);

  if (position == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turn on location access to send an SOS alert.')),
      );
    }
    return;
  }

  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyDispatchPage(
          userId: user.userId,
          clinicId: user.selectedClinicId!,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ),
    );
  }
}

Future<Position?> _getCurrentPosition() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  } catch (_) {
    return null;
  }
}
