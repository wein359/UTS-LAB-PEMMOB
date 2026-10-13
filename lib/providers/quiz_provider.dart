import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../data/quiz_data.dart';

/// Enum untuk merepresentasikan status/fase kuis saat ini.
enum QuizStatus {
  initial,    // Belum mulai, menunggu input nama pengguna
  inProgress, // Kuis sedang berjalan
  finished,   // Kuis selesai, tampilkan hasil
}

/// [QuizProvider] mengelola seluruh state kuis menggunakan ChangeNotifier
/// sehingga bisa dikonsumsi oleh widget melalui Provider/Consumer.
///
/// State yang dikelola:
///   - [username]             : nama pengguna yang diinput di halaman awal
///   - [currentQuestionIndex] : indeks soal yang sedang ditampilkan
///   - [userAnswers]          : map <questionId, answerIndex> jawaban pengguna
///   - [score]                : skor akhir (dihitung saat kuis selesai)
///   - [status]               : fase kuis (initial / inProgress / finished)
///   - [remainingSeconds]     : countdown timer per soal (default 15 detik)
class QuizProvider extends ChangeNotifier {
  // ─── Konstanta ────────────────────────────────────────────────────────────
  static const int _secondsPerQuestion = 15;

  // ─── State ────────────────────────────────────────────────────────────────
  String _username = '';
  int _currentQuestionIndex = 0;
  final Map<int, int> _userAnswers = {}; // {questionId: answerIndex}
  int _score = 0;
  QuizStatus _status = QuizStatus.initial;
  int _remainingSeconds = _secondsPerQuestion;
  Timer? _timer;

  // Daftar soal diambil dari dummy data; bisa diganti dengan fetch API nanti.
  final List<Question> _questions = quizQuestions;

  // ─── Getters (read-only untuk UI) ────────────────────────────────────────
  String get username => _username;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get userAnswers => Map.unmodifiable(_userAnswers);
  int get score => _score;
  QuizStatus get status => _status;
  int get remainingSeconds => _remainingSeconds;
  List<Question> get questions => List.unmodifiable(_questions);
  int get totalQuestions => _questions.length;

  /// Soal yang sedang aktif ditampilkan.
  Question get currentQuestion => _questions[_currentQuestionIndex];

  /// Apakah soal saat ini sudah dijawab.
  bool get isCurrentAnswered =>
      _userAnswers.containsKey(currentQuestion.id);

  /// Apakah ini soal terakhir.
  bool get isLastQuestion =>
      _currentQuestionIndex == _questions.length - 1;

  // ─── Actions ─────────────────────────────────────────────────────────────

  /// Simpan nama pengguna dan mulai kuis.
  void startQuiz(String name) {
    _username = name.trim();
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _score = 0;
    _status = QuizStatus.inProgress;
    _startTimer();
    notifyListeners();
  }

  /// Simpan jawaban pengguna untuk soal saat ini, lalu maju ke soal berikutnya
  /// atau selesaikan kuis jika sudah di soal terakhir.
  void answerQuestion(int answerIndex) {
    if (isCurrentAnswered) return; // Cegah double-answer

    _userAnswers[currentQuestion.id] = answerIndex;
    _stopTimer();
    notifyListeners();

    // Otomatis lanjut setelah 800ms agar user sempat lihat pilihan terpilih
    Future.delayed(const Duration(milliseconds: 800), () {
      if (isLastQuestion) {
        _finishQuiz();
      } else {
        nextQuestion();
      }
    });
  }

  /// Paksa lanjut ke soal berikutnya (dipanggil saat timer habis).
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _resetTimer();
      notifyListeners();
    } else {
      _finishQuiz();
    }
  }

  /// Reset kuis ke keadaan awal (kembali ke halaman welcome).
  void resetQuiz() {
    _stopTimer();
    _username = '';
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _score = 0;
    _remainingSeconds = _secondsPerQuestion;
    _status = QuizStatus.initial;
    notifyListeners();
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  void _finishQuiz() {
    _stopTimer();
    _calculateScore();
    _status = QuizStatus.finished;
    notifyListeners();
  }

  void _calculateScore() {
    int correct = 0;
    for (final question in _questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer != null && userAnswer == question.correctAnswerIndex) {
        correct++;
      }
    }
    _score = correct;
  }

  void _startTimer() {
    _remainingSeconds = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Waktu habis → tandai soal ini tidak terjawab, lanjut
        _stopTimer();
        nextQuestion();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetTimer() {
    _stopTimer();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
