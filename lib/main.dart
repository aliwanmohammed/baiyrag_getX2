import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import 'app/bindings/app_bindings.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'app/localization/language_controller.dart';
import 'features/auth/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Build the GetX dependency graph once before the application starts.
  AppBindings().dependencies();

  final auth = Get.find<AuthController>();
  final router = AppRouter.create(auth);

  runApp(
    MyApp(
      router: router,
    ),
  );

  // Restore the session without blocking the first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    auth.initSession();
  });
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (theme) {
        return GetBuilder<LanguageController>(
          builder: (language) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'البيرق هايبر ماركت',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: theme.mode,
              routerConfig: router,
              locale: language.locale,
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                return Directionality(
                  textDirection: language.isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }
}
