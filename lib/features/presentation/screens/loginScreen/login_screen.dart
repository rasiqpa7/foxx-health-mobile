import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foxxhealth/core/components/privacy_policy_bottom_sheet.dart';
import 'package:foxxhealth/features/presentation/screens/profile/terms_of_use_screen.dart';
import 'package:foxxhealth/core/utils/snackbar_utils.dart';
import 'package:foxxhealth/features/presentation/cubits/login/login_cubit.dart';
import 'package:foxxhealth/features/presentation/screens/api_logger/api_logger_screen.dart';
import 'package:foxxhealth/features/presentation/screens/main_navigation/main_navigation_screen.dart';
import 'package:foxxhealth/features/presentation/screens/onboarding/view/onboarding_flow.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foxxhealth/features/presentation/screens/forgotPassword/forgot_password_screen.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key, required this.isSign, this.showBackButton = true});
  bool isSign;
  bool showBackButton;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isOver16 = false;
  bool _isButtonEnabled = false;
  bool _obscurePassword = true;
  bool _hasMinLength = false;
  bool _hasLetterAndNumber = false;
  bool _hasCapitalLetter = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updatePasswordValidation);
  }

  void _updatePasswordValidation() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasLetterAndNumber = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
      _hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(password);
      _updateButtonState();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasLetterAndNumber = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
    final hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(password);

    return hasMinLength && hasLetterAndNumber && hasCapitalLetter;
  }

  void _updateButtonState() {
    setState(() {
      if (widget.isSign) {
        _isButtonEnabled = _formKey.currentState?.validate() ?? false &&
            _emailController.text.trim().isNotEmpty &&
            _passwordController.text.trim().isNotEmpty;
      } else {
        final emailValid = _formKey.currentState?.validate() ?? false;
        final emailNotEmpty = _emailController.text.trim().isNotEmpty;
        final passwordValid = validatePassword(_passwordController.text);
        final checkboxesChecked = _agreeToTerms && _isOver16;

        _isButtonEnabled = emailValid && emailNotEmpty && passwordValid && checkboxesChecked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(widget.showBackButton),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 30),
                  
                  // Form
                  _buildLoginForm(),
                  
                  const SizedBox(height: 40),
                  
                  // Bottom Button
                  _buildBottomButton(),
                  
                  const SizedBox(height: 20),
                  
                  // Toggle Sign In/Sign Up
                  _buildToggleSign(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool showBackButton) {
    return AppBar(
      leading: !showBackButton
          ? const SizedBox()
          : IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onDoubleTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ApiLoggerScreen(),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isSign ? 'Sign In' : 'Create your account',
            style: AppTypography.h2,
          ),
          if (widget.isSign) ...[
            SizedBox(height: 8),
            Text(
           'Welcome back',
            style: AppTypography.bodyLg.copyWith(fontWeight: AppTypography.regular),
          ),
          ],
          const SizedBox(height: 8),
          if (!widget.isSign) ...[
         
            const SizedBox(height: 4),
             Text(
              'Your health details are always protected. Logging in simply unlocks your private account.',
              textAlign: TextAlign.start,
              style: AppTypography.bodyLg.copyWith(fontWeight: AppTypography.regular),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface01,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.overlayLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                }
                final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onChanged: (value) {
                _formKey.currentState?.validate();
                _updateButtonState();
              },
              style: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular, color: AppColors.textInputPlaceholder),
                errorStyle: AppTypography.labelXsSemibold.copyWith(color: AppColors.red),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Password Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface01,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.overlayLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (!widget.isSign) {
                  if (value == null || value.isEmpty) return 'Must be at least 8 characters';
                  if (value.length < 8) return 'Must be at least 8 characters';
                  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain a capital letter';
                  if (!RegExp(r'(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                    return 'Must contain letters and numbers';
                  }
                }
                return null;
              },
              onChanged: (value) {
                if (!widget.isSign) {
                  _updatePasswordValidation();
                }
                _formKey.currentState?.validate();
                _updateButtonState();
              },
              style: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular, color: AppColors.textInputPlaceholder),
                errorStyle: AppTypography.labelXsSemibold.copyWith(color: AppColors.red),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.gray600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
          
          // Password Requirements (only for sign up)
          if (!widget.isSign) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.onSurfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password must be:',
                    style: AppTypography.labelSmSemibold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRule('Length: at least 8 characters', _hasMinLength),
                  _buildPasswordRule('Must include at least one letter and one number', _hasLetterAndNumber),
                  _buildPasswordRule('Must include capital letters', _hasCapitalLetter),
                ],
              ),
            ),
          ],
          
          // Forgot Password (only for sign in)
          if (widget.isSign) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: AppTypography.labelSmLink.copyWith(
                    color: AppColors.amethystViolet,
                  ),
                ),
              ),
            ),
          ],
          
          // Checkboxes (only for sign up)
          if (!widget.isSign) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                      _updateButtonState();
                    });
                  },
                  activeColor: AppColors.amethystViolet,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySmSemibold,
                      children: [
                        const TextSpan(text: 'I agree to '),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              PrivacyPolicyBottomSheet.show(context);
                            },
                          text: 'Privacy Policy',
                          style: AppTypography.labelSmLink.copyWith(
                            color: AppColors.amethystViolet,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const TermsOfUseScreen(),
                                ),
                              );
                            },
                          text: 'Terms and Conditions',
                          style: AppTypography.labelSmLink.copyWith(
                            color: AppColors.amethystViolet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isOver16,
                  onChanged: (value) {
                    setState(() {
                      _isOver16 = value ?? false;
                      _updateButtonState();
                    });
                  },
                  activeColor: AppColors.amethystViolet,
                ),
                Text(
                  'I am 16 years or older',
                  style: AppTypography.bodySmSemibold,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          if (!widget.isSign) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OnboardingFlow(
                  email: _emailController.text,
                  password: _passwordController.text,
                ),
              ),
            );
          } else {
            SnackbarUtils.showSuccess(
              context: context,
              title: 'Welcome back',
              message: _emailController.text.split('@')[0],
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
            );
          }
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTypography.bodySmSemibold.copyWith(
              color: AppColors.buttonTextPrimary,
                  ),
                ),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isButtonEnabled
                  ? () {
                    final loginCubit = context.read<LoginCubit>();
                    loginCubit.setUserDetails(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    if (!widget.isSign) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingFlow(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        ),
                      );
                    } else {
                      loginCubit.signInWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  }
                : null,
              style: ElevatedButton.styleFrom(
              backgroundColor: _isButtonEnabled ? AppColors.amethystViolet : AppColors.gray300,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: state is LoginLoading
                  ? const CircularProgressIndicator(color: AppColors.buttonTextPrimary)
                : Text(
                    widget.isSign ? 'Sign In' : 'Create An Account',
                    style: AppTypography.labelMdSemibold.copyWith(
              color: _isButtonEnabled ? AppColors.buttonTextPrimary : AppColors.gray600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildToggleSign() {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isSign = !widget.isSign;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isSign ? "Don't have an account?" : 'Already have an account?',
            style: AppTypography.bodySmSemibold,
          ),
          Text(
            widget.isSign ? ' Sign Up' : ' Sign In',
            style: AppTypography.labelSmLink.copyWith(
              color: AppColors.amethystViolet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRule(String rule, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? AppColors.insightPineGreen : AppColors.textPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rule,
              style: AppTypography.labelXsSemibold.copyWith(
                color: isMet ? AppColors.insightPineGreen : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}