// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'core/theme/app_theme.dart';

/// The root widget of the app. It reads the [goRouterProvider] which
/// contains the authentication‑aware routing configuration.
class AerogreenApp extends ConsumerWidget {
  const AerogreenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aerogreen',
      theme: AppTheme.lightTheme,
      builder: (context, child) => DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/aerogreen_foliage_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: router,
    );
  }
}
