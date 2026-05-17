import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/hiredriver/services/hiredriver.dart';

import 'package:hire_driver/view/hiredriver/provider/waitingdriveracceptance.dart';
import 'package:provider/provider.dart';

class AwaitingDriverAcceptanceScreen extends StatelessWidget {
  final Map<String, dynamic> waitingState;
  final Map<String, dynamic> hireRequest;

  const AwaitingDriverAcceptanceScreen({
    super.key,
    required this.waitingState,
    required this.hireRequest,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AwaitingDriverProvider(),
      child: _AwaitingDriverAcceptanceBody(
        waitingState: waitingState,
        hireRequest: hireRequest,
      ),
    );
  }
}

class _AwaitingDriverAcceptanceBody extends StatefulWidget {
  final Map<String, dynamic> waitingState;
  final Map<String, dynamic> hireRequest;

  const _AwaitingDriverAcceptanceBody({
    required this.waitingState,
    required this.hireRequest,
  });

  @override
  State<_AwaitingDriverAcceptanceBody> createState() =>
      _AwaitingDriverAcceptanceBodyState();
}

class _AwaitingDriverAcceptanceBodyState
    extends State<_AwaitingDriverAcceptanceBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _statusPollTimer;
  bool dialogShown = false;
  bool _acceptanceNotified = false;
  Map<String, dynamic> _liveHireRequest = {};
  Map<String, dynamic> _liveWaitingState = {};

  Map<String, dynamic> get selectedDriver =>
      _liveHireRequest['selectedDriver'] ?? {};

  String get currentStatus => _liveHireRequest['status']?.toString() ?? '';

  String get hireRequestId =>
      _liveHireRequest['id']?.toString() ??
      _liveHireRequest['_id']?.toString() ??
      _liveHireRequest['hireRequestId']?.toString() ??
      '';

  Map<String, dynamic> get pickup => _liveHireRequest['pickup'] ?? {};

  Map<String, dynamic> get dropoff => _liveHireRequest['dropoff'] ?? {};

  Map<String, dynamic> get vehicle => _liveHireRequest['userVehicle'] ?? {};

  @override
  void initState() {
    super.initState();

    _liveHireRequest = Map<String, dynamic>.from(widget.hireRequest);
    _liveWaitingState = Map<String, dynamic>.from(widget.waitingState);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final seconds = _liveWaitingState['secondsRemaining'] ?? 60;

      context.read<AwaitingDriverProvider>().startCountdown(seconds);
      _refreshRequestStatus(showToast: false);
      _startStatusPolling();
    });
  }

  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshRequestStatus(showToast: false);
    });
  }

  Future<void> _refreshRequestStatus({required bool showToast}) async {
    if (hireRequestId.isEmpty) {
      if (showToast && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request ID missing. Please go back and try again.'),
          ),
        );
      }
      return;
    }

    try {
      final data = await HireDriverApiService.getHireDriverRequest(
        hireRequestId: hireRequestId,
      );

      final latestHireRequest = Map<String, dynamic>.from(
        data['hireRequest'] ?? {},
      );

      if (!mounted) return;

      setState(() {
        _liveHireRequest = latestHireRequest;
      });

      final deadline = latestHireRequest['driverAcceptanceDeadline']
          ?.toString();
      if (deadline != null && deadline.isNotEmpty) {
        final parsed = DateTime.tryParse(deadline);
        if (parsed != null) {
          final seconds = parsed.difference(DateTime.now()).inSeconds;
          context.read<AwaitingDriverProvider>().syncRemainingSeconds(seconds);
          setState(() {
            _liveWaitingState['secondsRemaining'] = seconds < 0 ? 0 : seconds;
          });
        }
      }

      setState(() {
        if (currentStatus == 'confirmed') {
          _liveWaitingState['statusText'] = 'Driver accepted your request';
        } else if (currentStatus == 'awaiting_driver_acceptance') {
          _liveWaitingState['statusText'] = 'Waiting for driver response...';
        }
      });

      if (currentStatus == 'confirmed' && selectedDriver.isNotEmpty) {
        _statusPollTimer?.cancel();
        context.read<AwaitingDriverProvider>().cancelTimer();
        if (!_acceptanceNotified) {
          _acceptanceNotified = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${selectedDriver['driverName'] ?? 'Driver'} accepted your request',
                ),
              ),
            );
          }
        }
      }

      if (showToast && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver response refreshed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (showToast) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _cancelRequest() {
    context.read<AwaitingDriverProvider>().cancelTimer();
    Navigator.pop(context);
  }

  void _showNoResponseDialog() {
    if (dialogShown) return;

    dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.card(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'No Response',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.text1(context),
            ),
          ),
          content: Text(
            'Driver did not respond in time. Please try another driver.',
            style: TextStyle(color: AppColors.text2(context), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    context.read<AwaitingDriverProvider>().cancelTimer();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AwaitingDriverProvider>(
      builder: (context, provider, _) {
        if (provider.isTimeFinished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showNoResponseDialog();
          });
        }

        return Scaffold(
          backgroundColor: AppColors.bg(context),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildWaitingAnimation(),
                        const SizedBox(height: 24),
                        _buildStatusCard(provider),
                        const SizedBox(height: 18),
                        _buildDriverInfoCard(),
                        const SizedBox(height: 18),
                        _buildTripSummaryCard(),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _cancelRequest,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.card(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: Color(0xFFFFB6B6)),
                          ),
                        ),
                        child: const Text(
                          'Cancel Request',
                          style: TextStyle(
                            color: Color(0xFFFF4B4B),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: _cancelRequest,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.text1(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Awaiting Driver Acceptance',
              style: TextStyle(
                color: AppColors.text1(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _refreshRequestStatus(showToast: true),
            tooltip: 'Refresh status',
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.text1(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingAnimation() {
    final driverName =
        selectedDriver['driverName'] ??
        _liveWaitingState['driverName'] ??
        'Driver';

    return Column(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final scale = 1 + (_animationController.value * 0.12);

            return Transform.scale(
              scale: scale,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softBg(context),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          currentStatus == 'confirmed'
              ? 'Driver accepted your request'
              : (_liveWaitingState['statusText'] ??
                    'Waiting for driver response...'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text1(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your request has been sent to $driverName',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text2(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(AwaitingDriverProvider provider) {
    final totalSeconds = _liveWaitingState['secondsRemaining'] ?? 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            provider.formatTimer(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentStatus == 'confirmed'
                ? 'Your driver has accepted. You are confirmed.'
                : 'Driver has $totalSeconds seconds to accept your booking',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text2(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: totalSeconds == 0
                  ? 0
                  : provider.remainingSeconds / totalSeconds,
              backgroundColor: AppColors.secondary.withOpacity(0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _refreshRequestStatus(showToast: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF5B8A), Color(0xFFFF8A50)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              selectedDriver['avatarInitial'] ?? 'D',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedDriver['driverName'] ?? 'Driver',
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CNIC Verified · ${selectedDriver['tripsCompleted'] ?? 0} trips',
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedDriver['vehicleMakeModel'] ?? ''} · ${selectedDriver['vehiclePlate'] ?? ''}',
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFFFB020),
                ),
                const SizedBox(width: 4),
                Text(
                  '${selectedDriver['rating'] ?? 0}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.primary,
            label: 'Pickup',
            value: pickup['address'] ?? 'Pickup',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.flag_rounded,
            iconColor: const Color(0xFFFF7A30),
            label: 'Drop-off',
            value: dropoff['address'] ?? 'Drop-off',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF8E7CF7),
            label: 'Time',
            value: _liveHireRequest['scheduledTime'] ?? '--:--',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF4B8DFF),
            label: 'Vehicle',
            value: vehicle['makeModel'] ?? 'Vehicle',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.text2(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
