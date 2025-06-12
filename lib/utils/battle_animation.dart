// utils/battle_animation.dart

import 'dart:ui';

import 'package:PokeStats/Screens/models.dart';
import 'package:flutter/material.dart';

class BattleAnimation extends StatefulWidget {
  final PokemonDetail pokemon1;
  final PokemonDetail pokemon2;
  final VoidCallback onAnimationComplete;
  final String winnerName;

  const BattleAnimation({
    Key? key,
    required this.pokemon1,
    required this.pokemon2,
    required this.onAnimationComplete,
    required this.winnerName,
  }) : super(key: key);

  @override
  _BattleAnimationState createState() => _BattleAnimationState();
}

class _BattleAnimationState extends State<BattleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _leftPositionAnim;
  late Animation<double> _rightPositionAnim;
  late Animation<double> _flashAnim;
  late Animation<double> _winnerOpacityAnim;
  late Animation<double> _winnerScaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));

    // Ambos Pokémon se mueven hacia el centro (50 y 50)
    _leftPositionAnim = Tween<double>(begin: -150, end: 50).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _rightPositionAnim = Tween<double>(begin: -150, end: 50).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    // Flash amarillo en la mitad de la animación (ataque)
    _flashAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.65)),
    );

    // Animación para mostrar al ganador
    _winnerOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    _winnerScaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = 120.0;
    return SizedBox(
      height: 220,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Fondo flash cuando atacan
              Opacity(
                opacity: _flashAnim.value,
                child: Container(
                  color: Colors.yellowAccent.withOpacity(0.6),
                ),
              ),

              // Pokémon 1
              Positioned(
                left: _leftPositionAnim.value,
                top: 40,
                child: Transform.scale(
                  scale: _flashAnim.value > 0.5 ? 1.1 : 1.0, // pequeño zoom en ataque
                  child: Image.network(
                    widget.pokemon1.imageUrl ?? '',
                    width: size,
                    height: size,
                  ),
                ),
              ),

              // Pokémon 2
              Positioned(
                right: _rightPositionAnim.value,
                top: 40,
                child: Transform.scale(
                  scale: _flashAnim.value > 0.5 ? 1.1 : 1.0,
                  child: Image.network(
                    widget.pokemon2.imageUrl ?? '',
                    width: size,
                    height: size,
                  ),
                ),
              ),

              // Texto ganador animado
              Positioned(
                bottom: 10,
                child: Opacity(
                  opacity: _winnerOpacityAnim.value,
                  child: Transform.scale(
                    scale: _winnerScaleAnim.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.winnerName} gana!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 4,
                              color: Colors.yellow,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}