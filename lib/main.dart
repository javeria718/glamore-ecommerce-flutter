import 'package:ecom_app/view/welcome/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Supabase.initialize(
//     url: SupabaseConfig.normalizedUrl(),
//     anonKey: SupabaseConfig.anonKey,
//   );
//   runApp(const ProviderScope(child: MyApp()));
// }
Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Load .env

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 242, 255, 0),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Application',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        primaryTextTheme:
            GoogleFonts.poppinsTextTheme(baseTheme.primaryTextTheme),
      ),
      home: const SplashPage(),
    );
  }
}
