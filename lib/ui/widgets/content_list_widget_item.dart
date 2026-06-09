import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigator.dart';
import 'image_widget.dart';

class ContentListItem extends StatefulWidget {
  const ContentListItem(
      {super.key, required this.content, this.isLibraryItem = false});

  final dynamic content;
  final bool isLibraryItem;

  @override
  State<ContentListItem> createState() => _ContentListItemState();
}

class _ContentListItemState extends State<ContentListItem> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final isLibraryItem = widget.isLibraryItem;
    final isAlbum = content.runtimeType.toString() == "Album";
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onFocusChange: (focused) {
        setState(() {
          _hasFocus = focused;
        });
      },
      onTap: () {
        if (isAlbum) {
          Get.toNamed(ScreenNavigationSetup.albumScreen,
              id: ScreenNavigationSetup.id, arguments:(widget.content, widget.content.browseId));
          return;
        }
        Get.toNamed(ScreenNavigationSetup.playlistScreen,
            id: ScreenNavigationSetup.id,
            arguments: [widget.content, widget.content.playlistId]);
      },
      child: Container(
        width: 130,
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: _hasFocus
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isAlbum
                ? ImageWidget(
                    size: 120,
                    album: content,
                  )
                : content.isCloudPlaylist ||
                        !(content.playlistId == 'LIBRP' ||
                            content.playlistId == 'LIBFAV' ||
                            content.playlistId == 'SongsCache' ||
                            content.playlistId == 'SongDownloads')
                    ? SizedBox.square(
                        dimension: 120,
                        child: Stack(
                          children: [
                            ImageWidget(
                              size: 120,
                              playlist: content,
                            ),
                            if (content.isPipedPlaylist)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    child: Center(
                                        child: Text(
                                      "P",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 14),
                                    )),
                                  ),
                                ),
                              ),
                            if (!content.isCloudPlaylist)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    child: Center(
                                        child: Text(
                                      "L",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 14),
                                    )),
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    : Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Icon(
                          content.playlistId == 'LIBRP'
                              ? Icons.history
                              : content.playlistId == 'LIBFAV'
                                  ? Icons.favorite
                                  : content.playlistId == 'SongsCache'
                                      ? Icons.flight
                                      : Icons.download,
                          color: Colors.white,
                          size: 40,
                        ))),
            const SizedBox(height: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    // overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    isAlbum
                        ? isLibraryItem
                            ? ""
                            : "${content.artists[0]['name'] ?? ""} | ${content.year ?? ""}"
                        : isLibraryItem
                            ? ""
                            : content.description ?? "",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
