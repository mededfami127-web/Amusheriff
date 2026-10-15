import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_gate_providers.dart';
import 'admin_gate_sheet.dart';

/// Wraps a widget so five taps open the owner gate.
///
/// The logo is the handle: on the storefront home and on the gateway header,
/// tapping it five times within [window] opens the username/password panel. Four
/// taps are indistinguishable from a customer fidgeting with the badge, so the
/// customer experience is unchanged.
class AdminGateTaps extends ConsumerStatefulWidget {
  const AdminGateTaps({
    super.key,
    required this.child,
    this.window = const Duration(seconds: 3),
  });

  final Widget child;

  /// How long the taps stay "counting" before the streak resets.
  final Duration window;

  @override
  ConsumerState<AdminGateTaps> createState() => _AdminGateTapsState();
}

class _AdminGateTapsState extends ConsumerState<AdminGateTaps> {
  static const int _requiredTaps = 5;

  int _count = 0;
  DateTime? _firstTap;

  void _onTap() {
    final DateTime now = DateTime.now();
    if (_firstTap == null || now.difference(_firstTap!) > widget.window) {
      _firstTap = now;
      _count = 1;
    } else {
      _count++;
    }

    if (_count < _requiredTaps) return;
    _count = 0;
    _firstTap = null;

    // Already unlocked: skip the form and go straight to the gateway.
    showAdminGateSheet(
      context,
      alreadyUnlocked: ref.read(adminGateProvider).unlocked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: widget.child,
    );
  }
}
