// class SupabaseConfig {
//   static const url = String.fromEnvironment(
//     'SUPABASE_URL',
//     defaultValue: '',
//   );

//   static const anonKey = String.fromEnvironment(
//     'SUPABASE_ANON_KEY',
//     defaultValue:
//         '',
//   );

//   static String normalizedUrl() {
//     var raw = url.trim();
//     if (raw.endsWith('/')) {
//       raw = raw.substring(0, raw.length - 1);
//     }
//     raw = raw.replaceAll(RegExp(r'/rest/v1$'), '');
//     raw = raw.replaceAll(RegExp(r'/auth/v1$'), '');
//     return raw;
//   }
// }
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String normalizedUrl() {
    var raw = url.trim();
    if (raw.endsWith('/')) {
      raw = raw.substring(0, raw.length - 1);
    }
    raw = raw.replaceAll(RegExp(r'/rest/v1$'), '');
    raw = raw.replaceAll(RegExp(r'/auth/v1$'), '');
    return raw;
  }
}
