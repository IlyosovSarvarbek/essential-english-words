import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/vocabulary.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

Widget label(
  BuildContext context,
  String text, {
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? spacing,
  TextAlign? align,
  double height = 1.3,
  TextDecoration? decoration,
  int? maxLines,
}) => Text(
  text,
  textAlign: align,
  maxLines: maxLines,
  overflow: maxLines == null ? null : TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.of(context).text,
    letterSpacing: spacing,
    height: height,
    decoration: decoration,
  ),
);

class AppHeader extends StatelessWidget {
  const AppHeader(
    this.title, {
    super.key,
    this.back = true,
    this.onBack,
    this.themeToggle = false,
    this.trailing,
  });
  final String title;
  final bool back;
  final VoidCallback? onBack;
  final bool themeToggle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(
            color: (colors.dark ? Colors.white : Colors.black).withValues(
              alpha: colors.dark ? .08 : .06,
            ),
            width: .5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (back) ...[
                  IconControl(
                    icon: LucideIcons.arrowLeft,
                    tooltip: 'Go back',
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: label(
                    context,
                    title,
                    size: 20,
                    weight: FontWeight.w700,
                    spacing: -.3,
                    maxLines: 1,
                  ),
                ),
                if (themeToggle)
                  IconControl(
                    icon: colors.dark ? LucideIcons.sun : LucideIcons.moon,
                    tooltip: 'Toggle theme',
                    onPressed: () =>
                        AppScope.of(context).toggleTheme(colors.dark),
                  ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.back = true,
    this.onBack,
    this.themeToggle = false,
    this.trailing,
    this.belowHeader,
  });
  final String title;
  final Widget child;
  final bool back;
  final VoidCallback? onBack;
  final bool themeToggle;
  final Widget? trailing;
  final Widget? belowHeader;
  @override
  Widget build(BuildContext context) {
    final dark = AppColors.of(context).dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColors.of(context).background,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: Scaffold(
        body: Column(
          children: [
            AppHeader(
              title,
              back: back,
              onBack: onBack,
              themeToggle: themeToggle,
              trailing: trailing,
            ),
            ?belowHeader,
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class ContentList extends StatelessWidget {
  const ContentList({
    super.key,
    required this.children,
    this.top = 12,
    this.gap = 0,
  });
  final List<Widget> children;
  final double top;
  final double gap;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, top, 16, bottomSpace(context)),
        itemCount: children.length,
        separatorBuilder: (_, _) => SizedBox(height: gap),
        itemBuilder: (_, index) => children[index],
      ),
    ),
  );
}

double bottomSpace(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom.clamp(24, double.infinity) + 48;

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 12,
    this.onTap,
    this.color,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: color ?? colors.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: borderColor ?? colors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding.add(const EdgeInsets.all(1)),
            child: child,
          ),
        ),
      ),
    );
    return Semantics(container: true, button: onTap != null, child: card);
  }
}

class ProgressTrack extends StatelessWidget {
  const ProgressTrack(this.percent, {super.key, this.height = 6, this.color});
  final num percent;
  final double height;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      label: 'Progress',
      value: '${percent.round()}%',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: ColoredBox(
            color: colors.highest,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percent.toDouble().clamp(0, 100) / 100,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color ?? colors.blue,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconControl extends StatelessWidget {
  const IconControl({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 40,
    this.iconSize = 20,
    this.color,
    this.background,
    this.radius = 8,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final double radius;
  final Color? color;
  final Color? background;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    excludeFromSemantics: true,
    child: Semantics(
      container: true,
      button: true,
      label: tooltip,
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: background ?? AppColors.of(context).low,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          splashColor: (color ?? AppColors.of(context).primary).withValues(
            alpha: .18,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color: color ?? AppColors.of(context).text,
            ),
          ),
        ),
      ),
    ),
  );
}

class ActionButton extends StatelessWidget {
  const ActionButton(
    this.text, {
    super.key,
    required this.onPressed,
    this.icon,
    this.leadingIcon,
    this.background,
    this.color,
    this.border,
    this.height = 48,
    this.radius = 10,
    this.fontSize = 15,
    this.weight = FontWeight.w600,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? leadingIcon;
  final Color? background;
  final Color? color;
  final Color? border;
  final double height;
  final double radius;
  final double fontSize;
  final FontWeight weight;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = color ?? Colors.white;
    final button = Opacity(
      opacity: onPressed == null ? .4 : 1,
      child: Material(
        color: background ?? colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border ?? Colors.transparent),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          splashColor: foreground.withValues(alpha: .18),
          highlightColor: foreground.withValues(alpha: .06),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18, color: foreground),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: label(
                      context,
                      text,
                      size: fontSize,
                      weight: weight,
                      color: foreground,
                      align: TextAlign.center,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 6),
                    Icon(icon, size: 18, color: foreground),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      label: text,
      onTap: onPressed,
      excludeSemantics: true,
      child: button,
    );
  }
}

class PartOfSpeech extends StatelessWidget {
  const PartOfSpeech(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.weight = FontWeight.w600,
  });
  final String text;
  final EdgeInsets padding;
  final FontWeight weight;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.of(context).high,
      borderRadius: BorderRadius.circular(6),
    ),
    child: label(
      context,
      text.toUpperCase(),
      size: 11,
      weight: weight,
      color: AppColors.of(context).muted,
      spacing: .5,
    ),
  );
}

class AudioButton extends StatelessWidget {
  const AudioButton(this.word, {super.key, this.size = 38});
  final Word word;
  final double size;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final state = AppScope.of(context);
    return IconControl(
      icon: LucideIcons.volume2,
      tooltip: 'Listen pronunciation of ${word.english}',
      size: size,
      radius: size / 2,
      background: colors.high,
      color: colors.primary,
      onPressed: () => unawaited(
        state.pronunciation.speak(word.english).catchError((Object error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Pronunciation is unavailable. Check your English speech voice.',
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = LucideIcons.search,
    this.iconColor,
    this.actions,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 80),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.container,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: iconColor ?? colors.muted),
              ),
              const SizedBox(height: 16),
              label(
                context,
                title,
                size: 20,
                weight: FontWeight.w700,
                align: TextAlign.center,
              ),
              const SizedBox(height: 8),
              label(
                context,
                description,
                color: colors.muted,
                height: 20 / 14,
                align: TextAlign.center,
              ),
              if (actions != null) ...[
                const SizedBox(height: 24),
                for (final action in actions!) ...[
                  SizedBox(width: double.infinity, child: action),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
