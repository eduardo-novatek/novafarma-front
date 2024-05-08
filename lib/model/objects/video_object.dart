import '../globals/deserializable.dart';

class VideoObject implements Deserializable <VideoObject> {
  final bool? isFirst;
  final String? videoId;
  final String? title;
  final String? description;
  final String? url;

  VideoObject.empty()
      : isFirst = null, videoId = null, title = null, description = null,
        url = null;

  VideoObject({
    this.isFirst, this.videoId, this.title, this.description, this.url
  });

  @override
  VideoObject fromJson(Map<String, dynamic> json) {
    return VideoObject (
      videoId: json['videoId'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
    );
  }

}
