import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/models/meating_model.dart';
import 'package:hira_plus/screens/manager_screen/provider/meeting_provider.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class MeetingManagementScreen extends StatefulWidget {
  const MeetingManagementScreen({Key? key}) : super(key: key);

  @override
  State<MeetingManagementScreen> createState() =>
      _MeetingManagementScreenState();
}

class _MeetingManagementScreenState extends State<MeetingManagementScreen> {
  late MeetingProvider _provider;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logger.i('🏗️ [INIT] Initializing Meeting Management Screen');
    developer.log('🏗️ Initializing Meeting Management Screen',
        name: 'MeetingManagementScreen');

    _provider = MeetingProvider();
    Future.microtask(() {
      _logger.i('🔄 [DATA] Fetching meetings data');
      developer.log('🔄 Fetching meetings data',
          name: 'MeetingManagementScreen');
      _provider.fetchMeetings(context);
    });
  }

  @override
  void dispose() {
    _logger.i('🧹 [DISPOSE] Disposing Meeting Management Screen');
    developer.log('🧹 Disposing Meeting Management Screen',
        name: 'MeetingManagementScreen');
    _provider.dispose();
    super.dispose();
  }

  void _navigateToCreateScreen() {
    _logger.i('🧭 [NAVIGATION] Navigating to create meeting screen');
    developer.log('🧭 Navigating to create meeting screen',
        name: 'MeetingManagementScreen');

    navigateToWidget(
      context: context,
      route: ChangeNotifierProvider.value(
        value: _provider,
        child: const CreateMeetingScreen(),
      ),
    );
  }

  // Helper method to build detailed food text
  String _buildFoodDetailsText(MeetingModel meeting) {
    List<String> foodItems = [];

    if (meeting.breakfast > 0) {
      foodItems.add('Breakfast (${meeting.breakfast})');
    }
    if (meeting.midmorningSnacks > 0 || meeting.morningSnacksCount > 0) {
      foodItems.add(
          'Morning Snacks (${meeting.midmorningSnacks > 0 ? meeting.midmorningSnacks : meeting.morningSnacksCount})');
    }
    if (meeting.morningTeaCount > 0) {
      foodItems.add('Morning Tea (${meeting.morningTeaCount})');
    }
    if (meeting.lunch > 0) {
      foodItems.add('Lunch (${meeting.lunch})');
    }
    if (meeting.eveningsnacks > 0 || meeting.eveningSnacksCount > 0) {
      foodItems.add(
          'Evening Snacks (${meeting.eveningsnacks > 0 ? meeting.eveningsnacks : meeting.eveningSnacksCount})');
    }
    if (meeting.eveningTeaCount > 0) {
      foodItems.add('Evening Tea (${meeting.eveningTeaCount})');
    }
    if (meeting.dinner > 0) {
      foodItems.add('Dinner (${meeting.dinner})');
    }

    if (foodItems.isEmpty) {
      return 'Food Required (No items specified)';
    }

    return 'Food: ${foodItems.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MeetingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: ColorClass.brandWhite,
            appBar: AppBar(
              title: Text(
                'Meeting Management',
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 20,
                  color: ColorClass.white,
                ),
              ),
              backgroundColor: ColorClass.brandDarkGreen,
              elevation: 0,
              iconTheme: const IconThemeData(color: ColorClass.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _logger.i(
                      '🔙 [NAVIGATION] Navigating back from meeting management');
                  developer.log('🔙 Navigating back from meeting management',
                      name: 'MeetingManagementScreen');
                  navigateBack(context);
                },
              ),
            ),
            body: _buildBody(provider),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _navigateToCreateScreen,
              backgroundColor: ColorClass.brandDarkGreen,
              foregroundColor: Colors.white,
              icon: const Icon(LucideIcons.plus),
              label: const Text('Create Meeting'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(MeetingProvider provider) {
    if (provider.isLoading) {
      _logger.d('🔄 [UI] Showing loading state');
      developer.log('🔄 Showing loading state',
          name: 'MeetingManagementScreen');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 20),
            SizedBox(height: 16),
            Text('Loading meetings...'),
          ],
        ),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      _logger.e('❌ [ERROR] Error state: ${provider.errorMessage}');
      developer.log('❌ Error state: ${provider.errorMessage}',
          name: 'MeetingManagementScreen');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: ColorClass.neutral400,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.neutral500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _logger.i('🔄 [ACTION] Retry button pressed');
                developer.log('🔄 Retry button pressed',
                    name: 'MeetingManagementScreen');
                provider.fetchMeetings(context);
              },
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.brandDarkGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.meetings.isEmpty) {
      _logger.d('📭 [UI] Showing empty state');
      developer.log('📭 Showing empty state', name: 'MeetingManagementScreen');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendar,
              size: 64,
              color: ColorClass.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Meetings Found',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 20,
                color: ColorClass.neutral500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first meeting using the "Create Meeting" button below',
              textAlign: TextAlign.center,
              style: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: ColorClass.neutral400,
              ),
            ),
          ],
        ),
      );
    }

    _logger.d(
        '📋 [UI] Showing meetings list with ${provider.meetings.length} items');
    developer.log(
        '📋 Showing meetings list with ${provider.meetings.length} items',
        name: 'MeetingManagementScreen');

    return RefreshIndicator(
      onRefresh: () {
        _logger.i('🔄 [ACTION] Pull to refresh triggered');
        developer.log('🔄 Pull to refresh triggered',
            name: 'MeetingManagementScreen');
        return provider.fetchMeetings(context);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.meetings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final meeting = provider.meetings[index];
          return _buildMeetingCard(meeting, provider);
        },
      ),
    );
  }

  Widget _buildMeetingCard(MeetingModel meeting, MeetingProvider provider) {
    final formattedStartDate =
        DateFormat('EEEE, MMMM d, yyyy').format(meeting.startDatetime);
    final formattedStartTime =
        DateFormat('h:mm a').format(meeting.startDatetime);
    final formattedEndTime = DateFormat('h:mm a').format(meeting.endDatetime);
    final isPending = meeting.isPending;
    final isApproved = meeting.isApproved;

    return Container(
      decoration: BoxDecoration(
        color: ColorClass.brandWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? ColorClass.orangeLight.withOpacity(0.5)
              : ColorClass.brandLightGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPending
                ? ColorClass.orangeLight.withOpacity(0.1)
                : ColorClass.brandLightGreen.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.title,
                        style: TextStyleClass.poppinsSemiBold(
                          fontSize: 16,
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meeting.description,
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: ColorClass.neutral500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending
                        ? ColorClass.orangeLighter
                        : ColorClass.brandLightGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPending ? 'Pending Approval' : 'Approved',
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 12,
                      color: isPending
                          ? ColorClass.orangeDark
                          : ColorClass.brandDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meeting Details
            _buildDetailRow(LucideIcons.calendar, formattedStartDate),
            const SizedBox(height: 6),
            _buildDetailRow(
                LucideIcons.clock, '$formattedStartTime - $formattedEndTime'),
            const SizedBox(height: 6),
            _buildDetailRow(LucideIcons.mapPin, meeting.hall),
            const SizedBox(height: 6),
            _buildDetailRow(
                LucideIcons.users, '${meeting.noOfPersons} attendees'),
            const SizedBox(height: 6),
            _buildDetailRow(LucideIcons.building, meeting.department),

            if (meeting.foodRequired) ...[
              const SizedBox(height: 6),
              _buildDetailRow(
                  LucideIcons.utensils, _buildFoodDetailsText(meeting)),
            ],

            const SizedBox(height: 16),

            // Action Buttons based on status
            if (isPending) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _approveMeeting(meeting, provider),
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: Text(
                    'Approve Meeting',
                    style: TextStyleClass.poppinsMedium(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.greenBase,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else if (isApproved) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editMeeting(meeting),
                      icon: Icon(
                        LucideIcons.edit,
                        size: 14,
                        color: ColorClass.brandDarkGreen,
                      ),
                      label: Text(
                        'Edit',
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 12,
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorClass.brandLightGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(meeting, provider),
                      icon: Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: ColorClass.redDark,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 12,
                          color: ColorClass.redDark,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorClass.redLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            Text(
              'Created: ${DateFormat('MMM d, h:mm a').format(meeting.createdAt)}',
              style: TextStyleClass.poppinsRegular(
                fontSize: 11,
                color: ColorClass.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: ColorClass.neutral400,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyleClass.poppinsRegular(
              fontSize: 13,
              color: ColorClass.neutral500,
            ),
          ),
        ),
      ],
    );
  }

  void _approveMeeting(MeetingModel meeting, MeetingProvider provider) async {
    _logger.i('✅ [ACTION] Approving meeting: ${meeting.id}');
    developer.log('✅ Approving meeting: ${meeting.id}',
        name: 'MeetingManagementScreen');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success =
        await provider.updateMeetingStatus(context, meeting.id, 'approved');

    // Hide loading indicator
    if (mounted) {
      Navigator.of(context).pop();
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meeting "${meeting.title}" approved successfully'),
          backgroundColor: ColorClass.greenBase,
        ),
      );

      // Force refresh the meetings list
      await provider.fetchMeetings(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve meeting "${meeting.title}"'),
          backgroundColor: ColorClass.redBase,
        ),
      );
    }
  }

  void _showDeleteDialog(MeetingModel meeting, MeetingProvider provider) {
    _logger.i('🗑️ [ACTION] Delete dialog shown for meeting: ${meeting.id}');
    developer.log('🗑️ Delete dialog shown for meeting: ${meeting.id}',
        name: 'MeetingManagementScreen');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Meeting',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 18,
              color: ColorClass.brandDarkGreen,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${meeting.title}"?',
            style: TextStyleClass.poppinsRegular(
              fontSize: 16,
              color: ColorClass.neutral600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _logger.d('❌ [ACTION] Delete cancelled');
                developer.log('❌ Delete cancelled',
                    name: 'MeetingManagementScreen');
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: ColorClass.neutral500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                _logger.i(
                    '🗑️ [API] Attempting to delete meeting with id: [4m${meeting.id}[24m');
                developer.log(
                    '🗑️ Attempting to delete meeting with id: ${meeting.id}',
                    name: 'MeetingManagementScreen');

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                final success =
                    await provider.deleteMeeting(context, meeting.id);

                // Hide loading indicator
                if (mounted) {
                  Navigator.of(context).pop();
                }

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Meeting "${meeting.title}" deleted successfully'),
                      backgroundColor: ColorClass.greenBase,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed to delete meeting "${meeting.title}"'),
                      backgroundColor: ColorClass.redBase,
                    ),
                  );
                }
              },
              child: Text(
                'Delete',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: ColorClass.redDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editMeeting(MeetingModel meeting) {
    _logger.i('✏️ [NAVIGATION] Navigating to edit meeting: ${meeting.id}');
    developer.log('✏️ Navigating to edit meeting: ${meeting.id}',
        name: 'MeetingManagementScreen');

    navigateToWidget(
      context: context,
      route: ChangeNotifierProvider.value(
        value: _provider,
        child: CreateMeetingScreen(
          editingMeeting: meeting,
        ),
      ),
    );
  }
}

