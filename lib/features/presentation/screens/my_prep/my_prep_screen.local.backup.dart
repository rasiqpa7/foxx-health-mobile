import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/view/appointment_companion_screen.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/view/appointment_flow.dart';
import 'package:foxxhealth/features/data/models/appointment_companion_model.dart';
import 'package:foxxhealth/features/presentation/cubits/appointment_companion/appointment_companion_cubit.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/screens/my_prep/appointment_companion_details_screen.dart';

class MyPrepScreen extends StatefulWidget {
  const MyPrepScreen({Key? key}) : super(key: key);

  @override
  State<MyPrepScreen> createState() => _MyPrepScreenState();
}

class _MyPrepScreenState extends State<MyPrepScreen> {
  String selectedTag = 'All';
  final List<String> tags = ['All', 'Upcoming Visit', 'PCOS', 'Past', 'M'];
  
  final AppointmentCompanionCubit _service = AppointmentCompanionCubit();
  List<AppointmentCompanion> _companions = [];
  List<AppointmentCompanion> _filteredCompanions = [];
  bool _isLoading = true;
  String? _error;
  
  // Sort functionality
  String _selectedSortOption = 'Date updated';
  final List<String> _sortOptions = ['Date created', 'Date updated', 'Appointment date'];

  @override
  void initState() {
    super.initState();
    _loadAppointmentCompanions();
  }

  Future<void> _loadAppointmentCompanions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _service.getAppointmentCompanions();
      setState(() {
        _companions = response.companions;
        _filteredCompanions = _sortCompanions(_companions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: FoxxBackButton(),
          title: Text(
            'My Prep',
            style: AppOSTextStyles.osMdBold.copyWith(color: AppColors.primary01),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags Section
              Container(
                color: AppColors.crossGlassBase.withOpacity(0.38),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: AppOSTextStyles.osSmSemiboldLabel
                          .copyWith(color: AppColors.davysGray),
                    ),
                    const SizedBox(height: 12),
                    _buildTagsSection(),
                  ],
                ),
              ),
              const SizedBox(height: 34),

              // Title and Action Buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Prep',
                      style: AppHeadingTextStyles.h2
                          .copyWith(color: AppColors.primary01),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AppointmentCompanionDetailsScreen(
                                  origin: 'myprep',
                                ),
                              ),
                            );
                          },
                          child: _buildActionButton('New', Icons.add),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _showSortModal,
                          child: _buildActionButton('', Icons.sort),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Appointment Companions List
              Expanded(
                child: _buildAppointmentCompanionsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = tag == selectedTag;

          return Padding(
            padding: EdgeInsets.only(right: index < tags.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTag = tag;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.mauve50
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.amethyst : AppColors.gray200,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
                    color:
                        isSelected ? AppColors.amethyst : AppColors.davysGray,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.crossGlassBase.withOpacity(0.38),
        borderRadius: BorderRadius.circular(20),

      ),
      child: Center(
        child: text.isNotEmpty
            ? Text(
                text,
                style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
                  color: AppColors.amethyst,
                ),
              )
            : Icon(
                icon,
                color: AppColors.amethyst,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildAppointmentCompanionsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.amethystViolet, size: 48),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                color: AppColors.davysGray,
              ),
            ),
            const SizedBox(height: 8),
            // Text(
            //   'Unable to load appointment companions at this time',
            //   style: AppOSTextStyles.osSmSemiboldBody.copyWith(
            //     color: AppColors.davysGray,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _loadAppointmentCompanions,
            //   child: const Text('Retry'),
            // ),
          ],
        ),
      );
    }

    if (_companions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, color: AppColors.amethystViolet, size: 48),
            const SizedBox(height: 16),
            Text(
              'No appointment companions yet',
              style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                color: AppColors.davysGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first appointment companion to get started',
              style: AppOSTextStyles.osSmSemiboldBody.copyWith(
                color: AppColors.davysGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointmentCompanions,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _filteredCompanions.length,
        itemBuilder: (context, index) {
          final companion = _filteredCompanions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAppointmentCard(companion),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentCompanion companion) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AppointmentCompanionScreen(
              appointmentData: {
                'companionId': companion.id,
                'status': companion.status,
                'createdAt': companion.createdAt.toIso8601String(),
                'updatedAt': companion.updatedAt.toIso8601String(),
              },
              onRefresh: _loadAppointmentCompanions,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCardDecoration,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companion.displayTitle,
                    style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                      color: AppColors.primary01,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      //   decoration: BoxDecoration(
                      //     color: _getStatusColor(companion.status),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Text(
                      //     companion.status,
                      //     style: AppOSTextStyles.osSmSemiboldBody.copyWith(
                      //       color: Colors.white,
                      //       fontSize: 10,
                      //     ),
                      //   ),
                      // ),

                      Text(
                        _selectedSortOption == 'Date created' 
                            ? 'Created: ${companion.displayDate}'
                            : _selectedSortOption == 'Date updated'
                                ? 'Updated: ${_formatDate(companion.updatedAt)}'
                                : 'Appointment: ${_formatDate(companion.lastPausedAt)}',
                        style: AppOSTextStyles.osSmSemiboldBody.copyWith(
                          color: AppColors.davysGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.amethyst,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in-progress':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return AppColors.amethystViolet;
    }
  }

  List<AppointmentCompanion> _sortCompanions(List<AppointmentCompanion> companions) {
    final sortedList = List<AppointmentCompanion>.from(companions);
    
    switch (_selectedSortOption) {
      case 'Date created':
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Date updated':
        sortedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'Appointment date':
        sortedList.sort((a, b) => b.lastPausedAt.compareTo(a.lastPausedAt));
        break;
    }
    
    return sortedList;
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _SortModalContent(
          currentSortOption: _selectedSortOption,
          sortOptions: _sortOptions,
          onApply: (String selectedOption) {
            setState(() {
              _selectedSortOption = selectedOption;
              _filteredCompanions = _sortCompanions(_companions);
            });
          },
        );
      },
    );
  }

}

