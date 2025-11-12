import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import 'widgets/admin_sidebar.dart';

class AdminMovieFormScreen extends StatefulWidget {
  final int? movieId; // null for add, not null for edit

  const AdminMovieFormScreen({super.key, this.movieId});

  @override
  State<AdminMovieFormScreen> createState() => _AdminMovieFormScreenState();
}

class _AdminMovieFormScreenState extends State<AdminMovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _token;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _durationController = TextEditingController();
  final _directorController = TextEditingController();
  final _castController = TextEditingController();
  final _genreController = TextEditingController();
  final _ratingController = TextEditingController();
  final _trailerUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();

  String? _posterPath;
  String? _thumbnailPath;
  String? _videoPath;
  String? _posterUrl;
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    if (widget.movieId != null) {
      _loadMovieData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _durationController.dispose();
    _directorController.dispose();
    _castController.dispose();
    _genreController.dispose();
    _ratingController.dispose();
    _trailerUrlController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadMovieData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null && widget.movieId != null) {
        final movie = await AdminService.getMovieDetails(
          token: _token!,
          id: widget.movieId!,
        );

        if (movie != null) {
          setState(() {
            _titleController.text = movie['title'] ?? '';
            _descriptionController.text = movie['description'] ?? '';
            _yearController.text = movie['year']?.toString() ?? '';
            _durationController.text = movie['duration']?.toString() ?? '';
            _directorController.text = movie['director'] ?? '';
            _castController.text = movie['cast'] ?? '';
            _genreController.text = movie['genre'] ?? '';
            _ratingController.text = movie['rating']?.toString() ?? '';
            _trailerUrlController.text = movie['trailer_url'] ?? '';
            _videoUrlController.text = movie['video_url'] ?? '';
            _posterUrl = movie['poster_url'];
            _thumbnailUrl = movie['thumbnail_url'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading movie: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result;

      if (type == 'video') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            if (type == 'poster') {
              _posterPath = file.path!;
            } else if (type == 'thumbnail') {
              _thumbnailPath = file.path!;
            } else if (type == 'video') {
              _videoPath = file.path!;
            }
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في اختيار الملف: $e')),
        );
      }
    }
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token == null) {
        throw Exception('No auth token found');
      }

      // Upload files first if selected
      String? posterUrl = _posterUrl;
      String? thumbnailUrl = _thumbnailUrl;
      String? videoUrl = _videoUrlController.text;

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

      if (_videoPath != null) {
        final result = await AdminService.uploadMedia(
          token: _token!,
          filePath: _videoPath!,
          type: 'video',
        );
        if (result != null) videoUrl = result['url'];
      }

      // Prepare movie data
      final movieData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'year': int.tryParse(_yearController.text) ?? 2024,
        'duration': int.tryParse(_durationController.text) ?? 0,
        'director': _directorController.text,
        'cast': _castController.text,
        'genre': _genreController.text,
        'rating': double.tryParse(_ratingController.text) ?? 0.0,
        'trailer_url': _trailerUrlController.text,
        'video_url': videoUrl ?? '',
        'poster_url': posterUrl ?? '',
        'thumbnail_url': thumbnailUrl ?? '',
      };

      // Save movie
      final result = widget.movieId == null
          ? await AdminService.createMovie(token: _token!, data: movieData)
          : await AdminService.updateMovie(
              token: _token!,
              id: widget.movieId!,
              data: movieData,
            );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.movieId == null
                ? 'تم إضافة الفيلم بنجاح'
                : 'تم تحديث الفيلم بنجاح'),
          ),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to save movie');
      }
    } catch (e) {
      print('Error saving movie: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حفظ الفيلم: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
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
            color: Colors.white.withOpacity(0.1),
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
            widget.movieId == null ? 'إضافة فيلم جديد' : 'تعديل الفيلم',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildTextField(
                controller: _titleController,
                label: 'عنوان الفيلم',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان الفيلم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'الوصف',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف الفيلم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Year and Duration
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _yearController,
                      label: 'السنة',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال السنة';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      label: 'المدة (بالدقائق)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Director and Cast
              _buildTextField(
                controller: _directorController,
                label: 'المخرج',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _castController,
                label: 'الممثلون (مفصولون بفواصل)',
              ),
              const SizedBox(height: 16),

              // Genre and Rating
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _genreController,
                      label: 'النوع',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _ratingController,
                      label: 'التقييم (0-10)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // URLs
              _buildTextField(
                controller: _trailerUrlController,
                label: 'رابط الإعلان',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _videoUrlController,
                label: 'رابط الفيديو',
                validator: (value) {
                  if (_videoPath == null &&
                      (value == null || value.isEmpty)) {
                    return 'الرجاء إدخال رابط الفيديو أو رفع ملف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // File Uploads
              const Text(
                'الملفات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Poster
              _buildFileUpload(
                label: 'صورة الملصق',
                filePath: _posterPath,
                fileUrl: _posterUrl,
                onTap: () => _pickFile('poster'),
              ),
              const SizedBox(height: 16),

              // Thumbnail
              _buildFileUpload(
                label: 'الصورة المصغرة',
                filePath: _thumbnailPath,
                fileUrl: _thumbnailUrl,
                onTap: () => _pickFile('thumbnail'),
              ),
              const SizedBox(height: 16),

              // Video
              _buildFileUpload(
                label: 'ملف الفيديو (اختياري)',
                filePath: _videoPath,
                onTap: () => _pickFile('video'),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMovie,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.movieId == null ? 'إضافة الفيلم' : 'حفظ التغييرات',
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
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
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
}
