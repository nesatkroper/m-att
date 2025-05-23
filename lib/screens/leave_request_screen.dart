import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:attendance/providers/auth_provider.dart';
import 'package:attendance/providers/attendance_provider.dart';

class LeaveRequestScreen extends HookWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Form controllers
    final typeController = useState('sick'); // Default type
    final reasonController = useTextEditingController();
    final startDate = useState(DateTime.now());
    final endDate = useState(DateTime.now().add(const Duration(days: 1)));
    final isSubmitting = useState(false);

    // Form validation state
    final reasonError = useState<String?>(null);

    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    // Leave type options
    final leaveTypes = [
      {'value': 'sick', 'label': 'Sick Leave', 'icon': Icons.healing},
      {'value': 'vacation', 'label': 'Vacation', 'icon': Icons.beach_access},
      {'value': 'personal', 'label': 'Personal', 'icon': Icons.person},
      {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
    ];

    // Function to pick date
    Future<void> pickDate(bool isStartDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? startDate.value : endDate.value,
        firstDate: isStartDate ? DateTime.now() : startDate.value,
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: colorScheme.primary,
                onPrimary: colorScheme.onPrimary,
                surface: colorScheme.surface,
                onSurface: colorScheme.onSurface,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        if (isStartDate) {
          startDate.value = picked;
          // Ensure end date is not before start date
          if (endDate.value.isBefore(picked)) {
            endDate.value = picked;
          }
        } else {
          endDate.value = picked;
        }
      }
    }

    // Submit request function
    void submitRequest() async {
      // Validate form
      if (reasonController.text.trim().isEmpty) {
        reasonError.value = 'Please provide a reason for your leave request';
        return;
      } else {
        reasonError.value = null;
      }

      if (authProvider.currentEmployee == null) return;

      isSubmitting.value = true;

      try {
        await attendanceProvider.submitLeaveRequest(
          employeeId: authProvider.currentEmployee!.id,
          type: typeController.value,
          reason: reasonController.text.trim(),
          startDate: startDate.value,
          endDate: endDate.value,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorScheme.primary,
              content: const Text(
                'Leave request submitted successfully!',
                style: TextStyle(color: Colors.white),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pop(context, true); // Return success
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorScheme.error,
              content: Text(
                'Failed to submit request: ${e.toString()}',
                style: const TextStyle(color: Colors.white),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Leave'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave Type Selection
                Text(
                  'Leave Type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: leaveTypes.map((type) {
                      final isSelected = typeController.value == type['value'];
                      return InkWell(
                        onTap: () {
                          typeController.value = type['value'] as String;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colorScheme.outline.withOpacity(0.2),
                                width: type['value'] != leaveTypes.last['value']
                                    ? 0.5
                                    : 0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary.withOpacity(0.1)
                                      : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  type['icon'] as IconData,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withOpacity(0.6),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  type['label'] as String,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Radio<String>(
                                value: type['value'] as String,
                                groupValue: typeController.value,
                                onChanged: (value) {
                                  if (value != null) {
                                    typeController.value = value;
                                  }
                                },
                                activeColor: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Date Selection
                Text(
                  'Leave Dates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => pickDate(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${startDate.value.day}/${startDate.value.month}/${startDate.value.year}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => pickDate(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${endDate.value.day}/${endDate.value.month}/${endDate.value.year}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reason Input
                Text(
                  'Reason for Leave',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: reasonController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Please provide details about your leave request...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                      errorText: reasonError.value,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSubmitting.value ? null : submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor:
                          colorScheme.primary.withOpacity(0.5),
                    ),
                    child: isSubmitting.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send),
                              const SizedBox(width: 10),
                              Text(
                                'Submit Request',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
