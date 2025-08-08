import 'package:flutter/material.dart';

class CreateRecipeNextPlaceholder extends StatelessWidget {
  const CreateRecipeNextPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            'Siguiente paso (placeholder)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}


