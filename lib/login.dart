import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SensorStationApp extends StatelessWidget {
  const SensorStationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Station',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hidePass = true;

  Future<void> _handleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('username');
    final savedPass = prefs.getString('password');

    if (_username.text.isEmpty || _password.text.isEmpty) {
      _showMsg("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (savedUser == _username.text && savedPass == _password.text) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SensorMonitoringPage()),
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
              Image.asset(
                'assets/images/sensor.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 10),
              const Text('Sensor Station',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold , color: Colors.white,)),
              const Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              _buildField('Tên người dùng', 'user name', _username),
              const SizedBox(height: 12),
              _buildField('Mật khẩu', '********', _password,
                  isPassword: true,
                  obscure: _hidePass,
                  onToggle: () => setState(() => _hidePass = !_hidePass)),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen()),
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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4CF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chưa có tài khoản?",
                      style: TextStyle(color: Colors.grey[400])),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
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

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// FORGOT PASSWORD SCREEN
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

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

    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('username');
    final savedEmail = prefs.getString('email');

    // Kiểm tra username và email
    if (savedUser != _username.text || savedEmail != _email.text) {
      _showMsg('Tên người dùng hoặc email không đúng!');
      return;
    }

    // Kiểm tra mật khẩu mới có khớp không
    if (_newPassword.text != _confirmPassword.text) {
      _showMsg('Mật khẩu xác nhận không khớp!');
      return;
    }

    await prefs.setString('password', _newPassword.text);
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
          style: IconButton.styleFrom(
            foregroundColor: Colors.white, // Màu của icon
          ),
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
              Image.asset(
                'assets/images/sensor.png',
                width: 45,
                height: 45,
              ),
              const SizedBox(height: 6),
              const Text(
                'Đặt lại mật khẩu',
                style: TextStyle(fontSize: 20 , color: Colors.white,),
              ),
              const SizedBox(height: 20),

              _buildField('Tên người dùng', 'user name', _username),
              const SizedBox(height: 10),
              _buildField('Email', 'Example@gmail.com', _email),
              const SizedBox(height: 10),
              _buildField('Mật khẩu mới', '********', _newPassword,
                  isPassword: true,
                  obscure: _hideNewPass,
                  onToggle: () => setState(() => _hideNewPass = !_hideNewPass)),
              const SizedBox(height: 10),
              _buildField('Xác nhận mật khẩu mới', '********', _confirmPassword,
                  isPassword: true,
                  obscure: _hideConfirmPass,
                  onToggle: () => setState(() => _hideConfirmPass = !_hideConfirmPass)),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4CF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 13)),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: isPassword && obscure,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: onToggle,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// REGISTER SCREEN
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username.text);
    await prefs.setString('email', _email.text);
    await prefs.setString('password', _password.text);

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
          style: IconButton.styleFrom(
            foregroundColor: Colors.white, // Màu của icon
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/sensor.png',
                width: 45,
                height: 45,
              ),
              const SizedBox(height: 6),
              const Text(
                'Sensor Station',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold ,color: Colors.white,),
              ),
              const Text(
                'Đăng ký tài khoản',
                style: TextStyle(fontSize: 14,  color: Colors.white,),
              ),
              const SizedBox(height: 10),

              _buildField('Tên người dùng', 'user name', _username),
              const SizedBox(height: 10),
              _buildField('Email', 'Example@gmail.com', _email),
              const SizedBox(height: 10),
              _buildField('Mật khẩu', '********', _password,
                  isPassword: true,
                  obscure: _hidePass,
                  onToggle: () => setState(() => _hidePass = !_hidePass)),
              const SizedBox(height: 10),
              _buildField('Nhập lại mật khẩu', '********', _confirmPass,
                  isPassword: true,
                  obscure: _hideConfirm,
                  onToggle: () => setState(() => _hideConfirm = !_hideConfirm)),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4CF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 13)),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: isPassword && obscure,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: onToggle,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}