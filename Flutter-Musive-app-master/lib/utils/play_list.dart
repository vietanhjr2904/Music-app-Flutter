import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/main_controller.dart';
import 'loading.dart';

class PlayListWidget extends StatefulWidget {
  final MainController con;
  final List<Audio> audios;

  const PlayListWidget({
    Key? key,
    required this.con,
    required this.audios,
  }) : super(key: key);

  @override
  State<PlayListWidget> createState() => _PlayListWidgetState();
}

class _PlayListWidgetState extends State<PlayListWidget> {
  Audio findSong(title) {
    final currentlyPlayingAudio = widget.con.findByname(widget.audios, title);

    return currentlyPlayingAudio;
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Playlist",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Builder(
          builder: (context) {
            final currentlyPlayingAudio = widget.con.findByname(
              widget.audios,
              widget.con.player.getCurrentAudioTitle,
            );

            int indexOfCurrentAudio =
                widget.audios.indexOf(currentlyPlayingAudio);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PLAYING NOW TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Text(
                    "Playing Now",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 18),
                  ),
                ),

                /// CURRENT SONG
                InkWell(
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: CachedNetworkImage(
                              imageUrl: widget.audios[indexOfCurrentAudio].metas
                                  .image!.path,
                              width: 50,
                              height: 50,
                              memCacheHeight: (50 * devicePixelRatio).round(),
                              memCacheWidth: (50 * devicePixelRatio).round(),
                              maxHeightDiskCache:
                                  (50 * devicePixelRatio).round(),
                              maxWidthDiskCache:
                                  (50 * devicePixelRatio).round(),
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      const LoadingImage(),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.audios[indexOfCurrentAudio].metas
                                            .title ??
                                        '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.lightGreen[700],
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.audios[indexOfCurrentAudio].metas
                                            .artist ??
                                        '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// NEXT SONG TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Text(
                    "Next Songs",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 18),
                  ),
                ),

                /// FIX OVERFLOW HERE
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount:
                        widget.audios.sublist(indexOfCurrentAudio + 1).length,
                    onReorder: (int oldIndex, int newIndex) async {
                      final index =
                          newIndex > oldIndex ? newIndex - 1 : newIndex;

                      setState(() {
                        widget.audios.insert(
                          indexOfCurrentAudio + 1 + index,
                          widget.audios.removeAt(
                            indexOfCurrentAudio + 1 + oldIndex,
                          ),
                        );
                      });
                    },
                    itemBuilder: (context, i) {
                      final newAudio =
                          widget.audios.sublist(indexOfCurrentAudio + 1)[i];

                      return InkWell(
                        key: ValueKey(newAudio),
                        onTap: () async {
                          await widget.con.player.playlistPlayAtIndex(
                            widget.audios.indexOf(
                              findSong(newAudio.metas.title),
                            ),
                          );

                          setState(() {});
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: CachedNetworkImage(
                                    imageUrl: newAudio.metas.image!.path,
                                    width: 50,
                                    height: 50,
                                    memCacheHeight:
                                        (50 * devicePixelRatio).round(),
                                    memCacheWidth:
                                        (50 * devicePixelRatio).round(),
                                    progressIndicatorBuilder:
                                        (context, url, progress) =>
                                            const LoadingImage(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          newAudio.metas.title ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          newAudio.metas.artist ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                color: Colors.grey,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.line_horizontal_3,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
