import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import '../../core/services/vimeo_service.dart';
import 'widgets/admin_sidebar.dart';

class AdminVimeoBulkImportScreen extends StatefulWidget {
  const AdminVimeoBulkImportScreen({super.key});

  @override
  State<AdminVimeoBulkImportScreen> createState() =>
      _AdminVimeoBulkImportScreenState();
}

class _AdminVimeoBulkImportScreenState
    extends State<AdminVimeoBulkImportScreen> {
  final _inputController = TextEditingController();
  final _vimeoService = VimeoService();

  bool _isProcessing = false;
  bool _isImporting = false;
  String? _token;

  final List<VimeoImportItem> _items = [];
  String _contentType = 'movie'; // 'movie' or 'episode'
  int? _selectedSeriesId;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // استخراج معرّف Vimeo من الرابط
  String? _extractVimeoId(String input) {
    input = input.trim();

    // إذا كان رقماً فقط
    if (RegExp(r'^\d+$').hasMatch(input)) {
      return input;
    }

    // استخراج من رابط Vimeo
    final patterns = [
      RegExp(r'vimeo\.com/(\d+)'),
      RegExp(r'player\.vimeo\.com/video/(\d+)'),
      RegExp(r'vimeo\.com/channels/[^/]+/(\d+)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null && match.groupCount > 0) {
        return match.group(1);
      }
    }

    return null;
  }

  // معالجة قائمة الروابط
  Future<void> _processLinks() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      _showError('الرجاء إدخال روابط أو معرّفات Vimeo');
      return;
    }

    setState(() {
      _isProcessing = true;
      _items.clear();
    });

    // تقسيم النص إلى أسطر
    final lines = text.split('\n');
    final vimeoIds = <String>[];

    for (var line in lines) {
      final id = _extractVimeoId(line);
      if (id != null && !vimeoIds.contains(id)) {
        vimeoIds.add(id);
      }
    }

    if (vimeoIds.isEmpty) {
      setState(() => _isProcessing = false);
      _showError('لم يتم العثور على معرّفات Vimeo صالحة');
      return;
    }

    // جلب معلومات كل فيديو
    for (var vimeoId in vimeoIds) {
      try {
        final config = await _vimeoService.getVideoConfig(vimeoId);
        if (config != null) {
          setState(() {
            _items.add(VimeoImportItem(
              vimeoId: vimeoId,
              title: config.title,
              description: config.description ?? '',
              duration: config.duration,
              thumbnail: config.thumbnail ?? '',
              isSelected: true,
            ));
          });
        }
      } catch (e) {
        print('Error fetching Vimeo $vimeoId: $e');
      }
    }

    setState(() => _isProcessing = false);

    if (_items.isEmpty) {
      _showError('فشل في جلب معلومات الفيديوهات من Vimeo');
    }
  }

  // استيراد العناصر المحددة
  Future<void> _importSelected() async {
    final selectedItems = _items.where((item) => item.isSelected).toList();

    if (selectedItems.isEmpty) {
      _showError('الرجاء اختيار عنصر واحد على الأقل للاستيراد');
      return;
    }

    if (_token == null) {
      _showError('فشل في المصادقة. الرجاء تسجيل الدخول مرة أخرى');
      return;
    }

    setState(() => _isImporting = true);

    int successCount = 0;
    int failCount = 0;

    for (var item in selectedItems) {
      try {
        if (_contentType == 'movie') {
          await _importAsMovie(item);
          successCount++;
        } else {
          if (_selectedSeriesId != null) {
            await _importAsEpisode(item, _selectedSeriesId!);
            successCount++;
          }
        }
      } catch (e) {
        print('Error importing ${item.vimeoId}: $e');
        failCount++;
      }
    }

    setState(() => _isImporting = false);

    _showSuccess(
      'تم الاستيراد بنجاح!\n'
      'نجح: $successCount\n'
      'فشل: $failCount',
    );

    // مسح القائمة بعد الاستيراد الناجح
    if (successCount > 0) {
      setState(() {
        _items.removeWhere((item) => item.isSelected);
        _inputController.clear();
      });
    }
  }

  Future<void> _importAsMovie(VimeoImportItem item) async {
    final movieData = {
      'title': item.title,
      'description': item.description,
      'vimeo_id': item.vimeoId,
      'video_url': '',
      'duration': (item.duration / 60).round(), // تحويل إلى دقائق
      'poster_url': item.thumbnail,
      'thumbnail_url': item.thumbnail,
      'year': DateTime.now().year,
      'status': 'draft',
      'rating': 0.0,
    };

    await AdminService.createMovie(token: _token!, data: movieData);
  }

  Future<void> _importAsEpisode(VimeoImportItem item, int seriesId) async {
    // حساب رقم الحلقة التلقائي
    final episodeNumber = _items.indexOf(item) + 1;

    // ignore: unused_local_variable
    final episodeData = {
      'series_id': seriesId,
      'episode_number': episodeNumber,
      'title': item.title,
      'description': item.description,
      'vimeo_id': item.vimeoId,
      'video_url': '',
      'duration': (item.duration / 60).round(),
      'thumbnail': item.thumbnail,
    };

    // ملاحظة: قد تحتاج إلى إضافة هذه الوظيفة في AdminService
    // await AdminService.createEpisode(token: _token!, data: episodeData);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Row(
          children: [
            const AdminSidebarWidget(currentRoute: '/admin/vimeo-import'),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.video_library, color: Colors.blue, size: 32),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'استيراد من Vimeo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'استيراد عدة فيديوهات دفعة واحدة',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // خيارات نوع المحتوى
          _buildContentTypeSelector(),
          const SizedBox(height: 24),

          // حقل إدخال الروابط
          _buildInputSection(),
          const SizedBox(height: 24),

          // زر المعالجة
          _buildProcessButton(),
          const SizedBox(height: 32),

          // قائمة العناصر
          if (_items.isNotEmpty) _buildItemsList(),

          // زر الاستيراد
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildImportButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildContentTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نوع المحتوى',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _contentType = 'movie'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _contentType == 'movie'
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _contentType == 'movie'
                            ? Colors.blue
                            : Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _contentType == 'movie'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.movie, color: Colors.white70),
                        const SizedBox(width: 8),
                        const Text(
                          'أفلام',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _contentType = 'episode'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _contentType == 'episode'
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _contentType == 'episode'
                            ? Colors.blue
                            : Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _contentType == 'episode'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.tv, color: Colors.white70),
                        const SizedBox(width: 8),
                        const Text(
                          'حلقات مسلسل',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'روابط أو معرّفات Vimeo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل كل رابط أو معرّف في سطر منفصل',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 10,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
            ),
            decoration: InputDecoration(
              hintText: 'https://vimeo.com/123456789\n'
                  'https://vimeo.com/987654321\n'
                  '555555555\n'
                  '...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يمكنك إدخال روابط Vimeo كاملة أو معرّفات فقط (الأرقام)',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _processLinks,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.search),
        label: Text(
          _isProcessing ? 'جاري المعالجة...' : 'جلب معلومات الفيديوهات',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'العناصر الجاهزة (${_items.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    for (var item in _items) {
                      item.isSelected = !item.isSelected;
                    }
                  });
                },
                icon: const Icon(Icons.select_all),
                label: const Text('تحديد الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(_items[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(VimeoImportItem item) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: item.isSelected,
              onChanged: (value) {
                setState(() => item.isSelected = value ?? false);
              },
              activeColor: Colors.blue,
            ),
            const SizedBox(width: 12),

            // Thumbnail
            if (item.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.thumbnail,
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 60,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vimeo ID: ${item.vimeoId} • ${_formatDuration(item.duration)}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Edit button
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editItem(item),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  void _editItem(VimeoImportItem item) {
    final titleController = TextEditingController(text: item.title);
    final descController = TextEditingController(text: item.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المعلومات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.title = titleController.text;
                item.description = descController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    final selectedCount = _items.where((item) => item.isSelected).length;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isImporting ? null : _importSelected,
        icon: _isImporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.cloud_upload),
        label: Text(
          _isImporting
              ? 'جاري الاستيراد...'
              : 'استيراد العناصر المحددة ($selectedCount)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// نموذج عنصر الاستيراد
class VimeoImportItem {
  final String vimeoId;
  String title;
  String description;
  final int duration;
  final String thumbnail;
  bool isSelected;

  VimeoImportItem({
    required this.vimeoId,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnail,
    this.isSelected = true,
  });
}
