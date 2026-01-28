/// Utility Singleton for building tooltips that optionally display keyboard shortcuts.
class ShortcutTooltipUtils {
  ShortcutTooltipUtils._internal();

  static final ShortcutTooltipUtils instance = ShortcutTooltipUtils._internal();

  /// Convenience alias
  static ShortcutTooltipUtils get I => instance;

  bool _showShortcuts = true;

  bool get showShortcutsInTooltips => _showShortcuts;

  void setShowShortcutsInTooltips(bool value) {
    _showShortcuts = value;
  }

  /// Build a tooltip by appending a keyboard shortcut in parentheses.
  /// If [showShortcut] is null, it falls back to the global singleton state.
  String build(String baseText, String? shortcut, {bool? showShortcut}) {
    final shouldShow = showShortcut ?? _showShortcuts;
    if (shouldShow && shortcut != null && shortcut.trim().isNotEmpty) {
      return '$baseText ($shortcut)';
    }
    return baseText;
  }

  /// Format multiple shortcuts as a single string, joined by " / ".
  String formatShortcuts(List<String> shortcuts) {
    return shortcuts.where((s) => s.trim().isNotEmpty).join(' / ');
  }
}
