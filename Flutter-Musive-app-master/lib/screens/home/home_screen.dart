import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/main_controller.dart';
import '../../models/loading_enum.dart';
import '../../utils/horizontal_songs_list.dart';

import '../../utils/recent_users.dart';
import 'cubit/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  final MainController con;
  const HomeScreen({
    Key? key,
    required this.con,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..getUsers(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == LoadPage.loading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state.status == LoadPage.loaded) {
            List<T> safeSlice<T>(List<T> list, int start, [int? end]) {
              if (list.isEmpty || start >= list.length) return <T>[];
              final s = start < 0 ? 0 : start;
              final e = end == null
                  ? list.length
                  : (end > list.length ? list.length : end);
              if (e <= s) return <T>[];
              return list.sublist(s, e);
            }

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
                    con: con,
                    users: safeSlice(state.users, 0, 6),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      "Popular Hits",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  HorizontalSongList(
                      con: con, songs: safeSlice(state.songs, 0, 10)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      "Best Picks For You",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  HorizontalArtistList(
                      con: con, users: safeSlice(state.users, 6, 16)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      "New Releases",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  HorizontalSongList(
                      con: con, songs: safeSlice(state.songs, 10, 20)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      "You might also like",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  HorizontalArtistList(
                      con: con, users: safeSlice(state.users, 16)),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }
          if (state.status == LoadPage.error) {
            return const Scaffold(
              body: Center(
                child: Text(
                  "Error",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}
