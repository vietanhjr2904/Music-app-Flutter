import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/main_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List categories = [
    {"name": "Nhạc trẻ", "type": "nhactre"},
    {"name": "Rap Việt", "type": "rapviet"},
    {"name": "Trữ tình", "type": "trutinh"},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔍 SEARCH BOX
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  controller.searchSongs(value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Tìm bài hát, ca sĩ...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// 🎧 CATEGORY FILTER
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((c) {
                  final isSelected =
                      controller.selectedCategory == c['type'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        controller.loadCategory(c['type']);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            c['name'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            /// 🔄 LOADING
            if (controller.isSearching)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

            /// 🎵 RESULT
            else
              Expanded(
                child: ListView(
                  children: [
                    /// 🎵 SONGS
                    if (controller.searchedSongs.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Songs",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                    ...controller.searchedSongs
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      var song = entry.value;

                      return ListTile(
                        leading: Image.network(
                          song['thumbnail'] ??
                              song['cover'] ??
                              'https://picsum.photos/100',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          song['title'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          song['artist'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          controller.playSearchSong(index);
                        },
                      );
                    }).toList(),

                    /// 🎤 ARTISTS
                    if (controller.searchedArtists.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Artists",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                    ...controller.searchedArtists.map((artist) {
                      return ListTile(
                        leading: const Icon(Icons.person,
                            color: Colors.white),
                        title: Text(
                          artist['name'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}