class CreateMeetingScreen extends StatefulWidget {
  final MeetingModel? editingMeeting;

  const CreateMeetingScreen({
    Key? key,
    this.editingMeeting,
  }) : super(key: key);

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noOfPersonsController = TextEditingController();

  // Food controllers
  final _breakfastController = TextEditingController(text: '0');
  final _midmorningSnacksController = TextEditingController(text: '0');
  final _lunchController = TextEditingController(text: '0');
  final _eveningsnacksController = TextEditingController(text: '0');
  final _dinnerController = TextEditingController(text: '0');

  DateTime _startDatetime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endDatetime = DateTime.now().add(const Duration(hours: 3));
  bool _foodRequired = false;

  // Dropdown selections
  String? _selectedDepartment;
  String? _selectedHall;

  // Department data from API
  List<String> _departments = [];
  bool _departmentsLoading = true;

  // Predefined halls - match backend enum
  final List<String> _halls = [
    'Conference Hall [3rd Floor]',
    'Auditorium [2nd Floor]',
    'Meeting Space [1st Floor]',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();

    // If editing, populate form with existing data
    if (widget.editingMeeting != null) {
      _populateFormForEditing();
    }
  }

  void _populateFormForEditing() {
    final meeting = widget.editingMeeting!;
    _titleController.text = meeting.title;
    _descriptionController.text = meeting.description;
    _noOfPersonsController.text = meeting.noOfPersons.toString();
    _startDatetime = meeting.startDatetime;
    _endDatetime = meeting.endDatetime;
    _selectedHall = meeting.hall;
    _selectedDepartment = meeting.department;
    _foodRequired = meeting.foodRequired;

    if (_foodRequired) {
      _breakfastController.text = meeting.breakfast.toString();
      _midmorningSnacksController.text = meeting.midmorningSnacks.toString();
      _lunchController.text = meeting.lunch.toString();
      _eveningsnacksController.text = meeting.eveningsnacks.toString();
      _dinnerController.text = meeting.dinner.toString();
    }

    // Ensure the hall from the meeting exists in the halls list to avoid dropdown assertion errors
    if (meeting.hall.isNotEmpty && !_halls.contains(meeting.hall)) {
      _halls.add(meeting.hall);
    }
  }

