import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/spacing.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../navigation/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = ApiService();
      final result = await api.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await StorageService.saveToken(result['access_token']);
      await StorageService.saveUserId(result['user']['id']);
      await StorageService.saveEmail(_emailController.text.trim());
      await StorageService.setOnboardingComplete(true);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Login failed. Check your credentials.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.primaryDark)),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            const Text("Please enter your details to sign in", style: TextStyle(color: AppColors.primaryMuted)),
            AppSpacing.verticalLarge,
            
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
            ),
            AppSpacing.verticalMedium,
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline)),
            ),

            if (_error != null) ...[
              AppSpacing.verticalSmall,
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
            
            AppSpacing.verticalLarge,
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}