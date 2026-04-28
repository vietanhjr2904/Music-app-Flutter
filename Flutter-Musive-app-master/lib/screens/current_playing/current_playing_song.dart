import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotify_clone/controllers/main_controller.dart';
import 'package:spotify_clone/models/song_model.dart';
import 'package:spotify_clone/utils/botttom_sheet_widget.dart';
import 'package:spotify_clone/utils/like_button/like_button.dart';
import 'package:spotify_clone/utils/loading.dart';
import 'package:spotify_clone/utils/play_list.dart';
import 'package:spotify_clone/utils/player/playing_controls.dart';
import 'package:spotify_clone/utils/player/position_seek_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class CurrentPlayingSong extends StatelessWidget {
  final MainController con;

  const CurrentPlayingSong({
    Key? key,
    required this.con,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Container(
      child: con.player.builderCurrent(
        builder: (context, playing) {
          if (playing == null) {
            return Container();
          }

          final myAudio = con.find(con.audios, playing.audio.assetAudioPath);

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// HEADER
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Text(
                                            "NOW PLAYING",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            myAudio.metas.artist ?? '',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        useRootNavigator: true,
                                        isScrollControlled: true,
                                        elevation: 100,
                                        backgroundColor: Colors.black38,
                                        context: context,
                                        builder: (context) {
                                          return BottomSheetWidget(
                                            con: con,
                                            isNext: true,
                                            song: SongModel(
                                              songid: myAudio.metas.id,
                                              songname: myAudio.metas.title,
                                              userid: myAudio.metas.album,
                                              trackid: myAudio.path,
                                              duration: '',
                                              coverImageUrl:
                                                  myAudio.metas.image!.path,
                                              name: myAudio.metas.artist,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// COVER IMAGE
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 26),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: CachedNetworkImage(
                                    imageUrl: myAudio.metas.image!.path,
                                    memCacheHeight:
                                        (250 * devicePixelRatio).round(),
                                    memCacheWidth:
                                        (250 * devicePixelRatio).round(),
                                    maxHeightDiskCache:
                                        (250 * devicePixelRatio).round(),
                                    maxWidthDiskCache:
                                        (250 * devicePixelRatio).round(),
                                    progressIndicatorBuilder:
                                        (context, url, progress) =>
                                            const LoadingImage(
                                      icon: Icon(
                                        LineIcons.compactDisc,
                                        size: 120,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// TITLE + LIKE
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          myAudio.metas.title ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          myAudio.metas.artist ?? '',
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
                                LikeButton(
                                  name: myAudio.metas.title ?? '',
                                  fullname: myAudio.metas.artist ?? '',
                                  username: myAudio.metas.album ?? '',
                                  id: myAudio.metas.id ?? '',
                                  track: myAudio.path,
                                  isIcon: false,
                                  cover: myAudio.metas.image!.path,
                                ),
                                const SizedBox(width: 24),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// SEEK BAR
                            con.player.builderRealtimePlayingInfos(
                              builder: (context, RealtimePlayingInfos? infos) {
                                if (infos == null) {
                                  return const SizedBox();
                                }

                                return PositionSeekWidget(
                                  currentPosition: infos.currentPosition,
                                  duration: infos.duration,
                                  seekTo: (to) {
                                    con.player.seek(to);
                                    con.webSeek(to);
                                  },
                                );
                              },
                            ),

                            /// PLAYER CONTROLS
                            con.player.builderLoopMode(
                              builder: (context, loopMode) {
                                return PlayerBuilder.isPlaying(
                                  player: con.player,
                                  builder: (context, isPlaying) {
                                    return PlayingControls(
                                      loopMode: loopMode,
                                      isPlaying: isPlaying,
                                      con: con,
                                      isPlaylist: true,
                                      onStop: () {
                                        con.player.stop();
                                      },
                                      toggleLoop: () {
                                        con.player.toggleLoop();
                                      },
                                      onPlay: () {
                                        con.player.playOrPause();
                                        con.webPlayPause();
                                      },
                                      onNext: () {
                                        con.webNext();
                                        con.player.next();
                                      },
                                      onPrevious: () {
                                        con.webPrevious();
                                        con.player.previous();
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            /// ACTION BUTTONS
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 26),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final uri = Uri.parse(myAudio.path);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.download_sharp,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Share.share(
                                        'Nghe "${myAudio.metas.title}" của ${myAudio.metas.artist} trên Musive Việt: ${myAudio.path}',
                                        subject: myAudio.metas.title,
                                      );
                                    },
                                    child: const Icon(
                                      Icons.share,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => PlayListWidget(
                                            audios: con.player.playlist!.audios,
                                            con: con,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      CupertinoIcons.music_note_list,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
