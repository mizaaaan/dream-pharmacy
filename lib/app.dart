import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/router/app_router.dart';

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dream Pharmacy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0F9D58),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
