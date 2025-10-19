import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/custom_button.dart';
import 'sensor_station_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hidePass = true;

  Future<void> _handleLogin() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      _showMsg("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    bool isValid = await StorageService.validateLogin(
      _username.text,
      _password.text,
    );

    if (isValid) {
      await StorageService.setLoginStatus(true, _username.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SensorStationScreen()),
      );
    } else {
      _showMsg('Sai tài khoản hoặc mật khẩu');
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/sensor.png', width: 60, height: 60),
              const SizedBox(height: 10),
              const Text(
                'Sensor Station',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                label: 'Tên Người Dùng',
                hint: 'user name',
                controller: _username,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Mật khẩu',
                hint: '********',
                controller: _password,
                isPassword: true,
                obscure: _hidePass,
                onToggle: () => setState(() => _hidePass = !_hidePass),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              CustomButton(text: 'Đăng nhập', onPressed: _handleLogin),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Chưa có tài khoản?",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      ' Đăng ký',
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
