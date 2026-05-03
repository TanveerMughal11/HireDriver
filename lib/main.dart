import 'package:flutter/material.dart';
import 'package:hire_driver/view/book%20a%20ride/provider/drivercomingtoyou.dart';
import 'package:hire_driver/view/book%20a%20ride/provider/drivertraling.dart';
import 'package:hire_driver/view/book%20a%20ride/provider/offerrider.dart';
import 'package:hire_driver/view/book%20a%20ride/provider/riderating.dart';
import 'package:hire_driver/view/forms/provider/applyasrider.dart';
import 'package:provider/provider.dart';

import 'package:hire_driver/utils/theme_color_controller.dart';
import 'package:hire_driver/view/splashscreen.dart';
import 'package:hire_driver/utils/app_colors.dart';

import 'package:hire_driver/view/book a ride/provider/set_price.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SetPriceProvider()),
        ChangeNotifierProvider(create: (_) => DriverComingProvider()),
              ChangeNotifierProvider(create: (_) => ApplyAsRiderProvider()),
         ChangeNotifierProvider(create: (_) => RideReviewProvider()),
        ChangeNotifierProvider(create: (_) => OngoingRideProvider()),
        ChangeNotifierProvider(create: (_) => DriverOffersProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          themeMode: themeController.themeMode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}