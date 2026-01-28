import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p2lan/l10n/app_localizations.dart';
import 'package:p2lan/utils/date_utils.dart';

class LocalizationUtils {
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    // Use 'yMd' for a standard numeric date format that adapts to the locale
    // e.g., 'M/d/y' for en_US, 'd/M/y' for en_GB, etc.
    final DateFormat formatter = DateFormat.yMd(locale);
    return formatter.format(date);
  }

  static String formatDateTime(
      {required BuildContext context,
      required DateTime dateTime,
      DateTimeFormatType formatType = DateTimeFormatType.full}) {
    final locale = Localizations.localeOf(context).toString();
    switch (formatType) {
      case DateTimeFormatType.full:
        final DateFormat formatter =
            DateFormat.yMd(locale).add_jms(); // Date and time
        return formatter.format(dateTime);
      case DateTimeFormatType.exceptSec:
        final DateFormat formatter =
            DateFormat.yMd(locale).add_jm(); // Date and time without seconds
        return formatter.format(dateTime);
      case DateTimeFormatType.message:
        if (MyDateUtils.isToday(dateTime)) {
          // Return time only if today
          return DateFormat.jm(locale).format(dateTime);
        } else if (MyDateUtils.isWithinWeek(dateTime)) {
          // Return weekday name if within the week
          final l10n = AppLocalizations.of(context);
          return getLocalizedWeekdayName(dateTime.weekday, l10n);
        } else {
          // Return date only if older than a week
          return formatDate(context, dateTime);
        }
    }
  }

  static String getLocalizedWeekdayName(
      dynamic weekday, AppLocalizations l10n) {
    if (weekday == null) return '';
    final day =
        weekday is int ? weekday : int.tryParse(weekday.toString()) ?? 1;
    switch (day) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }

  static String getLocalizedMonthName(dynamic month, AppLocalizations l10n) {
    if (month == null) return '';
    final monthNum = month is int ? month : int.tryParse(month.toString()) ?? 1;
    switch (monthNum) {
      case 1:
        return l10n.january;
      case 2:
        return l10n.february;
      case 3:
        return l10n.march;
      case 4:
        return l10n.april;
      case 5:
        return l10n.may;
      case 6:
        return l10n.june;
      case 7:
        return l10n.july;
      case 8:
        return l10n.august;
      case 9:
        return l10n.september;
      case 10:
        return l10n.october;
      case 11:
        return l10n.november;
      case 12:
        return l10n.december;
      default:
        return '';
    }
  }

  static String getFormattedDateTimeFromTotalMs(
      BuildContext context, int timestamp,
      {bool use24hrFormat = true, bool includeSeconds = false}) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return getFormattedDateTime(context, date,
        use24hrFormat: use24hrFormat, includeSeconds: includeSeconds);
  }

  /// Returns a formatted date string according to locale and 24h/12h preference
  static String getFormattedDateTime(BuildContext context, DateTime date,
      {bool use24hrFormat = true, bool includeSeconds = false}) {
    return getDateTimeFormat(context,
            use24hrFormat: use24hrFormat, includeSeconds: includeSeconds)
        .format(date);
  }

  /// Returns a DateFormat for date/time according to locale and 24h/12h preference
  static DateFormat getDateTimeFormat(BuildContext context,
      {bool use24hrFormat = true, bool includeSeconds = false}) {
    final locale = Localizations.localeOf(context).toString();
    String timeFormat = use24hrFormat ? 'HH:mm:ss' : 'h:mm:ss a';
    if (!includeSeconds) {
      timeFormat = timeFormat.replaceAll(':ss', '');
    }
    // Return value base on chosen language
    switch (locale) {
      case 'en_US':
        return DateFormat('MM/dd/yyyy $timeFormat');
      case 'vi_VN':
        return DateFormat('dd/MM/yyyy $timeFormat');
      default:
        return DateFormat('MM/dd/yyyy $timeFormat');
    }
  }

  /// Returns a formatted date string according to locale and 24h/12h preference
  static String getFormattedDateFromTotalMs(
      BuildContext context, int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return getFormattedDate(context, date);
  }

  /// Returns a DateFormat for date according to locale
  static String getFormattedDate(BuildContext context, DateTime date) {
    return getDateFormat(context).format(date);
  }

  /// Returns a DateFormat for date according to locale
  static DateFormat getDateFormat(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    switch (locale) {
      case 'en_US':
        return DateFormat('MM/dd/yyyy');
      case 'vi_VN':
        return DateFormat('dd/MM/yyyy');
      default:
        return DateFormat('MM/dd/yyyy');
    }
  }
}

enum DateTimeFormatType { full, exceptSec, message }
