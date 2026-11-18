import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class AppColors {
  const AppColors(this.dark);
  final bool dark;
  Color get background =>
      dark ? const Color(0xff121316) : const Color(0xfff9f9ff);
  Color get surface => dark ? const Color(0xff121316) : Colors.white;
  Color get lowest => dark ? const Color(0xff0d0e11) : Colors.white;
  Color get low => dark ? const Color(0xff1b1b1f) : const Color(0xfff0f3ff);
  Color get container =>
      dark ? const Color(0xff1f1f23) : const Color(0xffe7eeff);
  Color get high => dark ? const Color(0xff292a2d) : const Color(0xffdee8ff);
  Color get highest => dark ? const Color(0xff343538) : const Color(0xffd8e3fb);
  Color get text => dark ? const Color(0xffe3e2e6) : const Color(0xff111c2d);
  Color get muted => dark ? const Color(0xffc4c6d4) : const Color(0xff515f74);
  Color get outline => dark ? const Color(0xff8e909d) : const Color(0xff747684);
  Color get outlineVariant =>
      dark ? const Color(0xff444652) : const Color(0xffc4c6d4);
  Color get primary => dark ? const Color(0xffb3c5ff) : const Color(0xff0f3b9a);
  Color get blue => const Color(0xff0f4cd9);
  Color get secondary =>
      dark ? const Color(0xffb5c4ff) : const Color(0xff515f74);
  Color get success => dark ? const Color(0xff4de082) : const Color(0xff15803d);
  Color get successContainer =>
      dark ? const Color(0xff003516) : const Color(0xffdcfce7);
  Color get error => dark ? const Color(0xffffb4ab) : const Color(0xffba1a1a);
  Color get errorContainer =>
      dark ? const Color(0xff2e1919) : const Color(0xfffee2e2);
  Color get cardBorder =>
      (dark ? Colors.white : Colors.black).withValues(alpha: .08);
  static AppColors of(BuildContext context) =>
      AppColors(Theme.of(context).brightness == Brightness.dark);
}

ThemeData appTheme(bool dark) {
  final colors = AppColors(dark);
  return ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.blue,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: colors.primary,
      surface: colors.background,
    ),
    fontFamily: kIsWeb || defaultTargetPlatform == TargetPlatform.android
        ? 'Roboto'
        : null,
    fontFamilyFallback: const ['NotoSansSymbols'],
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: colors.text, fontSize: 14, height: 1.2),
    ),
    splashFactory: InkRipple.splashFactory,
    splashColor: colors.primary.withValues(alpha: dark ? .16 : .12),
    highlightColor: colors.primary.withValues(alpha: .045),
    hoverColor: Colors.transparent,
    scrollbarTheme: const ScrollbarThemeData(
      thumbVisibility: WidgetStatePropertyAll(false),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SlidePageTransitionsBuilder(),
        TargetPlatform.iOS: SlidePageTransitionsBuilder(),
        TargetPlatform.windows: SlidePageTransitionsBuilder(),
        TargetPlatform.macOS: SlidePageTransitionsBuilder(),
        TargetPlatform.linux: SlidePageTransitionsBuilder(),
      },
    ),
  );
}

class SlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const SlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: SlideTransition(
        position: Tween(begin: Offset.zero, end: const Offset(-.25, 0)).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }
}
