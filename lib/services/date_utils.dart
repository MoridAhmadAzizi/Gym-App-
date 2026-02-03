class DateUtilsFa {
  static String two(int n) => n.toString().padLeft(2, '0');

  static String timeHm(DateTime dt) => '${two(dt.hour)}:${two(dt.minute)}';

  static String dateYmd(DateTime dt) => '${dt.year}/${two(dt.month)}/${two(dt.day)}';
}
