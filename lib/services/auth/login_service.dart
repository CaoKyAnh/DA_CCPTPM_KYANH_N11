import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hàm đăng nhập
  Future<User?> login(String email, String password) async {
    try {
      // Đăng nhập bằng email và mật khẩu
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential
          .user; // Trả về thông tin người dùng nếu đăng nhập thành công
    } catch (e) {
      throw Exception('Error logging in: ${e.toString()}');
    }
  }
}
