import 'package:timeago/timeago.dart' as timeago;

abstract class TimeUtils {
  static String timeagoFormat(DateTime? time) {
    if (time == null) return "Nunca";
    return timeago.format(time, locale: 'es');
  }

  static String generateDateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
