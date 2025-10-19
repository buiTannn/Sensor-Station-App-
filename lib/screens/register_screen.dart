import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/custom_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _hidePass = true;
  bool _hideConfirm = true;

  Future<void> _handleRegister() async {
    if (_username.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _confirmPass.text.isEmpty) {
      _showMsg("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (_password.text != _confirmPass.text) {
      _showMsg('Mật khẩu không khớp');
      return;
    }

    await StorageService.saveUserData(
      _username.text,
      _email.text,
      _password.text,
    );
    _showMsg('Đăng ký thành công!');
    Navigator.pop(context);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/sensor.png', width: 45, height: 45),
              const SizedBox(height: 6),
              const Text(
                'Sensor Station',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Đăng ký tài khoản',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 10),

              CustomTextField(
                label: 'Tên người dùng',
                hint: 'user name',
                controller: _username,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Email',
                hint: 'Example@gmail.com',
                controller: _email,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Mật khẩu',
                hint: '********',
                controller: _password,
                isPassword: true,
                obscure: _hidePass,
                onToggle: () => setState(() => _hidePass = !_hidePass),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Nhập lại mật khẩu',
                hint: '********',
                controller: _confirmPass,
                isPassword: true,
                obscure: _hideConfirm,
                onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
              ),

              const SizedBox(height: 40),

              CustomButton(
                text: 'Đăng ký',
                onPressed: _handleRegister,
                height: 45,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Đã có tài khoản?",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      ' Đăng nhập',
                      style: TextStyle(
                        color: Color(0xFF5B4CF5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
