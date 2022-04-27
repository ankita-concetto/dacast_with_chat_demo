import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///
/// This class contains all UI related styles
///
class AppTheme extends StatefulWidget {
  final Widget? child;

  AppTheme({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return AppThemeState();
  }

  static AppThemeState of(BuildContext context) {
    final _InheritedStateContainer? inheritedStateContainer =
    context.dependOnInheritedWidgetOfExactType();
    if (inheritedStateContainer == null) {
      return AppThemeState();
    } else {
      return inheritedStateContainer.data!;
    }
  }
}

class AppThemeState extends State<AppTheme> {
  double getResponsiveFont(double value) => ScreenUtil().setSp(value);

  double getResponsiveWidth(double value) => ScreenUtil().setWidth(value);

  double getResponsiveHeight(double value) => ScreenUtil().setHeight(value);

  Color get whiteColor => Color(0xFFFFFFFF);

  Color get lightWhiteColor => Color(0xFFEBEBEB);

  Color get primaryColor => Color(0xFF93C01F);

  Color get darkGreen => Color(0xFF4EC01F);

  Color get sellerPrimaryColor => Color(0xFF0086B5);

  Color get secondaryColor => Color(0xFF0086B5);

  Color get hexe1e1e1 => Color(0xffe1e1e1);

  Color get hexa1a1a1 => Color(0xffa1a1a1);

  Color get hexC9C9C9 => Color(0xFFC9C9C9);

  Color get redColor => Color(0xFFD9534F);

  Color get hexC2C2C2 => Color(0xFFC2C2C2);

  Color get hexF9FFEA => Color(0xFFF9FFEA);

  Color get hexCCCCCC => Color(0xFFCCCCCC);

  Color get hexF9FFE9 => Color(0xFFF9FFE9);

  Color get blackColor => Color(0xFF000000);

  Color get blackColorB3 => Color(0xB3000000);

  Color get hexBEFFFFFF => Color(0xBEFFFFFF); // whiteTransparent

  Color get bottomPanelColor => Color(0xFAFFFFFF);

  Color get hex717171 => Color(0xFF717171);

  Color get hex707070 => Color(0xFF707070);

  Color get hex8D8D8D => Color(0xFF8D8D8D);

  Color get hexE9E9E9 => Color(0xFFE9E9E9);

  Color get hexF5F5F5 => Color(0xFFF5F5F5);

  Color get hex9A9A9A => Color(0xFF9A9A9A);

  Color get hexF9ffea => Color(0xFFF9FFEA);

  Color get hex000000CC => Color(0xFF000000CC);

  Color get hex0000001A => Color(0x1100001A);

  Color get hex00000000 => Color(0xFF00000000);

  Color get bottomContainer => Color(0xFFE9E9E9);

  Color get greyBorder => Color(0xFFE1E1E1);

  Color get hex0086B5 => Color(0xFF0086B5);

  Color get hexE1E1E1 => Color(0xFFE1E1E1);

  Color get bottomNavigatorBackground => Color(0xFFF9FFEA);

  Color get hex71A9F2 => Color(0xFF71A9F2);

  Color get hex718DEE => Color(0xFF718DEE);

  Color get hex17C8B0 => Color(0xFF17C8B0);

  Color get hexFF9100 => Color(0xFFFF9100);

  Color get fbButtonBg => Color(0xFF1877F2);

  Color get hexC667F5 => Color(0xFFC667F5);

  Color get shimmerBackgroundColor => Color(0xff484848).withOpacity(0.3);

  Color get shimmerBaseColor => Colors.grey[300] ?? Colors.grey;

  Color get shimmerHighlightColor => Colors.grey[100] ?? Colors.grey;

  Color get hex4EC01F => Color(0xFF4EC01F);

  Color get sellerBottomContainer => Color(0xFFE5F8FF);

  Color get hexF7E6FF => Color(0xFFF7E6FF);

  Color get hexDFE4FF => Color(0xFFDFE4FF);

  Color get hexFFF0F3 => Color(0xFFFFF0F3);

  Color get hexE4F5F3 => Color(0xFFE4F5F3);

  Color get hexFF5A78 => Color(0xFFFF5A78);

  Color get hex24FFCB => Color(0xFF24FFCB);

  Color get hex0173F0 => Color(0xFF0173F0);

  Color get hexFF1059 => Color(0xFFFF1059);

  Color get hexF30C53 => Color(0xFFF30C53);

  Color get hexE5F8FF => Color(0xFFE5F8FF);

  Color get hex93C01F => Color(0xFF93C01F);

  Color get hexEBEBEB => Color(0xFFEBEBEB);

  ///
  /// Mention height and width which are mentioned in your design file(i.e XD)
  /// to maintain ratio for all other devices
  ///
  double get expectedDeviceWidth => 1080;

  double get expectedDeviceHeight => 1920;

  TextStyle customTextStyle(
      {double fontSize = 12,
        Color? color,
        TextDecoration? decoration}) {
    return TextStyle(
        decoration: decoration,
        fontSize: fontSize,
        color: color);
  }

  ThemeData darkTheme() {
    return ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.grey[900]);
  }

  ThemeData lightTheme() {
    return ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final AppThemeState? data;

  _InheritedStateContainer({
    Key? key,
    @required this.data,
    @required Widget? child,
  })  : assert(child != null),
        super(key: key, child: child!);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
