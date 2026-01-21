import 'package:flutter/material.dart';

/// Reusable form container used across the app (login, order, confirm, etc).
///
/// This intentionally handles:
/// - consistent rounded corners + padding
/// - optional title/description
/// - actions footer (e.g. Submit/Cancel buttons)
/// - scroll friendliness (wrap it in SingleChildScrollView in pages)
///
/// Field styling is controlled separately via Theme (`InputDecorationTheme`)
/// and button theming (`FilledButtonThemeData`, etc.).
class AppFormContainer extends StatelessWidget {
  const AppFormContainer({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.padding = const EdgeInsets.all(16),
    this.maxWidth = 520,
    this.expandChild = false,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final EdgeInsets padding;

  /// Useful for web/desktop: keeps forms from stretching too wide.
  final double maxWidth;

  /// Set true when [child] is a scrollable (e.g. ListView) so it can receive
  /// a bounded height and participate in layout correctly.
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHeader = (title != null && title!.trim().isNotEmpty) ||
        (subtitle != null && subtitle!.trim().isNotEmpty);
    final hasActions = actions != null && actions!.isNotEmpty;

    final Widget body = expandChild ? Expanded(child: child) : child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasHeader) ...[
                  if (title != null && title!.trim().isNotEmpty)
                    Text(title!, style: theme.textTheme.titleLarge),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 16),
                ],
                body,
                if (hasActions) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!
                        .expand((w) => [w, const SizedBox(width: 8)])
                        .toList()
                      ..removeLast(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


