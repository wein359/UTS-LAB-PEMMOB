/// Model untuk satu soal kuis pilihan ganda.
///
/// [id]                 – identifier unik tiap soal.
/// [questionText]       – teks pertanyaan yang ditampilkan.
/// [options]            – daftar pilihan jawaban (A, B, C, D).
/// [correctAnswerIndex] – indeks jawaban benar di dalam [options] (0-based).
class Question {
  final int id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  /// Kembalikan String jawaban benar berdasarkan [correctAnswerIndex].
  String get correctAnswer => options[correctAnswerIndex];
}
