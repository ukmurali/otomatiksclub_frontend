import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/instagram_service/api_instagram_service.dart';
import 'package:otomatiksclub/model/instagram_media.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:otomatiksclub/widgets/video_player_widget.dart';

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
      body: Container(
        color: Colors.grey[200], // Set your desired background color here
        child: FutureBuilder<List<InstagramMedia>>(
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
            return ListView.builder(
              itemCount: mediaList.length,
              itemBuilder: (context, index) {
                final media = mediaList[index];
                return MediaCard(media: media);
              },
            );
          },
        ),
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
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          media.mediaType == "IMAGE"
              ? AspectRatio(
                  aspectRatio: 1, // Maintain a 1:1 aspect ratio
                  child: Image.network(media.mediaUrl, fit: BoxFit.cover))
              : VideoPlayerWidget(
                  mediaUrl: media.mediaUrl, mediaType: "instagram"),
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
