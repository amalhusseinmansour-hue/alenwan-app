import 'live_stream_model.dart';

class LiveStreamPage {
  final List<LiveStreamModel> items;
  final String? next;

  LiveStreamPage({
    required this.items,
    this.next,
  });
}
