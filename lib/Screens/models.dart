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
}