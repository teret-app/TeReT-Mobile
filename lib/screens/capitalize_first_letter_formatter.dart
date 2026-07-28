import 'package:flutter/services.dart';

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  const CapitalizeFirstLetterFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    final firstNonSpaceIndex = text.indexOf(RegExp(r'\S'));

    if (firstNonSpaceIndex == -1) {
      return newValue;
    }

    final firstLetter = text[firstNonSpaceIndex];
    final capitalizedLetter = firstLetter.toUpperCase();

    if (firstLetter == capitalizedLetter) {
      return newValue;
    }

    final updatedText =
        text.substring(0, firstNonSpaceIndex) +
            capitalizedLetter +
            text.substring(firstNonSpaceIndex + 1);

    return newValue.copyWith(
      text: updatedText,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}