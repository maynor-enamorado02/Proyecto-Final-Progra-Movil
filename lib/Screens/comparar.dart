import 'package:PokeStats/utils/Battle_animation.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CompararPage extends StatefulWidget {
  final List<PokemonDetail> listaPokemones;

  const CompararPage({super.key, required this.listaPokemones});

  @override
  _CompararPageState createState() => _CompararPageState();
}

class _CompararPageState extends State<CompararPage> {
  final List<PokemonDetail> _pokemones = [];
  PokemonDetail? _pokemon1;
  PokemonDetail? _pokemon2;
  int _offset = 0;
  final int _limit = 50;
  bool _isLoading = false;
  bool _showBattleAnimation = false;
  String _winnerName = '';

void _startBattle() {
  if (_pokemon1 != null && _pokemon2 != null) {
    final p1Power = calcularPower(_pokemon1!);
    final p2Power = calcularPower(_pokemon2!);

    setState(() {
      _winnerName = p1Power >= p2Power ? _pokemon1!.name : _pokemon2!.name;
      _showBattleAnimation = true;
    });
  }
}

double calcularPower(PokemonDetail p) {
  return p.stats.values.fold(0, (sum, stat) => sum + stat);
}

void _onBattleComplete() {
  setState(() {
    _showBattleAnimation = false;
  });
}

  @override
  void initState() {
    super.initState();
    _loadNextBatch();
  }

  Future<void> _loadNextBatch() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final nuevos = await fetchPokemonDetailsBatch(_offset, _limit);
    setState(() {
      _pokemones.addAll(nuevos);
      _offset += _limit;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text("Comparar Pokémon"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Selecciona dos Pokémon",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildDropdown((p) => setState(() => _pokemon1 = p), _pokemon1)),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdown((p) => setState(() => _pokemon2 = p), _pokemon2)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _loadNextBatch,
                child: const Text("Cargar más Pokémon"),
              ),
              ElevatedButton(
                onPressed: (_pokemon1 != null && _pokemon2 != null && !_showBattleAnimation) ? _startBattle : null,
                child: const Text("Simular Batalla"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_showBattleAnimation && _pokemon1 != null && _pokemon2 != null)
  BattleAnimation(
    pokemon1: _pokemon1!,
    pokemon2: _pokemon2!,
    onAnimationComplete: _onBattleComplete,
    winnerName: _winnerName,
  )
          else if (_pokemon1 != null && _pokemon2 != null)
            Expanded(
              child: Column(
                children: [
                  _buildResultadoCombate(_pokemon1!, _pokemon2!),
                  const SizedBox(height: 20),
                  Expanded(child: _buildComparisonTable(_pokemon1!, _pokemon2!)),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  "Selecciona dos Pokémon para comparar",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildDropdown(ValueChanged<PokemonDetail?> onChanged, PokemonDetail? selected) {
    return DropdownSearch<PokemonDetail>(
      items: _pokemones,
      selectedItem: selected,
      itemAsString: (PokemonDetail p) => p.name[0].toUpperCase() + p.name.substring(1),
      onChanged: onChanged,
      compareFn: (a, b) => a.name == b.name,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(labelText: "Seleccionar"),
      ),
      filterFn: (item, filter) => item.name.toLowerCase().contains(filter.toLowerCase()),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        showSelectedItems: true,
        itemBuilder: (context, item, isSelected) {
          return ListTile(
            leading: item.imageUrl != null
                ? Image.network(item.imageUrl!, width: 40, height: 40)
                : const SizedBox(width: 40, height: 40),
            title: Text(item.name[0].toUpperCase() + item.name.substring(1)),
          );
        },
      ),
      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null) return const Text("Seleccionar");
        return Row(
          children: [
            if (selectedItem.imageUrl != null)
              Image.network(selectedItem.imageUrl!, width: 40, height: 40),
            const SizedBox(width: 10),
            Text(selectedItem.name[0].toUpperCase() + selectedItem.name.substring(1)),
          ],
        );
      },
    );
  }

  Widget _buildComparisonTable(PokemonDetail p1, PokemonDetail p2) {
    final statKeys = p1.stats.keys.toSet().intersection(p2.stats.keys.toSet()).toList();

    return ListView.builder(
      itemCount: statKeys.length,
      itemBuilder: (context, index) {
        final stat = statKeys[index];
        final v1 = p1.stats[stat] ?? 0;
        final v2 = p2.stats[stat] ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat[0].toUpperCase() + stat.substring(1),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (v1 / 150).clamp(0, 1),
                      color: Colors.blue,
                      backgroundColor: Colors.blue.shade100,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$v1', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 20),
                  Text('$v2', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (v2 / 150).clamp(0, 1),
                      color: Colors.red,
                      backgroundColor: Colors.red.shade100,
                      minHeight: 10,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  double calcularScore(PokemonDetail p) {
    return p.stats.values.fold(0, (sum, stat) => sum + stat);
  }

  Widget _buildResultadoCombate(PokemonDetail p1, PokemonDetail p2) {
    final score1 = calcularScore(p1);
    final score2 = calcularScore(p2);
    final total = score1 + score2;

    final prob1 = (score1 / total) * 100;
    final prob2 = (score2 / total) * 100;

    String ganador;
    if (prob1 > prob2) {
      ganador = "${p1.name.toUpperCase()} tiene más probabilidad de ganar";
    } else if (prob2 > prob1) {
      ganador = "${p2.name.toUpperCase()} tiene más probabilidad de ganar";
    } else {
      ganador = "Empate técnico";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                if (p1.imageUrl != null)
                  Image.network(p1.imageUrl!, width: 80, height: 80),
                const SizedBox(height: 8),
                Text(
                  p1.name[0].toUpperCase() + p1.name.substring(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            Column(
              children: [
                if (p2.imageUrl != null)
                  Image.network(p2.imageUrl!, width: 80, height: 80),
                const SizedBox(height: 8),
                Text(
                  p2.name[0].toUpperCase() + p2.name.substring(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          ganador,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: prob1 / 100,
                color: Colors.blue,
                backgroundColor: Colors.blue.shade100,
                minHeight: 10,
              ),
            ),
            const SizedBox(width: 8),
            Text("${prob1.toStringAsFixed(1)}%"),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: prob2 / 100,
                color: Colors.red,
                backgroundColor: Colors.red.shade100,
                minHeight: 10,
              ),
            ),
            const SizedBox(width: 8),
            Text("${prob2.toStringAsFixed(1)}%"),
          ],
        ),
      ],
    );
  }
}
