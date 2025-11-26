import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import '../../widgets/imdb_search_dialog.dart';
import 'widgets/admin_sidebar.dart';

class AdminSeriesFormScreen extends StatefulWidget {
  final int? seriesId;

  const AdminSeriesFormScreen({super.key, this.seriesId});

  @override
  State<AdminSeriesFormScreen> createState() => _AdminSeriesFormScreenState();
}

class _AdminSeriesFormScreenState extends State<AdminSeriesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _token;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _directorController = TextEditingController();
  final _castController = TextEditingController();
  final _genreController = TextEditingController();
  final _ratingController = TextEditingController();
  final _trailerUrlController = TextEditingController();

  String? _posterPath;
  String? _thumbnailPath;
  String? _posterUrl;
  String? _thumbnailUrl;

  List<Map<String, dynamic>> _episodes = [];

  @override
  void initState() {
    super.initState();
    if (widget.seriesId != null) {
      _loadSeriesData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _directorController.dispose();
    _castController.dispose();
    _genreController.dispose();
    _ratingController.dispose();
    _trailerUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSeriesData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null && widget.seriesId != null) {
        final series = await AdminService.getSeriesDetails(
          token: _token!,
          id: widget.seriesId!,
        );

        if (series != null) {
          setState(() {
            _titleController.text = series['title'] ?? '';
            _descriptionController.text = series['description'] ?? '';
            _yearController.text = series['year']?.toString() ?? '';
            _directorController.text = series['director'] ?? '';
            _castController.text = series['cast'] ?? '';
            _genreController.text = series['genre'] ?? '';
            _ratingController.text = series['rating']?.toString() ?? '';
            _trailerUrlController.text = series['trailer_url'] ?? '';
            _posterUrl = series['poster_url'];
            _thumbnailUrl = series['thumbnail_url'];
            _episodes =
                List<Map<String, dynamic>>.from(series['episodes'] ?? []);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading series: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showIMDbSearch() async {
    showDialog(
      context: context,
      builder: (context) => IMDbSearchDialog(
        contentType: 'series',
        onSelect: (data) {
          setState(() {
            _titleController.text = data['title'] ?? '';
            _descriptionController.text = data['description'] ?? '';
            _yearController.text = data['year']?.toString() ?? '';
            _directorController.text = data['director'] ?? '';
            _castController.text = data['cast'] ?? '';
            _genreController.text = data['genre'] ?? '';
            _ratingController.text = data['rating']?.toString() ?? '';
            if (data['poster_url'] != null && data['poster_url'] != 'N/A') {
              _posterUrl = data['poster_url'];
              _thumbnailUrl = data['poster_url'];
            }
          });
        },
      ),
    );
  }

  Future<void> _pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            if (type == 'poster') {
              _posterPath = file.path!;
            } else if (type == 'thumbnail') {
              _thumbnailPath = file.path!;
            }
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _saveSeries() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token == null) throw Exception('No auth token found');

      String? posterUrl = _posterUrl;
      String? thumbnailUrl = _thumbnailUrl;

      if (_posterPath != null) {
        final result = await AdminService.uploadMedia(
          token: _token!,
          filePath: _posterPath!,
          type: 'poster',
        );
        if (result != null) posterUrl = result['url'];
      }

      if (_thumbnailPath != null) {
        final result = await AdminService.uploadMedia(
          token: _token!,
          filePath: _thumbnailPath!,
          type: 'thumbnail',
        );
        if (result != null) thumbnailUrl = result['url'];
      }

      final seriesData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'year': int.tryParse(_yearController.text) ?? 2024,
        'director': _directorController.text,
        'cast': _castController.text,
        'genre': _genreController.text,
        'rating': double.tryParse(_ratingController.text) ?? 0.0,
        'trailer_url': _trailerUrlController.text,
        'poster_url': posterUrl ?? '',
        'thumbnail_url': thumbnailUrl ?? '',
      };

      final result = widget.seriesId == null
          ? await AdminService.createSeries(token: _token!, data: seriesData)
          : await AdminService.updateSeries(
              token: _token!,
              id: widget.seriesId!,
              data: seriesData,
            );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.seriesId == null
                ? 'تم إضافة المسلسل بنجاح'
                : 'تم تحديث المسلسل بنجاح'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving series: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حفظ المسلسل: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _addEpisode() {
    showDialog(
      context: context,
      builder: (context) => _EpisodeDialog(
        onSave: (episode) {
          setState(() => _episodes.add(episode));
        },
      ),
    );
  }

  void _editEpisode(int index) {
    showDialog(
      context: context,
      builder: (context) => _EpisodeDialog(
        episode: _episodes[index],
        onSave: (episode) {
          setState(() => _episodes[index] = episode);
        },
      ),
    );
  }

  void _deleteEpisode(int index) {
    setState(() => _episodes.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Row(
          children: [
            const AdminSidebarWidget(currentRoute: '/admin/content'),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildForm(),
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
          Text(
            widget.seriesId == null ? 'إضافة مسلسل جديد' : 'تعديل المسلسل',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _showIMDbSearch,
            icon: const Icon(Icons.search, size: 20),
            label: const Text('بحث في IMDb'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Container(
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
              _buildTextField(
                controller: _titleController,
                label: 'عنوان المسلسل',
                validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'الوصف',
                maxLines: 4,
                validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _yearController,
                      label: 'السنة',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _ratingController,
                      label: 'التقييم',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: _directorController, label: 'المخرج'),
              const SizedBox(height: 16),
              _buildTextField(controller: _castController, label: 'الممثلون'),
              const SizedBox(height: 16),
              _buildTextField(controller: _genreController, label: 'النوع'),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _trailerUrlController, label: 'رابط الإعلان'),
              const SizedBox(height: 24),
              const Text(
                'الملفات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildFileUpload(
                label: 'صورة الملصق',
                filePath: _posterPath,
                fileUrl: _posterUrl,
                onTap: () => _pickFile('poster'),
              ),
              const SizedBox(height: 16),
              _buildFileUpload(
                label: 'الصورة المصغرة',
                filePath: _thumbnailPath,
                fileUrl: _thumbnailUrl,
                onTap: () => _pickFile('thumbnail'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الحلقات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addEpisode,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة حلقة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_episodes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'لم تتم إضافة حلقات بعد',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                )
              else
                ..._episodes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final episode = entry.value;
                  return _buildEpisodeCard(index, episode);
                }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSeries,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.seriesId == null
                              ? 'إضافة المسلسل'
                              : 'حفظ التغييرات',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildFileUpload({
    required String label,
    String? filePath,
    String? fileUrl,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    filePath != null
                        ? filePath.split('/').last
                        : fileUrl != null
                            ? 'تم الرفع مسبقاً'
                            : 'اختر ملف',
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (filePath != null || fileUrl != null)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeCard(int index, Map<String, dynamic> episode) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          'حلقة ${episode['episode_number']}: ${episode['title']}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'المدة: ${episode['duration']} دقيقة',
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editEpisode(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEpisode(index),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeDialog extends StatefulWidget {
  final Map<String, dynamic>? episode;
  final Function(Map<String, dynamic>) onSave;

  const _EpisodeDialog({this.episode, required this.onSave});

  @override
  State<_EpisodeDialog> createState() => _EpisodeDialogState();
}

class _EpisodeDialogState extends State<_EpisodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _episodeNumberController;
  late final TextEditingController _durationController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _vimeoIdController;
  String _videoSource = 'url'; // 'url' or 'vimeo'

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.episode?['title'] ?? '');
    _episodeNumberController = TextEditingController(
      text: widget.episode?['episode_number']?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: widget.episode?['duration']?.toString() ?? '',
    );
    _videoUrlController = TextEditingController(
      text: widget.episode?['video_url'] ?? '',
    );
    _vimeoIdController = TextEditingController(
      text: widget.episode?['vimeo_id'] ?? '',
    );

    // Detect video source type
    if (widget.episode?['vimeo_id'] != null &&
        widget.episode!['vimeo_id'].toString().isNotEmpty) {
      _videoSource = 'vimeo';
    } else {
      _videoSource = 'url';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _episodeNumberController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    _vimeoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.episode == null ? 'إضافة حلقة' : 'تعديل الحلقة',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _episodeNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم الحلقة',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الحلقة',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'المدة (بالدقائق)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Video Source Selection
              const Text(
                'مصدر الفيديو',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _videoSource = 'url'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _videoSource == 'url'
                              ? Colors.blue.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _videoSource == 'url'
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _videoSource == 'url'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            const Text('رابط مباشر'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _videoSource = 'vimeo'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _videoSource == 'vimeo'
                              ? Colors.blue.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _videoSource == 'vimeo'
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _videoSource == 'vimeo'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            const Text('Vimeo'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_videoSource == 'url')
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الفيديو',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (_videoSource == 'url' && (v?.isEmpty ?? true)) {
                      return 'الرجاء إدخال رابط الفيديو';
                    }
                    return null;
                  },
                ),

              if (_videoSource == 'vimeo')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _vimeoIdController,
                      decoration: const InputDecoration(
                        labelText: 'معرّف فيديو Vimeo (Video ID)',
                        border: OutlineInputBorder(),
                        hintText: '123456789',
                      ),
                      validator: (v) {
                        if (_videoSource == 'vimeo' && (v?.isEmpty ?? true)) {
                          return 'الرجاء إدخال معرّف فيديو Vimeo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'مثال: 123456789 من https://vimeo.com/123456789',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave({
                          'episode_number':
                              int.parse(_episodeNumberController.text),
                          'title': _titleController.text,
                          'duration':
                              int.tryParse(_durationController.text) ?? 0,
                          'video_url':
                              _videoSource == 'url' ? _videoUrlController.text : '',
                          'vimeo_id':
                              _videoSource == 'vimeo' ? _vimeoIdController.text : '',
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
