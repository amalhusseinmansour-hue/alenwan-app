import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/download_model.dart';

class DownloadsController extends ChangeNotifier {
  List<DownloadModel> downloads = [];
  bool isLoading = false;

  static const String _storageKey = 'offline_downloads';

  Future<void> loadDownloads() async {
    isLoading = true;
    notifyListeners();

    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => DownloadModel.fromJson(e))
          .toList();
      downloads = list;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addDownload(DownloadModel d) async {
    downloads.insert(0, d);
    await _save();
    notifyListeners();
  }

  Future<void> deleteDownload(DownloadModel d) async {
    downloads.removeWhere((x) => x.id == d.id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _storageKey,
      jsonEncode(downloads.map((e) => e.toJson()).toList()),
    );
  }
}
