import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [CustomTextField] — Input field reusable dengan validasi, animasi fokus,
/// dan styling konsisten.
///
/// Parameter:
///   [controller]         – TextEditingController untuk mengakses value.
///   [hintText]           – placeholder text.
///   [labelText]          – label di atas field (opsional).
///   [prefixIcon]         – ikon di kiri field.
///   [suffixIcon]         – ikon di kanan field (misal: clear button).
///   [obscureText]        – sembunyikan input (untuk password).
///   [keyboardType]       – jenis keyboard (text, email, number, dll).
///   [textCapitalization] – auto-kapitalisasi (words, sentences, dll).
///   [maxLength]          – batasan karakter maksimal.
///   [maxLines]           – jumlah baris (1 = single line, >1 = textarea).
///   [validator]          – fungsi validasi Form (nullable String Function(String?)).
///   [onChanged]          – callback saat value berubah.
///   [onFieldSubmitted]   – callback saat user tekan enter/done.
///   [enabled]            – aktifkan atau nonaktifkan field.
///   [autofocus]          – langsung fokus saat widget muncul.
///   [inputFormatters]    – formatter input (misal: hanya angka).
///
/// Contoh pemakaian:
/// ```dart
/// CustomTextField(
///   controller: _nameController,
///   hintText: 'Masukkan nama kamu',
///   prefixIcon: Icons.person_outline,
///   validator: (value) {
///     if (value == null || value.trim().isEmpty) {
///       return 'Nama tidak boleh kosong';
///     }
///     return null;
///   },
/// )
/// ```
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warna dinamis berdasarkan state fokus
    final borderColor = _isFocused
        ? theme.colorScheme.primary
        : (isDark ? Colors.grey.shade700 : Colors.grey.shade300);

    final fillColor = widget.enabled
        ? (isDark ? const Color(0xFF374151) : Colors.grey.shade50)
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label opsional di atas field
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Field dengan animasi fokus
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 2.0 : 1.2,
            ),
            color: fillColor,
            // Shadow halus saat fokus
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? theme.colorScheme.primary
                          : Colors.grey.shade500,
                      size: 22,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              // Hilangkan border bawaan — pakai AnimatedContainer di luar
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 12 : 16,
                vertical: 16,
              ),
              // Sembunyikan counter bawaan maxLength
              counterText: '',
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
