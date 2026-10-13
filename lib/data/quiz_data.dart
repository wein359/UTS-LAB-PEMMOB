import '../models/question.dart';

/// Daftar soal kuis seputar Pemrograman Mobile & Flutter.
/// Tambah atau ganti soal di sini sesuai kebutuhan UTS.
const List<Question> quizQuestions = [
  Question(
    id: 1,
    questionText: 'Apa kepanjangan dari SDK dalam konteks Flutter?',
    options: [
      'Software Development Kit',
      'System Design Knowledge',
      'Source Data Kernel',
      'Structured Dart Kit',
    ],
    correctAnswerIndex: 0,
  ),
  Question(
    id: 2,
    questionText: 'Bahasa pemrograman utama yang digunakan Flutter adalah …',
    options: ['Kotlin', 'Swift', 'Dart', 'JavaScript'],
    correctAnswerIndex: 2,
  ),
  Question(
    id: 3,
    questionText:
        'Widget yang digunakan untuk membuat tata letak kolom vertikal di Flutter adalah …',
    options: ['Row', 'Stack', 'Column', 'Wrap'],
    correctAnswerIndex: 2,
  ),
  Question(
    id: 4,
    questionText:
        'Perintah Flutter untuk mengambil semua dependency di pubspec.yaml adalah …',
    options: [
      'flutter install',
      'flutter pub get',
      'dart pub fetch',
      'flutter get packages',
    ],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 5,
    questionText:
        'Manakah yang BUKAN merupakan jenis State Management di Flutter?',
    options: ['Provider', 'Riverpod', 'BLoC', 'Redux Native'],
    correctAnswerIndex: 3,
  ),
  Question(
    id: 6,
    questionText:
        'Widget mana yang tepat digunakan untuk menampilkan daftar item yang bisa di-scroll?',
    options: ['GridView', 'ListView', 'Column', 'Container'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 7,
    questionText:
        'Apa fungsi dari metode setState() pada StatefulWidget?',
    options: [
      'Menghapus state widget',
      'Membuat widget baru',
      'Memaksa Flutter me-rebuild UI setelah perubahan state',
      'Menyimpan data ke database lokal',
    ],
    correctAnswerIndex: 2,
  ),
  Question(
    id: 8,
    questionText:
        'File konfigurasi utama proyek Flutter yang menyimpan nama paket dan dependency disebut …',
    options: [
      'main.dart',
      'AndroidManifest.xml',
      'pubspec.yaml',
      'build.gradle',
    ],
    correctAnswerIndex: 2,
  ),
  Question(
    id: 9,
    questionText:
        'Hot Reload di Flutter berfungsi untuk …',
    options: [
      'Me-restart emulator',
      'Menyegarkan UI tanpa kehilangan state aplikasi',
      'Mem-build APK secara otomatis',
      'Menghapus cache proyek',
    ],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 10,
    questionText:
        'Manakah widget yang digunakan untuk navigasi antar halaman di Flutter?',
    options: ['Router', 'Navigator', 'PageView', 'Switcher'],
    correctAnswerIndex: 1,
  ),
];
