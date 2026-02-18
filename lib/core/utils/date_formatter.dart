class DateFormatter {
  static const List<String> meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  static String formatDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatMonthYear(int month, int year) {
    return '${meses[month - 1]} $year';
  }

  static String formatMonthYearShort(int month, int year) {
    return '${month.toString().padLeft(2, '0')}/$year';
  }

  static String getMesNombre(int month) => meses[month - 1];

  static DateTime now() => DateTime.now();

  static int currentYear() => DateTime.now().year;

  static int currentMonth() => DateTime.now().month;

  static DateTime fromMilliseconds(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  static String formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class MonthNavigation {
  static void previousMonth(void Function(int year, int month) update) {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;
    
    if (month == 1) {
      month = 12;
      year--;
    } else {
      month--;
    }
    update(year, month);
  }

  static void nextMonth(void Function(int year, int month) update) {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;
    
    if (month == 12) {
      month = 1;
      year++;
    } else {
      month++;
    }
    update(year, month);
  }

  static (int year, int month) getPrevious(int year, int month) {
    if (month == 1) {
      return (year - 1, 12);
    }
    return (year, month - 1);
  }

  static (int year, int month) getNext(int year, int month) {
    if (month == 12) {
      return (year + 1, 1);
    }
    return (year, month + 1);
  }
}
