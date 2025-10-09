// Updated by Joy — homescreen update - not final
import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';

import 'package:foxxhealth/features/presentation/cubits/appointment_companion/appointment_companion_cubit.dart';
import 'package:foxxhealth/features/data/models/appointment_companion_model.dart';
import 'dart:convert';

class AppointmentCompanionScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final VoidCallback? onRefresh;

  const AppointmentCompanionScreen({
    super.key,
    required this.appointmentData,
    this.onRefresh,
  });

  @override
  State<AppointmentCompanionScreen> createState() => _AppointmentCompanionScreenState();
}

class _AppointmentCompanionScreenState extends State<AppointmentCompanionScreen> {
  // State management
  bool _isCompanionTabSelected = true;
  final Map<String, bool> _expandedSections = {
    'symptoms': true,
    'healthHistory': false,
    'condition': false,
    'emotionalSupport': false,
  };
  
  // Hidden questions state - track which questions are hidden by section
  final Map<String, Set<String>> _hiddenQuestions = {
    'symptoms': <String>{},
    'healthHistory': <String>{},
    'condition': <String>{},
    'emotionalSupport': <String>{},
    'postVisit': <String>{},
  };
  
  // Tags state management
  final Set<String> _selectedTags = <String>{};
  final List<String> _availableTags = [
    'PCOS',
    'Perimenopause',
    'Custom tag 3',
    'Custom tag 4',
    'Custom tag 5',
  ];
  
  // Controllers
  final TextEditingController _newQuestionController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();
  final Map<String, TextEditingController> _customQuestionControllers = {
    'symptoms': TextEditingController(),
    'healthHistory': TextEditingController(),
    'condition': TextEditingController(),
    'emotionalSupport': TextEditingController(),
  };
  
  // Data
  AppointmentCompanion? _companionDetails;
  Map<String, dynamic>? _aiResponseData;
  DateTime? _selectedDate;
  
  // Loading states
  bool _isLoading = true;
  bool _isLoadingAIResponse = false;
  String? _error;
  
  // Track unsaved changes
  bool _hasUnsavedChanges = false;

  // Constants
  // static const List<String> _defaultQuestions = [
  //   'I\'ve tried various things and still feel without answers. What is our comprehensive diagnostic roadmap for my **fatigue** and **irregular cycles**, and what\'s the plan if initial tests don\'t provide a clear explanation?',
  // ];

  @override
  void initState() {
    super.initState();
    _loadCompanionDetails();
  }

