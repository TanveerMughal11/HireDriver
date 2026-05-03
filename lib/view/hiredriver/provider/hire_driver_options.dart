import 'package:flutter/material.dart';
import 'package:hire_driver/view/hiredriver/models/hire_driver_options.dart';
import 'package:hire_driver/view/hiredriver/services/hiredriver.dart';

class HireDriverTypeProvider extends ChangeNotifier {
  bool isLoading = false;
  bool hasLoaded = false;
  String errorMessage = '';

  List<HireDriverOptionModel> options = [];
  HireDriverOptionModel? selectedOption;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadOptions() async {
    if (isLoading || hasLoaded) return;

    isLoading = true;
    errorMessage = '';
    _safeNotify();

    try {
      final data = await HireDriverApiService.getOptions();

      if (_disposed) return;

      final rawOptions = data['options'];

      options = rawOptions is List
          ? rawOptions
              .map(
                (e) => HireDriverOptionModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : [];

      selectedOption = options.isNotEmpty ? options.first : null;
      hasLoaded = true;
    } catch (e) {
      if (_disposed) return;
      errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    if (_disposed) return;

    isLoading = false;
    _safeNotify();
  }

  void selectOption(HireDriverOptionModel option) {
    selectedOption = option;
    _safeNotify();
  }
}