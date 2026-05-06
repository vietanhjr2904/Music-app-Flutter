import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/main_controller.dart';
import '../../methods/string_methods.dart';
import '../../models/catagory.dart';
import '../genre_page/genre_page.dart';
import '../search_results/search_result.dart';

class SearchPage extends StatelessWidget {
  final MainController con;

  const SearchPage({
    Key? key,
    required this.con,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allTags = tags.map((e) => TagsModel.fromJson(e)).toList();

    return Consumer<MainController>(
      builder: (context, con, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),

                    /// TITLE
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "Search",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontSize: 36),
                        ),
                      ),
                    ),

                    /// 🔥 FILTER DROPDOWN
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          /// GENRE
                          Expanded(
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: con.genres.contains(con.selectedGenre)
                                    ? con.selectedGenre
                                    : 'All',
                                dropdownColor: Colors.black,
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: const TextStyle(color: Colors.white),
                                items: con.genres.map((genre) {
                                  return DropdownMenuItem(
                                    value: genre,
                                    child: Text(genre),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    con.setGenre(value);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// ARTIST
                          Expanded(
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: con.artists.contains(con.selectedArtist)
                                    ? con.selectedArtist
                                    : 'All',
                                dropdownColor: Colors.black,
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: const TextStyle(color: Colors.white),
                                items: con.artists.map((artist) {
                                  return DropdownMenuItem(
                                    value: artist,
                                    child: Text(artist),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    con.setArtist(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 10)),

                    /// SEARCH BAR
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverSearchAppBar(con: con),
                    ),
                  ];
                },

                /// BODY
                body: ListView(
                  children: [
                    /// TOP GENRE
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Text(
                        "Your Top genre",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 18),
                      ),
                    ),

                    GridView.builder(
                      itemCount: allTags.sublist(0, 4).length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 16 / 8,
                      ),
                      itemBuilder: (context, i) {
                        return TagWidget(
                            tag: allTags.sublist(0, 4)[i], con: con);
                      },
                    ),

                    /// BROWSE ALL
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        "Browse all",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 18),
                      ),
                    ),

                    GridView.builder(
                      itemCount: allTags.sublist(4).length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 16 / 8,
                      ),
                      itemBuilder: (context, i) {
                        return TagWidget(
                            tag: allTags.sublist(4)[i], con: con);
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ================= TAG =================
class TagWidget extends StatelessWidget {
  final TagsModel tag;
  final MainController con;

  const TagWidget({
    Key? key,
    required this.tag,
    required this.con,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => GenrePage(tag: tag, con: con),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
            color: tag.color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 5,
                right: -15,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(385 / 360),
                  child: CachedNetworkImage(
                    imageUrl: tag.image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  tag.tag.toTitleCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= SEARCH BAR =================
class SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  final MainController con;

  SliverSearchAppBar({required this.con});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SearchResultsPage(con: con),
          ),
        );
      },
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Icon(CupertinoIcons.search),
              const SizedBox(width: 10),
              Text(
                "Songs, Artists or Genres",
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}