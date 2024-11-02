import 'package:flutter/material.dart';
import 'package:stem_club/api/instagram_service/api_instagram_service.dart';
import 'package:stem_club/model/instagram_media.dart';
import 'package:stem_club/widgets/loading_indicator.dart';
import 'package:stem_club/widgets/video_player_widget.dart';

class InstagramMediaPage extends StatefulWidget {
  const InstagramMediaPage({super.key});

  @override
  _InstagramMediaPageState createState() => _InstagramMediaPageState();
}

class _InstagramMediaPageState extends State<InstagramMediaPage> {
  late Future<List<InstagramMedia>> futureMedia;
  final InstagramService instagramService = InstagramService();

  @override
  void initState() {
    super.initState();
    futureMedia = instagramService.fetchMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<InstagramMedia>>(
        future: futureMedia,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No media found"));
          }

          final mediaList = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final media = mediaList[index];
              return MediaCard(media: media);
            },
          );
        },
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final InstagramMedia media;

  const MediaCard({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: media.mediaType == "IMAGE"
                ? Image.network(media.mediaUrl, fit: BoxFit.cover)
                : VideoPlayerWidget(mediaUrl: media.mediaUrl, mediaType: "instagram")
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              media.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
