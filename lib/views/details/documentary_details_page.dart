import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DocumentaryDetailsPage extends StatefulWidget {
  final int documentaryId;

  const DocumentaryDetailsPage({super.key, required this.documentaryId});

  @override
  State<DocumentaryDetailsPage> createState() => _DocumentaryDetailsPageState();
}

class _DocumentaryDetailsPageState extends State<DocumentaryDetailsPage> {
  final _demoDocumentary = {
    'id': 1,
    'title': 'Planet Earth',
    'titleAr': 'كوكب الأرض',
    'description': 'سلسلة وثائقية رائدة تستكشف جمال وتنوع الحياة على كوكب الأرض من خلال لقطات مذهلة',
    'poster': 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
    'backdrop': 'https://image.tmdb.org/t/p/original/1R6cvRtZgsYCkh8UFuWFN33xBP4.jpg',
    'rating': 9.4,
    'year': 2006,
    'duration': '550 دقيقة',
    'episodes': 11,
    'narrator': 'David Attenborough',
    'genres': ['طبيعة', 'حيوانات', 'بيئة'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 30),
                _buildDetailsSection(),
                const SizedBox(height: 30),
                _buildRelatedDocumentaries(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _demoDocumentary['backdrop'] as String,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF121212).withValues(alpha: 0.7),
                    const Color(0xFF121212),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'وثائقي',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _demoDocumentary['titleAr'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${_demoDocumentary['rating']}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                '${_demoDocumentary['year']}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.video_library, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                '${_demoDocumentary['episodes']} حلقات',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_demoDocumentary['genres'] as List<String>).map((genre) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00A86B)),
                ),
                child: Text(
                  genre,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('مشاهدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              iconSize: 28,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share, color: Colors.white),
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نبذة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _demoDocumentary['description'] as String,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'الراوي: ',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              Text(
                _demoDocumentary['narrator'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedDocumentaries() {
    final relatedDocs = [
      {'title': 'Blue Planet', 'poster': 'https://image.tmdb.org/t/p/w500/674DSERJUmoI739FcSZNFJhRGsH.jpg'},
      {'title': 'Our Planet', 'poster': 'https://image.tmdb.org/t/p/w500/3PXLw0zjMalV98sFPUhZUd7BCQD.jpg'},
      {'title': 'Cosmos', 'poster': 'https://image.tmdb.org/t/p/w500/4WJ1GL52fVPOQ8wogrbGyP6yaBK.jpg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'وثائقيات مشابهة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: relatedDocs.length,
            itemBuilder: (context, index) {
              final doc = relatedDocs[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(left: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: doc['poster'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
