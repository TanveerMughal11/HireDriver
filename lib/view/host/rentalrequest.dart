import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/host/service.dart';

class HostRentalRequestScreen extends StatefulWidget {
  final String bookingId;

  const HostRentalRequestScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<HostRentalRequestScreen> createState() =>
      _HostRentalRequestScreenState();
}

class _HostRentalRequestScreenState extends State<HostRentalRequestScreen> {
  bool isLoading = true;
  String errorMessage = '';

  Map<String, dynamic>? request;

  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }
  Future<void> _acceptRequest() async {
  try {
    setState(() {
      isLoading = true;
    });

    final data = await RentalOwnerApi.acceptRentalRequest(
      widget.bookingId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          data['message'] ??
              'Rental request accepted successfully',
        ),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceAll('Exception: ', ''),
        ),
      ),
    );
  }
}
Future<void> _declineRequest() async {
  try {
    setState(() {
      isLoading = true;
    });

    final data = await RentalOwnerApi.declineRentalRequest(
      widget.bookingId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          data['message'] ??
              'Rental request declined successfully',
        ),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceAll('Exception: ', ''),
        ),
      ),
    );
  }
}
  Future<void> _loadRequestDetails() async {
    try {
      final data = await RentalOwnerApi.getOwnerRequestDetails(
        widget.bookingId,
      );

      setState(() {
        request = data['request'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';

    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}-${parsedDate.month}-${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final renter = request?['renter'] ?? {};
    final listing = request?['listing'] ?? {};
    final rentalPeriod = request?['rentalPeriod'] ?? {};
    final amount = request?['amount'] ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Rental Request',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _Card(
                        title: 'Renter Details',
                        children: [
                          _InfoRow(
                            Icons.person_rounded,
                            'Name',
                            renter['name'] ?? '-',
                          ),
                          _InfoRow(
                            Icons.phone_rounded,
                            'Phone',
                            renter['phone'] ?? '-',
                          ),
                          _InfoRow(
                            Icons.info_rounded,
                            'Status',
                            request?['status'] ?? '-',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _Card(
                        title: 'Car Details',
                        children: [
                          _InfoRow(
                            Icons.directions_car_rounded,
                            'Car',
                            listing['carName'] ?? '-',
                          ),
                          _InfoRow(
                            Icons.confirmation_number_rounded,
                            'Plate Number',
                            listing['plateNumber'] ?? '-',
                          ),
                          _InfoRow(
                            Icons.qr_code_rounded,
                            'Booking Code',
                            request?['bookingCode'] ?? '-',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _Card(
                        title: 'Rental Details',
                        children: [
                          _InfoRow(
                            Icons.date_range_rounded,
                            'Pickup Date',
                            _formatDate(rentalPeriod['pickupDate']),
                          ),
                          _InfoRow(
                            Icons.event_available_rounded,
                            'Return Date',
                            _formatDate(rentalPeriod['returnDate']),
                          ),
                          _InfoRow(
                            Icons.timelapse_rounded,
                            'Duration',
                            '${rentalPeriod['durationDays'] ?? 0} days',
                          ),
                          _InfoRow(
                            Icons.local_shipping_rounded,
                            'Pickup Method',
                            request?['pickupMethod'] ?? '-',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _Card(
                        title: 'Payment Details',
                        children: [
                          _InfoRow(
                            Icons.payments_rounded,
                            'Total Amount',
                            '${amount['currency'] ?? 'PKR'} ${amount['total'] ?? 0}',
                          ),
                          _InfoRow(
                            Icons.payment_rounded,
                            'Payment Status',
                            request?['paymentStatus'] ?? '-',
                          ),
                          _InfoRow(
                            Icons.security_rounded,
                            'Insurance',
                            request?['addInsurance'] == true ? 'Yes' : 'No',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(
                                  color: AppColors.secondary,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _declineRequest,
                              child: const Text(
                                'Decline',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                         onPressed: _acceptRequest,
                              child: const Text(
                                'Accept',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Card({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}