  /// Fetch departments from API
  Future<void> _fetchDepartments() async {
    try {
      developer.log('🏢 Fetching departments from API',
          name: 'CreateMeetingScreen');
      final url = '${ApiUrls.baseUrl}/admin/departments';

      final response = await HttpServiceUtils.fetchData(url, true);

      if (response != null) {
        List<String> departmentsList = [];

        // Handle different response formats
        if (response is Map<String, dynamic>) {
          if (response.containsKey('departments')) {
            final departments = response['departments'];
            if (departments is List) {
              departmentsList = departments.map((dept) {
                if (dept is Map && dept.containsKey('title')) {
                  return dept['title'].toString();
                }
                return dept.toString();
              }).toList();
            }
          } else if (response.containsKey('success') &&
              response['success'] == true) {
            // Handle success response format
            final departments =
                response['data'] ?? response['departments'] ?? [];
            if (departments is List) {
              departmentsList = departments.map((dept) {
                if (dept is Map && dept.containsKey('title')) {
                  return dept['title'].toString();
                }
                return dept.toString();
              }).toList();
            }
          }
        } else if (response is List) {
          // Direct list response
          departmentsList = response.map((dept) {
            if (dept is Map && dept.containsKey('title')) {
              return dept['title'].toString();
            }
            return dept.toString();
          }).toList();
        }

        if (mounted) {
          setState(() {
            _departments = departmentsList.isNotEmpty
                ? (departmentsList.toSet().toList()..sort())
                : ['IT', 'HR', 'Finance', 'Operations', 'Other']; // Fallback
            _departmentsLoading = false;

            // Ensure selected department is valid
            if (_selectedDepartment == null && _departments.isNotEmpty) {
              _selectedDepartment = _departments.first;
            } else if (_selectedDepartment != null &&
                !_departments.contains(_selectedDepartment)) {
              _selectedDepartment = _departments.first;
            }
          });
        }

        developer.log(
            '✅ Departments loaded: ${_departments.length} departments: $_departments',
            name: 'CreateMeetingScreen');
      } else {
        throw Exception('Empty response from server');
      }
    } catch (e) {
      developer.log('❌ Error fetching departments: $e',
          name: 'CreateMeetingScreen');
      if (mounted) {
        setState(() {
          _departmentsLoading = false;
          // Fallback to default departments
          _departments = ['IT', 'HR', 'Finance', 'Operations', 'Other'];
        });

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load departments. Using default list.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noOfPersonsController.dispose();
    _breakfastController.dispose();
    _midmorningSnacksController.dispose();
    _lunchController.dispose();
    _eveningsnacksController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingMeeting != null;

    return Scaffold(
      backgroundColor: ColorClass.brandWhite,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Meeting' : 'Create Meeting',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
        backgroundColor: ColorClass.brandDarkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorClass.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => navigateBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildTextField(
                controller: _titleController,
                label: 'Meeting Title',
                icon: LucideIcons.fileText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter meeting title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: LucideIcons.alignLeft,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter meeting description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date and Time Section
              Text(
                'Date & Time',
                style: TextStyleClass.poppinsSemiBold(fontSize: 16),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'Start Date & Time',
                      dateTime: _startDatetime,
                      onTap: () => _selectDateTime(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'End Date & Time',
                      dateTime: _endDatetime,
                      onTap: () => _selectDateTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hall Dropdown
              _buildHallDropdown(),
              const SizedBox(height: 16),

              // Number of Persons Field
              _buildTextField(
                controller: _noOfPersonsController,
                label: 'Number of Attendees',
                icon: LucideIcons.users,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of attendees';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Department Dropdown
              _buildDepartmentDropdown(),
              const SizedBox(height: 24),

              // Food Required Section
              Row(
                children: [
                  Switch(
                    value: _foodRequired,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _foodRequired = value;
                        });
                      }
                    },
                    activeColor: ColorClass.brandDarkGreen,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Food Required',
                    style: TextStyleClass.poppinsMedium(fontSize: 16),
                  ),
                ],
              ),

              if (_foodRequired) ...[
                const SizedBox(height: 16),
                Text(
                  'Food Requirements',
                  style: TextStyleClass.poppinsSemiBold(fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Food options grid
                Row(
                  children: [
                    Expanded(
                      child: _buildFoodCountField(
                        controller: _breakfastController,
                        label: 'Breakfast',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFoodCountField(
                        controller: _midmorningSnacksController,
                        label: 'Morning Snacks',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildFoodCountField(
                        controller: _lunchController,
                        label: 'Lunch',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFoodCountField(
                        controller: _eveningsnacksController,
                        label: 'Evening Snacks',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildFoodCountField(
                  controller: _dinnerController,
                  label: 'Dinner',
                ),
              ],

              const SizedBox(height: 32),

              // Create/Update Button
              SizedBox(
                width: double.infinity,
                child: Consumer<MeetingProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _saveMeeting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorClass.brandDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white)
                          : Text(
                              isEditing ? 'Update Meeting' : 'Create Meeting',
                              style:
                                  TextStyleClass.poppinsSemiBold(fontSize: 16),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorClass.brandDarkGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorClass.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorClass.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorClass.brandDarkGreen, width: 2),
        ),
        filled: true,
        fillColor: ColorClass.neutral100,
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime dateTime,
    required VoidCallback onTap,
  }) {
    final formatter = DateFormat('MMM dd, yyyy\nhh:mm a');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorClass.neutral300),
          borderRadius: BorderRadius.circular(12),
          color: ColorClass.neutral100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyleClass.poppinsRegular(
                fontSize: 12,
                color: ColorClass.neutral500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatter.format(dateTime),
              style: TextStyleClass.poppinsMedium(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHallDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hall/Venue',
          style: TextStyleClass.poppinsRegular(
            fontSize: 12,
            color: ColorClass.neutral500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedHall,
          decoration: InputDecoration(
            labelText: 'Select Hall/Venue',
            prefixIcon:
                Icon(LucideIcons.mapPin, color: ColorClass.brandDarkGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorClass.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorClass.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: ColorClass.brandDarkGreen, width: 2),
            ),
            filled: true,
            fillColor: ColorClass.neutral100,
          ),
          items: _halls.map((String hall) {
            return DropdownMenuItem<String>(
              value: hall,
              child: Text(hall),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (mounted) {
              setState(() {
                _selectedHall = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a hall/venue';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
          style: TextStyleClass.poppinsRegular(
            fontSize: 12,
            color: ColorClass.neutral500,
          ),
        ),
        const SizedBox(height: 8),
        _departmentsLoading
            ? Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: ColorClass.neutral300),
                  borderRadius: BorderRadius.circular(12),
                  color: ColorClass.neutral100,
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(width: 12),
                      Text('Loading departments...'),
                    ],
                  ),
                ),
              )
            : DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: 'Select Department',
                  prefixIcon: Icon(LucideIcons.building,
                      color: ColorClass.brandDarkGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: ColorClass.brandDarkGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: ColorClass.neutral100,
                ),
                items: _departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (mounted) {
                    setState(() {
                      _selectedDepartment = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
              ),
      ],
    );
  }

  Widget _buildFoodCountField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: ColorClass.neutral100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) {
        final number = int.tryParse(value ?? '0');
        if (number == null || number < 0) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final currentDateTime = isStartTime ? _startDatetime : _endDatetime;

    final date = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );

      if (time != null && mounted) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (mounted) {
          if (isStartTime) {
            _startDatetime = newDateTime;
            // Ensure end time is after start time
            if (_endDatetime.isBefore(_startDatetime)) {
              _endDatetime = _startDatetime.add(const Duration(hours: 2));
            }
          } else {
            if (newDateTime.isAfter(_startDatetime)) {
              _endDatetime = newDateTime;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End time must be after start time'),
                  backgroundColor: ColorClass.redBase,
                ),
              );
              return; // Don't call setState if invalid
            }
          }
          setState(() {}); // Update UI
        }
      }
    }
  }

  void _saveMeeting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<MeetingProvider>(context, listen: false);
    final isEditing = widget.editingMeeting != null;
    MeetingModel? meeting;
    if (isEditing) {
      meeting = await provider.updateMeeting(
        context,
        meetingId: widget.editingMeeting!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDatetime: _startDatetime,
        endDatetime: _endDatetime,
        hall: _selectedHall ?? 'Auditorium',
        noOfPersons: int.parse(_noOfPersonsController.text),
        foodRequired: _foodRequired,
        breakfast: int.parse(_breakfastController.text),
        midmorningSnacks: int.parse(_midmorningSnacksController.text),
        lunch: int.parse(_lunchController.text),
        eveningsnacks: int.parse(_eveningsnacksController.text),
        dinner: int.parse(_dinnerController.text),
        department: _selectedDepartment ?? 'IT',
      );
    } else {
      meeting = await provider.createMeeting(
        context,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDatetime: _startDatetime,
        endDatetime: _endDatetime,
        hall: _selectedHall ?? 'Auditorium',
        noOfPersons: int.parse(_noOfPersonsController.text),
        foodRequired: _foodRequired,
        breakfast: int.parse(_breakfastController.text),
        midmorningSnacks: int.parse(_midmorningSnacksController.text),
        lunch: int.parse(_lunchController.text),
        eveningsnacks: int.parse(_eveningsnacksController.text),
        dinner: int.parse(_dinnerController.text),
        department: _selectedDepartment ?? 'IT',
      );
    }

    if (meeting != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Meeting "${meeting.title}" ${isEditing ? 'updated' : 'created'} successfully'),
          backgroundColor: ColorClass.greenBase,
        ),
      );
      // Navigate back to the list screen
      navigateBack(context);
    }
  }
}
