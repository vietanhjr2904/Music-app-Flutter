import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:spotify_clone/controllers/main_controller.dart';
import 'package:spotify_clone/screens/auth/auth_service.dart';
import 'package:spotify_clone/screens/auth/login_screen.dart';
import 'package:spotify_clone/screens/bottom_nav_bar/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// INIT HIVE
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
  }

  /// OPEN BOXES
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MainController()..init(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// MIGRATE (giữ nguyên)
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

  Future<bool> _checkLogin() async {
    return await AuthService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musive Việt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Proxima',
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return const App();
          } else {
            return const LoginScreen();
          }
        },
      ),
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
