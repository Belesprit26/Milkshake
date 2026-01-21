import 'package:flutter/material.dart';

/// Reusable list/tile card used for Drafts and Orders lists.
///
/// Keeps list items visually aligned with the rest of the app (rounded corners,
/// subtle border, consistent padding, and proper tap affordance).
class AppTileCard extends StatelessWidget {
  const AppTileCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = backgroundColor ?? Colors.white;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle(
                      style: theme.textTheme.titleSmall ??
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      DefaultTextStyle(
                        style: theme.textTheme.bodyMedium ??
                            const TextStyle(fontSize: 14, color: Color(0xFF667085)),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                DefaultTextStyle(
                  style: theme.textTheme.titleSmall ??
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


