// widgets/meeting_food_requirements_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/meeting_food_provider.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/meeting_food_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class MeetingFoodWidget extends StatefulWidget {
  const MeetingFoodWidget({Key? key}) : super(key: key);

  @override
  State<MeetingFoodWidget> createState() => _MeetingFoodWidgetState();
}

class _MeetingFoodWidgetState extends State<MeetingFoodWidget> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingFoodProvider>().fetchMeetingFoodRequirements(context);
    });
  }

  void _selectDate(BuildContext context) async {
    final provider = context.read<MeetingFoodProvider>();
    final availableDates = provider.availableDates;
    
    if (availableDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meeting dates available')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: availableDates.first,
      lastDate: availableDates.last,
      selectableDayPredicate: (date) => provider.hasDataForDate(date),
    );

    if (picked != null) {
      provider.setSelectedDate(picked);
    }
  }

  Widget _buildFoodCountCard(FoodItem foodItem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorClass.brandLightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorClass.brandLightGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            foodItem.name,
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: ColorClass.brandDarkGreen,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorClass.brandDarkGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              foodItem.count.toString(),
              style: TextStyleClass.poppinsBold(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting title
          Text(
            meeting.title,
            style: TextStyleClass.poppinsSemiBold(fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Department and created by
          Row(
            children: [
              Icon(LucideIcons.building, size: 16, color: ColorClass.neutral400),
              const SizedBox(width: 4),
              Text(
                'Department: ${meeting.department}',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.user, size: 16, color: ColorClass.neutral400),
              const SizedBox(width: 4),
              Text(
                'Created by: ${meeting.createdBy}',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.neutral600,
                ),
              ),
            ],
          ),
          // Food requirements for this meeting
          if (meeting.foodCounts.activeFoodItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Food Requirements:',
              style: TextStyleClass.poppinsMedium(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: meeting.foodCounts.activeFoodItems
                  .map((foodItem) => _buildFoodCountCard(foodItem))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf({bool shareInsteadOfOpen = false}) async {
    final provider = context.read<MeetingFoodProvider>();
    final data = provider.getFormattedDataForPdf();
    
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to export')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Meeting Food Requirements',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date: ${DateFormat('dd MMM yyyy').format(provider.selectedDate)}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 16),
              
              // Overall totals
              pw.Text(
                'Total Food Requirements:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              
              // Food items summary
              ...(data['activeFoodItems'] as List<FoodItem>).map((item) => 
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${item.name}:', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('${item.count}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${data['grandTotal']}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Meetings details
              pw.Text(
                'Meeting Details (${data['totalMeetings']} meetings):',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              
              ...(data['meetings'] as List<Map<String, dynamic>>).map((meeting) => 
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      meeting['title'],
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Department: ${meeting['department']}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Created by: ${meeting['createdBy']}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Time: ${meeting['timeRange']}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Hall: ${meeting['hall']}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Persons: ${meeting['noOfPersons']}', style: pw.TextStyle(fontSize: 12)),
                    
                    // Food counts for this meeting
                    if ((meeting['foodCounts'] as List<FoodItem>).isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('Food Requirements:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ...(meeting['foodCounts'] as List<FoodItem>).map((food) => 
                        pw.Text('  • ${food.name}: ${food.count}', style: pw.TextStyle(fontSize: 11)),
                      ),
                    ],
                    
                    pw.SizedBox(height: 12),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/meeting-food-requirements-${data['date']}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (shareInsteadOfOpen) {
        await Share.shareXFiles([XFile(file.path)],
            text: 'Meeting Food Requirements - ${data['date']}');
      } else {
        await OpenFile.open(file.path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(shareInsteadOfOpen 
              ? 'PDF shared successfully' 
              : 'PDF generated and opened'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingFoodProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading meeting food requirements...'),
              ],
            ),
          );
        }

        if (provider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  provider.errorMessage.contains('Authentication')
                      ? LucideIcons.lock
                      : LucideIcons.alertCircle,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.brandDarkGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => provider.fetchMeetingFoodRequirements(context),
                ),
              ],
            ),
          );
        }

        if (provider.meetingFoodData == null) {
          return const SizedBox.shrink();
        }

        final selectedDateTotals = provider.selectedDateTotals;
        final selectedDateMeetings = provider.selectedDateMeetings;

        // Only show if there are food details for the selected date
        if (selectedDateTotals == null || selectedDateTotals.totalCount == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selection header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorClass.brandLightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorClass.brandLightGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Meeting Food Requirements',
                            style: TextStyleClass.poppinsSemiBold(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // No print/share buttons here
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Row(
                        children: [
                          Icon(LucideIcons.calendar, size: 16, color: ColorClass.brandDarkGreen),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(provider.selectedDate),
                            style: TextStyleClass.poppinsMedium(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down, color: ColorClass.brandDarkGreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Selected date totals (only)
              Text(
                'Selected Date Requirements',
                style: TextStyleClass.poppinsSemiBold(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorClass.neutral200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total for ${DateFormat('dd MMM').format(provider.selectedDate)}:',
                          style: TextStyleClass.poppinsMedium(fontSize: 16),
                        ),
                        Text(
                          selectedDateTotals.totalCount.toString(),
                          style: TextStyleClass.poppinsBold(
                            fontSize: 18,
                            color: ColorClass.brandDarkGreen,
                          ),
                        ),
                      ],
                    ),
                    if (selectedDateTotals.activeFoodItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedDateTotals.activeFoodItems
                            .map((foodItem) => _buildFoodCountCard(foodItem))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Meetings list for selected date
              if (selectedDateMeetings.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meetings (${selectedDateMeetings.length})',
                      style: TextStyleClass.poppinsSemiBold(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...selectedDateMeetings.map((meeting) => _buildMeetingCard(meeting)),
              ],
            ],
          ),
        );
      },
    );
  }
}