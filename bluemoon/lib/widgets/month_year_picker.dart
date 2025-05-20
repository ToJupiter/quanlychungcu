import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime?> showMonthYearPicker(
  BuildContext context,
  {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }
) async {
  final ThemeData theme = Theme.of(context);
  final bool isDark = theme.brightness == Brightness.dark;
  final Color headerColor = isDark ? theme.colorScheme.surface : theme.colorScheme.primary;
  final Color headerTextColor = isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary;

  DateTime? selectedDate = initialDate;
  final List<String> months = DateFormat.MMMM('vi_VN').dateSymbols.MONTHS; // Full month names in Vietnamese

  // Determine year range
  final int currentYear = DateTime.now().year;
  final int firstYear = firstDate?.year ?? currentYear - 10;
  final int lastYear = lastDate?.year ?? currentYear + 10;
  List<int> years = List<int>.generate(lastYear - firstYear + 1, (index) => firstYear + index);

  int displayedYear = selectedDate.year;
  if (!years.contains(displayedYear)) {
    displayedYear = years.last;
  }

  return await showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Container(
              color: headerColor,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_left, color: headerTextColor),
                    onPressed: () {
                      if (years.contains(displayedYear - 1)) {
                        setStateDialog(() {
                          displayedYear--;
                        });
                      }
                    },
                  ),
                  Text(
                    displayedYear.toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerTextColor),
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_right, color: headerTextColor),
                    onPressed: () {
                       if (years.contains(displayedYear + 1)) {
                        setStateDialog(() {
                          displayedYear++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            content: SizedBox(
              width: 300, // Constrain width
              height: 320, // Constrain height to fit approx 6 months + year nav
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.8, // Adjust for button size
                ),
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final bool isSelected = selectedDate?.month == month && selectedDate?.year == displayedYear;
                  final bool isDisabled = 
                    (firstDate != null && displayedYear == firstDate.year && month < firstDate.month) ||
                    (lastDate != null && displayedYear == lastDate.year && month > lastDate.month) ||
                    (displayedYear < firstYear || displayedYear > lastYear);

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? theme.colorScheme.primaryContainer : null,
                        foregroundColor: isSelected ? theme.colorScheme.onPrimaryContainer : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isDisabled ? null : () {
                        selectedDate = DateTime(displayedYear, month);
                        Navigator.of(context).pop(selectedDate);
                      },
                      child: Text(months[index], textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Hủy'),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              TextButton(
                child: Text('Chọn Tháng Hiện Tại (${DateFormat('MM/yyyy').format(DateTime.now())})'),
                onPressed: () => Navigator.of(context).pop(DateTime(DateTime.now().year, DateTime.now().month)),
              ),
            ],
          );
        },
      );
    },
  );
} 