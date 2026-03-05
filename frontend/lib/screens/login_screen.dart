import 'package:flutter/material.dart';

// Your functional imports (Adjust paths if necessary)
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../navigation/main_shell.dart';

// --- THEME CONSTANTS FOR EXACT VISUAL MATCH ---
const Color _bgWhite = Color(0xFFF7F6F2);
const Color _primaryDark = Color(0xFF45384D);
const Color _primaryMuted = Color(0xFF6E5C77);
const Color _disabledButton = Color(0xFFB1A6B6);
const Color _textGray = Color(0xFF8A8290);
const Color _lightGray = Color(0xFFE4DFE5);
const Color _errorBg = Color(0xFFFDECEE);
const Color _errorText = Color(0xFFE53935);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.trim().isNotEmpty &&
                    _passwordController.text.isNotEmpty;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus(); // Hide keyboard
    setState(() { _isLoading = true; _error = null; });
    
    try {
      final result = await ApiService().login(
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
      setState(() { 
        _isLoading = false; 
        _error = 'Login failed. Please check your credentials and try again.'; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      "Welcome Back",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _primaryDark, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please enter your details to sign in.",
                      style: TextStyle(fontSize: 16, color: _textGray),
                    ),
                    const SizedBox(height: 40),

                    // Inputs
                    _buildInputGroup("Email", "your@email.com", _emailController, isEmail: true),
                    const SizedBox(height: 20),
                    _buildPasswordGroup("Password", "••••••••", _passwordController),
                    
                    const SizedBox(height: 12),
                    
                    // Forgot Password (Optional placeholder)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement Forgot Password
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryMuted,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text("Forgot Password?", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error Message Container
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _errorBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: _errorText, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: _errorText, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),
                    const SizedBox(height: 32),

                    // Login Button
                    ElevatedButton(
                      onPressed: (_isFormValid && !_isLoading) ? _login : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryMuted,
                        disabledBackgroundColor: _disabledButton,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInputGroup(String label, String hint, TextEditingController controller, {bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textGray)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          style: const TextStyle(color: _primaryDark, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textGray.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordGroup(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textGray)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: _obscurePassword,
          style: const TextStyle(color: _primaryDark, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textGray.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _textGray,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }
}