import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/feedback/feedback_input_screen.dart';

class FeedbackPreferencesScreen extends StatefulWidget {
  const FeedbackPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackPreferencesScreen> createState() => _FeedbackPreferencesScreenState();
}

class _FeedbackPreferencesScreenState extends State<FeedbackPreferencesScreen> {
  final List<String> _options = [
    'My health tracker',
    'Appointment companion',
    'Community den',
    'Symptom insights',
  ];
  
  final Set<int> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
               
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.amethyst,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Feedback',
                      style: AppHeadingTextStyles.h2.copyWith(
                        color: AppColors.primary01,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What is your favorite part of FoXX?',
                        style: AppHeadingTextStyles.h2.copyWith(
                          color: AppColors.primary01,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'If you love a few parts equally, select them all!',
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Options
                      Expanded(
                        child: ListView.builder(
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedOptions.contains(index);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedOptions.remove(index);
                                    } else {
                                      _selectedOptions.add(index);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.programBase : AppColors.mauve50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppColors.programBase : AppColors.mauve50,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? AppColors.programBase : Colors.transparent,
                                          border: Border.all(
                                            color: AppColors.amethyst,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                color: AppColors.amethyst,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          _options[index],
                                          style: AppTextStyles.bodyOpenSans.copyWith(
                                             color: isSelected ? AppColors.primary01 : AppColors.textSecondary,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom button
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedOptions.isNotEmpty
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FeedbackInputScreen(
                                  selectedPreferences: _selectedOptions.map((index) => _options[index]).toList(),
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOptions.isNotEmpty 
                          ? AppColors.amethyst 
                          : AppColors.disabledButton,
                      foregroundColor: AppColors.foxxWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Next',
                      style: AppTextStyles.buttonOpenSans.copyWith(
                        color: _selectedOptions.isNotEmpty 
                            ? AppColors.foxxWhite 
                            : AppColors.gray600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
