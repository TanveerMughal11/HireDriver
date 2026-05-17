import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class RideReviewProvider extends ChangeNotifier {
  int selectedRating = 0;
  bool isDownloading = false;

  void selectRating(int value) {
    selectedRating = value;
    notifyListeners();
  }

  Future<bool> downloadReceipt({
    String trip = '0 km - 0 min',
    String rider = 'Accepted rider',
    String pickup = 'Pickup location',
    String dropoff = 'Destination',
    String totalPaid = '0',
  }) async {
    try {
      isDownloading = true;
      notifyListeners();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HireDrive Receipt',
                    style: pw.TextStyle(fontSize: 24),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Trip: $trip'),
                  pw.Text('Rider: $rider'),
                  pw.Text('Pickup: $pickup'),
                  pw.Text('Destination: $dropoff'),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Total Paid: PKR $totalPaid',
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Thank you for using HireDrive'),
                ],
              ),
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/receipt.pdf');

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      isDownloading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isDownloading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    selectedRating = 0;
    isDownloading = false;
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
