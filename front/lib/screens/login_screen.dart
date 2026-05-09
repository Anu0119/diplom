import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
  setState(() => _isLoading = true);
  bool success = await ApiService().login(_emailController.text, _passController.text);
  setState(() => _isLoading = false);

  if (success) {
    // UniqueKey нэмснээр MainNavigation-ийн initState заавал дахин ажиллана
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => MainNavigation(key: UniqueKey()) 
      )
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Имэйл эсвэл нууц үг буруу!"))
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                _textField("Имэйл", Icons.email_outlined, _emailController),
                SizedBox(height: 15),
                _textField("Нууц үг", Icons.lock_outline, _passController, isPass: true),
                SizedBox(height: 30),
                _isLoading 
                  ? CircularProgressIndicator() 
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3F37D9),
                        minimumSize: Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: Text("Нэвтрэх", style: TextStyle(color: Colors.white)),
                    ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
                  child: Text("Шинэ бүртгэл үүсгэх", style: TextStyle(color: Color(0xFF3F37D9))),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300, width: double.infinity,
      decoration: BoxDecoration(color: Color(0xFF3F37D9), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.hub, size: 80, color: Colors.white),
        Text("UniConnect", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _textField(String hint, IconData icon, TextEditingController controller, {bool isPass = false}) {
    return TextField(
      controller: controller, obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint, prefixIcon: Icon(icon),
        filled: true, fillColor: Color(0xFFF1F3F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }
} 