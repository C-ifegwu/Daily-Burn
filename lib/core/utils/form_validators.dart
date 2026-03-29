class FormValidators {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final isNumber = double.tryParse(value);
    if (isNumber == null || isNumber <= 0) {
      return 'Please enter a valid positive number';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
