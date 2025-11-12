import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  // Demo Data
  final _demoMovie = {
    'id': 1,
    'title': 'The Godfather',
    'titleAr': 'العراب',
    'description': 'قصة عائلة مافيا إيطالية أمريكية ونقل السلطة من الأب إلى الابن المتردد',
    'poster': 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
    'backdrop': 'https://image.tmdb.org/t/p/original/tmU7GeKVybMWFButWEGl2M4GeiP.jpg',
    'rating': 9.2,
    'year': 1972,
    'duration': '175 دقيقة',
    'genres': ['جريمة', 'دراما'],
    'director': 'Francis Ford Coppola',
    'cast': ['Marlon Brando', 'Al Pacino', 'James Caan', 'Robert Duvall'],
    'trailer': 'https://www.youtube.com/watch?v=sY1S34973zA',
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
                _buildCastSection(),
                const SizedBox(height: 30),
                _buildSimilarMovies(),
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
              imageUrl: _demoMovie['backdrop'] as String,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.error, color: Colors.white),
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
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'فيلم',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_demoMovie['rating']}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
          Text(
            _demoMovie['titleAr'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _demoMovie['title'] as String,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_demoMovie['year']}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                _demoMovie['duration'] as String,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_demoMovie['genres'] as List<String>).map((genre) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE50914)),
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
              onPressed: () {
                // Play movie
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('تشغيل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Play trailer
              },
              icon: const Icon(Icons.movie),
              label: const Text('المقدمة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
            'القصة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _demoMovie['description'] as String,
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
                'الإخراج: ',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              Text(
                _demoMovie['director'] as String,
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

  Widget _buildCastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'طاقم التمثيل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: (_demoMovie['cast'] as List<String>).length,
            itemBuilder: (context, index) {
              final actor = (_demoMovie['cast'] as List<String>)[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(left: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      child: Text(
                        actor.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      actor,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarMovies() {
    final similarMovies = [
      {'title': 'The Godfather Part II', 'poster': 'https://image.tmdb.org/t/p/w500/hek3koDUyRQk7FIhPXsa6mT2Zc3.jpg'},
      {'title': 'Goodfellas', 'poster': 'https://image.tmdb.org/t/p/w500/aKuFiU82s5ISJpGZp7YkIr3kCUd.jpg'},
      {'title': 'The Departed', 'poster': 'https://image.tmdb.org/t/p/w500/nT97ifVT2J1yMQmeq20Qblg61T.jpg'},
      {'title': 'Scarface', 'poster': 'https://image.tmdb.org/t/p/w500/iQ5ztdjvteGeboxtmRdXEChJOHh.jpg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'أفلام مشابهة',
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
            itemCount: similarMovies.length,
            itemBuilder: (context, index) {
              final movie = similarMovies[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(left: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: movie['poster'] as String,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
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
