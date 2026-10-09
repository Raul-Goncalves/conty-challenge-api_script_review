class TimezoneUtils {
  static const Duration saoPauloOffset = Duration(hours: -3);
  static DateTime endOfDayInSaoPaulo(DateTime localDate) {
    final localEndOfDay = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
      23,
      59,
      59,
      999,
      999,
    );
    return localEndOfDay.subtract(saoPauloOffset);
  }
}