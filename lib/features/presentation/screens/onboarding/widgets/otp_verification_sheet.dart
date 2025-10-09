import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foxxhealth/features/presentation/cubits/login/login_cubit.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/core/utils/snackbar_utils.dart';

class OTPVerificationSheet extends StatefulWidget {
  final String email;
  final Function() onSuccess;

  const OTPVerificationSheet({
    super.key,
    required this.email,
    required this.onSuccess,
  });

  @override
  State<OTPVerificationSheet> createState() => _OTPVerificationSheetState();
}

class _OTPVerificationSheetState extends State<OTPVerificationSheet> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      SnackbarUtils.showError(
        context: context,
        title: 'Error',
        message: 'Please enter the OTP',
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final loginCubit = context.read<LoginCubit>();
    final success = await loginCubit.verifyRegistrationOTP(
      widget.email,
      _otpController.text.trim(),
    );

    setState(() {
      _isVerifying = false;
    });

    if (success) {
      // After successful OTP verification, proceed with login
      // We need to get the password from the cubit's stored data
      final loginSuccess = await loginCubit.signInWithEmail(
        widget.email,
        loginCubit.password ?? '', // Get password from cubit
      );

      if (loginSuccess) {
        widget.onSuccess();
      } else {
        SnackbarUtils.showError(
          context: context,
          title: 'Login Failed',
          message: 'Failed to login after OTP verification',
        );
      }
    } else {
      SnackbarUtils.showError(
        context: context,
        title: 'Verification Failed',
        message: 'Invalid OTP. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'We\'ve sent a verification code to\n${widget.email}',
              style: const TextStyle(
                fontSize: 16,
            color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // OTP Input Field
            TextFormField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryTint),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              maxLength: 6,
              onFieldSubmitted: (_) => _verifyOTP(),
            ),
            const SizedBox(height: 24),
            
            // Verify Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTint,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Resend OTP
            TextButton(
              onPressed: _isVerifying ? null : () {
                // TODO: Implement resend OTP functionality
                SnackbarUtils.showInfo(
                  context: context,
                  title: 'Info',
                  message: 'Resend OTP functionality will be implemented',
                );
              },
              child: const Text(
                'Didn\'t receive the code? Resend',
                style: TextStyle(
                  color: AppColors.primaryTint,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
