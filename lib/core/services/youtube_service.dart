import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/youtube_stream_model.dart';
import '../../models/youtube_comment_model.dart';

class YouTubeService {
  final String apiKey;

  YouTubeService({required this.apiKey});

  /// 🔹 جلب تفاصيل البث المباشر
  Future<YouTubeStreamModel> fetchLiveStreamDetails(String videoId) async {
    final url =
        'https://www.googleapis.com/youtube/v3/videos?part=snippet,liveStreamingDetails&id=$videoId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final snippet = data['items'][0]['snippet'];
          return YouTubeStreamModel.fromMap({
            'title': snippet['title'],
            'channelName': snippet['channelTitle'],
            'thumbnail': snippet['thumbnails']['high']['url'],
          });
        }
        throw Exception('No data found for this live stream');
      } else {
        throw Exception('Failed to load live stream details');
      }
    } catch (e) {
      throw Exception('خطأ أثناء جلب تفاصيل البث');
    }
  }

  /// 🔹 جلب التعليقات
  Future<List<YouTubeCommentModel>> fetchComments(String videoId) async {
    final url =
        'https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=$videoId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<YouTubeCommentModel> comments = [];

        for (var item in data['items'] ?? []) {
          final snippet = item['snippet']['topLevelComment']['snippet'];
          comments.add(YouTubeCommentModel.fromMap({
            'text': snippet['textDisplay'],
            'author': snippet['authorDisplayName'],
            'publishedAt': snippet['publishedAt'],
          }));
        }

        return comments;
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('خطأ أثناء تحميل التعليقات');
    }
  }
}
