import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../controllers/main_controller.dart';
import '../../models/loading_enum.dart';
import '../../utils/horizontal_songs_list.dart';
import '../../utils/recent_users.dart';
import 'cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  final MainController con;

  const HomeScreen({
    Key? key,
    required this.con,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeCubit _homeCubit = HomeCubit();

  Timer? _networkTimer;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _homeCubit.getUsers();
    _startNetworkWatcher();
  }

  void _startNetworkWatcher() {
    _networkTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final hasInternet = await _hasInternet();

      if (!mounted) return;

      if (!hasInternet && !_wasOffline) {
        _wasOffline = true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Mất kết nối mạng. Vui lòng kiểm tra Internet.',
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(days: 1),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () async {
                final online = await _hasInternet();

                if (!mounted) return;

                if (online) {
                  _wasOffline = false;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _homeCubit.getUsers();
                }
              },
            ),
          ),
        );
      }

      if (hasInternet && _wasOffline) {
        _wasOffline = false;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã kết nối mạng trở lại.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        _homeCubit.getUsers();
      }
    });
  }

  Future<bool> _hasInternet() async {
    if (kIsWeb) return true;

    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  List<T> safeSlice<T>(List<T> list, int start, [int? end]) {
    if (list.isEmpty || start >= list.length) return <T>[];
    final s = start < 0 ? 0 : start;
    final e = end == null ? list.length : (end > list.length ? list.length : end);
    if (e <= s) return <T>[];
    return list.sublist(s, e);
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == LoadPage.loading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            );
          }

          if (state.status == LoadPage.loaded) {
            return Scaffold(
              body: ListView(
                padding: const EdgeInsets.only(top: 0, bottom: 120),
                children: [
                  if (kIsWeb)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.fromLTRB(12, 40, 12, 0),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        border: Border.all(color: Colors.amber, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '⚠️ Chế độ Web demo: trình duyệt chặn YouTube (CORS) '
                            'nên audio đang dùng nhạc placeholder. '
                            'Chạy trên Android để nghe nhạc Việt thật.',
                        style: TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),

                  RecentUsers(
                    con: widget.con,
                    users: safeSlice(state.users, 0, 6),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      "Popular Hits",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  HorizontalSongList(
                    con: widget.con,
                    songs: safeSlice(state.songs, 0, 10),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      "Best Picks For You",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  HorizontalArtistList(
                    con: widget.con,
                    users: safeSlice(state.users, 6, 16),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      "New Releases",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  HorizontalSongList(
                    con: widget.con,
                    songs: safeSlice(state.songs, 10, 20),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      "You might also like",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  HorizontalArtistList(
                    con: widget.con,
                    users: safeSlice(state.users, 16),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          }

          if (state.status == LoadPage.error) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.redAccent,
                        size: 56,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Kết nối mạng không ổn định',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vui lòng kiểm tra Internet rồi thử lại.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _homeCubit.getUsers();
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
