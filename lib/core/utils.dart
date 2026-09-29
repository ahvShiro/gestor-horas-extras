import 'package:flutter/services.dart';

class Utils {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira sua senha';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter ao menos 1 letra maiúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter ao menos 1 letra minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter ao menos 1 número';
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\]\\/;`~]').hasMatch(value)) {
      return 'A senha deve conter ao menos 1 caractere especial';
    }

    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Insira um email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Insira um email válido';
    }
    return null;
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static DateTime? parseDateBr(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
    if (match == null) {
      return null;
    }

    final day = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final year = int.tryParse(match.group(3) ?? '');
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  static int parseHourMinuteToMinutes(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return -1;
    }

    final match = RegExp(r'^(\d{1,2}):([0-5]\d)$').firstMatch(text);
    if (match == null) {
      return -1;
    }

    final hours = int.tryParse(match.group(1) ?? '0');
    final minutes = int.tryParse(match.group(2) ?? '0');
    if (hours == null || minutes == null || hours < 0 || hours > 23) {
      return -1;
    }

    return (hours * 60) + minutes;
  }

  static DateTime? parseHourMinuteToDateTime(String value, DateTime date) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (match == null) return null;

    final hours = int.tryParse(match.group(1) ?? '0');
    final minutes = int.tryParse(match.group(2) ?? '0');
    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;

    return DateTime(date.year, date.month, date.day, hours, minutes);
  }

  static String formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String? validateHourMinute(
    String? value, {
    required bool requiredField,
    String requiredMessage = 'Insira um horário',
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return requiredField ? requiredMessage : null;
    }

    if (parseHourMinuteToMinutes(text) < 0) {
      return 'Use o formato HH:MM';
    }

    return null;
  }

  static TextInputFormatter hourMinuteInputFormatter() {
    return _HourMinuteInputFormatter();
  }

  static String? validateDateBr(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Insira a data';
    }

    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!datePattern.hasMatch(value.trim())) {
      return 'Use o formato dd/MM/aaaa';
    }

    return null;
  }

  static String formatMinutes(int totalMinutes) {
    final safeMinutes = totalMinutes < 0 ? 0 : totalMinutes;
    final hours = safeMinutes ~/ 60;
    final minutes = safeMinutes % 60;
    return '${hours}h${minutes.toString().padLeft(2, '0')}min';
  }
}

class _HourMinuteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final clipped = digitsOnly.length > 4
        ? digitsOnly.substring(0, 4)
        : digitsOnly;
    final formattedText = clipped.length <= 2
        ? clipped
        : '${clipped.substring(0, clipped.length - 2)}:${clipped.substring(clipped.length - 2)}';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
