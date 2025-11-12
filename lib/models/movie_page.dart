import 'movie_model.dart';

class MoviePage {
  final List<MovieModel> items;
  final String? next;

  MoviePage({
    required this.items,
    this.next,
  });
}
