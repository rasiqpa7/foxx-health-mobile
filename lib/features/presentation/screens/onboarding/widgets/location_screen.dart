import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:foxxhealth/features/presentation/widgets/neumorphic.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';

class LocationScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final Function(String)? onDataUpdate;
  
  const LocationScreen({super.key, this.onNext, this.onDataUpdate});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  bool _isSearching = false;
  String? selectedState;
  List<String> filteredStates = [];

  static const List<String> allStates = [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
    'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
    'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
    'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
    'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
    'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
    'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
    'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
    'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
  ];

  @override
  void initState() {
    super.initState();
    filteredStates = List.from(allStates);
  }

  void _filterStates(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStates = List.from(allStates);
      } else {
        filteredStates = allStates
            .where((state) => state.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showStateSelector() {
    setState(() {
      filteredStates = List.from(allStates);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(CupertinoIcons.xmark)),
                        Text(
                          'Location',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: AppTypography.semibold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 50)
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: AppColors.lightViolet,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search state',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _filterStates('');
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filterStates(value);
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredStates.length,
                  itemBuilder: (context, index) {
                    final state = filteredStates[index];
                    return InkWell(
                      onTap: () {
                        this.setState(() {
                          selectedState = state;
                          _locationController.text = state;
                        });
                        _searchController.clear();
                        _filterStates('');
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Text(
                          state,
                          style: AppTypography.bodyMd,
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
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _searchController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where do you live?',
                  style: AppHeadingTextStyles.h2,
                ),
                const SizedBox(height: 8),
                Text(
                  'We ask this because where you live can shape your health in real ways, whether it\'s care availability, environmental factors, or local support resources.',
                  style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                NeumorphicCard(
                  isSelected: false,
                  onTap: _showStateSelector,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _locationController,
                          focusNode: _locationFocusNode,
                          readOnly: true,
                          onTap: _showStateSelector,
                          decoration: InputDecoration(
                            hintText: 'Select state',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FoxxNextButton(
                    isEnabled: _locationController.text.isNotEmpty,
                    onPressed: () {
                      if (_locationController.text.isNotEmpty) {
                        widget.onDataUpdate?.call(_locationController.text);
                      }
                      widget.onNext?.call();
                    },
                    text: 'Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}