  @override
  void dispose() {
    _newQuestionController.dispose();
    _newTagController.dispose();
    _customQuestionControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // Data loading methods
  Future<void> _loadCompanionDetails() async {
    final companionId = widget.appointmentData['companionId'] as int?;
    
    // Debug: Print the appointment data and companion ID
    print('🔍 Debug - appointmentData: ${widget.appointmentData}');
    print('🔍 Debug - companionId: $companionId');
    print('🔍 Debug - companionId type: ${companionId.runtimeType}');
    
    if (companionId == null) {
      print('❌ Error - companionId is null, cannot load companion details');
      print('🔍 Debug - Available keys in appointmentData: ${widget.appointmentData.keys.toList()}');
      
      // Try to find companionId in different possible formats
      final possibleCompanionId = widget.appointmentData['companionId'] ?? 
                                 widget.appointmentData['companion_id'] ?? 
                                 widget.appointmentData['id'];
      
      if (possibleCompanionId != null) {
        print('🔍 Debug - Found alternative companionId: $possibleCompanionId');
        print('🔍 Debug - Alternative companionId type: ${possibleCompanionId.runtimeType}');
        
        // Try to convert to int if it's a string
        int? convertedId;
        if (possibleCompanionId is String) {
          convertedId = int.tryParse(possibleCompanionId);
        } else if (possibleCompanionId is int) {
          convertedId = possibleCompanionId;
        }
        
        if (convertedId != null) {
          print('🔍 Debug - Successfully converted companionId to int: $convertedId');
          // Recursively call with the converted ID
          widget.appointmentData['companionId'] = convertedId;
          await _loadCompanionDetails();
          return;
        }
      }
      
      setState(() => _isLoading = false);
      return;
    }

    try {
      print('🔍 Debug - Calling getAppointmentCompanionDetails with ID: $companionId');
      final appointmentCubit = AppointmentCompanionCubit();
      final details = await appointmentCubit.getAppointmentCompanionDetails(companionId);
      
      print('🔍 Debug - Received companion details: $details');
      
      setState(() {
        _companionDetails = details;
        _isLoading = false;
      });
      
      print('🔍 Debug - Calling _generateAIResponse with ID: $companionId');
      await _generateAIResponse(companionId);
    } catch (e) {
      print('❌ Error - Failed to load companion details: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAIResponse(int companionId) async {
    print('🔍 Debug - Starting _generateAIResponse with ID: $companionId');
    setState(() {
      _isLoadingAIResponse = true;
      _error = null;
    });

    try {
      final appointmentCubit = AppointmentCompanionCubit();
      print('🔍 Debug - Calling generateAIResponse API');
      final aiResponse = await appointmentCubit.generateAIResponse(companionId);
      
      print('🔍 Debug - Received AI response: $aiResponse');
      
      setState(() {
        _aiResponseData = aiResponse;
        _isLoadingAIResponse = false;
      });
      
      // Debug: Print updated data
      print('🔄 AI Response Updated: ${aiResponse?['symptoms_list']}');
      print('🔄 Symptoms List: ${_symptomsList}');
      print('🔄 History List: ${_historyList}');
      print('🔄 Conditions List: ${_conditionsList}');
    } catch (e) {
      print('❌ Error - Failed to generate AI response: $e');
      setState(() {
        _error = e.toString();
        _isLoadingAIResponse = false;
      });
    }
  }

  Future<void> _addCustomQuestion(String sectionKey, String question) async {
    if (question.trim().isEmpty) return;

    // Add the question to the local AI response data immediately
    setState(() {
      if (_aiResponseData == null) {
        _aiResponseData = {};
      }
      _hasUnsavedChanges = true;
      
      // Helper function to ensure we have a List<String>
      List<String> ensureList(String key) {
        final data = _aiResponseData![key];
        if (data == null) return [];
        
        if (data is List) {
          return data.cast<String>();
        } else if (data is String) {
          try {
            final parsed = json.decode(data) as List;
            return parsed.cast<String>();
          } catch (e) {
            print('🔄 Error parsing JSON for $key: $e');
            return [];
          }
        }
        return [];
      }
      
      // Add the new question to the appropriate section
      switch (sectionKey) {
        case 'symptoms':
          // Get existing questions and add new one
          final existingSymptoms = ensureList('symptoms_list');
          existingSymptoms.add(question);
          _aiResponseData!['symptoms_list'] = existingSymptoms;
          
          // Also add to questions_symptoms for compatibility
          final existingQuestionsSymptoms = ensureList('questions_symptoms');
          existingQuestionsSymptoms.add(question);
          _aiResponseData!['questions_symptoms'] = existingQuestionsSymptoms;
          
          // Debug: Print the updated lists
          print('🔄 Added custom symptom question: $question');
          print('🔄 Updated symptoms_list: ${_aiResponseData!['symptoms_list']}');
          break;
        case 'healthHistory':
          // Get existing questions and add new one
          final existingHistory = ensureList('history_list');
          existingHistory.add(question);
          _aiResponseData!['history_list'] = existingHistory;
          
          // Also add to questions_history for compatibility
          final existingQuestionsHistory = ensureList('questions_history');
          existingQuestionsHistory.add(question);
          _aiResponseData!['questions_history'] = existingQuestionsHistory;
          
          // Debug: Print the updated lists
          print('🔄 Added custom history question: $question');
          print('🔄 Updated history_list: ${_aiResponseData!['history_list']}');
          break;
        case 'condition':
          // Get existing questions and add new one
          final existingConditions = ensureList('conditions_list');
          existingConditions.add(question);
          _aiResponseData!['conditions_list'] = existingConditions;
          
          // Also add to questions_conditions for compatibility
          final existingQuestionsConditions = ensureList('questions_conditions');
          existingQuestionsConditions.add(question);
          _aiResponseData!['questions_conditions'] = existingQuestionsConditions;
          
          // Debug: Print the updated lists
          print('🔄 Added custom condition question: $question');
          print('🔄 Updated conditions_list: ${_aiResponseData!['conditions_list']}');
          break;
        case 'emotionalSupport':
          if (_aiResponseData!['emotional_support'] == null) {
            _aiResponseData!['emotional_support'] = '';
          }
          if (_aiResponseData!['emotional_support'].isNotEmpty) {
            _aiResponseData!['emotional_support'] += '\n\n$question';
          } else {
            _aiResponseData!['emotional_support'] = question;
          }
          
          // Debug: Print the updated content
          print('🔄 Added custom emotional support: $question');
          print('🔄 Updated emotional_support: ${_aiResponseData!['emotional_support']}');
          break;
      }
    });
    
    // Debug: Print the current state after adding question
    print('🔄 Current _symptomsList: ${_symptomsList}');
    print('🔄 Current _historyList: ${_historyList}');
    print('🔄 Current _conditionsList: ${_conditionsList}');
    
    // Force a rebuild to ensure UI updates
    setState(() {});
    
    // Clear the input field
    _customQuestionControllers[sectionKey]?.clear();
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Helper methods
  void _toggleSection(String sectionKey) {
    setState(() {
      _expandedSections[sectionKey] = !(_expandedSections[sectionKey] ?? false);
    });
  }

  void _toggleTab() {
    setState(() => _isCompanionTabSelected = !_isCompanionTabSelected);
  }

  // Question hide/unhide methods
  void _hideQuestion(String sectionKey, String question) {
    setState(() {
      _hiddenQuestions[sectionKey]?.add(question);
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Question hidden'),
        backgroundColor: AppColors.amethyst,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _unhideAllQuestions() {
    setState(() {
      _hiddenQuestions.forEach((sectionKey, hiddenSet) {
        hiddenSet.clear();
      });
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All questions are now visible'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _isQuestionHidden(String sectionKey, String question) {
    return _hiddenQuestions[sectionKey]?.contains(question) ?? false;
  }

  List<String> _getVisibleQuestions(String sectionKey, List<String> allQuestions) {
    return allQuestions.where((question) => !_isQuestionHidden(sectionKey, question)).toList();
  }

  // Tag management methods
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _hasUnsavedChanges = true;
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
      _hasUnsavedChanges = true;
    });
  }

  void _addCustomTag(String tagName) {
    if (tagName.trim().isNotEmpty && !_availableTags.contains(tagName.trim())) {
      setState(() {
        _availableTags.add(tagName.trim());
        _selectedTags.add(tagName.trim());
        _hasUnsavedChanges = true;
      });
      _newTagController.clear();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag "$tagName" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  int _getHiddenCount(String sectionTitle) {
    // Map section titles to section keys
    String sectionKey;
    switch (sectionTitle) {
      case 'Based on my symptoms':
        sectionKey = 'symptoms';
        break;
      case 'Based on my health history':
        sectionKey = 'healthHistory';
        break;
      case 'Based on my condition':
        sectionKey = 'condition';
        break;
      case 'Emotional Support':
        sectionKey = 'emotionalSupport';
        break;
      case 'Post appointment questions':
        sectionKey = 'postVisit';
        break;
      default:
        return 0;
    }
    
    return _hiddenQuestions[sectionKey]?.length ?? 0;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary01,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primary01,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      // Update the API with the new date
      await _updateAppointmentDate(picked);
    }
  }

  Future<void> _updateAppointmentDate(DateTime newDate) async {
    // Update the local data only - API call will happen on save
    setState(() {
      if (_aiResponseData == null) {
        _aiResponseData = {};
      }
      _aiResponseData!['appointment_date'] = newDate.toIso8601String();
      _hasUnsavedChanges = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment date updated locally. Press Save to apply changes.'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _generateMoreLikeThis(String sectionKey) async {
    final companionId = widget.appointmentData['companionId'] as int?;
    if (companionId == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final appointmentCubit = AppointmentCompanionCubit();
      
      // Call the API to generate more like this responses
      final moreLikeThisResponse = await appointmentCubit.generateMoreLikeThis(companionId);
      
      if (moreLikeThisResponse != null) {
        // Update the AI response data with new content locally
        setState(() {
          if (_aiResponseData == null) {
            _aiResponseData = {};
          }
          _hasUnsavedChanges = true;
          
          // Add new content to the appropriate section
          switch (sectionKey) {
            case 'symptoms':
              final newSymptoms = moreLikeThisResponse['questions_symptoms'] ?? moreLikeThisResponse['symptoms_list'] ?? [];
              if (newSymptoms is List) {
                final currentSymptoms = _symptomsList;
                final allSymptoms = [...currentSymptoms, ...newSymptoms.cast<String>()];
                // Update both keys to ensure compatibility
                _aiResponseData!['symptoms_list'] = allSymptoms;
                _aiResponseData!['questions_symptoms'] = allSymptoms;
                
                // Debug: Print the updated data
                print('🔄 Generated more symptoms: ${newSymptoms.length} new questions');
                print('🔄 Total symptoms now: ${allSymptoms.length}');
                print('🔄 Updated symptoms_list: ${_aiResponseData!['symptoms_list']}');
              }
              break;
            case 'healthHistory':
              final newHistory = moreLikeThisResponse['questions_history'] ?? moreLikeThisResponse['history_list'] ?? [];
              if (newHistory is List) {
                final currentHistory = _historyList;
                final allHistory = [...currentHistory, ...newHistory.cast<String>()];
                // Update both keys to ensure compatibility
                _aiResponseData!['history_list'] = allHistory;
                _aiResponseData!['questions_history'] = allHistory;
                
                // Debug: Print the updated data
                print('🔄 Generated more history: ${newHistory.length} new questions');
                print('🔄 Total history now: ${allHistory.length}');
                print('🔄 Updated history_list: ${_aiResponseData!['history_list']}');
              }
              break;
            case 'condition':
              final newConditions = moreLikeThisResponse['questions_conditions'] ?? moreLikeThisResponse['conditions_list'] ?? [];
              if (newConditions is List) {
                final currentConditions = _conditionsList;
                final allConditions = [...currentConditions, ...newConditions.cast<String>()];
                // Update both keys to ensure compatibility
                _aiResponseData!['conditions_list'] = allConditions;
                _aiResponseData!['questions_conditions'] = allConditions;
                
                // Debug: Print the updated data
                print('🔄 Generated more conditions: ${newConditions.length} new questions');
                print('🔄 Total conditions now: ${allConditions.length}');
                print('🔄 Updated conditions_list: ${_aiResponseData!['conditions_list']}');
              }
              break;
            case 'emotionalSupport':
              final newEmotionalSupport = moreLikeThisResponse['emotional_support'] ?? '';
              if (newEmotionalSupport.isNotEmpty) {
                final currentEmotionalSupport = _emotionalSupport ?? '';
                _aiResponseData!['emotional_support'] = '$currentEmotionalSupport\n\n$newEmotionalSupport';
              }
              break;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Generated more questions for ${_getSectionDisplayName(sectionKey)}! Press Save to apply changes.'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // Force a rebuild to show the new questions
        setState(() {});
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate more questions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getSectionDisplayName(String sectionKey) {
    switch (sectionKey) {
      case 'symptoms':
        return 'symptoms';
      case 'healthHistory':
        return 'health history';
      case 'condition':
        return 'condition';
      case 'emotionalSupport':
        return 'emotional support';
      default:
        return 'this section';
    }
  }

  void _showMoreOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMoreOptionsMenu(),
    );
  }

  Widget _buildMoreOptionsMenu() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Menu options
          // _buildMenuItem(
          //   icon: Icons.edit,
          //   title: 'Edit my answers',
          //   onTap: _editMyAnswers,
          // ),
          _buildMenuItem(
            icon: Icons.edit_note,
            title: 'Change appointment name',
            onTap: _changeAppointmentName,
          ),
          _buildMenuItem(
            icon: Icons.visibility,
            title: 'Unhide questions',
            onTap: _unhideQuestions,
          ),
          _buildMenuItem(
            icon: Icons.label,
            title: 'Manage Tags',
            onTap: _manageTags,
          ),
          _buildMenuItem(
            icon: Icons.share,
            title: 'Share',
            onTap: _shareAppointment,
          ),
          _buildMenuItem(
            icon: Icons.delete,
            title: 'Delete',
            onTap: _showDeleteConfirmation,
            isDestructive: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTagManagementModal(StateSetter setModalState) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Selected tags display
          if (_selectedTags.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Selected tags:',
                    style: AppOSTextStyles.osMd.copyWith(
                      color: AppColors.davysGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTags.map((tag) => _buildSelectedTagChip(tag, setModalState)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),
          ],
          // Available tags list
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableTags.length + 1, // +1 for "New tag" option
              itemBuilder: (context, index) {
                if (index == _availableTags.length) {
                  return _buildNewTagOption(setModalState);
                }
                return _buildTagOption(_availableTags[index], setModalState);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSelectedTagChip(String tag, StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amethyst,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppOSTextStyles.osMd.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _removeTag(tag);
              setModalState(() {}); // Trigger modal rebuild
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagOption(String tag, StateSetter setModalState) {
    final isSelected = _selectedTags.contains(tag);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          _toggleTag(tag);
          setModalState(() {}); // Trigger modal rebuild
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: isSelected ? AppColors.amethyst : AppColors.gray400,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  tag,
                  style: AppOSTextStyles.osMd.copyWith(
                    color: AppColors.davysGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewTagOption(StateSetter setModalState) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _showAddNewTagDialog(setModalState),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 20,
                color: AppColors.amethyst,
              ),
              const SizedBox(width: 16),
              Text(
                'New tag',
                style: AppOSTextStyles.osMd.copyWith(
                  color: AppColors.amethyst,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.gray200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? AppColors.red : AppColors.davysGray,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppOSTextStyles.osMd.copyWith(
                  color: isDestructive ? AppColors.red : AppColors.primary01,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  // Action methods for menu items
  void _editMyAnswers() {
    Navigator.of(context).pop(); // Close the menu
    // TODO: Navigate to edit answers screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit my answers functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _changeAppointmentName() {
    Navigator.of(context).pop(); // Close the menu
    _showChangeAppointmentNameDialog();
  }

  void _unhideQuestions() {
    Navigator.of(context).pop(); // Close the menu
    _unhideAllQuestions();
  }

  void _manageTags() {
    Navigator.of(context).pop(); // Close the menu
    _showTagManagementModal();
  }

  void _shareAppointment() {
    Navigator.of(context).pop(); // Close the menu
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDeleteConfirmation() {
    Navigator.of(context).pop(); // Close the menu
    _showDeleteDialog();
  }

  void _showChangeAppointmentNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _title ?? 'Appointment Preparation Guide',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Appointment Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter new appointment name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  // Update the title locally
                  if (_aiResponseData == null) {
                    _aiResponseData = {};
                  }
                  _aiResponseData!['title'] = newName;
                  _hasUnsavedChanges = true;
                });
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Appointment name changed to: $newName'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thinking about deleting this?'),
        content: const Text(
          'If you delete your Appointment Companion, all your prep and notes will be gone for good. We just want to be sure before you let it go.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAppointmentCompanion();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTagManagementModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _buildTagManagementModal(setModalState),
      ),
    );
  }

  void _showAddNewTagDialog(StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Tag'),
        content: TextField(
          controller: _newTagController,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addCustomTag(value.trim());
              Navigator.of(context).pop();
              setModalState(() {}); // Refresh modal to show new tag
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tagName = _newTagController.text.trim();
              if (tagName.isNotEmpty) {
                _addCustomTag(tagName);
                Navigator.of(context).pop();
                setModalState(() {}); // Refresh modal to show new tag
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppointmentCompanion() async {
    final companionId = widget.appointmentData['companionId'] as int?;
    if (companionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete: Companion ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final appointmentCubit = AppointmentCompanionCubit();
      final isDeleted = await appointmentCubit.deleteAppointmentCompanion(companionId);

      setState(() {
        _isLoading = false;
      });

      if (isDeleted) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment companion deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to previous screen after successful deletion
          Navigator.of(context).pop();
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete appointment companion. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting appointment companion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<String> _parseDataToList(dynamic data) {
    if (data == null) return [];
    
    // If it's already a List, cast it to List<String>
    if (data is List) {
      return data.cast<String>();
    }
    
    // If it's a String, try to parse it as JSON
    if (data is String) {
      if (data.isEmpty) return [];
      try {
        final List<dynamic> parsed = json.decode(data);
        return parsed.cast<String>();
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  List<String> _parseJsonList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> parsed = json.decode(jsonString);
      return parsed.cast<String>();
    } catch (e) {
      return [];
    }
  }

  // Getters for AI response data
  List<String> get _historyList => _parseDataToList(_aiResponseData?['history_list'] ?? _aiResponseData?['questions_history']);
  List<String> get _symptomsList => _parseDataToList(_aiResponseData?['symptoms_list'] ?? _aiResponseData?['questions_symptoms']);
  List<String> get _conditionsList => _parseDataToList(_aiResponseData?['conditions_list'] ?? _aiResponseData?['questions_conditions']);
  String? get _emotionalSupport => _aiResponseData?['emotional_support'];
  String? get _appointmentDate {
    final dateStr = _aiResponseData?['appointment_date'];
    if (dateStr == null) return null;
    
    // If it's already a full datetime, return as is
    if (dateStr.contains('T') || dateStr.contains(' ')) {
      return dateStr;
    }
    
    // If it's just a date (YYYY-MM-DD), convert to full datetime
    if (dateStr.length == 10) {
      return '${dateStr}T00:00:00.000Z';
    }
    
    return dateStr;
  }
  String? get _title => _aiResponseData?['title'];

  String _generatePersonalizedMessage() {
    if (_aiResponseData?['introduction'] != null && _aiResponseData!['introduction'].isNotEmpty) {
      return _aiResponseData!['introduction'];
    }
    
    if (_companionDetails != null) {
      final symptoms = _companionDetails!.importantSymptomsToDiscuss?.map((s) => s.description).toList() ?? [];
      final stressors = _companionDetails!.lifeStressorsAffectingHealth?.map((s) => s.description).toList() ?? [];
      
      if (symptoms.isNotEmpty || stressors.isNotEmpty) {
        String message = "Based on your appointment companion data, here's your personalized preparation guide.";
        
        if (symptoms.isNotEmpty) {
          message += " You've noted concerns about ${symptoms.take(2).join(', ')}";
        }
        
        if (stressors.isNotEmpty) {
          message += " and mentioned life stressors including ${stressors.take(2).join(', ')}";
        }
        
        message += ". Use the AI-generated questions below to prepare for your appointment and advocate for your health effectively.";
        
        return message;
      }
    }
    
    return "Welcome to your appointment preparation guide. The AI has generated personalized questions to help you make the most of your medical appointment. Review the questions below and use them to advocate for your health effectively.";
  }

  Future<void> _saveAppointmentCompanion() async {
    final companionId = widget.appointmentData['companionId'] as int?;
    if (companionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save: Companion ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final appointmentCubit = AppointmentCompanionCubit();
      
      // Prepare the request data with all current data including custom questions
      Map<String, dynamic> requestData = {
        'title': _title ?? 'Appointment Preparation Guide',
        'symptoms_custom_questions': _symptomsList,
        'conditions_custom_questions': _conditionsList,
        'history_custom_questions': _historyList,
        'my_appointment_notes': [_emotionalSupport ?? ''],
        'appointment_date': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'post_appointment_notes': [],
        'tags': _selectedTags.toList(),
      };

      // Call the API to update the companion
      await appointmentCubit.updateAppointmentCompanionCustom(companionId, requestData);
      
      setState(() {
        _isLoading = false;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment companion saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save appointment companion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: _isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary01,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildTabSelector(),
                      _isCompanionTabSelected 
                          ? _buildCompanionContent()
                          : _buildPostVisitContent(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary01),
        onPressed: () {
          // Call refresh callback if provided
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Appointment Companion',
        style: AppHeadingTextStyles.h4.copyWith(color: AppColors.primary01),
      ),
      actions: [
        TextButton(
          onPressed: _hasUnsavedChanges ? _saveAppointmentCompanion : null,
          child: Text(
            'Save',
            style: AppOSTextStyles.osMd.copyWith(
              color: _hasUnsavedChanges ? AppColors.amethyst : AppColors.gray400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Header section
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateChip(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _showMoreOptionsMenu,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _title ?? 'Appointment Preparation Guide',
            style: AppHeadingTextStyles.h4.copyWith(color: AppColors.primary01),
          ),
          const SizedBox(height: 8),
          _buildAddTagButton(),
        ],
      ),
    );
  }

  Widget _buildDateChip() {
    // Format the date properly
    String displayDate = 'Select Date';
    if (_selectedDate != null) {
      displayDate = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    } else if (_appointmentDate != null) {
      // Parse the existing appointment date if available
      try {
        final existingDate = DateTime.parse(_appointmentDate!);
        displayDate = '${existingDate.day}/${existingDate.month}/${existingDate.year}';
        // Set the selected date to the existing date
        if (_selectedDate == null) {
          _selectedDate = existingDate;
        }
      } catch (e) {
        displayDate = 'Invalid Date';
      }
    }

    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary01.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.primary01),
            const SizedBox(width: 8),
            Text(
              'Appointment: $displayDate',
              style: AppOSTextStyles.osMd.copyWith(
                color: AppColors.primary01,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary01),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTagButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected tags display
        if (_selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) => _buildHeaderTagChip(tag)).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // Add tag button
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showTagManagementModal,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(Icons.add, size: 16, color: AppColors.amethyst)),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Add tag',
                  style: AppOSTextStyles.osSmSemiboldLabel.copyWith(color: AppColors.amethyst),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.amethyst.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amethyst.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppOSTextStyles.osMd.copyWith(
              color: AppColors.amethyst,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(
              Icons.close,
              size: 14,
              color: AppColors.amethyst,
            ),
          ),
        ],
      ),
    );
  }

  // Tab selector
  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('Companion', _isCompanionTabSelected),
          _buildTabButton('Post Visit', !_isCompanionTabSelected),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: _toggleTab,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.backgroundHighlighted.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: isSelected ? const Radius.circular(20) : Radius.zero,
              bottomLeft: isSelected ? const Radius.circular(20) : Radius.zero,
              topRight: !isSelected ? const Radius.circular(20) : Radius.zero,
              bottomRight: !isSelected ? const Radius.circular(20) : Radius.zero,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppOSTextStyles.osMd.copyWith(
              color: isSelected ? AppColors.amethyst : AppColors.davysGray,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Companion content
  Widget _buildCompanionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonalizedResultSection(),
        const SizedBox(height: 24),
        _buildQuestionsSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPersonalizedResultSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Here\'s your result for your appointment companion',
            style: AppHeadingTextStyles.h4.copyWith(color: AppColors.primary01),
          ),
          const SizedBox(height: 16),
          Text(
            _generatePersonalizedMessage(),
            style: AppOSTextStyles.osMd.copyWith(
              color: AppColors.davysGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Container(
      
      padding: const EdgeInsets.all(20),
      decoration: AppColors.glassCardDecoration.copyWith(
        color: Colors.white.withOpacity(0.48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions to ask your doctor',
            style: AppHeadingTextStyles.h4.copyWith(color: AppColors.primary01),
          ),
          const SizedBox(height: 20),
          _buildExpandableSection(
            'symptoms',
            'Based on my symptoms',
            _symptomsList,
            _isLoadingAIResponse,
            'No symptom questions available',
          ),
          _buildExpandableSection(
            'healthHistory',
            'Based on my health history',
            _historyList,
            false,
            'No health history questions available',
          ),
          _buildExpandableSection(
            'condition',
            'Based on my condition',
            _conditionsList,
            false,
            'No condition questions available',
          ),
          _buildEmotionalSupportSection(),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    String sectionKey,
    String title,
    List<String> questions,
    bool isLoading,
    String noDataMessage,
  ) {
    final isExpanded = _expandedSections[sectionKey] ?? false;
    final visibleQuestions = _getVisibleQuestions(sectionKey, questions);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, isExpanded, () => _toggleSection(sectionKey)),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          _buildMoreLikeThisButton(sectionKey),
          const SizedBox(height: 16),
          if (isLoading)
            _buildLoadingIndicator()
          else if (visibleQuestions.isNotEmpty)
            ...visibleQuestions.map((question) => _buildQuestionCard(sectionKey, question))
          else if (questions.isNotEmpty && visibleQuestions.isEmpty)
            _buildAllQuestionsHiddenMessage()
          else
            _buildNoDataMessage(noDataMessage),
          const SizedBox(height: 16),
          _buildCustomQuestionInput(sectionKey),
        ],
      ],
    );
  }

  Widget _buildEmotionalSupportSection() {
    final isExpanded = _expandedSections['emotionalSupport'] ?? false;
    final emotionalSupportContent = _emotionalSupport ?? '';
    final isHidden = _isQuestionHidden('emotionalSupport', emotionalSupportContent);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Emotional Support', isExpanded, () => _toggleSection('emotionalSupport')),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          _buildMoreLikeThisButton('emotionalSupport'),
          const SizedBox(height: 16),
          if (emotionalSupportContent.isNotEmpty && !isHidden)
            _buildEmotionalSupportContent(emotionalSupportContent)
          else if (emotionalSupportContent.isNotEmpty && isHidden)
            _buildHiddenContentMessage()
          else
            _buildNoDataMessage('No emotional support content available'),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isExpanded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.gray200, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppOSTextStyles.osMd.copyWith(
                      color: AppColors.primary01,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Show hidden count if any questions are hidden
                  if (_getHiddenCount(title) > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_getHiddenCount(title)} hidden',
                        style: AppOSTextStyles.osMd.copyWith(
                          color: AppColors.gray600,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.amethyst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlighted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.amethyst),
          ),
          const SizedBox(width: 16),
          Text(
            'Generating AI questions...',
            style: AppOSTextStyles.osMd.copyWith(color: AppColors.davysGray),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlighted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: Text(
        message,
        style: AppOSTextStyles.osMd.copyWith(
          color: AppColors.davysGray,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildHiddenContentMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlighted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_off, size: 16, color: AppColors.gray400),
          const SizedBox(width: 8),
          Text(
            'Content hidden',
            style: AppOSTextStyles.osMd.copyWith(
              color: AppColors.gray400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllQuestionsHiddenMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlighted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_off, size: 16, color: AppColors.gray400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'All questions in this section are hidden. Use "Unhide questions" from the menu to show them again.',
              style: AppOSTextStyles.osMd.copyWith(
                color: AppColors.gray400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalSupportContent(String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlighted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: AppOSTextStyles.osMd.copyWith(
              color: AppColors.davysGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _hideQuestion('emotionalSupport', content),
            child: Text(
              'Hide content',
              style: AppOSTextStyles.osMd.copyWith(
                color: AppColors.amethyst,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreLikeThisButton(String sectionKey) {
    return GestureDetector(
      onTap: () => _generateMoreLikeThis(sectionKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.foxxWhite.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.amethyst.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.refresh, size: 16, color: AppColors.amethyst),
            const SizedBox(width: 8),
            Text(
              'More like this',
              style: AppOSTextStyles.osMd.copyWith(
                color: AppColors.buttonTextOutline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomQuestionInput(String sectionKey) {
    final controller = _customQuestionControllers[sectionKey];
    
    return Column(
      children: [
        Row(
          children: [

            const SizedBox(width: 8),
            Text(
              'Add custom question',
              style: AppOSTextStyles.osMd.copyWith(color: AppColors.amethyst),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: AppColors.foxxWhite.withOpacity(0.5),
            border: Border.all(color: AppColors.foxxWhite),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.drag_handle, size: 16, color: AppColors.gray400),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Type your question and press Enter',
                    
                    border: InputBorder.none,
                    hintStyle: AppOSTextStyles.osMd.copyWith(color: AppColors.gray400),
                  ),
                  style: AppOSTextStyles.osMd.copyWith(color: AppColors.buttonTextOutline),
                  onSubmitted: (question) {
                    if (question.trim().isNotEmpty) {
                      _addCustomQuestion(sectionKey, question.trim());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddQuestionSection() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.add, size: 16, color: AppColors.amethyst),
            const SizedBox(width: 8),
            Text(
              'Add question',
              style: AppOSTextStyles.osMd.copyWith(color: AppColors.amethyst),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.drag_handle, size: 16, color: AppColors.gray400),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _newQuestionController,
                  decoration: InputDecoration(
                    hintText: 'Add question',
                    border: InputBorder.none,
                    hintStyle: AppOSTextStyles.osMd.copyWith(color: AppColors.gray400),
                  ),
                  style: AppOSTextStyles.osMd.copyWith(color: AppColors.primary01),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String sectionKey, String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundHighlighted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.drag_handle, size: 16, color: AppColors.gray400),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppOSTextStyles.osMd.copyWith(
                      color: AppColors.primary01,
                      height: 1.4,
                    ),
                    children: _parseQuestionText(question),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _hideQuestion(sectionKey, question),
            child: Text(
              'Hide question',
              style: AppOSTextStyles.osMd.copyWith(
                color: AppColors.amethyst,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseQuestionText(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;
    
    for (final Match match in boldPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      
      lastIndex = match.end;
    }
    
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
    
    return spans;
  }

  // Post visit content
  Widget _buildPostVisitContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildPostVisitTitle(),
          const SizedBox(height: 32),
          _buildPostVisitQuestionsSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPostVisitTitle() {
    return Text(
      'Post appointment questions',
      style: AppHeadingTextStyles.h4.copyWith(color: AppColors.primary01),
    );
  }

  Widget _buildPostVisitQuestionsSection() {
    final allQuestions = ['postVisit1', 'postVisit2'];
    final visibleQuestions = allQuestions.where((key) => !_isQuestionHidden('postVisit', key)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with hidden count
        _buildPostVisitSectionHeader(),
        const SizedBox(height: 20),
        if (visibleQuestions.isNotEmpty) ...[
          if (visibleQuestions.contains('postVisit1')) ...[
            _buildPostVisitQuestion(
              'postVisit1',
              'How did you feel during the appointment? Did you feel truly heard and understood by your doctor? Reflecting on this can help you decide if this is the right healthcare partner for your ongoing journey',
              'Add notes',
            ),
            if (visibleQuestions.contains('postVisit2')) const SizedBox(height: 24),
          ],
          if (visibleQuestions.contains('postVisit2'))
            _buildPostVisitQuestion(
              'postVisit2',
              'Based on today\'s conversation, what are the two most important immediate next steps you need to take (e.g., scheduling labs, starting a new treatment, researching a referral)? Writing these down can help you feel in control and clarify your path forward.',
              'Add notes',
            ),
        ] else ...[
          _buildAllQuestionsHiddenMessage(),
        ],
      ],
    );
  }

  Widget _buildPostVisitSectionHeader() {
    final hiddenCount = _getHiddenCount('Post appointment questions');
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  'Questions to reflect on',
                  style: AppOSTextStyles.osMd.copyWith(
                    color: AppColors.primary01,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Show hidden count if any questions are hidden
                if (hiddenCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$hiddenCount hidden',
                      style: AppOSTextStyles.osMd.copyWith(
                        color: AppColors.gray600,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostVisitQuestion(String questionKey, String questionText, String placeholder) {
    final isHidden = _isQuestionHidden('postVisit', questionKey);
    
    if (isHidden) {
      return _buildHiddenPostVisitQuestion(questionKey, questionText);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text with hide option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppColors.glassCardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: AppOSTextStyles.osMd.copyWith(
                    color: AppColors.davysGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _hideQuestion('postVisit', questionKey),
                  child: Text(
                    'Hide question',
                    style: AppOSTextStyles.osMd.copyWith(
                      color: AppColors.amethyst,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: placeholder,
                      border: InputBorder.none,
                      hintStyle: AppOSTextStyles.osMd.copyWith(color: AppColors.gray400),
                    ),
                    style: AppOSTextStyles.osMd.copyWith(color: AppColors.primary01),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.mic,
                  size: 20,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenPostVisitQuestion(String questionKey, String questionText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hidden question indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundHighlighted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility_off, size: 16, color: AppColors.gray400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Question hidden',
                    style: AppOSTextStyles.osMd.copyWith(
                      color: AppColors.gray400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Hidden input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Input field hidden',
                    style: AppOSTextStyles.osMd.copyWith(
                      color: AppColors.gray400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.mic,
                  size: 20,
                  color: AppColors.gray300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetails() {
    if (_companionDetails == null) {
      return const Center(child: Text('No appointment details available'));
    }
    
    final details = _companionDetails!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.typeOfVisitOrExam != null) ...[
            _buildDetailSection('Appointment Type', details.typeOfVisitOrExam!.description),
            const SizedBox(height: 16),
          ],
          if (details.typeOfDoctorProvider != null) ...[
            _buildDetailSection('Care Provider', details.typeOfDoctorProvider!.description),
            const SizedBox(height: 16),
          ],
          if (details.mainReasonForVisit != null) ...[
            _buildDetailSection('Main Reason for Visit', details.mainReasonForVisit!.description),
            const SizedBox(height: 16),
          ],
          if (details.importantSymptomsToDiscuss?.isNotEmpty == true) ...[
            _buildDetailSection(
              'Important Symptoms to Discuss',
              details.importantSymptomsToDiscuss!.map((s) => s.description).join(', '),
            ),
            const SizedBox(height: 16),
          ],
          if (details.lifeStressorsAffectingHealth?.isNotEmpty == true) ...[
            _buildDetailSection(
              'Life Stressors',
              details.lifeStressorsAffectingHealth!.map((s) => s.description).join(', '),
            ),
            const SizedBox(height: 16),
          ],
          if (details.journeyWithThisConcern != null) ...[
            _buildDetailSection('Journey with This Concern', details.journeyWithThisConcern!.description),
            const SizedBox(height: 16),
          ],
          if (details.prioritizeYourConcerns != null) ...[
            _buildDetailSection('Priority Concerns', details.prioritizeYourConcerns!.description),
            const SizedBox(height: 16),
          ],
          if (details.symptomsBeenChangingOverTime != null) ...[
            _buildDetailSection('Symptoms Changing Over Time', details.symptomsBeenChangingOverTime!.description),
            const SizedBox(height: 16),
          ],
          if (details.communicateWithYourHealthcare?.isNotEmpty == true) ...[
            _buildDetailSection(
              'Communication Preferences',
              details.communicateWithYourHealthcare!.map((s) => s.description).join(', '),
            ),
            const SizedBox(height: 16),
          ],
          if (details.tryingToGetCare?.isNotEmpty == true) ...[
            _buildDetailSection(
              'Challenges Getting Care',
              details.tryingToGetCare!.map((s) => s.description).join(', '),
            ),
            const SizedBox(height: 16),
          ],
          if (details.afraidOverlooked?.isNotEmpty == true) ...[
            _buildDetailSection(
              'Concerns About Being Overlooked',
              details.afraidOverlooked!.map((s) => s.description).join(', '),
            ),
            const SizedBox(height: 16),
          ],
          _buildDetailSection('Status', details.status ?? 'Unknown'),
          const SizedBox(height: 16),
          if (details.createdAt != null) ...[
            _buildDetailSection('Created', _formatDate(details.createdAt!)),
            const SizedBox(height: 16),
          ],
          if (details.updatedAt != null) ...[
            _buildDetailSection('Last Updated', _formatDate(details.updatedAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crossGlassBase.withOpacity(0.28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200.withOpacity(0.9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppOSTextStyles.osMdSemiboldTitle.copyWith(color: AppColors.primary01),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppOSTextStyles.osMd.copyWith(color: AppColors.davysGray),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