class _SortModalContent extends StatefulWidget {
  final String currentSortOption;
  final List<String> sortOptions;
  final Function(String) onApply;

  const _SortModalContent({
    required this.currentSortOption,
    required this.sortOptions,
    required this.onApply,
  });

  @override
  State<_SortModalContent> createState() => _SortModalContentState();
}

class _SortModalContentState extends State<_SortModalContent> {
  late String _selectedSortOption;

  @override
  void initState() {
    super.initState();
    _selectedSortOption = widget.currentSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.sort, color: AppColors.amethystViolet),
                const SizedBox(width: 8),
                Text(
                  'Sort by',
                  style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                    color: AppColors.primary01,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sort options
          ...widget.sortOptions.map((option) => Column(
            children: [
              RadioListTile<String>(
                title: Text(
                  option,
                  style: AppOSTextStyles.osMdSemiboldBody.copyWith(
                    color: AppColors.primary01,
                  ),
                ),
                value: option,
                groupValue: _selectedSortOption,
                onChanged: (value) {
                  setState(() {
                    _selectedSortOption = value!;
                  });
                },
                activeColor: AppColors.amethystViolet,
              ),
              if (option != widget.sortOptions.last)
                Divider(
                  color: AppColors.gray200,
                  height: 1,
                ),
            ],
          )),

          const SizedBox(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedSortOption);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amethystViolet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Apply',
                      style: AppOSTextStyles.osMdSemiboldBody.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppOSTextStyles.osMdSemiboldBody.copyWith(
                      color: AppColors.amethystViolet,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNavigationBottomSheet(
      BuildContext context, String appointmentTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  appointmentTitle,
                  style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                    color: AppColors.primary01,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Navigation options
              _buildNavigationOption(
                context,
                Icons.edit,
                'Edit Appointment Companion',
                'Modify details and questions',
                () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit screen
                },
              ),
              _buildNavigationOption(
                context,
                Icons.share,
                'Share',
                'Share with your healthcare provider',
                () {
                  Navigator.pop(context);
                  // TODO: Implement share functionality
                },
              ),
              _buildNavigationOption(
                context,
                Icons.download,
                'Export',
                'Download as PDF or document',
                () {
                  Navigator.pop(context);
                  // TODO: Implement export functionality
                },
              ),
              _buildNavigationOption(
                context,
                Icons.delete_outline,
                'Delete',
                'Remove this appointment companion',
                () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, appointmentTitle);
                },
              ),
              const SizedBox(height: 20),

              // Cancel button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppOSTextStyles.osMdSemiboldLink.copyWith(
                        color: AppColors.davysGray,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.mauve50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.amethyst,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
          color: AppColors.primary01,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppOSTextStyles.osSmSemiboldBody.copyWith(
          color: AppColors.davysGray,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, String appointmentTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Appointment Companion',
            style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
              color: AppColors.primary01,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$appointmentTitle"? This action cannot be undone.',
            style: AppOSTextStyles.osMd.copyWith(
              color: AppColors.davysGray,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppOSTextStyles.osMdSemiboldLink.copyWith(
                  color: AppColors.davysGray,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement delete functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$appointmentTitle deleted'),
                    backgroundColor: AppColors.amethyst,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: AppOSTextStyles.osMdSemiboldLink.copyWith(
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary01 : AppColors.gray600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
              color: isActive ? AppColors.primary01 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
