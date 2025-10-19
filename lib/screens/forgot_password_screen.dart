import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _hideNewPass = true;
  bool _hideConfirmPass = true;

  Future<void> _handleResetPassword() async {
    if (_username.text.isEmpty ||
        _email.text.isEmpty ||
        _newPassword.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      _showMsg("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    bool isValid = await StorageService.validateUserData(
      _username.text,
      _email.text,
    );

    if (!isValid) {
      _showMsg('Tên người dùng hoặc email không đúng!');
      return;
    }

    if (_newPassword.text != _confirmPassword.text) {
      _showMsg('Mật khẩu xác nhận không khớp!');
      return;
    }

    await StorageService.updatePassword(_newPassword.text);
    _showMsg('Đổi mật khẩu thành công!');

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
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
        title: const Text('Quên mật khẩu'),
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
                'Đặt lại mật khẩu',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),

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
                label: 'Mật khẩu mới',
                hint: '********',
                controller: _newPassword,
                isPassword: true,
                obscure: _hideNewPass,
                onToggle: () => setState(() => _hideNewPass = !_hideNewPass),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Xác nhận mật khẩu mới',
                hint: '********',
                controller: _confirmPassword,
                isPassword: true,
                obscure: _hideConfirmPass,
                onToggle: () =>
                    setState(() => _hideConfirmPass = !_hideConfirmPass),
              ),

              const SizedBox(height: 40),

              CustomButton(
                text: 'Đổi mật khẩu',
                onPressed: _handleResetPassword,
                height: 45,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
