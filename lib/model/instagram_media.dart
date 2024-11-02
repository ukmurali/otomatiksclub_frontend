// instagram_media.dart
class InstagramMedia {
  final String id;
  final String mediaType;
  final String mediaUrl;
  final String caption;

  InstagramMedia({
    required this.id,
    required this.mediaType,
    required this.mediaUrl,
    required this.caption,
  });

  factory InstagramMedia.fromJson(Map<String, dynamic> json) {
    return InstagramMedia(
      id: json['id'],
      mediaType: json['media_type'],
      mediaUrl: json['media_url'],
      caption: json['caption'] ?? '',
    );
  }
}
