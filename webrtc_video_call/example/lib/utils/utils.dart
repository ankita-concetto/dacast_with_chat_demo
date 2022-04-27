import 'package:intl/intl.dart';

class Utils {
  static const bool USER_STATUS_ENABLE = true;
  static const bool USER_MESSAGE_SENT_STATUS = true;
  static const bool UPLOAD_IMAGE = true;

  static final date_format_dd_mm_yyyy = DateFormat('dd-MM-yyyy');
  static final date_format_mmmm_dd_yyyy  = DateFormat("MMM dd, yyyy");
  static final date_format_yyyy_mm_dd_hh_mm_ss = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
  static final date_format_hh_mm_a = DateFormat('hh:mm a');
}
