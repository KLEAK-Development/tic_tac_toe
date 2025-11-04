import 'package:flutter/material.dart';
import 'package:tic_tac_toe/src/core/theme/app_spacing.dart' as spacing;

/// Reusable widget for popup menu items with checkmarks.
///
/// Displays a checkmark icon when selected, or empty space when not selected,
/// followed by the label text. Commonly used in PopupMenuButton items for
/// theme mode selection, language selection, and other settings.
class CheckableMenuItem extends StatelessWidget {
  /// Whether this menu item is currently selected
  final bool isSelected;

  /// The text label to display
  final String label;

  const CheckableMenuItem({
    super.key,
    required this.isSelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isSelected)
          const Icon(Icons.check, size: 20)
        else
          const SizedBox(width: 20),
        const SizedBox(width: spacing.sm),
        Text(label),
      ],
    );
  }
}
