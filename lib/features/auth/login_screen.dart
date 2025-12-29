import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart'; 

class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); 
  final AuthService _auth = AuthService();
  
  bool _isLogin = true; 
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
  
    final primaryColor = AppTheme.neonBlue; 
    final accentColor = const Color.fromARGB(255, 48, 15, 61);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_dining, size: 80, color: primaryColor),
              const SizedBox(height: 10),
              Text(
                "NUTRIMATE", 
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                )
              ),
              const SizedBox(height: 40),
              
              if (!_isLogin)
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name", 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Colors.white70)
                  ),
                ),
              if (!_isLogin) const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.white70)
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.white70)
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
            
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: Text(
                          _isLogin ? "LOGIN" : "CREATE ACCOUNT",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              
              const SizedBox(height: 16),

              
              if (!_isLoading) 
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await _auth.signInWithGoogle();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Google Sign In Failed: $e")),
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  icon: const Icon(Icons.login, color: Colors.white), 
                  label: const Text("SIGN IN WITH GOOGLE"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accentColor),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              
           
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? "New here? Create Account" : "Have an account? Login",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}