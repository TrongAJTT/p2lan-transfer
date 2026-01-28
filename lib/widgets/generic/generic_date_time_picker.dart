import 'package:flutter/material.dart';

import 'package:p2lan/utils/localization_utils.dart';

Future<DateTime?> showGenericDateTimePickerDialog(
  BuildContext context, {
  DateTime? initialDateTime,
  bool use24hrFormat = true,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => GenericDateTimePickerDialog(
      initialDateTime: initialDateTime,
      use24hrFormat: use24hrFormat,
    ),
  );
}

class GenericDateTimePickerDialog extends StatefulWidget {
  final DateTime? initialDateTime;
  final bool use24hrFormat;

  const GenericDateTimePickerDialog({
    super.key,
    this.initialDateTime,
    this.use24hrFormat = true,
  });

  @override
  State<GenericDateTimePickerDialog> createState() =>
      _GenericDateTimePickerDialogState();
}

class _GenericDateTimePickerDialogState
    extends State<GenericDateTimePickerDialog>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDateTime;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime ?? DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = LocalizationUtils.getDateTimeFormat(context,
        use24hrFormat: widget.use24hrFormat);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final dialogWidth = isDesktop ? 400.0 : double.infinity;
    final dialogPadding =
        isDesktop ? const EdgeInsets.all(32) : const EdgeInsets.all(16);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 8, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Padding(
          padding: dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Date'),
                  Tab(text: 'Time'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Date picker
                    CalendarDatePicker(
                      initialDate: _selectedDateTime,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            _selectedDateTime.hour,
                            _selectedDateTime.minute,
                          );
                        });
                      },
                    ),
                    // Time picker
                    Center(
                      child: TimePickerSpinner(
                        time: _selectedDateTime,
                        is24HourMode: widget.use24hrFormat,
                        onTimeChange: (time) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              _selectedDateTime.year,
                              _selectedDateTime.month,
                              _selectedDateTime.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                format.format(_selectedDateTime),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedDateTime),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple time picker spinner for hours/minutes (custom, no dependency)
class TimePickerSpinner extends StatelessWidget {
  final DateTime time;
  final bool is24HourMode;
  final ValueChanged<DateTime> onTimeChange;

  const TimePickerSpinner({
    super.key,
    required this.time,
    this.is24HourMode = true,
    required this.onTimeChange,
  });

  @override
  Widget build(BuildContext context) {
    final hour = time.hour;
    final minute = time.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour =
        is24HourMode ? hour : ((hour % 12 == 0) ? 12 : hour % 12);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour spinner
        NumberPicker(
          value: displayHour,
          minValue: is24HourMode ? 0 : 1,
          maxValue: is24HourMode ? 23 : 12,
          onChanged: (h) {
            onTimeChange(DateTime(
              time.year,
              time.month,
              time.day,
              is24HourMode ? h : (amPm == 'PM' ? (h % 12) + 12 : h % 12),
              minute,
            ));
          },
        ),
        const Text(":", style: TextStyle(fontSize: 24)),
        // Minute spinner
        NumberPicker(
          value: minute,
          minValue: 0,
          maxValue: 59,
          onChanged: (m) {
            onTimeChange(DateTime(
              time.year,
              time.month,
              time.day,
              hour,
              m,
            ));
          },
        ),
        if (!is24HourMode)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: DropdownButton<String>(
              value: amPm,
              items: const [
                DropdownMenuItem(value: 'AM', child: Text('AM')),
                DropdownMenuItem(value: 'PM', child: Text('PM'))
              ],
              onChanged: (v) {
                int newHour = hour;
                if (v == 'AM' && hour >= 12) newHour -= 12;
                if (v == 'PM' && hour < 12) newHour += 12;
                onTimeChange(DateTime(
                  time.year,
                  time.month,
                  time.day,
                  newHour,
                  minute,
                ));
              },
            ),
          ),
      ],
    );
  }
}

/// Simple number picker (no dependency)
class NumberPicker extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const NumberPicker({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 120,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: value - minValue),
        onSelectedItemChanged: (index) => onChanged(minValue + index),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final val = minValue + index;
            if (val > maxValue) return null;
            return Center(
              child: Text(
                val.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          },
        ),
      ),
    );
  }
}
