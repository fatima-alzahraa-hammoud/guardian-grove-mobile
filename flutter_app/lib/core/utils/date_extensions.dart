import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Returns a formatted date string like "17, 12, 2023"
  String get memberSinceFormat => DateFormat('dd, MM, yyyy').format(this);
  
  /// Returns a formatted date string like "Monday, December 17, 2023"
  String get fullDateFormat => DateFormat('EEEE, MMMM d, yyyy').format(this);
  
  /// Returns a formatted time string like "2:45 PM"
  String get timeFormat => DateFormat('h:mm a').format(this);
  
  /// Returns a formatted date and time string like "Dec 17, 2:45 PM"
  String get shortDateTimeFormat => DateFormat('MMM d, h:mm a').format(this);
  
  /// Returns age based on this birthday
  int get ageFromBirthday {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
  
  /// Returns a relative time string like "2 hours ago"
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Returns true if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Returns true if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Returns a human-readable date string
  String get humanReadableDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    
    final now = DateTime.now();
    final difference = now.difference(this).inDays;
    
    if (difference < 7) {
      return DateFormat('EEEE').format(this); // Monday, Tuesday, etc.
    } else if (difference < 365) {
      return DateFormat('MMM d').format(this); // Jan 15, Feb 20, etc.
    } else {
      return DateFormat('MMM d, yyyy').format(this); // Jan 15, 2023
    }
  }
}