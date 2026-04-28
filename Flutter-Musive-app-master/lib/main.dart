import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify_clone/screens/auth/auth_service.dart';
import 'package:spotify_clone/screens/auth/login_screen.dart';
import 'package:spotify_clone/screens/bottom_nav_bar/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
  }
  await Hive.openBox('liked');
  await Hive.openBox('Recentsearch');
  await Hive.openBox('RecentlyPlayed');
  await Hive.openBox('playlists');
  await Hive.openBox('users');
  await Hive.openBox('session');
  await Hive.openBox('spotifyCache');
  await Hive.openBox('ytCache');
  await Hive.openBox('appMeta');
  await _migrateStaleData();
  runApp(const MyApp());
}

/// Drop pre-YouTube cached entries (SoundHelix URLs whose titles were Vietnamese
/// from mock_data.dart) so users don't see "Sơn Tùng" but hear electronic music.
Future<void> _migrateStaleData() async {
  const migrationKey = 'migration_yt_v2';
  final meta = Hive.box('appMeta');
  if (meta.get(migrationKey) == true) return;

  final boxes = ['RecentlyPlayed', 'liked', 'playlists', 'Recentsearch'];
  for (final name in boxes) {
    final box = Hive.box(name);
    final keysToRemove = <dynamic>[];
    for (final k in box.keys) {
      final v = box.get(k);
      if (v is Map && v['track'] is String) {
        final track = v['track'] as String;
        if (track.contains('soundhelix.com')) {
          keysToRemove.add(k);
        }
      }
    }
    for (final k in keysToRemove) {
      await box.delete(k);
    }
  }
  await Hive.box('ytCache').clear();
  await Hive.box('spotifyCache').clear();
  await meta.put(migrationKey, true);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musive Việt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Proxima',
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
        highlightColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.black,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        progressIndicatorTheme: ProgressIndicatorThemeData(
          circularTrackColor: Colors.greenAccent[700],
          color: Colors.greenAccent[400],
          linearMinHeight: 10,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Proxima Bold',
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        return MediaQuery(
          child: ScrollConfiguration(
            behavior: NoGlowBehavior(),
            child: child!,
          ),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      home: AuthService.isLoggedIn() ? const App() : const LoginScreen(),
    );
  }
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
