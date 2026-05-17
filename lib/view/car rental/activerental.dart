import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/carrentalreview.dart';

class ActiveRentalScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const ActiveRentalScreen({super.key, required this.booking});

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(rawDate).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  String _firstString(List<dynamic> values, String fallback) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return fallback;
  }

  Map<String, dynamic> get listing {
    return _asMap(booking['listing'] ?? booking['car'] ?? booking['vehicle']);
  }

  Map<String, dynamic> get carInfo {
    return _asMap(listing['carInfo'] ?? booking['carInfo'] ?? listing);
  }

  String get carName {
    final explicitName = _firstString(
      [
        carInfo['name'],
        carInfo['title'],
        booking['carName'],
        listing['title'],
      ],
      '',
    );
    if (explicitName.isNotEmpty) return explicitName;

    final name =
        '${carInfo['make'] ?? carInfo['brand'] ?? ''} ${carInfo['model'] ?? ''}'
            .trim();
    return name.isEmpty ? 'Rental Car' : name;
  }

  String get hostName {
    final host = _asMap(booking['host'] ?? booking['owner']);
    return _firstString([host['name'], host['fullName'], host['userName']], 'Host');
  }

  String get returnDate {
    return _formatDate(
      _firstString(
        [booking['returnDate'], booking['endDate'], booking['dropoffDate']],
        '',
      ),
    );
  }

  String get bookingCode {
    return _firstString([booking['bookingCode'], booking['code']], 'N/A');
  }

  String get totalAmount {
    final pricing = _asMap(booking['pricing']);
    return _firstString(
      [pricing['totalAmount'], booking['totalAmount'], booking['totalPrice']],
      '0',
    );
  }

  int get daysLeft {
    try {
      final rawDate = _firstString(
        [booking['returnDate'], booking['endDate'], booking['dropoffDate']],
        '',
      );
      final date = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      final diff = date.difference(now).inDays;
      return diff < 0 ? 0 : diff;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _showIssueDialog(BuildContext context) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Report Issue'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe the issue with this active rental',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      controller.text.trim().isEmpty
                          ? 'Issue reported successfully'
                          : 'Issue reported: ${controller.text.trim()}',
                    ),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text1(context)),
        title: Text(
          'Active Rental',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.darkPrimary],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rental Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$daysLeft days left until return',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: daysLeft <= 0 ? 1 : 0.55,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Car Details',
              children: [
                _InfoRow(
                  icon: Icons.directions_car_rounded,
                  title: 'Car',
                  value: carName,
                ),
                _InfoRow(
                  icon: Icons.confirmation_number_rounded,
                  title: 'Booking Code',
                  value: bookingCode,
                ),
                _InfoRow(
                  icon: Icons.date_range_rounded,
                  title: 'Return Date',
                  value: returnDate,
                ),
                _InfoRow(
                  icon: Icons.payments_rounded,
                  title: 'Amount',
                  value: 'Rs. $totalAmount',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Host Contact',
              children: [
                _InfoRow(
                  icon: Icons.person_rounded,
                  title: 'Host',
                  value: hostName,
                ),
                const _InfoRow(
                  icon: Icons.phone_rounded,
                  title: 'Contact',
                  value: 'Call Host',
                ),
                const _InfoRow(
                  icon: Icons.chat_rounded,
                  title: 'Message',
                  value: 'Message Host',
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReturnReviewScreen(booking: booking),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_turned_in_rounded),
              label: const Text(
                'Confirm Return',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: AppColors.card(context),
                side: const BorderSide(color: Color(0xFFFFB6B6)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _showIssueDialog(context),
              icon: const Icon(Icons.report_problem_rounded),
              label: const Text(
                'Report Issue',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
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

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

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
              style: TextStyle(
                color: AppColors.text1(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.text2(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
