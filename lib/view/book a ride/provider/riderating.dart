import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class RideReviewProvider extends ChangeNotifier {
  int selectedRating = 0;
  bool isDownloading = false;

  void selectRating(int value) {
    selectedRating = value;
    notifyListeners();
  }

  Future<bool> downloadReceipt() async {
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
                    "HireDrive Receipt",
                    style: pw.TextStyle(fontSize: 24),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text("Trip: 12 km · 28 min"),
                  pw.Text("Driver: Zain Ul Abideen"),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Total Paid: PKR 350",
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text("Thank you for using HireDrive"),
                ],
              ),
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/receipt.pdf");

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
}