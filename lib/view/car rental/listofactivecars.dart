import 'package:flutter/material.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/car%20rental/activerental.dart';

class ActiveRentalsListScreen extends StatelessWidget {
  const ActiveRentalsListScreen({super.key});

  List<Map<String, dynamic>> get activeBookings => [
        {
          "bookingCode": "HDR-1021",
          "returnDate": "2026-05-18",
          "host": {
            "name": "Ali Raza",
          },
          "pricing": {
            "totalAmount": 12000,
          },
          "listing": {
            "carInfo": {
              "make": "Toyota",
              "model": "Corolla",
            }
          }
        },
        {
          "bookingCode": "HDR-2045",
          "returnDate": "2026-05-21",
          "host": {
            "name": "Usman Khan",
          },
          "pricing": {
            "totalAmount": 18500,
          },
          "listing": {
            "carInfo": {
              "make": "Honda",
              "model": "Civic",
            }
          }
        },
        {
          "bookingCode": "HDR-3321",
          "returnDate": "2026-05-26",
          "host": {
            "name": "Ahmed",
          },
          "pricing": {
            "totalAmount": 24000,
          },
          "listing": {
            "carInfo": {
              "make": "KIA",
              "model": "Sportage",
            }
          }
        },
      ];

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        title: Text(
          'Active Rentals',
          style: TextStyle(
            color: AppColors.text1(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.text1(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: activeBookings.length,
        itemBuilder: (context, index) {
          final booking = activeBookings[index];

          final listing = booking['listing'] ?? {};
          final carInfo = listing['carInfo'] ?? {};

          final carName =
              '${carInfo['make'] ?? ''} ${carInfo['model'] ?? ''}'
                  .trim();

          final returnDate =
              _formatDate(booking['returnDate'].toString());

          final amount =
              booking['pricing']?['totalAmount'] ?? 0;

          final host =
              booking['host']?['name'] ?? 'Host';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveRentalScreen(
                      booking: booking,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        AppColors.secondary.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.primary.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 68,
                      width: 68,
                      decoration: BoxDecoration(
                        color: AppColors.softBg(context),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            carName.isEmpty
                                ? 'Rental Car'
                                : carName,
                            style: TextStyle(
                              color:
                                  AppColors.text1(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Host: $host',
                            style: TextStyle(
                              color:
                                  AppColors.text2(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Return: $returnDate',
                            style: TextStyle(
                              color:
                                  AppColors.text2(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. $amount',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green
                                .withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}