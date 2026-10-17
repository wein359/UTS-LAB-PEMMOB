import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/question.dart';
import '../data/quiz_data.dart';

/// Enum untuk merepresentasikan status/fase kuis saat ini.
enum QuizStatus {
  initial, // Belum mulai, menunggu input nama pengguna
  inProgress, // Kuis sedang berjalan
  finished, // Kuis selesai, tampilkan hasil
}

/// [QuizProvider] mengelola seluruh state kuis menggunakan ChangeNotifier.
///
/// Perubahan di Tahap 3:
///   - [answerQuestion] tidak lagi auto-navigasi ke soal berikutnya.
///     UI (QuizScreen) yang mengontrol kapan lanjut via tombol "Selanjutnya".
///   - Getter [canGoNext] : true jika soal sudah dijawab (tombol aktif).
///   - Getter [liveScore] : hitung skor jawaban benar sampai soal saat ini.
///   - Timer tetap berjalan; saat habis soal otomatis ditandai skip,
///     lalu [canGoNext] = true agar tombol aktif.
class QuizProvider extends ChangeNotifier {
  // ─── Konstanta ─────────────────────────────────────────────────────────────
  static const int secondsPerQuestion = 15;

  // ─── State ─────────────────────────────────────────────────────────────────
  String _username = '';
  int _currentQuestionIndex = 0;
  final Map<int, int> _userAnswers = {}; // {questionId: answerIndex}
  int _score = 0;
  QuizStatus _status = QuizStatus.initial;
  int _remainingSeconds = secondsPerQuestion;
  Timer? _timer;

  // Tandai bahwa timer soal ini sudah habis (soal di-skip otomatis)
  bool _timerExpired = false;

  final List<Question> _questions = quizQuestions;

  // ─── Getters ───────────────────────────────────────────────────────────────
  String get username => _username;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get userAnswers => Map.unmodifiable(_userAnswers);
  int get score => _score;
  QuizStatus get status => _status;
  int get remainingSeconds => _remainingSeconds;
  bool get timerExpired => _timerExpired;
  List<Question> get questions => List.unmodifiable(_questions);
  int get totalQuestions => _questions.length;

  Question get currentQuestion => _questions[_currentQuestionIndex];

  bool get isCurrentAnswered =>
      _userAnswers.containsKey(currentQuestion.id) || _timerExpired;

  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;

  /// Tombol "Selanjutnya"/"Selesai" aktif hanya jika soal sudah dijawab
  /// atau timer habis.
  bool get canGoNext => isCurrentAnswered;

  /// Skor live: jumlah jawaban benar dari soal yang sudah dijawab sejauh ini.
  int get liveScore {
    int correct = 0;
    for (final q in _questions) {
      final ans = _userAnswers[q.id];
      if (ans != null && ans == q.correctAnswerIndex) correct++;
    }
    return correct;
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  /// Mulai kuis baru dengan nama pengguna.
  void startQuiz(String name) {
    _username = name.trim();
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _score = 0;
    _timerExpired = false;
    _status = QuizStatus.inProgress;
    _startTimer();
    notifyListeners();
  }

  /// Simpan jawaban pengguna.
  /// Tidak lagi auto-navigasi — UI yang memutuskan kapan lanjut.
  void answerQuestion(int answerIndex) {
    if (isCurrentAnswered) return; // cegah double-answer

    _userAnswers[currentQuestion.id] = answerIndex;
    _stopTimer(); // hentikan timer begitu dijawab
    notifyListeners();
  }

  /// Lanjut ke soal berikutnya (dipanggil dari tombol "Selanjutnya").
  /// Hanya bisa dilakukan jika [canGoNext] == true.
  void goToNextQuestion() {
    if (!canGoNext) return;

    if (isLastQuestion) {
      _finishQuiz();
    } else {
      _currentQuestionIndex++;
      _timerExpired = false;
      _startTimer();
      notifyListeners();
    }
  }

  /// Reset kuis ke keadaan awal.
  void resetQuiz() {
    _stopTimer();
    _username = '';
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _score = 0;
    _remainingSeconds = secondsPerQuestion;
    _timerExpired = false;
    _status = QuizStatus.initial;
    notifyListeners();
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  void _finishQuiz() {
    _stopTimer();
    _calculateScore();
    _status = QuizStatus.finished;
    notifyListeners();
  }

  void _calculateScore() {
    int correct = 0;
    for (final q in _questions) {
      final ans = _userAnswers[q.id];
      if (ans != null && ans == q.correctAnswerIndex) correct++;
    }
    _score = correct;
  }

  void _startTimer() {
    _remainingSeconds = secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Waktu habis → soal ini di-skip, aktifkan tombol next
        _stopTimer();
        _timerExpired = true;
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
