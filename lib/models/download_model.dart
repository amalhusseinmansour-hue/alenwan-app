enum DownloadStatus { completed, downloading, paused, failed }

class DownloadModel {
  final int id;
  final String title;
  final String path; // مسار محلي
  final int fileSize;

  DownloadModel({
    required this.id,
    required this.title,
    required this.path,
    required this.fileSize,
  });

  factory DownloadModel.fromJson(Map<String, dynamic> j) {
    return DownloadModel(
      id: j['id'],
      title: j['title'],
      path: j['path'],
      fileSize: j['fileSize'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'path': path,
    'fileSize': fileSize,
  };
}
