import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'download_service.dart';

class EnhancedDownloadManager extends ChangeNotifier {
  static final EnhancedDownloadManager _instance =
      EnhancedDownloadManager._internal();
  factory EnhancedDownloadManager() => _instance;
  EnhancedDownloadManager._internal();

  final Dio _dio = Dio();
  final DownloadService _downloadService = DownloadService();
  Database? _database;

  final Map<String, CancelToken> _activeDownloads = {};
  final Map<String, DownloadProgress> _progressTrackers = {};
  final List<DownloadTask> _downloadQueue = [];
  bool _isProcessingQueue = false;
  int _maxConcurrentDownloads = 3;

  // Download status
  static const String statusQueued = 'queued';
  static const String statusDownloading = 'downloading';
  static const String statusPaused = 'paused';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFile = path.join(dbPath, 'enhanced_downloads.db');

    return await openDatabase(
      dbFile,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE download_tasks (
            id TEXT PRIMARY KEY,
            content_id INTEGER,
            content_type TEXT,
            title TEXT,
            description TEXT,
            thumbnail_url TEXT,
            video_url TEXT,
            file_path TEXT,
            file_size INTEGER,
            downloaded_size INTEGER,
            status TEXT,
            progress REAL,
            quality TEXT,
            priority INTEGER DEFAULT 0,
            retry_count INTEGER DEFAULT 0,
            error_message TEXT,
            created_at INTEGER,
            started_at INTEGER,
            completed_at INTEGER,
            metadata TEXT
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_status ON download_tasks(status);
          CREATE INDEX idx_priority ON download_tasks(priority DESC);
          CREATE INDEX idx_created ON download_tasks(created_at DESC);
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE download_tasks ADD COLUMN priority INTEGER DEFAULT 0');
          await db.execute(
              'ALTER TABLE download_tasks ADD COLUMN retry_count INTEGER DEFAULT 0');
          await db.execute(
              'ALTER TABLE download_tasks ADD COLUMN error_message TEXT');
        }
      },
    );
  }

  // Get download directory based on content type
  Future<Directory> _getDownloadDirectory(String contentType) async {
    Directory baseDir;

    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      baseDir = Directory('${directory!.path}/Alenwan');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      baseDir = Directory('${directory.path}/Alenwan');
    }

    // Create subdirectories for different content types
    final subDir =
        Directory('${baseDir.path}/${_getContentFolder(contentType)}');
    if (!await subDir.exists()) {
      await subDir.create(recursive: true);
    }

    return subDir;
  }

  String _getContentFolder(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'movie':
        return 'Movies';
      case 'series':
        return 'Series';
      case 'cartoon':
        return 'Cartoons';
      case 'documentary':
        return 'Documentaries';
      case 'sport':
        return 'Sports';
      default:
        return 'Downloads';
    }
  }

  // Add download to queue with priority
  Future<String> addDownload({
    required int contentId,
    required String contentType,
    required String title,
    required String videoUrl,
    String? description,
    String? thumbnailUrl,
    String quality = 'HD',
    int priority = 0,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final downloadId =
          '${contentType}_${contentId}_${DateTime.now().millisecondsSinceEpoch}';
      final downloadDir = await _getDownloadDirectory(contentType);

      // Clean filename
      final cleanTitle =
          title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final fileName = '${contentId}_${cleanTitle}_$quality.mp4';
      final filePath = '${downloadDir.path}/$fileName';

      // Check if already downloading
      final existingDownload =
          await _checkExistingDownload(contentId, contentType);
      if (existingDownload != null) {
        return existingDownload;
      }

      // Add to database
      final db = await database;
      await db.insert('download_tasks', {
        'id': downloadId,
        'content_id': contentId,
        'content_type': contentType,
        'title': title,
        'description': description ?? '',
        'thumbnail_url': thumbnailUrl ?? '',
        'video_url': videoUrl,
        'file_path': filePath,
        'file_size': 0,
        'downloaded_size': 0,
        'status': statusQueued,
        'progress': 0.0,
        'quality': quality,
        'priority': priority,
        'retry_count': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'metadata': jsonEncode(metadata ?? {}),
      });

      // Add to queue
      final task = DownloadTask(
        id: downloadId,
        contentId: contentId,
        contentType: contentType,
        title: title,
        videoUrl: videoUrl,
        filePath: filePath,
        priority: priority,
      );

      _downloadQueue.add(task);
      _downloadQueue.sort((a, b) => b.priority.compareTo(a.priority));

      // Process queue
      _processQueue();

      notifyListeners();
      return downloadId;
    } catch (e) {
      throw Exception('Failed to add download: $e');
    }
  }

  // Check for existing download
  Future<String?> _checkExistingDownload(
      int contentId, String contentType) async {
    final db = await database;
    final results = await db.query(
      'download_tasks',
      where: 'content_id = ? AND content_type = ? AND status IN (?, ?, ?)',
      whereArgs: [
        contentId,
        contentType,
        statusQueued,
        statusDownloading,
        statusCompleted
      ],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first['id'] as String;
    }
    return null;
  }

  // Process download queue
  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_downloadQueue.isNotEmpty &&
        _activeDownloads.length < _maxConcurrentDownloads) {
      final task = _downloadQueue.removeAt(0);
      _startDownload(task);
    }

    _isProcessingQueue = false;
  }

  // Start download
  Future<void> _startDownload(DownloadTask task) async {
    final cancelToken = CancelToken();
    _activeDownloads[task.id] = cancelToken;

    final progress = DownloadProgress(task.id);
    _progressTrackers[task.id] = progress;

    try {
      // Update status
      await _updateStatus(task.id, statusDownloading);
      await _updateStartedAt(task.id);

      // Check if file partially exists (for resume)
      final file = File(task.filePath);
      int startByte = 0;
      if (await file.exists()) {
        startByte = await file.length();
      }

      // Download with resume support
      await _dio.download(
        task.videoUrl,
        task.filePath,
        cancelToken: cancelToken,
        deleteOnError: false,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            final totalReceived = startByte + received;
            final totalSize = startByte + total;
            final progressValue = totalReceived / totalSize;

            progress.updateProgress(totalReceived, totalSize, progressValue);

            // Update database periodically (every 1% progress)
            if ((progressValue * 100).toInt() !=
                (progress.lastSavedProgress * 100).toInt()) {
              await _updateProgress(
                  task.id, totalReceived, totalSize, progressValue);
              progress.lastSavedProgress = progressValue;
            }
          }
        },
        options: Options(
          headers: startByte > 0 ? {'Range': 'bytes=$startByte-'} : {},
        ),
      );

      // Download completed successfully
      await _onDownloadComplete(task);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        await _updateStatus(task.id, statusPaused);
      } else {
        await _onDownloadError(task, e.message ?? 'Download failed');
      }
    } catch (e) {
      await _onDownloadError(task, e.toString());
    } finally {
      _activeDownloads.remove(task.id);
      _progressTrackers.remove(task.id);
      _processQueue(); // Process next in queue
      notifyListeners();
    }
  }

  // Handle download completion
  Future<void> _onDownloadComplete(DownloadTask task) async {
    await _updateStatus(task.id, statusCompleted);
    await _updateCompletedAt(task.id);

    // Get file info
    final file = File(task.filePath);
    final fileSize = await file.length();

    // Save to server via DownloadService
    try {
      await _downloadService.storeCompletedDownload(
        mediaId: task.contentId.toString(),
        mediaType: task.contentType,
        title: task.title,
        fileSizeBytes: fileSize,
        localFilePath: task.filePath,
        quality: 'HD',
      );
    } catch (e) {
      print('Failed to sync with server: $e');
    }

    notifyListeners();
  }

  // Handle download error with retry
  Future<void> _onDownloadError(DownloadTask task, String error) async {
    final db = await database;

    // Get current retry count
    final results = await db.query(
      'download_tasks',
      where: 'id = ?',
      whereArgs: [task.id],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final retryCount = (results.first['retry_count'] as int? ?? 0) + 1;

      if (retryCount <= 3) {
        // Retry after delay
        await Future.delayed(Duration(seconds: retryCount * 5));

        await db.update(
          'download_tasks',
          {'retry_count': retryCount, 'error_message': error},
          where: 'id = ?',
          whereArgs: [task.id],
        );

        _downloadQueue.add(task);
        _processQueue();
      } else {
        // Max retries exceeded
        await _updateStatus(task.id, statusFailed);
        await db.update(
          'download_tasks',
          {'error_message': error},
          where: 'id = ?',
          whereArgs: [task.id],
        );
      }
    }
  }

  // Pause download
  Future<void> pauseDownload(String downloadId) async {
    final cancelToken = _activeDownloads[downloadId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    notifyListeners();
  }

  // Resume download
  Future<void> resumeDownload(String downloadId) async {
    final db = await database;
    final results = await db.query(
      'download_tasks',
      where: 'id = ?',
      whereArgs: [downloadId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final task = DownloadTask.fromMap(results.first);
      _downloadQueue.add(task);
      _processQueue();
    }
  }

  // Delete download
  Future<void> deleteDownload(String downloadId) async {
    // Cancel if active
    pauseDownload(downloadId);

    // Get file path
    final db = await database;
    final results = await db.query(
      'download_tasks',
      where: 'id = ?',
      whereArgs: [downloadId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final filePath = results.first['file_path'] as String?;
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Delete from database
    await db.delete(
      'download_tasks',
      where: 'id = ?',
      whereArgs: [downloadId],
    );

    notifyListeners();
  }

  // Update methods
  Future<void> _updateStatus(String id, String status) async {
    final db = await database;
    await db.update(
      'download_tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _updateProgress(
      String id, int downloaded, int total, double progress) async {
    final db = await database;
    await db.update(
      'download_tasks',
      {
        'downloaded_size': downloaded,
        'file_size': total,
        'progress': progress,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _updateStartedAt(String id) async {
    final db = await database;
    await db.update(
      'download_tasks',
      {'started_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _updateCompletedAt(String id) async {
    final db = await database;
    await db.update(
      'download_tasks',
      {'completed_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get downloads
  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await database;
    return await db.query(
      'download_tasks',
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getDownloadsByStatus(String status) async {
    final db = await database;
    return await db.query(
      'download_tasks',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
  }

  // Get progress for a download
  DownloadProgress? getProgress(String downloadId) {
    return _progressTrackers[downloadId];
  }

  // Settings
  void setMaxConcurrentDownloads(int max) {
    _maxConcurrentDownloads = max.clamp(1, 5);
    _processQueue();
  }

  // Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    int totalSize = 0;
    int fileCount = 0;

    for (final contentType in [
      'movie',
      'series',
      'cartoon',
      'documentary',
      'sport'
    ]) {
      final dir = await _getDownloadDirectory(contentType);
      if (await dir.exists()) {
        final files = dir.listSync(recursive: true);
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
            fileCount++;
          }
        }
      }
    }

    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'formattedSize': _formatBytes(totalSize),
    };
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

// Download Task Model
class DownloadTask {
  final String id;
  final int contentId;
  final String contentType;
  final String title;
  final String videoUrl;
  final String filePath;
  final int priority;

  DownloadTask({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.videoUrl,
    required this.filePath,
    required this.priority,
  });

  factory DownloadTask.fromMap(Map<String, dynamic> map) {
    return DownloadTask(
      id: map['id'] as String,
      contentId: map['content_id'] as int,
      contentType: map['content_type'] as String,
      title: map['title'] as String,
      videoUrl: map['video_url'] as String,
      filePath: map['file_path'] as String,
      priority: map['priority'] as int? ?? 0,
    );
  }
}

// Download Progress Tracker
class DownloadProgress extends ChangeNotifier {
  final String downloadId;
  int downloadedBytes = 0;
  int totalBytes = 0;
  double progress = 0.0;
  double speed = 0.0;
  double lastSavedProgress = 0.0;
  DateTime? _lastUpdate;
  int _lastBytes = 0;

  DownloadProgress(this.downloadId);

  void updateProgress(int downloaded, int total, double progressValue) {
    downloadedBytes = downloaded;
    totalBytes = total;
    progress = progressValue;

    // Calculate download speed
    final now = DateTime.now();
    if (_lastUpdate != null) {
      final timeDiff = now.difference(_lastUpdate!).inMilliseconds / 1000.0;
      if (timeDiff > 0) {
        speed = (downloaded - _lastBytes) / timeDiff;
      }
    }
    _lastUpdate = now;
    _lastBytes = downloaded;

    notifyListeners();
  }

  String get formattedSpeed {
    if (speed < 1024) return '${speed.toStringAsFixed(2)} B/s';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(2)} KB/s';
    return '${(speed / (1024 * 1024)).toStringAsFixed(2)} MB/s';
  }

  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  String get formattedSize {
    final downloaded = _formatBytes(downloadedBytes);
    final total = _formatBytes(totalBytes);
    return '$downloaded / $total';
  }

  String get estimatedTimeRemaining {
    if (speed <= 0) return 'Calculating...';
    final remainingBytes = totalBytes - downloadedBytes;
    final remainingSeconds = (remainingBytes / speed).toInt();

    if (remainingSeconds < 60) return '$remainingSeconds seconds';
    if (remainingSeconds < 3600) return '${remainingSeconds ~/ 60} minutes';
    return '${remainingSeconds ~/ 3600} hours';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
