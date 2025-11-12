// Script to add JSON decoding logic to all models
// Run manually: dart run update_models.dart

import 'dart:io';

void main() {
  final modelsToUpdate = [
    'documentary_model.dart',
    'live_stream_model.dart',
    'podcast_model.dart',
    'sport_model.dart',
  ];

  for (final model in modelsToUpdate) {
    final file = File(model);
    if (!file.existsSync()) continue;

    var content = file.readAsStringSync();

    // Add import if not present
    if (!content.contains('import \'dart:convert\';')) {
      content = 'import \'dart:convert\';\n\n$content';
    }

    // Update title handling
    content = content.replaceAllMapped(
      RegExp(r'if \(j\[\'title\'\] is Map\)'),
      (match) {
        return '''dynamic titleData = j['title'];
    if (titleData is String && titleData.startsWith('{')) {
      try {
        titleData = jsonDecode(titleData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (titleData is Map)''';
      },
    );

    // Update description handling
    content = content.replaceAllMapped(
      RegExp(r'if \(j\[\'description\'\] is Map\)'),
      (match) {
        return '''dynamic descData = j['description'];
    if (descData is String && descData.startsWith('{')) {
      try {
        descData = jsonDecode(descData);
      } catch (e) {
        // If decoding fails, use as-is
      }
    }

    if (descData is Map)''';
      },
    );

    // Replace j['title'] with titleData in the Map handling block
    content = content.replaceAll(
      RegExp(r"j\['title'\]\['"),
      "titleData['",
    );

    // Replace j['description'] with descData in the Map handling block
    content = content.replaceAll(
      RegExp(r"j\['description'\]\['"),
      "descData['",
    );

    file.writeAsStringSync(content);
    print('Updated $model');
  }
}
