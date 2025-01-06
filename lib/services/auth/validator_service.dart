class ValidatorService {
  bool isValidPassword(String password) {
    // Kiểm tra password có nhiều hơn 8 ký tự
    if (password.length < 8) return false;

    // Kiểm tra có ít nhất 1 chữ hoa, 1 chữ thường, và 1 số
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));

    return hasUppercase && hasLowercase && hasDigits;
  }

  bool isValidEmail(String email) {
    // Biểu thức kiểm tra định dạng email
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailPattern).hasMatch(email);
  }

  bool isValidCode(String code) {
    if (code.length != 6) return false;
    bool allUppercase = !code.contains(RegExp(r'[a-z]'));

    return allUppercase;
  }

  bool isValidLICNumber(String licNumber) {
    // Kiểm tra LICNumber có đúng 12 ký tự và tất cả là số
    return RegExp(r'^[0-9]{12}$').hasMatch(licNumber);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    // Kiểm tra LICNumber có đúng 12 ký tự và tất cả là số
    return RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber);
  }
}
