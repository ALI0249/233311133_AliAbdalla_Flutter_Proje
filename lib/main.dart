import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'core/theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MuzemApp());
}

class MuzemApp extends StatelessWidget {
  const MuzemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Müzem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
