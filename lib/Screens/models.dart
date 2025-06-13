import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonSummary {
  final String name;
  final String url;

  PokemonSummary({required this.name, required this.url});

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    return PokemonSummary(
      name: json['name'],
      url: json['url'],
    );
  }

  Future<String?> getImageUrl() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['sprites']['front_default'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class PokemonDetail {
  final String name;
  final String? imageUrl;
  final Map<String, int> stats;

  PokemonDetail({
    required this.name,
    this.imageUrl,
    required this.stats,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    Map<String, int> extractedStats = {};
    for (var stat in json['stats']) {
      String statName = stat['stat']['name'];
      int baseStat = stat['base_stat'];
      extractedStats[statName] = baseStat;
    }

    return PokemonDetail(
      name: json['name'],
      imageUrl: json['sprites']['front_default'],
      stats: extractedStats,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonDetail &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

// Función para obtener detalles de un Pokemon específico en comparar
Future<List<PokemonDetail>> fetchPokemonDetailsBatch(int offset, int limit) async {
  final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List results = data['results'];

    List<Future<PokemonDetail?>> futures = results.map((item) async {
      try {
        final detailResponse = await http.get(Uri.parse(item['url']));
        if (detailResponse.statusCode == 200) {
          final detailData = json.decode(detailResponse.body);
          return PokemonDetail.fromJson(detailData);
        }
      } catch (_) {}
      return null;
    }).toList();

    final details = await Future.wait(futures);
    return details.whereType<PokemonDetail>().toList();
  } else {
    throw Exception('Error al cargar los Pokémon');
  }
}

