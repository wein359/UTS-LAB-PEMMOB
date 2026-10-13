import 'package:flutter/material.dart';
import '../models/question.dart';

/// Menampilkan teks pertanyaan di dalam Card bergaya.
class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          question.questionText,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
