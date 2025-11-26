import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/imdb_service.dart';

class IMDbSearchDialog extends StatefulWidget {
  final String contentType; // 'movie' or 'series'
  final Function(Map<String, dynamic>) onSelect;

  const IMDbSearchDialog({
    super.key,
    required this.contentType,
    required this.onSelect,
  });

  @override
  State<IMDbSearchDialog> createState() => _IMDbSearchDialogState();
}

class _IMDbSearchDialogState extends State<IMDbSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final IMDbService _imdbService = IMDbService();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await _imdbService.search(
        _searchController.text.trim(),
        type: widget.contentType,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      if (results.isEmpty) {
        setState(() {
          _errorMessage = 'لم يتم العثور على نتائج';
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'حدث خطأ أثناء البحث';
      });
    }
  }

  Future<void> _selectItem(String imdbId) async {
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final details = await _imdbService.getDetails(imdbId);

      if (details != null) {
        widget.onSelect(details);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage = 'فشل في جلب التفاصيل';
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء جلب التفاصيل';
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'بحث في IMDb',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Field
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.contentType == 'movie'
                    ? 'ابحث عن فيلم...'
                    : 'ابحث عن مسلسل...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2A2A3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 12),

            // Search Button
            ElevatedButton(
              onPressed: _isSearching ? null : _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSearching
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'بحث',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Results
            Expanded(
              child: _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoadingDetails) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'جاري تحميل التفاصيل...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'ابحث عن ${widget.contentType == 'movie' ? 'فيلم' : 'مسلسل'}',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildResultItem(item);
      },
    );
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    final title = item['Title'] ?? 'Unknown';
    final year = item['Year'] ?? '';
    final poster = item['Poster'] ?? '';
    final imdbId = item['imdbID'] ?? '';
    final type = item['Type'] ?? '';

    return Card(
      color: const Color(0xFF2A2A3E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _selectItem(imdbId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: poster != 'N/A' && poster.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: poster,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey[800],
                          child: const Icon(Icons.movie, color: Colors.white54),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 90,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (year.isNotEmpty) ...[
                          const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            year,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (type.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type == 'movie' ? 'فيلم' : 'مسلسل',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Select Icon
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.amber,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
